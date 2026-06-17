# Internos del GarbageCollector: foreground vs. background

> **Versión de Kubernetes:** v1.29+
> **Fuentes:**
> [kubernetes.io/docs/concepts/architecture/garbage-collection/](https://kubernetes.io/docs/concepts/architecture/garbage-collection/),
> [kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/](https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/)

## Prerequisitos

- [Borrado en cascada: foreground, background y orphan](03-cascade-orphan.md)

## Revisión: el GarbageCollector como controlador

El `GarbageCollector` no es un proceso de limpieza que ejecuta en un horario fijo.
Es un **controlador** que reacciona a eventos en tiempo real.
Corre dentro del `kube-controller-manager` y procesa una workqueue
con los objetos candidatos a borrado.

> **Analogía — el gestor de residuos de un edificio de oficinas:**
> El gestor no pasa a horas fijas con un calendario.
> Tiene un intercomunicador conectado a cada oficina (los informers).
> Cuando una oficina se vacía (el propietario desaparece),
> el intercomunicador avisa al gestor,
> quien apunta la oficina en su lista de pendientes (la workqueue).
> Si la política es "foreground", el gestor espera a que todos los muebles sean retirados
> antes de liberar la llave de la oficina principal.
> Si es "background", la llave se libera de inmediato
> y los muebles se recogen cuando el gestor llega a esa entrada en su lista.

## El flujo interno del GraphBuilder

El `GraphBuilder` es el componente que mantiene el grafo de dependencias en memoria.
Recibe eventos de todos los recursos del clúster a través de informers dinámicos:

```text
API Server
    │
    ▼ (watch events: ADDED, MODIFIED, DELETED)
GraphBuilder informers (uno por GVR)
    │
    ├── Evento ADDED/MODIFIED → actualizar nodo y aristas en el grafo
    ├── Evento DELETED / DeletedFinalStateUnknown → marcar nodo como "a borrar"
    │     └── si el nodo borrado tiene dependientes → encolamos esos dependientes
    └── Evento de objeto con ownerRef a propietario ausente → encolar para evaluación
```

El `GraphBuilder` no borra objetos directamente.
Solo mantiene el grafo y encola candidatos.
El componente `GarbageCollector` es quien ejecuta el borrado.

## Procesamiento de la workqueue

El `GarbageCollector` saca elementos de la workqueue y evalúa cada uno:

```text
Para cada objeto candidato (uid):

1. ¿Tiene ownerReferences?
   - No → no es candidato a GC, descartar
   - Sí → continuar

2. ¿Todos los propietarios existen en el grafo?
   - Sí, todos existen → no es huérfano, descartar
   - Alguno no existe → continuar

3. ¿El propietario ausente realmente fue borrado?
   (consulta al API Server para confirmar)
   - No, es un error temporal → reintentar con backoff
   - Sí, fue borrado → proceder con la política de propagación

4. Aplicar la política:
   - Background → DELETE del objeto candidato
   - Orphan     → PATCH para eliminar la ownerReference del objeto candidato
```

### Ejemplo: qué pasa en background con un ReplicaSet borrado

```bash
# 1. Se borra el ReplicaSet "nginx-rs" (con --cascade=background)
# kubectl delete rs nginx-rs

# 2. El GraphBuilder recibe el evento DELETED del ReplicaSet
# → Marca el nodo ReplicaSet como borrado en el grafo
# → Los Pods que apuntan al ReplicaSet quedan con ownerRef inválida
# → Encola esos Pods en la workqueue del GarbageCollector

# 3. El GarbageCollector evalúa cada Pod:
# → Tiene ownerRef → el RS ya no existe → borra el Pod

# 4. Puedes observarlo en tiempo real:
kubectl get pods --watch
```

## Flujo detallado del foreground deletion

El foreground deletion es más complejo porque garantiza que los dependientes
con `blockOwnerDeletion: true` desaparezcan **antes** que el propietario.

```text
Usuario: kubectl delete deployment/nginx --cascade=foreground
    │
    ▼
API Server:
  1. Establece metadata.deletionTimestamp en el Deployment
  2. Añade finalizer "foregroundDeletion" al Deployment
  3. Retorna 200 OK (el Deployment sigue existiendo en la API)

    │
    ▼
GarbageCollector detecta el Deployment con finalizer "foregroundDeletion":
  4. Busca todos los dependientes del Deployment en el grafo
  5. Para cada dependiente con blockOwnerDeletion=true:
     → Borra el dependiente (que puede iniciar su propio foreground)
  6. Espera a que desaparezcan (los monitorea via informer)

    │ (una vez que todos los dependientes con blockOwnerDeletion=true desaparecen)
    ▼
  7. GarbageCollector elimina el finalizer "foregroundDeletion" del Deployment
  8. API Server puede ahora borrar definitivamente el Deployment de etcd
```

La garantía del foreground deletion es que **el propietario desaparece después que sus dependientes**.
Los dependientes con `blockOwnerDeletion: false` no bloquean este proceso.

## Verificar el estado durante un foreground deletion

```bash
# Iniciar el borrado foreground
kubectl delete deployment nginx-deployment --cascade=foreground

# En otra terminal, observar el estado del Deployment
kubectl get deployment nginx-deployment -w

# Verás algo así:
# NAME               READY   UP-TO-DATE   AVAILABLE   AGE
# nginx-deployment   3/3     3            3           10m
# nginx-deployment   3/3     3            3           10m     <- deletionTimestamp establecido
# nginx-deployment   0/3     0            0           10m     <- Pods en proceso de borrado
# (el Deployment desaparece cuando todos los Pods con blockOwnerDeletion=true se han ido)

# Ver el finalizer del Deployment durante el proceso
kubectl get deployment nginx-deployment -o jsonpath='{.metadata.finalizers}'
# ["foregroundDeletion"]
```

## GarbageCollector vs. otros mecanismos de limpieza

El `GarbageCollector` no es el único mecanismo de limpieza en Kubernetes:

| Mecanismo                    | Qué limpia                                             | Cómo funciona                               |
| ---------------------------- | ------------------------------------------------------ | ------------------------------------------- |
| `GarbageCollector`           | Objetos con ownerReference a propietario borrado       | Grafo de dependencias                       |
| Finalizers                   | Recursos externos antes de borrar el objeto Kubernetes | El controlador limpia y retira el finalizer |
| `TTLAfterFinished` (Jobs)    | Jobs completados después de un tiempo                  | Controlador TTL                             |
| Kubelet (contenedores)       | Contenedores e imágenes sin usar en el nodo            | Límites de disco (`HighThresholdPercent`)   |
| `NamespacedResourcesDeleter` | Todos los recursos de un namespace en `Terminating`    | Proceso de borrado de namespace (semana 2)  |

El `GarbageCollector` no gestiona la limpieza de recursos externos al clúster.
Para eso, necesitas finalizers con lógica custom en tu controlador.

## Ciclos de dependencia: por qué no pueden ocurrir

El grafo del `GarbageCollector` es un **DAG** (_Directed Acyclic Graph_).
Las `ownerReferences` siempre apuntan de un dependiente a su propietario,
y no al revés.
Kubernetes impide ciclos de varios modos:

- Los objetos de alcance de clúster no pueden apuntar a objetos con namespace como propietarios.
- El API server rechaza `ownerReferences` que crearían dependencias circulares directas.
- El `GraphBuilder` detecta y reporta referencias inválidas con el evento `OwnerRefInvalidNamespace`.

Si existiera un ciclo, el `GarbageCollector` nunca podría borrar ningún nodo del ciclo,
lo que resultaría en recursos que nunca se limpian.

## Resumen del ciclo de vida completo

```text
Crear Deployment
    └── DeploymentController crea ReplicaSet (ownerRef → Deployment)
            └── ReplicaSetController crea Pods (ownerRef → ReplicaSet)

Borrar Deployment (background, defecto)
    ├── API Server borra Deployment de etcd
    ├── GC detecta ReplicaSet huérfano → borra ReplicaSet
    └── GC detecta Pods huérfanos → borra Pods

Borrar Deployment (foreground)
    ├── API Server añade finalizer foregroundDeletion al Deployment
    ├── GC borra Pods (blockOwnerDeletion=true)
    ├── GC borra ReplicaSet (blockOwnerDeletion=true)
    ├── GC elimina finalizer del Deployment
    └── API Server borra Deployment de etcd
```

## Glosario

| Término                  | Definición breve                                                                                                                  |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| `GraphBuilder`           | Componente que mantiene el grafo de dependencias en memoria y encola objetos candidatos al `GarbageCollector`.                    |
| workqueue del GC         | Cola de trabajo del `GarbageCollector` que recibe candidatos a evaluación y aplica la política de borrado correspondiente.        |
| `DeletedFinalStateUnknown` | Evento que el informer entrega cuando no recibió el borrado en tiempo real; contiene el último estado conocido del objeto.      |
| borrado foreground       | Modalidad en que el propietario espera, visible en la API, a que todos sus dependientes con `blockOwnerDeletion=true` desaparezcan antes de borrarse. |
| borrado background       | Modalidad por defecto: el propietario se elimina de `etcd` de inmediato y los dependientes los recoge el GC en segundo plano.    |
| `GVR`                    | `GroupVersionResource`: identificador de un tipo de recurso en la API de Kubernetes; los informers dinámicos del `GraphBuilder` cubren todos los GVR del clúster. |

## Siguiente paso

[README de la semana 4](README.md) →
revisa el mapa conceptual de la semana para consolidar cómo los cuatro artículos se relacionan.

## Referencias

- [Garbage Collection](https://kubernetes.io/docs/concepts/architecture/garbage-collection/)
  — kubernetes.io
- [Owners and Dependents](https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/)
  — kubernetes.io
- [Use Cascading Deletion](https://kubernetes.io/docs/tasks/administer-cluster/use-cascading-deletion/)
  — kubernetes.io

[← Atrás](03-cascade-orphan.md) | [Inicio semana](README.md)
