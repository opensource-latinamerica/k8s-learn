---
layout: default
type: Explicación
description: Compara las políticas de borrado Background, Foreground y Orphan.
tags: [kubernetes, session01, module04, garbage-collector, borrado, finalizers]
status: stable
title: 03 — Borrado en cascada
nav_order: 3
parent: Módulo 4 — Garbage Collector
---

> **Versión de Kubernetes:** v1.29+
> **Fuentes:**
> [kubernetes.io/docs/concepts/architecture/garbage-collection/](https://kubernetes.io/docs/concepts/architecture/garbage-collection/),
> [kubernetes.io/docs/tasks/administer-cluster/use-cascading-deletion/](https://kubernetes.io/docs/tasks/administer-cluster/use-cascading-deletion/)

## Prerequisitos

- [ownerReferences y ciclos de dependencia](02-owner-references.md)

## Las tres políticas de propagación

Cuando borras un objeto con dependientes,
Kubernetes te permite elegir qué ocurre con esos dependientes.
Hay tres políticas de propagación (_propagationPolicy_):

| Política     | Comportamiento                                                            | Parámetro `kubectl`              |
| ------------ | ------------------------------------------------------------------------- | -------------------------------- |
| `Background` | Borra el propietario de inmediato; GC limpia dependientes después         | `--cascade=background` (defecto) |
| `Foreground` | Espera a que todos los dependientes se borren; luego borra el propietario | `--cascade=foreground`           |
| `Orphan`     | Borra el propietario; los dependientes quedan huérfanos (no se borran)    | `--cascade=orphan`               |

## Background cascading deletion

Es el comportamiento por defecto.
El API server marca el propietario como borrado (`deletionTimestamp`)
y lo elimina de `etcd` inmediatamente.
El `GarbageCollector` detecta que los dependientes tienen una `ownerReference`
a un propietario que ya no existe y los borra en el fondo.

> **Analogía — clausurar un negocio y limpiar después:**
> La autoridad registra la clausura y el negocio desaparece del padrón al instante.
> La cuadrilla de limpieza (el GarbageCollector) llega después
> para retirar lo que quedó dentro (los Pods, ReplicaSets, etc.).
> Durante un momento, el sistema de monitoreo puede ver esos recursos
> aunque el propietario ya no figure en los registros.

```bash
# Borrado en background (comportamiento por defecto)
kubectl delete deployment nginx-deployment
# equivale a:
kubectl delete deployment nginx-deployment --cascade=background

# Los Pods desaparecen en segundos, después de que el GC los detecte como huérfanos
kubectl get pods -l app=nginx --watch
```

## Foreground cascading deletion

El propietario entra en un estado de "borrado en progreso" antes de desaparecer.
En este estado:

1. El API server establece `metadata.deletionTimestamp`.
2. El API server añade el finalizer `foregroundDeletion` a `metadata.finalizers`.
3. El objeto **sigue visible** en la API durante todo el proceso.

El `GarbageCollector` entonces borra los dependientes que tienen `blockOwnerDeletion: true`.
Solo cuando todos esos dependientes han desaparecido,
el `GarbageCollector` elimina el finalizer `foregroundDeletion` del propietario,
lo que permite que el API server lo borre definitivamente.

> **Analogía — desalojar un local antes de entregarlo:**
> En una entrega controlada, la persona responsable primero confirma
> que todo el equipo (Pods con `blockOwnerDeletion=true`) salió del local.
> Solo cuando no queda nada pendiente, entrega el espacio principal.
> El local aparece en los registros como "en proceso de entrega"
> hasta que la operación termina por completo.

```bash
# Iniciar borrado foreground
kubectl delete deployment nginx-deployment --cascade=foreground

# Durante el proceso, el Deployment aparece en la API con el finalizer
kubectl get deployment nginx-deployment -o jsonpath='{.metadata.finalizers}'
# ["foregroundDeletion"]

# Los Pods se borran antes que el Deployment
# Una vez que los Pods han desaparecido, el Deployment también desaparece
kubectl get pods -l app=nginx --watch
```

## Orphan deletion

Borra el propietario pero deja los dependientes vivos.
Kubernetes añade el finalizer `orphan` al propietario,
lo que indica al `GarbageCollector` que debe **eliminar** las `ownerReferences`
de los dependientes en lugar de borrarlos.

```bash
# Borrar el Deployment dejando los Pods y ReplicaSets vivos
kubectl delete deployment nginx-deployment --cascade=orphan

# Los Pods continúan corriendo sin controlador que los gestione
kubectl get pods -l app=nginx
# Los Pods están Running pero ya no tienen ownerReference activa
```

### Casos de uso de orphan deletion

- Transferir la gestión de los `Pods` a otro controlador.
- Inspeccionar los `Pods` antes de eliminarlos manualmente.
- Borrar solo el `Deployment` para evitar que cree nuevos `Pods`,
  manteniendo los existentes mientras termina su trabajo.

## Comparación del comportamiento observable

```text
# Escenario: Deployment con 3 Pods; ejecutamos la eliminación
# en t=0

Política      t=0            t=1s              t=5s
-----------   ----------     ---------------   ---------
Background    Deployment ✗   Pods aún visibles  Pods ✗
              (borrado ya)   (GC en progreso)   (GC terminó)

Foreground    Deployment ✓*  Pods ✗            Deployment ✗
              (*visible pero (borrados antes    (finalizer
              en deleting)   que el Deployment) eliminado)

Orphan        Deployment ✗   Pods ✓            Pods ✓
              (borrado ya)   (sin ownerRef)     (sin controlador)
```

## Qué política usar en cada contexto

| Situación                                                                              | Política recomendada   |
| -------------------------------------------------------------------------------------- | ---------------------- |
| Despliegue normal en producción                                                        | `Background` (defecto) |
| Necesitas garantizar que los Pods terminaron gracefully antes de retirar el Deployment | `Foreground`           |
| Estás haciendo una migración de controlador                                            | `Orphan`               |
| Borrando un namespace completo con muchos recursos                                     | `Background`           |
| Herramienta de CI/CD que necesita esperar al borrado completo                          | `Foreground`           |

## Usando la API REST directamente

Las políticas también se pueden especificar vía API REST:

```bash
kubectl proxy --port=8080 &

# Foreground
curl -X DELETE localhost:8080/apis/apps/v1/namespaces/default/deployments/nginx-deployment \
  -H "Content-Type: application/json" \
  -d '{"kind":"DeleteOptions","apiVersion":"v1","propagationPolicy":"Foreground"}'

# Background
curl -X DELETE localhost:8080/apis/apps/v1/namespaces/default/deployments/nginx-deployment \
  -H "Content-Type: application/json" \
  -d '{"kind":"DeleteOptions","apiVersion":"v1","propagationPolicy":"Background"}'

# Orphan
curl -X DELETE localhost:8080/apis/apps/v1/namespaces/default/deployments/nginx-deployment \
  -H "Content-Type: application/json" \
  -d '{"kind":"DeleteOptions","apiVersion":"v1","propagationPolicy":"Orphan"}'
```

## Preguntas de repaso

Antes de continuar con la siguiente sesión,
intenta responder las siguientes preguntas:

1. ¿Qué ocurre con los dependientes cuando borras un objeto con `Background`?
2. ¿Por qué `Foreground` espera antes de borrar definitivamente al propietario?
3. ¿Qué significa que `Orphan` deje vivos a los dependientes?
4. ¿En qué caso te conviene preservar los `Pods` aunque borres el `Deployment`?

Si no puedes responder alguna pregunta con confianza,
revisa nuevamente el contenido de la sesión antes de avanzar.

## Lo que aprendí hoy

Hoy entendí las políticas de borrado como tres formas de cerrar un negocio.
Con `Background`, cierro la puerta principal y la limpieza continúa detrás.
Con `Foreground`, espero en el lugar hasta que desaparezcan los dependientes
que bloquean el borrado.
Con `Orphan`, cierro el negocio pero dejo los recursos hijos funcionando y
sin la etiqueta que los ataba al dueño.
La política correcta depende de si priorizo rapidez, limpieza completa o
conservar temporalmente los dependientes.

Las tres políticas toman decisiones distintas sobre las relaciones de
propiedad que acabas de estudiar en [la lección anterior](02-owner-references.md).
El comportamiento depende de si quieres borrar los dependientes,
conservarlos o esperar a que terminen de desaparecer.

## Glosario

| Término                          | Definición breve                                                                                                                 |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `propagationPolicy`              | Parámetro que controla qué ocurre con los dependientes al borrar un propietario: `Background`, `Foreground` u `Orphan`.          |
| `Background`                     | Política por defecto: el propietario se elimina de inmediato y el GC borra los dependientes en segundo plano.                    |
| `Foreground`                     | Política que mantiene visible el propietario hasta que todos sus dependientes con `blockOwnerDeletion=true` hayan sido borrados. |
| `Orphan`                         | Política que borra el propietario pero deja los dependientes vivos, eliminándoles las `ownerReferences`.                         |
| `foregroundDeletion` (finalizer) | Finalizer de sistema que el API server añade al propietario para mantenerlo visible durante el borrado foreground.               |
| `orphan` (finalizer)             | Finalizer de sistema que indica al GC que debe eliminar las `ownerReferences` de los dependientes en lugar de borrarlos.         |

## Siguiente paso

[Eliminación en primer plano vs. segundo plano: internos del GarbageCollector](04-foreground-background-internals.md) →
explica cómo el `GarbageCollector` procesa cada política internamente
y cómo interactúa con los finalizers del sistema.

## Referencias

- [Cascading deletion](https://kubernetes.io/docs/concepts/architecture/garbage-collection/#cascading-deletion)
  — kubernetes.io
- [Use Cascading Deletion in a Cluster](https://kubernetes.io/docs/tasks/administer-cluster/use-cascading-deletion/)
  — kubernetes.io

[← Atrás](02-owner-references.md) | [Inicio módulo](README.md) | [Siguiente →](04-foreground-background-internals.md)
