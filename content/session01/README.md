# Currícula de estudio: reconciliación en Kubernetes a profundidad

## Mapa general de estudio

La ruta recomendada es:

- Fundamentos del patrón de reconciliación
- Primitivas compartidas: informers, listers, workqueues, expectations
- Controlador simple: Namespace
- Controlador canónico: ReplicaSet
- Controlador compuesto: Deployment
- Controlador avanzado: Job
- Reconciliación basada en grafo: Garbage Collector
- Reconciliación del nodo: Kubelet
- Subsistemas con bucles de reconciliación especializados
- Integración completa y ejercicios de trazado

## Plan de estudio

### Semana 1 — Fundamentos

[x] [La reconciliación en Kubernetes: fundamentos](week01/01-reconciliation-theory.md)

- bucle de control, estado deseado vs. actual, controladores integrados,
  ciclo de reconciliación, convergencia eventual, patrón Operator
- introducción a _informers_ y caché local (concepto)

[x] [Informers, cachés y listers en Kubernetes](week01/02-informers-listers.md)

- `SharedIndexInformer`, `Reflector`, `DeltaFIFO`, `Indexer`, `Lister`,
  `SharedInformerFactory`, `WaitForCacheSync`

[x] [Workqueues en Kubernetes](week01/03-workqueues.md)

- `TypedInterface`, `TypedDelayingInterface`, `TypedRateLimitingInterface`,
  rate limiters, `DefaultTypedControllerRateLimiter`, patrón `Forget`

[x] [Utilidades de controladores en Kubernetes](week01/04-controller-utilities.md)

- `SetControllerReference`, `SetOwnerReference`, finalizers,
  `CreateOrUpdate`, `CreateOrPatch`

### Semana 2 — Controladores básicos

[x] [El controlador de Namespace en Kubernetes](week02/01-namespace-controller.md)

- `syncNamespace` y ciclo de vida (Active / Terminating)
- `NamespacedResourcesDeleter` y los cinco pasos del borrado
- `namespaceDeletionGracePeriod`, `ResourcesRemainingError`, finalizers

[x] [El limpiador de tokens heredados de ServiceAccount](week02/02-token-cleaner.md)

- detección de tokens de `ServiceAccount` obsoletos con cinco condiciones
- borrado en dos etapas: invalidar → borrar
- patrón de bucle periódico con `wait.UntilWithContext`

[x] [El controlador de ServiceAccounts en Kubernetes](week02/03-serviceaccounts-controller.md)

- garantizar la `ServiceAccount` `default` en todos los `Namespaces` activos
- patrón get-or-create idempotente
- manejo de tombstones en borrados

### Semana 3 — Deployment a profundidad

[x] [La relación Deployment ↔ ReplicaSet](week03/01-deployment-replicaset.md)

- jerarquía Deployment → ReplicaSet → Pod
- `ownerReference`, `pod-template-hash` y adopción de `Pods`
- cuándo se crea un nuevo `ReplicaSet`

[x] [Rollouts y estrategias de actualización](week03/02-rollout-strategies.md)

- estrategias `Recreate` y `RollingUpdate`
- `maxUnavailable`, `maxSurge`, rollover
- pausa y reanudación de rollouts

[x] [Gestión del campo status en un Deployment](week03/03-deployment-status.md)

- campos `updatedReplicas`, `readyReplicas`, `availableReplicas`
- condiciones `Progressing`, `Available`, `ReplicaFailure`
- `progressDeadlineSeconds` y detección de rollouts atascados

[x] [Rollback y revisiones de un Deployment](week03/04-rollback-revisions.md)

- historial de revisiones basado en `ReplicaSets`
- `rollout undo` y `--to-revision`
- `revisionHistoryLimit` y sus implicaciones

### Semana 4 — Garbage Collector

[x] [El grafo de propietarios y el GarbageCollector](week04/01-graph-builder.md)

- arquitectura `GraphBuilder` + procesador de workqueue
- grafo de dependencias (DAG) y tombstones
- cómo se detectan los objetos huérfanos

[x] [ownerReferences y ciclos de dependencia](week04/02-owner-references.md)

- campos `uid`, `controller`, `blockOwnerDeletion`
- restricciones de namespace en ownerReferences
- `SetControllerReference` y propiedad manual

[x] [Borrado en cascada: foreground, background y orphan](week04/03-cascade-orphan.md)

- políticas `Background`, `Foreground` y `Orphan`
- finalizers de sistema `foregroundDeletion` y `orphan`
- guía de cuándo usar cada política

[x] [Internos del GarbageCollector: foreground vs. background](week04/04-foreground-background-internals.md)

- algoritmo de evaluación de la workqueue del GC
- flujo paso a paso del foreground deletion
- GarbageCollector vs. finalizers, TTLAfterFinished y kubelet

### Semana 5 — Kubelet

[ ] Reconciliación del nodo: Kubelet

- `syncLoop` y fuentes de eventos
- `HandlePod*` — creación, actualización y terminación
- `podWorkers` y paralelismo de reconciliación
- `SyncPod` — flujo principal de sincronización
- flujo de terminación de Pods

### Semana 6 — Subsistemas especializados

[ ] Subsistemas con bucles de reconciliación especializados

- volume manager reconciler
- attach/detach reconciler
- comparación transversal de patrones

### Semana 7 — Integración

[ ] Integración completa y ejercicios de trazado

- trazado end-to-end de un cambio de spec
- ejercicios de depuración y análisis
- mapas mentales de dependencias entre controladores
- resumen técnico final
