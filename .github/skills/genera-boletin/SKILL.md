---
name: genera-boletin
description: "Genera un boletín corto en español a partir del siguiente artículo pendiente de un módulo de k8s-learn, listo para enviarse por WhatsApp o Slack y ayudar a prepararse para la sesión de estudio. Elige automáticamente el próximo artículo no resumido (orden secuencial por sesión/módulo) y registra en memoria de repositorio cuál fue usado para no repetirlo. Úsalo cuando pidan: 'genera el boletín', 'genera boletin', 'resumen para whatsapp', 'resumen para slack', 'prepárame para la próxima sesión', 'resume el próximo artículo', 'boletín de estudio'."
argument-hint: "Opcional: ruta o tema de un artículo específico (p. ej. 'docs/session01/module02/01-namespace-controller.md'). Si se omite, se elige automáticamente el siguiente pendiente."
---

# genera-boletin

Produce un boletín breve, listo para copiar/pegar en WhatsApp o Slack, que resume las ideas
principales de **un solo artículo** de un módulo de k8s-learn. El resultado lo consume el
agente **hermes**, así que la salida final del chat debe ser el boletín en texto plano
(no un archivo) — no lo guardes como documento del repositorio.

## Cuándo usar esta skill

- Alguien pide preparar material corto para la próxima sesión de estudio.
- Se pide un resumen de un artículo/módulo para compartir por WhatsApp o Slack.
- Se pide generar "el boletín" sin especificar artículo (selección automática).

## Registro anti-duplicados

Antes de elegir un artículo, lee `/memories/repo/genera-boletin-historial.md` (memoria de
repositorio, herramienta `memory`). Si el archivo no existe, créalo vacío con este formato:

```markdown
# Historial de boletines — genera-boletin

| Fecha | Artículo |
| ----- | -------- |
```

Cada fila registra la ruta del artículo ya convertido en boletín. Nunca vuelvas a elegir
un artículo que ya aparezca en esta tabla, salvo que el usuario lo pida explícitamente por
ruta o tema (argumento explícito).

## Procedimiento

### Paso 1 — Elegir el artículo

- **Si el usuario da un argumento** (ruta o tema): usa `file_search`/`grep_search` para
  localizar el archivo `.md` correspondiente dentro de `docs/sessionNN/moduleNN/`.
- **Si no da argumento**: construye la lista de candidatos con todos los archivos `.md`
  bajo `docs/sessionNN/moduleNN/` que **no** sean `README.md` (los README son índices, no
  artículos). Ordena la lista alfabéticamente por ruta completa — ese orden ya respeta la
  secuencia numérica de los módulos (`01-...`, `02-...`, `02a-...`, `03-...`, ...). Recorre
  la lista en orden y toma el **primer** archivo que no esté en el historial.
- Si todos los artículos ya están en el historial, avisa al usuario y pregunta si quiere
  reiniciar el ciclo o elegir uno puntual.

### Paso 2 — Leer el artículo

Lee el archivo completo con `read_file`. Identifica:

- El título (`# H1`) y de qué sesión/módulo proviene.
- 3 a 5 ideas centrales (evita detalles de implementación menores).
- Una analogía o ejemplo del documento, si existe, para anclar el concepto.

### Paso 3 — Redactar el boletín

Escribe en **español neutro**, tono cercano, listo para WhatsApp/Slack (ambos soportan
`*negrita*` y `_cursiva_` con un solo símbolo). Longitud objetivo: **5 a 8 líneas**. Usa
esta plantilla:

```text
📘 *Boletín k8s-learn — <Título del artículo>*
📍 <Sesión NN / Módulo NN>

• <Idea principal 1, en una línea>
• <Idea principal 2, en una línea>
• <Idea principal 3, en una línea>

🎯 Antes de la sesión, piensa: <pregunta de reflexión ligada al artículo>
```

Reglas:

- Máximo 3-4 viñetas; cada una es una sola oración corta, sin jerga innecesaria.
- No copies párrafos del artículo: parafrasea y comprime.
- La pregunta de reflexión debe poder responderse tras leer solo el boletín, pero invita a
  profundizar en el artículo completo.
- No incluyas bloques de código ni tablas — el boletín debe leerse en una pantalla de chat.

### Paso 4 — Entregar y registrar

1. Entrega el boletín como mensaje final de texto plano (esto es lo que consume hermes).
   No lo guardes en el repositorio ni crees un archivo `.md` con su contenido.
2. Actualiza `/memories/repo/genera-boletin-historial.md` agregando una fila con la fecha
   actual y la ruta del artículo usado.
