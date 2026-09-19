---
layout: default
title: 02d — SharedIndexInformer
nav_order: 4
parent: 02 — Informers, cachés y listers
---

# SharedIndexInformer y manejadores de eventos

## Prerequisitos

- [Store e Indexer](02c-store-indexer.md)

## Responsabilidad

`SharedIndexInformer` coordina `Reflector`, `DeltaFIFO` e `Indexer`.
Una sola instancia puede entregar eventos a varios controladores interesados
en el mismo tipo de recurso.

> **Analogía — el periódico de una colonia:**
> Una mesa recibe un solo ejemplar del periódico.
> Cada persona consulta la sección que necesita.
> Así no se compran diez ejemplares para leer las mismas noticias.

Los handlers reciben `OnAdd`, `OnUpdate` y `OnDelete`.
Su trabajo habitual es obtener una clave y encolarla.
No deben modificar directamente los objetos recibidos.

```go
informer.AddEventHandler(cache.ResourceEventHandlerFuncs{
    AddFunc: func(obj interface{}) {
        key, _ := cache.MetaNamespaceKeyFunc(obj)
        queue.Add(key)
    },
})
```

Los eventos disparan trabajo, pero la reconciliación decide según el estado
actual observado en la caché.

## Resincronización y transformación

Una resincronización reenvía objetos de la caché sin generar tráfico adicional
al API server.
Una `TransformFunc` puede eliminar campos innecesarios antes de guardar un
objeto, pero debe ser rápida e idempotente.

## Contenido relacionado

- [Listers y consultas locales](02e-listers.md)
- [SharedInformerFactory y sincronización](02f-informer-factory.md)

## Referencias

- [SharedIndexInformer en client-go](https://pkg.go.dev/k8s.io/client-go/tools/cache#SharedIndexInformer)
