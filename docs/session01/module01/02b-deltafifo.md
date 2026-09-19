---
layout: default
type: Explicación
description: Explica cómo DeltaFIFO acumula y ordena cambios de recursos.
tags: [kubernetes, session01, module01, deltafifo, informers, eventos]
status: stable
title: 02b — DeltaFIFO
nav_order: 2
parent: 02 — Informers, cachés y listers
---

# DeltaFIFO y acumulación de cambios

## Prerequisitos

- [Reflector y ListAndWatch](02a-reflector-list-watch.md)

## Objetivos de aprendizaje

Al terminar esta sección serás capaz de:

- Explicar por qué `DeltaFIFO` existe entre `Reflector` y controlador.
- Describir las decisiones de diseño más importantes de su evolución.
- Interpretar qué significa procesar por clave y no por evento aislado.
- Seguir el flujo interno con seudocódigo de encolado, `Pop`, `Replace` y `Resync`.

## Responsabilidad

`DeltaFIFO` recibe los eventos del `Reflector` y los agrupa por clave.
Una clave como `produccion/web` identifica el objeto sin convertirlo en la
fuente de verdad del controlador.

La fuente de verdad sigue siendo el estado observado en la caché local.
Por eso, `DeltaFIFO` no intenta darte una cronología perfecta de todos los cambios.
Su objetivo es entregarte suficiente contexto por clave para reconciliar bien.

## Qué problema resuelve

En un clúster real, un mismo objeto puede cambiar muchas veces en pocos milisegundos.
Si procesaras cada notificación en bruto, tu controlador gastaría CPU en trabajo redundante.

`DeltaFIFO` resuelve ese problema con tres ideas:

1. Agrupar por clave para evitar procesamiento duplicado innecesario.
2. Acumular deltas para no perder el contexto mínimo de lo que pasó.
3. Entregar trabajo en orden FIFO de claves pendientes.

En términos prácticos, tú no "reaccionas a eventos".
Tú "reconcilias estado actual" cuando una clave llega a la cola.

## Tipos de delta

| Tipo       | Significado                                        |
| ---------- | -------------------------------------------------- |
| `Added`    | El objeto aparece por primera vez.                 |
| `Updated`  | El objeto cambia.                                  |
| `Deleted`  | El objeto desaparece.                              |
| `Replaced` | Un relist reemplaza el estado conocido.            |
| `Sync`     | Se reenvía el objeto durante una resincronización. |

Para una misma clave pueden acumularse varios deltas:

```text
Deltas["default/mi-configmap"] = [
  {Type: Updated, Object: <version 2>},
  {Type: Updated, Object: <version 3>},
]
```

El consumidor procesa la entrada agrupada y después actualiza el `Store`.
El controlador debe reconciliar el estado actual que obtiene de la caché,
no depender de que un evento concreto sea el último.

## Decisiones de diseño que explican su comportamiento

Aunque no hay un KEP "solo de DeltaFIFO", su diseño queda bien documentado
en comentarios de `client-go` y en discusiones de `SIG API Machinery`.
Estas son las decisiones clave que debes recordar:

### 1. Compatibilidad histórica entre `Sync` y `Replaced`

Cuando se añadió `Replaced`, muchos consumidores existentes solo entendían `Sync`.
Por eso existe `EmitDeltaTypeReplaced`.

Si está desactivado, un `Replace()` sigue emitiendo `Sync`.
Si está activado, emite `Replaced`.

Esta decisión mantiene compatibilidad hacia atrás y evita romper controladores antiguos.

### 2. No crecer sin límite con `Deleted` repetidos

Si llega un `Deleted` y el último delta ya era `Deleted`, no se agrega otro.
Solo se reemplaza si el anterior era un tombstone más débil.

Esto evita ruido y protege memoria en escenarios con desconexiones o relist frecuentes.

### 3. Tombstones para borrados perdidos

Durante una caída del `watch`, puedes perder el evento exacto de borrado.
Para no omitir esa intención, `DeltaFIFO` genera `DeletedFinalStateUnknown`.

Eso te dice: "sé que desapareció, pero el último objeto puede estar desactualizado".

### 4. `Replace()` detecta faltantes como borrados sintéticos

En un relist, si una clave existía antes y ya no viene en la lista nueva,
se encola un `Deleted` sintético.

Esta decisión es vital para converger tras errores `410 Gone` y reconexiones.

