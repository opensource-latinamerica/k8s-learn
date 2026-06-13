---
name: k8s-researcher
description: "Investiga un tema de Kubernetes usando el servidor MCP code-wiki, la documentación oficial kubernetes/website y otras fuentes. Genera contenido en español con formato Markdown listo para el proyecto k8s-learn. Úsalo cuando necesites: 'investiga el tema X de Kubernetes', 'busca información sobre Pods', 'explícame cómo funciona el scheduler', 'qué es un Deployment', 'documenta el concepto de namespaces', 'investiga la última versión de Kubernetes', 'traduce y resume la documentación oficial'."
argument-hint: "Tema o pregunta de Kubernetes a investigar (p. ej., 'StatefulSets', '¿Cómo funciona el autoscaling?')"
---

# k8s-researcher

Recopila información precisa y actualizada sobre cualquier tema de Kubernetes combinando el servidor
MCP code-wiki, el repositorio oficial `kubernetes/website` y otras fuentes de referencia.
Todo el resultado se entrega en **español** con formato Markdown, listo para integrarse en el proyecto
k8s-learn siguiendo sus convenciones de estilo (Diataxis, SemBr, español neutro).

## Cuándo usar esta habilidad

- Necesitas documentar un concepto de Kubernetes en español.
- Quieres verificar que la información que manejas es la más reciente.
- Estás preparando material para una sesión del grupo de estudio.
- Buscas ejemplos de manifiestos YAML oficiales o comandos `kubectl`.
- Requieres comparar comportamientos entre versiones de Kubernetes.

## Herramientas disponibles

| Herramienta                              | Propósito                                                                 |
| ---------------------------------------- | ------------------------------------------------------------------------- |
| `mcp_codewiki_codewiki_read_structure`   | Ver estructura de secciones disponible para un repositorio                |
| `mcp_codewiki_codewiki_read_contents`    | Leer contenido del wiki por secciones                                     |
| `mcp_codewiki_codewiki_search_wiki`      | Hacer preguntas en lenguaje natural sobre un repositorio indexado         |
| `mcp_codewiki_codewiki_request_indexing` | Solicitar indexación cuando el repositorio no está disponible en CodeWiki |
| `mcp_github_mcp_se_search_code`          | Buscar texto/código dentro de `kubernetes/website`                        |
| `mcp_github_mcp_se_get_file_contents`    | Leer archivos concretos del repo oficial                                  |
| `fetch_webpage`                          | Obtener contenido de páginas web (kubernetes.io, pkg.go.dev, blog, KEPs)  |
| `semantic_search`                        | Buscar contexto relevante en el workspace actual                          |

> **Nota operativa:**
> Si CodeWiki devuelve error temporal,
> continúa con el fallback sin bloquear la investigación.
> Si devuelve `NOT_INDEXED`,
> usa `mcp_codewiki_codewiki_request_indexing`
> y sigue con fuentes oficiales mientras se procesa la solicitud.

## Procedimiento

### Paso 1 — Clarificar el tema

Identifica con precisión qué se busca:

- ¿Es un concepto (Explicación), un procedimiento (Guía práctica / Tutorial) o una referencia de API?
- ¿Hay una versión específica de Kubernetes involucrada?
- ¿Se necesita un ejemplo práctico o solo la definición?

Si la solicitud es ambigua, pregunta antes de investigar.

### Paso 2 — Intentar code-wiki MCP

1. Llama a `mcp_codewiki_codewiki_read_structure`
   con `repo_url: "kubernetes/website"`.
2. Si responde con `NOT_INDEXED`,
   usa `mcp_codewiki_codewiki_request_indexing`
   y continúa con el Paso 3 (fallback).
3. Si responde con error temporal,
   **salta directamente al Paso 3 (fallback)**.
4. Si responde correctamente:
   - Usa `mcp_codewiki_codewiki_read_contents`
     para leer las secciones más relevantes.
   - Si necesitas síntesis dirigida,
     usa `mcp_codewiki_codewiki_search_wiki`
     con una pregunta concreta en inglés.
   - Registra las secciones y rutas citables que sustentan la respuesta.
   - Continúa con el Paso 3 para profundizar y validar.

### Paso 3 — Fallback: repositorio oficial + web

Cuando code-wiki falle (o como complemento), usa estas fuentes en orden de preferencia:

#### 3a. Archivos del repo `kubernetes/website`

