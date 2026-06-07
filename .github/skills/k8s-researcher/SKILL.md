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

| Herramienta                              | Propósito                                                                |
| ---------------------------------------- | ------------------------------------------------------------------------ |
| `mcp_codewiki-mcp_codewiki_search_repos` | Buscar repos disponibles en el servidor code-wiki                        |
| `mcp_codewiki-mcp_codewiki_fetch_repo`   | Indexar o actualizar el repo `kubernetes/website`                        |
| `mcp_codewiki-mcp_codewiki_ask_repo`     | Hacer preguntas en lenguaje natural sobre un repo indexado               |
| `mcp_github_mcp_se_search_code`          | Buscar texto/código dentro de `kubernetes/website`                       |
| `mcp_github_mcp_se_get_file_contents`    | Leer archivos concretos del repo oficial                                 |
| `fetch_webpage`                          | Obtener contenido de páginas web (kubernetes.io, pkg.go.dev, blog, KEPs) |
| `semantic_search`                        | Buscar contexto relevante en el workspace actual                         |

> **Estado del servicio code-wiki (verificado 2026-06-06):**
> `mcp_codewiki-mcp_codewiki_search_repos`, `fetch_repo` y `ask_repo`
> devuelven `RPC_FAIL: fetch failed` de forma consistente para cualquier consulta.
> El servicio está caído. Usa el **Procedimiento de fallback** directamente.

## Procedimiento

### Paso 1 — Clarificar el tema

Identifica con precisión qué se busca:

- ¿Es un concepto (Explicación), un procedimiento (Guía práctica / Tutorial) o una referencia de API?
- ¿Hay una versión específica de Kubernetes involucrada?
- ¿Se necesita un ejemplo práctico o solo la definición?

Si la solicitud es ambigua, pregunta antes de investigar.

### Paso 2 — Intentar code-wiki MCP

1. Llama a `mcp_codewiki-mcp_codewiki_search_repos` con query `"kubernetes/website"`.
2. Si responde con `RPC_FAIL` o cualquier error, **salta directamente al Paso 3 (fallback)**.
   No reintentes; el servicio no está disponible.
3. Si responde correctamente:
   - Si `kubernetes/website` no aparece, usa `mcp_codewiki-mcp_codewiki_fetch_repo`
     con `repo: "https://github.com/kubernetes/website"`.
   - Formula la pregunta en inglés con `mcp_codewiki-mcp_codewiki_ask_repo`:
     - `repo`: `"https://github.com/kubernetes/website"`
     - `question`: pregunta concreta en inglés
   - Registra las secciones y rutas de archivo que devuelva la respuesta.
   - Continúa con el Paso 3 para profundizar.

### Paso 3 — Fallback: repositorio oficial + web

Cuando code-wiki falle (o como complemento), usa estas fuentes en orden de preferencia:

#### 3a. Archivos del repo `kubernetes/website`

```
mcp_github_mcp_se_get_file_contents:
  owner: kubernetes
  repo: website
  path: content/en/docs/concepts/...   ← documentación estable
```

Usa `mcp_github_mcp_se_search_code` para localizar el archivo correcto:

```
query: "<término técnico> repo:kubernetes/website"
```

#### 3b. Documentación web oficial

```
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

## Ejemplos de uso

```
/k8s-researcher ¿Cómo funciona el garbage collection de Pods en Kubernetes?
/k8s-researcher Explica el concepto de PersistentVolume y PersistentVolumeClaim
/k8s-researcher ¿Qué cambió en el scheduler de Kubernetes en la versión 1.30?
/k8s-researcher Guía práctica para configurar NetworkPolicies
```
