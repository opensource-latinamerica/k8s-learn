---
layout: default
title: 01a — Ciclo de vida de Namespace
nav_order: 1
parent: 01 — Namespace
---

# Ciclo de vida y reconciliación de Namespace

## Prerequisitos

- [El controlador de Namespace](01-namespace-controller.md)

## Estados principales

| Estado        | Significado                                         |
| ------------- | --------------------------------------------------- |
| `Active`      | El namespace acepta recursos nuevos.                |
| `Terminating` | Se solicitó el borrado y la limpieza está en curso. |

Al borrar un `Namespace`, el API server fija `metadata.deletionTimestamp`.
El controlador observa ese cambio, encola la clave y empieza la reconciliación.

> **Analogía — una mudanza de oficina:**
> La dirección sigue registrada mientras se retira el equipo.
> El proceso termina cuando no queda nada pendiente y se entregan las llaves.

## Orden de reconciliación

1. Detectar el `deletionTimestamp`.
2. Enumerar los recursos que pertenecen al namespace.
3. Borrar los recursos restantes.
4. Retirar el finalizer del namespace.

El API server rechaza crear recursos nuevos en un namespace que ya está en
`Terminating`.

## Contenido relacionado

- [NamespacedResourcesDeleter](01b-namespaced-resources-deleter.md)
- [Finalizers y ciclo de borrado](../week01/04-controller-utilities.md)