```yaml
mcp_github_mcp_se_get_file_contents:
  owner: kubernetes
  repo: website
  path: content/en/docs/concepts/...   ← documentación estable
```

Usa `mcp_github_mcp_se_search_code` para localizar el archivo correcto:

```yaml
query: "<término técnico> repo:kubernetes/website"
```

#### 3b. Documentación web oficial

```yaml
fetch_webpage:
  urls:
    - https://kubernetes.io/docs/<ruta-del-tema>/
    - https://pkg.go.dev/<paquete-go>/      ← para APIs de client-go / controller-runtime
```

URLs de referencia frecuentes:

| Fuente                   | URL                                                               |
| ------------------------ | ----------------------------------------------------------------- |
| Conceptos                | `https://kubernetes.io/docs/concepts/`                            |
| Referencia de API        | `https://kubernetes.io/docs/reference/kubernetes-api/`            |
| client-go tools/cache    | `https://pkg.go.dev/k8s.io/client-go/tools/cache`                 |
| client-go util/workqueue | `https://pkg.go.dev/k8s.io/client-go/util/workqueue`              |
| controller-runtime       | `https://pkg.go.dev/sigs.k8s.io/controller-runtime`               |
| Blog oficial             | `https://kubernetes.io/blog/`                                     |
| KEPs                     | `https://github.com/kubernetes/enhancements`                      |
| Changelog                | `https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/` |

### Paso 4 — Sintetizar y traducir

Combina la información recopilada siguiendo estas reglas:

1. **Prioridad de fuentes** (de mayor a menor confiabilidad):
   1. Documentación oficial `kubernetes/website` (rama `main`)
   2. Blog oficial de Kubernetes
   3. KEPs aprobados
   4. Fuentes de la comunidad verificadas

2. **Traducción al español**:
   - Usa español neutro sin regionalismos.
   - Los términos técnicos sin traducción establecida se mantienen en inglés
     (`Pod`, `Deployment`, `namespace`, `kubectl`) y se escriben en `código`.
   - Proporciona una breve explicación la primera vez que aparece un término nuevo.

3. **Indicar la versión** de Kubernetes a la que aplica el contenido cuando sea relevante.

4. **Citar las fuentes** al final del documento con enlaces directos a los originales en inglés.

5. **Analogías obligatorias** — cada concepto abstracto debe tener al menos una analogía
   del mundo cotidiano que lo haga concreto.
   Sigue este patrón fijo para cada analogía:

   ```markdown
   > **Analogía — <título breve>:**
   > <párrafo de 3-5 oraciones que compara el concepto con algo cotidiano>.
   ```

   Criterios para una buena analogía en k8s-learn:

   - **Concreta:** usa objetos o situaciones reales, no otros conceptos técnicos.
   - **Proporcional:** la analogía cubre solo el aspecto que estás explicando;
     no intentes que cubra todo el componente.
   - **Situada antes del código o tabla:** aparece justo antes del bloque que explica,
     no al final.
   - **Coherente con el documento:** no repitas la misma analogía en el mismo artículo.

   Ejemplos de analogías ya establecidas en el proyecto
   (no las repitas, crea nuevas):

   | Concepto                   | Analogía usada                                      |
   | -------------------------- | --------------------------------------------------- |
   | Bucle de control           | Termostato / jardinero del huerto                   |
   | Level-based reconciliation | Circuito level-based vs edge-based en electrónica   |
   | Convergencia eventual      | GPS recalculando la ruta                            |
   | Workqueue                  | Bandeja de comandas del restaurante                 |
   | DeltaFIFO                  | Extracto bancario con todos los movimientos         |
   | Reflector                  | Vigilante de almacén que anota entradas y salidas   |
   | SharedIndexInformer        | Suscripción compartida al periódico                 |
   | SharedInformerFactory      | Departamento de IT centralizado                     |
   | Indexer/Store              | Biblioteca con catálogo de fichas temáticas         |
   | Lister                     | Catálogo en línea de la biblioteca                  |
   | ownerReferences            | Documentos dentro de una carpeta                    |
   | Finalizer                  | Fianza del apartamento                              |
   | CreateOrUpdate             | Perfil de usuario en app (crear o actualizar)       |
   | NamespaceController        | Dar de baja una empresa ante el registro            |
   | LegacySATokenCleaner       | Llaves maestras caducadas del hotel                 |
   | Bucle periódico vs WQ      | Limpieza nocturna vs conserje reactivo              |
   | ServiceAccountsController  | Tarjeta de acceso de empleado nuevo por RR HH       |
   | Controlador mínimo         | Cadena de montaje de cuatro puestos                 |
   | Token bucket               | Cubo de fichas de una máquina expendedora           |
   | Backoff exponencial        | Dispositivos reconectándose tras apagón             |
   | Problema de escalar obs.   | Banco y alertas de movimiento vs llamadas repetidas |

