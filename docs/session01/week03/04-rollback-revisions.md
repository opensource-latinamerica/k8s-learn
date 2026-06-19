---
layout: default
title: 04 — Rollback & Revisions
nav_order: 4
parent: Week 3 — Deployment
---

> **Versión de Kubernetes:** v1.29+
> **Fuentes:**
> [kubernetes.io/docs/concepts/workloads/controllers/deployment/](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

## Prerequisitos

- [Gestión del campo status en un Deployment](03-deployment-status.md)

## Cómo funciona el historial de revisiones

Cada vez que el campo `.spec.template` cambia,
el `DeploymentController` crea un nuevo `ReplicaSet` y asigna una nueva **revisión**.
Los `ReplicaSets` previos se conservan con cero réplicas:
son el historial de revisiones que permite el rollback.

> **Analogía — el historial de versiones de un documento:**
> Cada vez que guardas una nueva versión de un contrato,
> las versiones anteriores se archivan automáticamente.
> Si el cliente rechaza la última versión firmada,
> puedes recuperar la versión anterior en segundos
> sin tener que reconstruirla desde cero.
> El historial de revisiones de un `Deployment` funciona igual:
> cada `ReplicaSet` antiguo es una "versión archivada" lista para restaurar.

La relación entre revisiones y `ReplicaSets`:

```bash
# Ver el historial de revisiones
kubectl rollout history deployment/nginx-deployment

# Salida
# REVISION    CHANGE-CAUSE
# 1           <none>
# 2           <none>
# 3           <none>
```

El campo `CHANGE-CAUSE` se lee de la anotación `kubernetes.io/change-cause`.
Puedes rellenarla para dejar trazabilidad:

```bash
kubectl annotate deployment/nginx-deployment \
  kubernetes.io/change-cause="Actualizar nginx a 1.16.1 — JIRA-1234"
```

## Inspeccionar una revisión concreta

```bash
# Ver el PodTemplate de la revisión 2
kubectl rollout history deployment/nginx-deployment --revision=2

# Salida
# deployments "nginx-deployment" revision 2
#   Labels:  app=nginx
#            pod-template-hash=1159050644
#   Containers:
#    nginx:
#     Image: nginx:1.16.1
#     Port:  80/TCP
```

Internamente, cada revisión se corresponde con un `ReplicaSet` específico.
Puedes ver qué `ReplicaSet` corresponde a cada revisión:

```bash
kubectl get rs -l app=nginx \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.deployment\.kubernetes\.io/revision}{"\n"}{end}'

# Salida
# nginx-deployment-75675f5897   1
# nginx-deployment-1564180365   2
# nginx-deployment-3066724191   3
```

## Ejecutar un rollback

### Rollback a la revisión anterior

```bash
# Volver a la revisión inmediatamente anterior
kubectl rollout undo deployment/nginx-deployment

# Salida
# deployment.apps/nginx-deployment rolled back
```

El rollback **no revierte** el número de revisión:
en cambio, crea una **nueva revisión** con el `PodTemplate` de la versión anterior.
Si estabas en la revisión 3, después del rollback estarás en la revisión 4
(que tiene el mismo template que la revisión 2).

```bash
kubectl rollout history deployment/nginx-deployment

# REVISION    CHANGE-CAUSE
# 1           <none>
# 3           <none>
# 4           <none>     ← nueva revisión con el template de la revisión 2
```

### Rollback a una revisión específica

```bash
# Volver exactamente a la revisión 1
kubectl rollout undo deployment/nginx-deployment --to-revision=1

# Comprobar que el rollback fue exitoso
kubectl rollout status deployment/nginx-deployment
kubectl get deployment nginx-deployment
```

## El revisionHistoryLimit

`.spec.revisionHistoryLimit` (por defecto: 10) controla cuántos `ReplicaSets`
históricos (con cero réplicas) se conservan.

```yaml
spec:
  revisionHistoryLimit: 5 # conserva solo las últimas 5 revisiones
```

> **Advertencia:** Si estableces `revisionHistoryLimit: 0`,
> Kubernetes borra todos los `ReplicaSets` históricos inmediatamente después de cada rollout.
> Perderás la capacidad de hacer rollback completamente.
> Incluso con límite 0, el nuevo rollout crea un `ReplicaSet` antes de borrar el anterior,
> pero no habrá historial disponible después.

## Cuándo un rollback no es suficiente

El rollback restaura el `PodTemplate`, pero **no restaura**:

- El número de réplicas (`.spec.replicas`) si fue modificado independientemente.
- Las configuraciones externas al clúster (bases de datos, secrets de terceros).
- El estado de los datos persistentes en `PersistentVolumes`.

Para despliegues con cambios de esquema de base de datos,
considera estrategias adicionales como migraciones forward-only o uso de `StatefulSets`.

## Ciclo completo: despliegue → fallo → diagnóstico → rollback

```bash
# 1. Desplegar una versión con error (imagen inexistente)
kubectl set image deployment/nginx-deployment nginx=nginx:1.999

# 2. Detectar que el rollout está atascado
kubectl rollout status deployment/nginx-deployment
# Waiting for rollout to finish: 1 out of 3 new replicas have been updated...

# 3. Ver la causa del problema
kubectl get pods -l app=nginx
# nginx-deployment-XXXXXXX-YYYY   0/1   ImagePullBackOff   0   30s

# 4. Confirmar la condición de fallo
kubectl get deployment nginx-deployment \
  -o jsonpath='{.status.conditions[?(@.type=="Progressing")].reason}'
# ProgressDeadlineExceeded   (después del timeout)

# 5. Ejecutar el rollback
kubectl rollout undo deployment/nginx-deployment

# 6. Verificar que la aplicación está recuperada
kubectl rollout status deployment/nginx-deployment
# deployment "nginx-deployment" successfully rolled out
```

## Glosario

| Término                   | Definición breve                                                                                                              |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| revisión                  | Número secuencial que el `DeploymentController` asigna a cada cambio en `.spec.template`; se corresponde con un `ReplicaSet`. |
| `CHANGE-CAUSE`            | Anotación `kubernetes.io/change-cause` que documenta el motivo de cada revisión y se muestra en `kubectl rollout history`.    |
| `revisionHistoryLimit`    | Número máximo de revisiones históricas conservadas para permitir rollback; si es 0, el rollback queda deshabilitado.          |
| rollback                  | Operación que restaura el `PodTemplate` de una revisión anterior creando una nueva revisión con ese contenido.                |
| `kubectl rollout undo`    | Comando que ejecuta un rollback a la revisión inmediatamente anterior o a una revisión específica (`--to-revision`).          |
| `kubectl rollout history` | Comando que lista el historial de revisiones de un `Deployment` con su `CHANGE-CAUSE`.                                        |

## Siguiente paso

[README de la semana 3](README.md) →
revisa el mapa conceptual de la semana para consolidar cómo se relacionan todos los temas.

## Referencias

- [Rolling Back a Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-back-a-deployment)
  — kubernetes.io
- [Clean up Policy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy)
  — kubernetes.io

[← Atrás](03-deployment-status.md) | [Inicio semana](README.md) | [Siguiente →](../week04/README.md)
