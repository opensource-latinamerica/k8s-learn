---
layout: default
title: 03c — Colas con retraso
nav_order: 3
parent: 03 — Workqueues
---

# Colas con retraso

## Prerequisitos

- [Workers, `Get` y `Done`](03b-workers-get-done.md)

## `TypedDelayingInterface`

Esta interfaz añade `AddAfter` a la cola básica.
El worker no queda bloqueado mientras transcurre el retraso.

```go
queue.AddAfter("produccion/web", 5*time.Second)
```

> **Analogía — una nota pendiente en una bodega:**
> Anotas una revisión de inventario para dentro de dos horas.
> La persona que registra la nota puede continuar con otras tareas.
> Cuando llega la hora, la revisión vuelve a estar disponible.

Usa `AddAfter` cuando el retraso es fijo y conocido.
Para errores repetidos, prefiere `AddRateLimited`, que calcula el retraso
según el historial del item.

## Contenido relacionado

- [Rate limiters](03d-rate-limiters.md)

## Referencias

- [TypedDelayingInterface](https://pkg.go.dev/k8s.io/client-go/util/workqueue#TypedDelayingInterface)