6. **Evitar simplificaciones arquitectónicas** en temas de controladores y reconciliación:

- Explica que no existe un único loop global,
  sino múltiples controladores independientes en paralelo.
- Distingue reconciliación **level-based** (comparación de estado)
  del uso de eventos como disparadores de encolado.
- Incluye el papel de `watch`, `informer`/`lister` y `workqueue`.
- Aclara que la consistencia es eventual y que puede haber `no-op`,
  reintentos o decisiones de no actuar inmediatamente.
- Añade al menos un ejemplo real enlazando `Deployment` y `ReplicaSet`.

### Paso 5 — Verificación técnica final

Antes de devolver el resultado,
haz una validación de precisión para detectar sobre-simplificaciones:

1. Revisa que no se afirme implícita o explícitamente
   la existencia de un controlador único para todo Kubernetes.
2. Verifica que los eventos no se presenten como fuente de verdad,
   sino como disparadores hacia una reconciliación basada en estado.
3. Confirma que el texto indique límites reales:
   no hay convergencia instantánea,
   puede haber latencia,
   backoff y reintentos.
4. Comprueba que los ejemplos prácticos incluyan recursos concretos
   y flujo entre componentes del plano de control.

### Paso 6 — Formatear el resultado

Produce un documento Markdown listo para usar en k8s-learn:

```markdown
# <Título descriptivo del tema>

> **Versión de Kubernetes:** vX.YY
> **Fuentes:** [kubernetes.io/docs/...](URL), [kubernetes/website](URL)

## Objetivos de aprendizaje ← solo para tutoriales y guías prácticas

Al terminar esta sección serás capaz de:

- ...

## <Sección principal>

...

## Referencias

- [Título original en inglés](URL) — Documentación oficial
- [Título del KEP](URL) — Propuesta de mejora relacionada
```

Aplica las convenciones del proyecto definidas en
[k8s-learn.instructions.md](../../instructions/k8s-learn.instructions.md):

- Máximo dos niveles de encabezado (`##` y `###`).
- Saltos de línea semánticos (SemBr) en el Markdown fuente.
- Bloques de código con lenguaje especificado y comentarios en español.
- Un concepto = un término consistente en todo el documento.

## Criterios de calidad

Antes de entregar el resultado, verifica:

- [ ] La información proviene de la rama `main` del repo oficial (no de versiones anteriores).
- [ ] Los comandos y manifiestos YAML son ejecutables y están probados o tomados literalmente
      de la documentación oficial.
- [ ] Se indica la versión mínima de Kubernetes requerida cuando aplica.
- [ ] El español es claro y no contiene anglicismos innecesarios.
- [ ] Las fuentes están citadas con URLs directas.
- [ ] El documento sigue la estructura Diataxis apropiada para el tipo de contenido.
- [ ] En temas de reconciliación,
      se diferencia explícitamente el modelo level-based del modelo basado en eventos.
- [ ] En temas de controladores,
      se describe concurrencia entre controladores y no un loop único global.
- [ ] **Cada concepto abstracto tiene al menos una analogía** con el formato
      `> **Analogía — <título>:** ...` situada antes del bloque que explica.
- [ ] Ninguna analogía repite una que ya exista en otro artículo del mismo proyecto
      (consulta la tabla del Paso 4 para verificar).
- [ ] Las analogías son concretas (mundo real) y proporcionales
      (explican un aspecto, no todo el componente).

## Ejemplos de uso

```text
/k8s-researcher ¿Cómo funciona el garbage collection de Pods en Kubernetes?
/k8s-researcher Explica el concepto de PersistentVolume y PersistentVolumeClaim
/k8s-researcher ¿Qué cambió en el scheduler de Kubernetes en la versión 1.30?
/k8s-researcher Guía práctica para configurar NetworkPolicies
```
