---
description: "Estándares de documentación didáctica para el proyecto k8s-learn"
applyTo: "**/*.md"
---

# Reglas de Documentación — k8s-learn

Todo el contenido generado en archivos Markdown de este proyecto debe escribirse **únicamente en español**.
No se permiten mezclas de idiomas, anglicismos innecesarios ni fragmentos en inglés, salvo términos técnicos
propios de Kubernetes que no tienen traducción establecida (p. ej., `Pod`, `Deployment`, `namespace`).

## 1. Idioma y Tono

- Redacta siempre en **español neutro** (sin regionalismos marcados).
- Dirígete al lector de **segunda persona del singular** ("tú"): "ejecuta el comando", "comprueba el resultado".
- Usa **voz activa** y **tiempo presente** para las descripciones: "el Pod escala", no "el Pod será escalado".
- Evita adverbios redundantes, frases hechas y humor que no se traduzca bien a todos los hablantes de español.
- Los términos técnicos en inglés se escriben en `código` o en _cursiva_ la primera vez, seguidos de una breve
  explicación entre paréntesis cuando sea necesario.

## 2. Tipo de Contenido (Diataxis)

Cada documento pertenece a **uno solo** de los cuatro cuadrantes de Diataxis.
No mezcles propósitos en el mismo archivo.

| Cuadrante         | Pregunta que responde    | Cuándo usarlo en este proyecto                          |
| ----------------- | ------------------------ | ------------------------------------------------------- |
| **Tutorial**      | "¿Puedes enseñarme a…?"  | Introducción guiada para estudiantes nuevos             |
| **Guía práctica** | "¿Cómo hago X?"          | Tareas concretas con pasos numerados                    |
| **Referencia**    | "¿Qué es / qué hace X?"  | Descripción neutra de recursos y API de k8s             |
| **Explicación**   | "¿Por qué funciona así?" | Contexto conceptual, arquitectura, decisiones de diseño |

Reglas clave por tipo:

- **Tutorial** — oriéntate al aprendizaje; el estudiante debe poder seguir cada paso y obtener un resultado visible.
  Usa un tono alentador ("¡Perfecto, ya tienes tu primer Pod corriendo!").
- **Guía práctica** — sé directo; pasos numerados, resultado esperado al final de cada paso.
  Sin digresiones conceptuales: enlaza a la explicación correspondiente.
- **Referencia** — describe sin instruir ni opinar; tablas y listas, no párrafos narrativos.
- **Explicación** — no incluyas procedimientos paso a paso; proporciona el "por qué" con diagramas o analogías.

## 3. Estructura del Documento

- Comienza con un encabezado `# H1` que describa el propósito del documento con claridad.
- Usa máximo **dos niveles de anidamiento** en la navegación (`##` y `###`); más profundidad desorienta al lector.
- Cada documento enlaza a: (a) requisitos previos, (b) contenido relacionado, (c) siguiente paso lógico.
  No dejes documentos sin salida.
- Incluye un bloque de **objetivos de aprendizaje** al inicio de tutoriales y guías prácticas:

  ```markdown
  ## Objetivos de aprendizaje

  Al terminar esta sección serás capaz de:

  - Crear un Pod básico con `kubectl run`.
  - Verificar su estado con `kubectl get pods`.
  - Eliminar el Pod de forma segura.
  ```

## 4. Estilo de Escritura

- **Un concepto = un término.** Decide cómo llamar a cada concepto y úsalo siempre igual.
  No alternes entre "contenedor" y "container", ni entre "clúster" y "cluster".
- **Máximo 2-3 avisos por página.** Si todo es una advertencia, nada lo es.
  Usa `> **Nota:**` para información útil, `> **Advertencia:**` solo para riesgos reales.
- **Saltos de línea semánticos** (SemBr) en el fuente Markdown: véase la sección 8 para las reglas completas.
- Usa tablas para comparar opciones o convenciones de nomenclatura.
- Cada concepto abstracto necesita un ejemplo concreto: código, diagrama o salida de terminal.

## 5. Ejemplos de Código y Comandos

