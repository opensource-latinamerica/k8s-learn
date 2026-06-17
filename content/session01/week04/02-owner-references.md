# ownerReferences y ciclos de dependencia en Kubernetes

> **Versión de Kubernetes:** v1.29+
> **Fuentes:**
> [kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/](https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/),
> [kubernetes.io/docs/concepts/architecture/garbage-collection/](https://kubernetes.io/docs/concepts/architecture/garbage-collection/)

## Prerequisitos

- [El grafo de propietarios y el GarbageCollector](01-graph-builder.md)

## Anatomía de una ownerReference

Una `ownerReference` es un objeto embebido en `metadata.ownerReferences` que describe
exactamente un propietario:

```yaml
ownerReferences:
  - apiVersion: apps/v1 # grupo/versión del propietario
    kind: ReplicaSet # tipo del propietario
    name: nginx-deployment-75675f5897 # nombre del propietario en el mismo namespace
    uid: e129deca-f864-481b-bb16-b27abfd92292 # UID inmutable del propietario
    controller: true # ¿es este el controlador activo del objeto?
    blockOwnerDeletion: true # ¿debe este dependiente bloquear el borrado foreground del propietario?
```

### Por qué se usa el UID y no solo el nombre

El nombre de un objeto puede reutilizarse tras borrarlo y recrearlo.
El UID es único e irrepetible en todo el ciclo de vida del clúster.
Si un `ReplicaSet` es borrado y creado de nuevo con el mismo nombre,
tendrá un UID diferente.
Los `Pods` que apuntaban al UID antiguo quedan huérfanos
(su propietario no existe en el grafo) y el `GarbageCollector` los limpia.

> **Analogía — el número de pasaporte vs. el nombre:**
> Dos personas pueden llamarse "María García",
> pero cada una tiene un número de pasaporte único.
> Si buscas a alguien solo por nombre, puedes confundir a dos personas distintas.
> El UID del objeto Kubernetes es como el número de pasaporte:
> identifica sin ambigüedad al propietario exacto al que se hace referencia,
> aunque se cree otro objeto con el mismo nombre después.

## El campo controller

Solo puede haber un propietario marcado con `controller: true` por objeto.
Este es el controlador que gestiona activamente el objeto:
toma decisiones sobre él, lo actualiza y es responsable de su ciclo de vida.

Un objeto puede tener múltiples `ownerReferences` con `controller: false`,
lo que indica propiedad sin control activo.
Por ejemplo, un `Pod` puede ser propiedad (sin control) de un recurso de auditoría
mientras el `ReplicaSet` es su controlador activo.

```bash
# Ver si un Pod tiene múltiples ownerReferences
kubectl get pod mi-pod -o jsonpath='{.metadata.ownerReferences}'
```

## El campo blockOwnerDeletion

Controla si este dependiente puede bloquear el borrado de su propietario
durante el proceso de **borrado en primer plano** (_foreground cascading deletion_).

- `blockOwnerDeletion: true` → el borrado foreground del propietario espera hasta que este dependiente sea borrado.
- `blockOwnerDeletion: false` → el propietario puede borrarse aunque este dependiente siga existiendo.

Kubernetes establece automáticamente `blockOwnerDeletion: true`
cuando el controlador (como el `DeploymentController`) establece la `ownerReference`.
Puedes modificarlo manualmente,
pero el servidor de admisión requerirá que tengas permisos de borrado sobre el propietario.

## Propiedad automática vs. manual

La mayoría de `ownerReferences` las establece Kubernetes automáticamente:

| Objeto creado      | Propietario asignado automáticamente |
| ------------------ | ------------------------------------ |
| `ReplicaSet`       | `Deployment`                         |
| `Pod` (vía RS)     | `ReplicaSet`                         |
| `EndpointSlice`    | `Service`                            |
| `Job` (en CronJob) | `CronJob`                            |

También puedes establecerlas manualmente usando `controllerutil.SetControllerReference`
(de `controller-runtime`) o `metav1.SetControllerReference` (de `k8s.io/apimachinery`):

```go
// Establecer ownerReference en un Secret creado por un Operator
import (
    "sigs.k8s.io/controller-runtime/pkg/controller/controllerutil"
)

func (r *MyReconciler) ensureSecret(ctx context.Context, owner *myv1.MyResource) error {
    secret := &corev1.Secret{
        ObjectMeta: metav1.ObjectMeta{
            Name:      owner.Name + "-credentials",
            Namespace: owner.Namespace,
        },
    }
    // SetControllerReference establece ownerReference y controller=true automáticamente
    if err := controllerutil.SetControllerReference(owner, secret, r.Scheme); err != nil {
        return err
    }
    // ... crear o actualizar el Secret
    return nil
}
```

## Restricciones de namespace

Las `ownerReferences` no pueden cruzar namespaces.

```text
✓ Pod (namespace=production) → ReplicaSet (namespace=production)
✓ Pod (namespace=production) → ClusterRole (scope=cluster)
✗ Pod (namespace=production) → ReplicaSet (namespace=staging)  ← INVÁLIDO
✗ ClusterRole (scope=cluster) → Deployment (namespace=default)  ← INVÁLIDO
```

Desde v1.20+, el `GarbageCollector` detecta estas referencias inválidas
y emite un evento de advertencia.
El dependiente con una referencia inválida no puede ser recolectado por garbage collection.

```bash
# Auditar ownerReferences inválidas en el clúster
kubectl get events -A --field-selector=reason=OwnerRefInvalidNamespace \
  -o custom-columns='NAMESPACE:.metadata.namespace,OBJECT:.involvedObject.name,MESSAGE:.message'
```

## ownerReferences y finalizers: interacción

Los finalizers y las `ownerReferences` se complementan:

- Las `ownerReferences` definen **quién limpia a quién** (el GarbageCollector).
- Los finalizers definen **cuándo** se permite que ocurra esa limpieza.

Cuando un controlador custom crea recursos secundarios con `ownerReference`
y necesita realizar acciones de limpieza propias antes del borrado,
puede añadir un finalizer al objeto padre.
El GarbageCollector no borrará el padre hasta que el finalizer sea eliminado por el controlador.

```bash
# Ver finalizers y ownerReferences de todos los recursos de un namespace
kubectl get all -n mi-namespace \
  -o custom-columns='KIND:.kind,NAME:.metadata.name,FINALIZERS:.metadata.finalizers,OWNER:.metadata.ownerReferences[0].name'
```

## Glosario

| Término                  | Definición breve                                                                                                                  |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| `UID`                    | Identificador único e irrepetible asignado por Kubernetes a cada objeto; no cambia aunque el objeto se borre y recree con el mismo nombre. |
| `controller` (campo)     | Campo booleano en `ownerReference` que marca a este propietario como el que gestiona activamente el objeto; solo puede ser `true` en uno.  |
| `blockOwnerDeletion`     | Campo booleano que, si es `true`, impide que el propietario sea eliminado definitivamente en modo foreground hasta que este dependiente desaparezca. |
| `SetControllerReference` | Función de `controller-runtime` que establece una `ownerReference` con `controller: true` en el objeto dependiente.             |
| `SetOwnerReference`      | Función que establece una `ownerReference` sin `controller: true` para dependencias de ciclo de vida sin control activo.          |
| `AlreadyOwnedError`      | Error que retorna `SetControllerReference` cuando el objeto ya tiene un propietario con `controller: true`.                       |

## Siguiente paso

[Borrado en cascada: foreground, background y orphan](03-cascade-orphan.md) →
explica las tres políticas de propagación que controlan qué pasa con los dependientes
cuando se borra un propietario.

## Referencias

- [Owners and Dependents](https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/)
  — kubernetes.io
- [Garbage Collection](https://kubernetes.io/docs/concepts/architecture/garbage-collection/)
  — kubernetes.io

[← Atrás](01-graph-builder.md) | [Inicio semana](README.md) | [Siguiente →](03-cascade-orphan.md)
