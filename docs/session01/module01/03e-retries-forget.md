---
layout: default
type: Explicación
description: Explica los reintentos, el backoff y el uso correcto de Forget.
tags: [kubernetes, session01, module01, workqueues, reintentos, forget]
status: stable
title: 03e — Reintentos y Forget
nav_order: 5
parent: 03 — Workqueues
---

# Reintentos y `Forget`

## Prerequisitos

- [Rate limiters y backoff](03d-rate-limiters.md)
- [Workers, `Get` y `Done`](03b-workers-get-done.md)

## Patrón de error

Cuando una reconciliación falla, `AddRateLimited` reencola la clave con el
retraso que calcula el rate limiter.
Cuando tiene éxito, `Forget` elimina el historial de fallos.

```go
if err := reconcile(ctx, key); err != nil {
    queue.AddRateLimited(key)
    return
}
queue.Forget(key)
```

> **Analogía — una hoja de seguimiento:**
> La persona responsable anota cada intento fallido y aumenta el tiempo
> antes del siguiente.
> Cuando el trámite termina correctamente, archiva la hoja.
> Si no lo borra, una tarea nueva heredaría una espera que ya no corresponde.

`Forget` no reemplaza a `Done`.
El primero limpia el estado del rate limiter y el segundo termina el ciclo de
procesamiento de la cola.

## Contenido relacionado

- [Workers, `Get` y `Done`](03b-workers-get-done.md)
- [Rate limiters y backoff](03d-rate-limiters.md)

## Referencias

- [TypedRateLimitingInterface](https://pkg.go.dev/k8s.io/client-go/util/workqueue#TypedRateLimitingInterface)
