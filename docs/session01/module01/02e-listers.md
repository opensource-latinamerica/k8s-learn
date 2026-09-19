---
layout: default
title: 02e — Listers
nav_order: 5
parent: 02 — Informers, cachés y listers
---

# Listers y consultas a la caché local

## Prerequisitos

- [Store e Indexer](02c-store-indexer.md)
- [SharedIndexInformer y handlers](02d-shared-index-informer.md)

## Responsabilidad

Un lister ofrece una interfaz tipada para consultar el `Indexer`.
Nunca realiza una llamada de red al API server.

> **Analogía — el catálogo de una biblioteca pública:**
> El catálogo indica dónde está cada libro sin llamar a la editorial.
> Puedes buscar por sección o título y recibir una referencia local.
> El lister cumple esa función para los objetos almacenados en la caché.

```go
pod, err := podLister.Pods("produccion").Get("web-7d8f9-x4k2p")
pods, err := podLister.Pods("produccion").List(labels.Everything())
```

Usa el lister para las lecturas normales del loop de reconciliación.
Usa el cliente cuando necesites una lectura directamente desde el API server
con una garantía de frescura más fuerte.

## Consistencia

El lister puede observar el estado anterior durante un intervalo breve.
Por eso el código debe tolerar objetos que ya no existen y repetir la
reconciliación cuando otro evento actualice la caché.

## Contenido relacionado

- [Workers y workqueues](03b-workers-get-done.md)
- [SharedInformerFactory y sincronización](02f-informer-factory.md)

## Referencias

- [Listers generados en client-go](https://pkg.go.dev/k8s.io/client-go/tools/cache)