- Todos los bloques de código deben ser **ejecutables y probados**; no incluyas fragmentos que fallen.
- Especifica siempre el lenguaje del bloque de código (` ```yaml `, ` ```bash `, ` ```json `).
- Muestra la salida esperada tras el comando cuando sea relevante para la comprensión.
- Los manifiestos YAML de Kubernetes incluyen comentarios en español explicando los campos clave.

  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: mi-pod # Nombre único dentro del namespace
    namespace: default # Espacio de nombres donde se despliega
  spec:
    containers:
      - name: nginx
        image: nginx:1.27 # Usa siempre una etiqueta de versión concreta; evita `latest`
  ```

## 6. Orientación Didáctica (específica de k8s-learn)

- Diseña cada sección de acuerdo con el embudo de adopción de este proyecto:

  ```
  Descubrir  → "¿Qué es Kubernetes?"       → Explicación, README
  Evaluar    → "¿Por qué necesito k8s?"    → Arquitectura, Comparativas
  Comenzar   → "¿Cómo empiezo?"            → Quickstart, Tutorial
  Construir  → "¿Cómo hago X en k8s?"      → Guías prácticas, Referencia
  Operar     → "¿Cómo lo mantengo?"        → Runbooks, Solución de problemas
  Avanzar    → "¿Cómo migro a la siguiente versión?" → Guías de migración
  ```

- Incluye verificaciones intermedias en los tutoriales para que el estudiante confirme que va por buen camino
  antes de continuar.
- Evita presuponer conocimiento previo sin advertirlo; indica claramente los **prerequisitos** al inicio.
- Cuando un concepto puede confundirse con otro (p. ej., `Deployment` vs. `ReplicaSet`),
  añade una nota de aclaración con un enlace a la explicación correspondiente.

## 7. Diseño Didáctico Eficaz

Aplica las **4 C's de la documentación técnica efectiva** en cada archivo:

| C               | Significado                                      | Aplicación práctica                                     |
| --------------- | ------------------------------------------------ | ------------------------------------------------------- |
| **Claridad**    | El lector entiende el texto a la primera lectura | Usa verbos activos: "selecciona", "verifica", "ejecuta" |
| **Concisión**   | Sin palabras ni secciones innecesarias           | Máximo un concepto por párrafo; elimina relleno         |
| **Corrección**  | La información es técnicamente exacta            | Prueba cada comando antes de publicar                   |
| **Completitud** | El lector tiene todo lo que necesita para actuar | Incluye prerequisitos, pasos y resultado esperado       |

### 7.1 Estructura y Claridad

- **Define las 5 W's** al inicio de cada documento:
  _quién_ es el lector, _qué_ aprenderá, _por qué_ le es útil, _cuándo_ aplicarlo, _dónde_ encaja en el proyecto.
- **Fragmenta la información** (_chunking_): divide los temas complejos en secciones cortas con un encabezado claro cada una.
  Ninguna sección debería superar 200 palabras sin un subtítulo o lista intermedia.
- **Lenguaje llano:** evita la jerga innecesaria.
  Cuando debas usar un término especializado, defínelo en el momento en que aparece por primera vez.
- **Glosario integrado:** incluye un glosario al final de cada tutorial o guía práctica
  que contenga los términos de Kubernetes introducidos en ese documento.

  ```markdown
  ## Glosario

  | Término     | Definición breve                                                            |
  | ----------- | --------------------------------------------------------------------------- |
  | `Pod`       | Unidad mínima desplegable en Kubernetes; agrupa uno o más contenedores.     |
  | `namespace` | Partición lógica del clúster para aislar recursos entre equipos o entornos. |
  ```

### 7.2 Diseño Visual y Densidad de Texto

- **Evita bloques densos:** ningún párrafo de prosa continua debe superar 4 líneas.
  Sustituye los párrafos largos por listas con viñetas, listas numeradas o tablas.
- **Énfasis selectivo:** usa **negrita** para términos clave y `código` para comandos y nombres de recursos.
  No uses _cursiva_ para énfasis general; reserva las cursivas para introducir términos nuevos.
- **Ayudas visuales:** complementa el texto con diagramas, capturas de pantalla anotadas o salidas de terminal
  cuando ilustren un concepto mejor que las palabras.
  Añade texto alternativo (`alt`) a cualquier imagen para accesibilidad.
- **Espacio en blanco:** deja una línea en blanco antes y después de cada bloque de código,
  tabla, lista y admonición para mejorar la legibilidad en el fuente y en el renderizado.

### 7.3 Alineación Constructiva y Revisión

- **Alineación objetivos–actividad–evaluación:** cada objetivo de aprendizaje declarado al inicio
  debe corresponderse con al menos una actividad práctica y una verificación comprobable en el mismo documento.
- **Verificaciones intermedias** (_checkpoints_): en los tutoriales, incluye un bloque de verificación
  después de cada grupo de pasos significativo.

  ````markdown
  ### Verificación

  Ejecuta el siguiente comando y comprueba que la salida coincide:

  ```bash
  kubectl get pods -n default
  ```
  ````

  Deberías ver `mi-pod` con estado `Running`.

  ```

  ```

- **Revisión por un usuario "novato":** antes de publicar un documento nuevo,
  pídele a alguien ajeno al tema que lo recorra y señale cualquier ambigüedad.
- **Ciclo de actualización:** revisa cada documento al menos una vez por versión menor de Kubernetes
  o cuando cambien los comandos o manifiestos que contiene.

## 8. Saltos de Línea Semánticos (SemBr)

Los archivos fuente Markdown de este proyecto siguen la especificación
[Semantic Line Breaks](https://sembr.org) (SemBr).
Los saltos de línea semánticos no alteran el texto renderizado,
pero hacen que el fuente sea más fácil de leer, revisar y comparar en Git.

### Reglas obligatorias

1. Un salto de línea semántico **no debe** alterar la salida renderizada del documento.
2. Un salto de línea semántico **no debe** alterar el significado previsto del texto.
3. Un salto de línea semántico **debe** aparecer después de cada oración,
   marcada por punto (`.`), signo de exclamación (`!`) o signo de interrogación (`?`).
4. Un salto de línea semántico **no debe** ocurrir dentro de una palabra con guion.

### Reglas recomendadas

5. Un salto de línea semántico **debería** aparecer después de una cláusula independiente
   marcada por coma (`,`), punto y coma (`;`), dos puntos (`:`) o raya (—).
6. Un salto de línea semántico **puede** aparecer después de una cláusula dependiente
   para aclarar la estructura gramatical o respetar la longitud máxima de línea.
7. Se **recomienda** un salto de línea antes de una lista enumerada o con viñetas.
8. Un salto de línea **puede** usarse después de uno o más elementos de una lista
   para agrupar lógicamente ítems relacionados.
9. Un salto de línea **puede** aparecer antes y después de un hipervínculo.
10. Un salto de línea **puede** aparecer antes de un elemento de marcado en línea.
11. La longitud máxima de línea **recomendada** es de **80 caracteres**.
12. Una línea **puede** superar ese límite cuando sea necesario
    (p. ej., para acomodar enlaces, elementos de código u otro marcado).

### Ejemplo correcto

```markdown
Todos los Pods en Kubernetes deben tener un nombre único dentro de su namespace.
Si dos Pods tienen el mismo nombre, el segundo no se creará correctamente
y recibirás un error de conflicto.
```

### Ejemplo incorrecto

```markdown
Todos los Pods en Kubernetes deben tener un nombre único dentro de su namespace. Si dos Pods tienen el mismo nombre, el segundo no se creará correctamente y recibirás un error de conflicto.
```

### Uso con Git

Para ver diferencias a nivel de palabras en lugar de líneas completas:

```bash
git diff --word-diff
```

## 9. Convenciones de Nomenclatura de Archivos

- Nombres de archivo en minúsculas con guiones: `01-fundamentos.md`, `como-crear-un-deployment.md`.
- Los tutoriales numerados usan prefijo ordinal de dos dígitos: `01-`, `02-`, etc.
- Los archivos `README.md` describen el propósito del directorio, no repiten el contenido de otros archivos.
