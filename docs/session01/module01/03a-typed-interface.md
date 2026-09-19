---
layout: default
type: Explicación
description: Describe el contrato y el estado interno de una workqueue tipada.
tags:
  [kubernetes, session01, module01, workqueues, typed-interface, concurrencia]
status: stable
title: 03a — TypedInterface
nav_order: 1
parent: 03 — Workqueues
---

# TypedInterface y estado interno de una workqueue

## Prerequisitos

- [Workqueues en Kubernetes](03-workqueues.md)

## Contrato básico

`TypedInterface[T]` define las operaciones básicas de una cola tipada:

```go
type TypedInterface[T comparable] interface {
    Add(item T)
    Get() (T, bool)
    Done(item T)
    ShutDown()
}
```

Para un controlador, `T` suele ser `string` y representa `namespace/name`.
La cola deduplica un item pendiente y evita entregarlo a dos workers a la vez.

> **Analogía — un turno en una clínica:**
> Cada paciente recibe un solo número aunque entregue varias actualizaciones.
> El turno permanece en espera, pasa a una persona y vuelve a estar disponible
> si llegó una modificación mientras se procesaba.

Internamente se distinguen los items listos (`queue`), los pendientes de
procesamiento (`dirty`) y los que están en manos de un worker (`processing`).

## Contenido relacionado

- [Workers, `Get` y `Done`](03b-workers-get-done.md)
- [Reintentos y `Forget`](03e-retries-forget.md)

## Referencias

- [Workqueue tipada en client-go](https://pkg.go.dev/k8s.io/client-go/util/workqueue#TypedInterface)
