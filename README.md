# k8s-learn

## Propósito del repositorio

Este repositorio es un espacio de estudio colaborativo
cuyo objetivo final es preparar a sus participantes para **contribuir al código fuente de Kubernetes**.
No se trata solo de usar Kubernetes:
se trata de leer, entender y eventualmente mejorar el código que lo hace funcionar.

El material está organizado en español y cubre los mecanismos internos del proyecto —
controladores, informers, workqueues, patrones de reconciliación —
partiendo siempre del código real en [`kubernetes/kubernetes`](https://github.com/kubernetes/kubernetes).

## A quién está dirigido

- Personas que ya usan Kubernetes y quieren entender cómo funciona por dentro.
- Equipos o grupos de estudio que quieran colaborar en español.
- Profesionales que busquen hacer su primera contribución al proyecto Kubernetes.

## Ruta de aprendizaje

El contenido sigue una progresión desde los fundamentos hasta los componentes avanzados:

```
Descubrir  → ¿Qué es la reconciliación?      → Teoría del bucle de control
Construir  → ¿Cómo funciona por dentro?       → Informers, workqueues, utilidades
Analizar   → ¿Cómo lo aplica Kubernetes?      → Controladores reales del código fuente
Contribuir → ¿Cómo mejoro el proyecto?        → Lectura de código, propuestas, PRs
```

## Contenido disponible

### [Sesión 1 — Reconciliación en Kubernetes a profundidad](content/session01/README.md)

**Semana 1 — Fundamentos**

| Documento | Tema |
| --------- | ---- |
| [01 — La reconciliación: fundamentos](content/session01/week01/01-reconciliation-theory.md) | Bucle de control, estado deseado vs. actual, patrón Operator |
| [02 — Informers, cachés y listers](content/session01/week01/02-informers-listers.md) | `SharedIndexInformer`, `Reflector`, `DeltaFIFO`, `Indexer`, `Lister` |
| [03 — Workqueues](content/session01/week01/03-workqueues.md) | `TypedInterface`, rate limiters, patrón `Forget` |
| [04 — Utilidades de controladores](content/session01/week01/04-controller-utilities.md) | `SetControllerReference`, finalizers, `CreateOrUpdate` |

**Semana 2 — Controladores básicos**

| Documento | Tema |
| --------- | ---- |
| [01 — El controlador de Namespace](content/session01/week02/01-namespace-controller.md) | Ciclo de vida `Active / Terminating`, borrado en cascada |
| [02 — El limpiador de tokens heredados](content/session01/week02/02-token-cleaner.md) | Tokens de `ServiceAccount` obsoletos, borrado en dos etapas |
| [03 — El controlador de ServiceAccounts](content/session01/week02/03-serviceaccounts-controller.md) | Patrón get-or-create idempotente, manejo de tombstones |

## Contexto de creación

El proyecto nació para dar continuidad a un grupo de estudio
que se reúne periódicamente para leer el código fuente de Kubernetes en profundidad.
Cada sesión genera notas, diagramas y documentos que se incorporan aquí
para que cualquier persona pueda seguir la misma ruta de aprendizaje.

La [minuta de la sesión inaugural (2026-05-22)](content/session01/2026-05-22-arranque-grupo-estudio-kubernetes.md)
describe el origen del grupo y sus acuerdos de trabajo.