### 5. `Resync()` no pisa trabajo ya en cola

Si una clave ya tiene deltas pendientes, la resincronización no vuelve a encolarla.
Así se evita la carrera clásica de "resync viejo" contra "update nuevo".

## Estructuras internas mínimas

Puedes entender `DeltaFIFO` con dos estructuras:

- `items: map[key]Deltas`.
- `queue: []key`.

La cola mantiene el orden de claves pendientes.
El mapa mantiene el historial compacto de cambios por clave.

## Flujo interno en seudocódigo

### Encolado de un cambio (`Add`, `Update`, `Delete`)

```text
func queueAction(actionType, obj):
  key = KeyOf(obj)
  if transform exists and obj no es tombstone y actionType != Sync:
    obj = transform(obj)

  oldDeltas = items[key]
  newDeltas = dedup(append(oldDeltas, Delta{Type: actionType, Object: obj}))

  if oldDeltas estaba vacio:
    queue.append(key)

  items[key] = newDeltas
  signal(cond)
```

Punto importante: la clave se mete una sola vez en `queue` mientras tenga trabajo pendiente.

### Consumo (`Pop`)

```text
func Pop(process):
  wait hasta queue no vacia o cola cerrada
  key = queue.popFront()
  deltas = items[key]
  delete(items, key)

  process(deltas)
  return deltas
```

El consumidor recibe todos los deltas acumulados de esa clave de una sola vez.

### Relist (`Replace`)

```text
func Replace(newList):
  keysNuevas = set()

  for each obj in newList:
    key = KeyOf(obj)
    keysNuevas.add(key)
    queueAction(Replaced o Sync, obj)

  for each key conocida en (items U knownObjects):
    if key no esta en keysNuevas:
      queueAction(Deleted, DeletedFinalStateUnknown{key, ultimoObjetoConocido})
```

Este bloque explica por qué reaparecen borrados "sintéticos" tras un relist.

### Resincronización (`Resync`)

```text
func Resync():
  for each key in knownObjects:
    if key no tiene deltas pendientes en items:
      obj = knownObjects[key]
      queueAction(Sync, obj)
```

Si la clave ya está en `items`, se omite para no duplicar trabajo.

## Cómo debes consumirlo en tu controlador

Patrón correcto:

1. Tomas una clave o `Deltas` desde la cola.
2. Lees estado actual desde `Indexer` o `Lister`.
3. Calculas estado deseado.
4. Ejecutas reconciliación idempotente.

Patrón incorrecto:

- Tomar decisiones solo por el tipo de evento (`Updated`, `Deleted`, etc.).
- Asumir que viste "todos" los cambios intermedios.
- Acoplar lógica a un orden global entre objetos distintos.

## Verificación mental rápida

Si para la clave `default/web` recibes este lote:

```text
[
  {Type: Updated, Object: web@rv=20},
  {Type: Updated, Object: web@rv=21},
  {Type: Sync,    Object: web@rv=21}
]
```

La lectura correcta es:

- "Debo reconciliar `default/web`".
- "El estado más reciente observado es `rv=21`".
- "No necesito aplicar tres flujos distintos, sino una reconciliación idempotente".

## Glosario

| Término                    | Definición breve                                                                    |
| -------------------------- | ----------------------------------------------------------------------------------- |
| `Delta`                    | Registro de un cambio (`Added`, `Updated`, `Deleted`, etc.) para un objeto.         |
| `Deltas`                   | Lista ordenada de `Delta` para una misma clave.                                     |
| `DeltaFIFO`                | Cola productor-consumidor que agrupa cambios por clave.                             |
| `DeletedFinalStateUnknown` | Tombstone usado cuando se infiere un borrado pero el último objeto puede ser viejo. |
| `Resync`                   | Reencolado periódico para volver a reconciliar objetos conocidos.                   |

## Contenido relacionado

- [Store e Indexer](02c-store-indexer.md)
- [SharedIndexInformer y handlers](02d-shared-index-informer.md)

## Referencias

- [Paquete `cache` de client-go](https://pkg.go.dev/k8s.io/client-go/tools/cache)
- [Código fuente de `delta_fifo.go`](https://github.com/kubernetes/client-go/blob/master/tools/cache/delta_fifo.go)
- [Conceptos de `watch`, `resourceVersion` y reconexión en la API](https://kubernetes.io/docs/reference/using-api/api-concepts/)
