---
layout: default
type: Explicación
description: Explica cómo SharedInformerFactory coordina informers y sincronización.
tags:
  [kubernetes, session01, module01, informer-factory, informers, sincronización]
status: stable
title: 02f — SharedInformerFactory
nav_order: 6
parent: 02 — Informers, cachés y listers
---

# SharedInformerFactory y sincronización

## Prerequisitos

- [SharedIndexInformer y handlers](02d-shared-index-informer.md)

## Fábrica compartida

`SharedInformerFactory` administra una instancia compartida por tipo de recurso.
Esto evita abrir conexiones `Watch` duplicadas para el mismo recurso.

```go
factory := informers.NewSharedInformerFactory(clientset, 30*time.Second)
podInformer := factory.Core().V1().Pods()
factory.Start(stopCh)
factory.WaitForCacheSync(stopCh)
```

También puede limitarse a un namespace o a un selector de etiquetas cuando el
controlador no necesita observar todo el clúster.

> **Analogía — un mercado de abasto:**
> El mercado recibe un solo cargamento de cada producto.
> Después lo reparte entre todos los puestos que lo necesitan.
> Repetir el mismo cargamento para cada puesto consume más recursos
> sin aportar datos nuevos.

## Sincronización inicial

No empieces a reconciliar hasta que la caché haya recibido el `List` inicial.
Usa `WaitForNamedCacheSync` o `WaitForCacheSync` según el ciclo de vida del
controlador.

## Contenido relacionado

- [Reflector y ListAndWatch](02a-reflector-list-watch.md)
- [Listers y consultas locales](02e-listers.md)

## Referencias

- [SharedInformerFactory en client-go](https://pkg.go.dev/k8s.io/client-go/informers)
