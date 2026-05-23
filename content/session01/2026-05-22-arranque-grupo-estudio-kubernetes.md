# Minuta de sesión (2026-05-22)

## Contexto

Sesión inicial del grupo de estudio para aprender Kubernetes a profundidad desde el código fuente, con énfasis en el patrón de reconciliación y posibles contribuciones futuras al proyecto.

## Participantes

- Victor Morales
- Cassandra Valadez
- Luis Pineda
- Abraham Alfaro

## Objetivo de la sesión

- Alinear expectativas del grupo.
- Definir una ruta de aprendizaje colaborativa.
- Identificar herramientas y dinámica de trabajo para documentar avances.

## Temas tratados

1. Experiencia previa de contribución a Kubernetes

- Se compartió un [intento previo](https://github.com/kubernetes/kubernetes/pull/112289) de mejora en pruebas unitarias para ejecución en paralelo.
- El cambio llegó a merge, pero fue revertido al detectarse dependencias y problemas de concurrencia.

2. Enfoque del grupo de estudio

- La prioridad es aprender juntos "las tripas" de Kubernetes.
- Se acuerda usar un repositorio para centralizar minutas, hallazgos y material técnico.
- Se enfatiza el uso de IA como apoyo de aprendizaje, no para atajos.

3. Posibles líneas técnicas de investigación

- Flujo de API y ciclo de reconciliación.
- Rol de cachés locales y su impacto en rendimiento.
- Exploración conceptual de mejoras de inteligencia en reconciliación (idea inicial, sujeta a investigación).

4. Herramientas y entorno

- Se intentó usar un servicio MCP ([Open Aware](https://github.com/qodo-ai/open-aware)), pero estuvo caído.
- Se revisó alternativa con [DevContainers](https://containers.dev/)/[Codespaces](https://github.com/codespaces/) para evitar dependencias fuertes en máquinas locales.
- Se recordó apagar/eliminar recursos remotos para no consumir cuotas gratuitas.

## Decisiones y acuerdos

- Mantener un plan de estudio por fases y desglosarlo en temas más pequeños.
- Documentar el material de forma colaborativa en el repositorio.
- Iniciar con fundamentos de reconciliación y flujo API/controladores.
- Considerar sesiones mensuales como base y, si el ritmo lo permite, pasar a quincenales.
- Promover trabajo offline entre sesiones para llegar con dudas y hallazgos concretos.

## Tareas

- Cada participante:
  - Investigar la primera fase (fundamentos del patrón de reconciliación).
  - Subir recursos útiles (diagramas, notas, referencias) al repositorio.
  - Registrar dudas puntuales para discusión grupal.
- Facilitación:
  - Publicar esta minuta y el plan general.
  - Intentar nuevamente la integración MCP en la próxima sesión.

## Riesgos identificados

- Dependencia de servicios externos (MCP caído).
- Pérdida de continuidad si hay demasiado tiempo entre sesiones.
- Curva de aprendizaje alta en componentes internos de Kubernetes.

## Próxima sesión

- Tentativa: próximo mes.
- Meta: revisar avances de la fase 1 y consolidar preguntas técnicas para profundizar.
