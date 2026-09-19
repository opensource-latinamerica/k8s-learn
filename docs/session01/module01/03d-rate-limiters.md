---
layout: default
type: Explicación
description: Describe los limitadores de tasa y el backoff de las workqueues.
tags: [kubernetes, session01, module01, workqueues, rate-limiters, backoff]
status: stable
title: 03d — Limitadores de tasa
nav_order: 4
parent: 03 — Workqueues
---

# Rate limiters y backoff

## Prerequisitos

- [Colas con retraso](03c-delaying-queues.md)

## Dos límites complementarios

`TypedItemExponentialFailureRateLimiter` aumenta el retraso de un item según
el número de fallos.
`TypedBucketRateLimiter` limita el ritmo global y permite una ráfaga inicial.

> **Analogía — una ventanilla de trámites:**
> Si una solicitud llega incompleta, la persona debe esperar más antes de volver.
> Además, la ventanilla solo atiende cierto número de personas por minuto.
> Las dos reglas evitan que un error individual o una avalancha bloqueen el servicio.

`TypedMaxOfRateLimiter` combina varios limitadores y aplica el retraso mayor.
`DefaultTypedControllerRateLimiter` combina backoff exponencial por item y
cubo global para el caso habitual de un controlador.

```go
queue := workqueue.NewTypedRateLimitingQueue(
    workqueue.DefaultTypedControllerRateLimiter[string](),
)
```

## Contenido relacionado

- [Reintentos y `Forget`](03e-retries-forget.md)

## Referencias

- [Rate limiters de client-go](https://pkg.go.dev/k8s.io/client-go/util/workqueue#TypedRateLimiter)
