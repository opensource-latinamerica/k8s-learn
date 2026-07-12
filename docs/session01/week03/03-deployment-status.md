---
layout: default
title: 03 — Deployment Status
nav_order: 3
parent: Week 3 — Deployment
---

> **Versión de Kubernetes:** v1.29+
> **Fuentes:**
> [kubernetes.io/docs/concepts/workloads/controllers/deployment/](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

## Prerequisitos

- [Rollouts y estrategias de actualización](02-rollout-strategies.md)

## Por qué importa el campo status

El campo `.status` de un `Deployment` es la forma en que el `DeploymentController` comunica
qué está pasando en este momento.
No es solo información de lectura:
herramientas de CI/CD, controladores de nivel superior y el propio operador humano
dependen de él para decidir si continuar, esperar o intervenir.

> **Analogía — el panel de control de un vuelo:**
> Así como los pilotos no necesitan asomarse por la ventana para saber si el avión está subiendo,
> el `.status` del `Deployment` te da todos los indicadores sin tener que inspeccionar cada `Pod`.
> Cuando la altimetría (`availableReplicas`) coincide con el plan de vuelo (`replicas`),
> el sistema está en crucero estable.
> Cuando una condición cambia a `False`,
> es la luz de emergencia que indica que algo requiere atención.

## Los campos de status más importantes

```yaml
# kubectl get deployment nginx-deployment -o yaml
status:
  replicas: 3 # Pods totales existentes (running + terminating)
  updatedReplicas: 3 # Pods que ya usan la versión más reciente del template
  readyReplicas: 3 # Pods que han pasado sus readinessProbes
  availableReplicas: 3 # Pods listos durante al menos minReadySeconds
  unavailableReplicas: 0 # Pods que deberían estar disponibles pero no lo están
  observedGeneration: 2 # Última generación del spec que el controller procesó
  conditions:
    - type: Available
      status: "True"
      reason: MinimumReplicasAvailable
    - type: Progressing
      status: "True"
      reason: NewReplicaSetAvailable
```

### Diferencia entre readyReplicas y availableReplicas

Un `Pod` está `ready` en cuanto sus `readinessProbes` pasan.
Un `Pod` está `available` cuando además lleva **al menos** `.spec.minReadySeconds` en ese estado.
Si `minReadySeconds=0` (valor por defecto), ambas cifras son iguales.

```yaml
spec:
  minReadySeconds: 30 # el Pod debe estar listo 30s antes de contar como "available"
```

Esto permite desacelerar un rollout en aplicaciones que tardan en calentarse:
el controlador no avanza al siguiente `Pod` hasta que el nuevo esté verdaderamente estable.

## Las tres condiciones del Deployment

### Progressing

Indica que el `Deployment` está en medio de un rollout o que acaba de completarlo.

| reason                     | status | Significado                                                       |
| -------------------------- | ------ | ----------------------------------------------------------------- |
| `NewReplicaSetCreated`     | True   | Se creó un nuevo ReplicaSet; el rollout empezó                    |
| `FoundNewReplicaSet`       | True   | Se encontró un RS existente compatible                            |
| `ReplicaSetUpdated`        | True   | El RS actual está siendo escalado                                 |
| `NewReplicaSetAvailable`   | True   | Rollout completado; todos los Pods del nuevo RS están disponibles |
| `ProgressDeadlineExceeded` | False  | El rollout no avanzó dentro de `.spec.progressDeadlineSeconds`    |

> **Nota:** Cuando `type: Progressing` tiene `reason: NewReplicaSetAvailable`,
> el rollout está **completo**, no en progreso.
> El nombre de la condición es confuso: significa "la progresión terminó bien".

### Available

Indica que el `Deployment` tiene al menos el mínimo de réplicas disponibles.

| reason                       | status | Significado                                      |
| ---------------------------- | ------ | ------------------------------------------------ |
| `MinimumReplicasAvailable`   | True   | `availableReplicas >= replicas - maxUnavailable` |
| `MinimumReplicasUnavailable` | False  | No hay suficientes réplicas disponibles          |

### ReplicaFailure

Aparece cuando el `ReplicaSet` no puede crear o mantener `Pods`.
Causas comunes: cuota de namespace agotada, imágenes inaccesibles, permisos insuficientes.

```bash
# Ver condiciones en formato tabular
kubectl get deployment nginx-deployment \
  -o jsonpath='{range .status.conditions[*]}{.type}{"\t"}{.status}{"\t"}{.reason}{"\n"}{end}'

# Salida durante un rollout saludable
# Available       True    MinimumReplicasAvailable
# Progressing     True    NewReplicaSetAvailable
```

## El progressDeadlineSeconds

`.spec.progressDeadlineSeconds` (por defecto: 600 segundos)
define cuánto tiempo puede pasar sin avance antes de que el controlador marque el rollout como fallido.

```bash
# Acortar el deadline para detectar problemas más rápido (útil en CI)
kubectl patch deployment nginx-deployment \
  -p '{"spec":{"progressDeadlineSeconds":120}}'

# Simular un rollout atascado con una imagen incorrecta
kubectl set image deployment/nginx-deployment nginx=nginx:nonexistent

# Esperar a que el deadline expire y comprobar la condición
kubectl rollout status deployment/nginx-deployment
# error: deployment "nginx-deployment" exceeded its progress deadline
echo $?
# 1  ← el exit code no-cero permite que los pipelines de CI detecten el fallo
```

## Monitorear los Pods en terminación (v1.35+)

A partir de Kubernetes v1.35 (beta activado por defecto),
el campo `.status.terminatingReplicas` muestra cuántos `Pods` están en estado `Terminating`.
Esto es útil cuando los `Pods` tienen `terminationGracePeriodSeconds` largos
y el recuento total supera temporalmente `.spec.replicas`.

```bash
kubectl get deployment nginx-deployment \
  -o jsonpath='{.status.terminatingReplicas}'
```

## Leer el status en la práctica

```bash
# Esperar a que el Deployment esté disponible (útil en scripts de despliegue)
kubectl rollout status deployment/nginx-deployment --timeout=5m

# Comprobar si el rollout completó exitosamente (exit code 0 = éxito)
kubectl rollout status deployment/nginx-deployment && echo "Rollout completado"

# Ver el status completo en YAML
kubectl get deployment nginx-deployment -o yaml | grep -A 30 "^status:"
```

## Preguntas de repaso

Antes de continuar con la siguiente sesión,
intenta responder las siguientes preguntas:

1. ¿Qué información aporta cada campo entre `replicas`, `updatedReplicas`, `readyReplicas` y `availableReplicas`?
2. ¿Qué te indica la condición `Progressing` sobre el rollout?
3. ¿Cómo ayuda `progressDeadlineSeconds` a detectar un despliegue atascado?
4. ¿Por qué `availableReplicas` y `readyReplicas` no siempre tienen el mismo valor?

Si no puedes responder alguna pregunta con confianza,
revisa nuevamente el contenido de la sesión antes de avanzar.

## Glosario

| Término                      | Definición breve                                                                                                         |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `observedGeneration`         | Última generación del `.spec` procesada por el controlador; confirma que los últimos cambios declarados ya se aplicaron. |
| `updatedReplicas`            | Número de `Pods` que ya usan la versión más reciente del `PodTemplate`.                                                  |
| `readyReplicas`              | Número de `Pods` que han superado sus `readinessProbes`.                                                                 |
| `availableReplicas`          | Número de `Pods` listos que llevan al menos `minReadySeconds` en ese estado.                                             |
| `unavailableReplicas`        | Número de `Pods` que deberían estar disponibles pero no lo están.                                                        |
| `minReadySeconds`            | Tiempo mínimo (segundos) que un `Pod` debe estar listo antes de contabilizarse como `available` (defecto: 0).            |
| `Progressing` (condición)    | Condición que indica si el rollout está en marcha, si ha completado correctamente o si ha excedido el deadline.          |
| `Available` (condición)      | Condición que indica si el `Deployment` tiene al menos el mínimo de réplicas disponibles.                                |
| `ReplicaFailure` (condición) | Condición que indica que el `ReplicaSet` no puede crear o mantener `Pods` (cuota agotada, imagen inaccesible, etc.).     |
| `progressDeadlineSeconds`    | Timeout en segundos tras el que el controlador marca el rollout como fallido si no hay avance (defecto: 600).            |
| `terminatingReplicas`        | Campo (v1.35+ beta) que muestra el número de `Pods` actualmente en fase `Terminating`.                                   |

## Siguiente paso

[Rollback y revisiones de un Deployment](04-rollback-revisions.md) →
explica cómo usar el historial de revisiones para deshacer un rollout problemático.

## Referencias

- [Deployments — Deployment status](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#deployment-status)
  — kubernetes.io

[← Atrás](02-rollout-strategies.md) | [Inicio semana](README.md) | [Siguiente →](04-rollback-revisions.md)
