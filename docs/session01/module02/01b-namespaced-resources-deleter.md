---
layout: default
type: Explicación
description: Explica cómo NamespacedResourcesDeleter elimina recursos de un Namespace.
tags: [kubernetes, session01, module02, namespace, borrado, controladores]
status: stable
title: 01b — Eliminador de recursos del Namespace
nav_order: 2
parent: 01 — Controlador de Namespace
---

# NamespacedResourcesDeleter

## Prerequisitos

- [Ciclo de vida y reconciliación de Namespace](01a-namespace-lifecycle.md)

## Responsabilidad

`NamespacedResourcesDeleter` elimina los recursos namespaced que todavía
existen durante el borrado de un `Namespace`.
Consulta los tipos de recursos disponibles, intenta borrarlos y vuelve a
comprobar si queda contenido.

> **Analogía — entregar un local rentado:**
> La persona responsable revisa cada espacio, retira los objetos y verifica el
> inventario final.
> No entrega las llaves mientras encuentra pertenencias pendientes.

## Resultado de la limpieza

- Si todavía hay recursos, el controlador reintenta más tarde.
- Si hay finalizers en dependientes, informa de que el borrado continúa.
- Cuando el namespace está vacío y sus finalizers pueden retirarse, actualiza
  el objeto para permitir que el API server lo elimine.

La limpieza es eventualmente consistente.
Un namespace puede permanecer en `Terminating` si un recurso o finalizer no
responde, si un APIService no está disponible o si el borrado requiere varios
intentos.

## Contenido relacionado

- [Diagnóstico de namespaces atascados](01c-namespace-diagnosis.md)
- [Borrado en cascada](../module04/03-cascade-orphan.md)
