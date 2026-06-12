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

[ ] Deployment a profundidad

- relación Deployment ↔ ReplicaSet
- rollouts y estrategias de actualización
- gestión del campo status
- rollback y revisiones

### Semana 4 — Garbage Collector

[ ] Reconciliación basada en grafo: Garbage Collector

- graph builder y modelo de grafo de propietarios
- lógica de borrado por huérfanos (_orphan_) vs. en cascada
- owner references y ciclos de dependencia
- eliminación en primer plano (_foreground_) vs. segundo plano (_background_)

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
