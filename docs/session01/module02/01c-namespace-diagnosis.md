---
layout: default
type: Explicación
description: Presenta técnicas para diagnosticar namespaces atascados en Terminating.
tags: [kubernetes, session01, module02, namespace, diagnóstico, troubleshooting]
status: stable
title: 01c — Diagnóstico de namespaces atascados
nav_order: 3
parent: 01 — Controlador de Namespace
---

# Diagnóstico de un Namespace atascado

## Prerequisitos

- [NamespacedResourcesDeleter](01b-namespaced-resources-deleter.md)

## Confirmar el estado

```bash
kubectl get namespace mi-namespace -o yaml
kubectl describe namespace mi-namespace
```

Comprueba `status.phase`, `metadata.deletionTimestamp` y los mensajes de
`status.conditions`.

## Buscar recursos restantes

```bash
kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get --ignore-not-found -n mi-namespace
```

Revisa especialmente recursos con finalizers o tipos cuyo APIService esté
fallando.

> **Advertencia:** No elimines finalizers manualmente como primera opción.
> Primero identifica qué operación de limpieza representan y corrige su causa.

## Interpretar el bloqueo

| Señal                    | Investigación                                        |
| ------------------------ | ---------------------------------------------------- |
| Recursos restantes       | Elimina o corrige esos recursos.                     |
| Finalizer persistente    | Revisa el controlador que debe retirarlo.            |
| APIService no disponible | Recupera el servicio o elimina su registro obsoleto. |

## Contenido relacionado

- [Finalizers y ciclo de borrado](../module01/04-controller-utilities.md)
- [Ciclo de vida y reconciliación](01a-namespace-lifecycle.md)
