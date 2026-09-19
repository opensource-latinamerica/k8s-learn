---
layout: default
type: Explicación
description: Explica el ciclo Get, procesamiento y Done de los workers.
tags: [kubernetes, session01, module01, workqueues, workers, concurrencia]
status: stable
title: 03b — Workers, Get y Done
nav_order: 2
parent: 03 — Workqueues
---

# Workers, `Get` y `Done`

## Prerequisitos

- [TypedInterface y estado interno](03a-typed-interface.md)

## Ciclo del worker

Un worker obtiene una clave, reconcilia y marca la clave como terminada.

```go
func processNextItem(ctx context.Context) bool {
    key, shutdown := queue.Get()
    if shutdown {
        return false
    }
    defer queue.Done(key)

    if err := reconcile(ctx, key); err != nil {
        queue.AddRateLimited(key)
    }
    return true
}
```

> **Analogía — el mostrador de un taller:**
> El mostrador entrega una orden de trabajo cada vez.
> Al terminar, la persona la marca formalmente como recibida de vuelta
> para que el sistema pueda entregar una nueva versión de esa orden.

`Done` es obligatorio incluso cuando la reconciliación falla.
Si se omite, el item puede quedar marcado como procesándose y no volver a salir.

## Cierre

`ShutDown` despierta a los workers para que terminen.
`ShutDownWithDrain` espera además a que los items entregados reciban su `Done`.

## Contenido relacionado

- [Rate limiters](03d-rate-limiters.md)
- [Reintentos y `Forget`](03e-retries-forget.md)

## Referencias

- [Interfaz de cola tipada](https://pkg.go.dev/k8s.io/client-go/util/workqueue#TypedInterface)
