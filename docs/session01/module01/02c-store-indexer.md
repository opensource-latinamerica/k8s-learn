---
layout: default
title: 02c — Store e Indexer
nav_order: 3
parent: 02 — Informers, cachés y listers
---

# Store e Indexer en la caché de Kubernetes

## Prerequisitos

- [DeltaFIFO y acumulación de cambios](02b-deltafifo.md)

## `Store`

El `Store` mantiene en memoria el estado conocido de cada objeto.
Su acceso seguro permite que varias goroutines lean y escriban sin administrar
un bloqueo externo.

## `Indexer`

`Indexer` extiende el `Store` con índices por campos.
El índice `NamespaceIndex`, por ejemplo, permite localizar objetos de un
namespace sin recorrer toda la caché.

```go
pods, err := indexer.ByIndex(cache.NamespaceIndex, "produccion")
```

También puedes registrar un índice propio:

```go
indexer.AddIndexers(cache.Indexers{
    "byNode": func(obj interface{}) ([]string, error) {
        pod := obj.(*corev1.Pod)
        if pod.Spec.NodeName == "" {
            return nil, nil
        }
        return []string{pod.Spec.NodeName}, nil
    },
})
```

> **Analogía — un archivo con separadores:**
> El archivo conserva todos los expedientes.
> Los separadores permiten encontrar rápidamente los documentos por
> estado, responsable o fecha sin revisar cada carpeta.

## Límite importante

La caché es una vista local y eventualmente consistente.
Para crear, actualizar o eliminar usa el cliente del API server.
Para leer durante la reconciliación, prefiere un lister sobre la caché.

## Contenido relacionado

- [Listers y consultas locales](02e-listers.md)
- [SharedIndexInformer y handlers](02d-shared-index-informer.md)

## Referencias

- [Indexer en client-go](https://pkg.go.dev/k8s.io/client-go/tools/cache#Indexer)
