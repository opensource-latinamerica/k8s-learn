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

- teoría de reconciliación
- informers / caches / listers
- workqueues
- controller utilities

### Semana 2 — Controladores básicos

- Namespace
- TokenCleaner
- algún controlador pequeño adicional

### Semana 3 — Deployment a profundidad

- relación Deployment <-> ReplicaSet
- rollouts
- status
- rollback

### Semana 4 — Garbage Collector

- graph builder
- delete/orphan logic
- owner references
- foreground/background deletion

### Semana 5 — Kubelet

- syncLoop
- HandlePod*
- podWorkers
- SyncPod
- terminating flow

### Semana 6 — Subsistemas especializados

- volume manager reconciler
- attach/detach reconciler
- comparación transversal

### Semana 7 — Integración

- trazado end-to-end
- ejercicios
- mapas mentales
- resumen técnico final

