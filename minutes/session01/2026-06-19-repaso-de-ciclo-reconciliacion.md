# Protocolo de Reunión - Grupo de Estudio de Kubernetes

**Fecha:** 2026-06-19

---

## Resumen

La reunión presentó un grupo de estudio enfocado en Kubernetes, orientado a aprender sus componentes internos, contribuir a proyectos de código abierto y construir documentación reutilizable de forma colaborativa. Victor Morales explicó que la iniciativa busca ser práctica y sostenible, combinando borradores asistidos por inteligencia artificial con revisión manual y flujos de trabajo compartidos en repositorio. El grupo revisó cómo se está organizando el material en un repositorio público y conversó sobre el uso de GitHub Pages, documentación compartida y futuros pull requests para mejorar el contenido entre todos. Una parte importante de la sesión se centró en la reconciliación de Kubernetes, el comportamiento de los controladores, la presión sobre el API server y por qué entender estos conceptos es clave para problemas operativos reales. El grupo acordó mantener un formato informal, reunirse aproximadamente una vez al mes y continuar la coordinación por Slack y el repositorio compartido.

## Participantes

- Cassandra Valadez
- Victor Morales
- Abraham Alfaro Sosa
- Ana Maria Reyna Rosas
- Antonio Hernández
- Pavel Francisco Reynoso
- Jesus Salvador Arreola Rojas
- Valeria Ramírez
- Yannick Becker Jiménez

## Temas Tratados

### Propósito del Grupo y Expectativas

Victor Morales abrió la sesión presentando el grupo como un espacio de aprendizaje colaborativo e informal, más que como un formato de exposición tradicional. El énfasis estuvo en aprender Kubernetes desde distintas perspectivas, especialmente entendiendo el código y la arquitectura detrás de la plataforma en lugar de concentrarse solo en certificaciones operativas. Las personas participantes se presentaron y compartieron su interés en Kubernetes, en la contribución a código abierto, en la preparación para certificaciones y en aprender de un grupo con perfiles diversos.

### Repositorio Compartido y Flujo de Documentación

El grupo revisó un repositorio compartido que centraliza el material de estudio. Victor explicó que los contenidos se están generando de forma pragmática usando asistencia de inteligencia artificial, fuentes oficiales y revisión manual, con el objetivo de mantener el esfuerzo realista y sostenible. El repositorio está pensado como una base de conocimiento colaborativa, y el equipo conversó sobre el uso de GitHub Pages para publicar el contenido y sobre apoyarse en pull requests para mejorar secciones con el tiempo.

### Reconciliación de Kubernetes e Internos de los Controladores

La discusión técnica principal se centró en el modelo de reconciliación de Kubernetes. Victor explicó el modelo de estado deseado frente a estado actual, cómo los controladores detectan desviaciones y cómo interactúan componentes como el API server, el reflector, la cola FIFO y los controladores. También usó analogías como un termostato y el manejo de eventos en electrónica para volver más intuitivo el ciclo de reconciliación. El grupo coincidió en que la reconciliación es un concepto fundamental que vale la pena comprender a profundidad porque explica cómo Kubernetes mantiene el estado del clúster.

### Incidentes Operativos y Carga sobre el API Server

Las y los participantes compartieron experiencias prácticas relacionadas con el diseño de controladores y la saturación del API server. Un ejemplo describió latencia e inestabilidad causadas por llamadas repetidas al API cuando el caché no estaba configurado correctamente, lo que afectó pods y el comportamiento general del clúster. Otro ejemplo relató un entorno interno en Microsoft donde una actividad excesiva sobre la API provocó una sobrerreacción del controlador y una inestabilidad más amplia en la plataforma. Estos casos reforzaron por qué el comportamiento de los controladores, la estrategia de caché y los bucles de reconciliación son importantes tanto a nivel conceptual como operativo.

### Próximas Sesiones y Coordinación

El grupo discutió que las siguientes sesiones deben mantenerse casuales, basadas en conversación y colaborativas. Victor sugirió que las personas clonen el repositorio y contribuyan mejoras mediante pull requests, especialmente si desean ampliar contenidos sobre temas específicos como el API server. También se habló de crear o integrarse a un espacio de [Slack de Kubernetes](https://communityinviter.com/apps/kubernetes/community) para facilitar la coordinación entre sesiones. La cadencia prevista es de aproximadamente una sesión por mes, con el siguiente punto de contacto esperado hacia finales de julio.

## Decisiones

- **El grupo de estudio se enfocará en los internos de Kubernetes y en el entendimiento a nivel de código, no solo en el uso operativo o la preparación para certificaciones.** — _Justificación:_ El grupo tiene perfiles diversos y busca construir una comprensión más profunda y transferible explorando cómo funciona Kubernetes internamente.
- **El repositorio compartido seguirá siendo el lugar central para materiales, notas y mejoras colaborativas.** — _Justificación:_ Contar con una fuente pública y única facilita escalar la iniciativa, mantener transparencia y permitir mejoras asíncronas.
- **El grupo mantendrá un formato informal y una frecuencia aproximada mensual.** — _Justificación:_ Una cadencia ligera reduce la sobrecarga de coordinación y ayuda a que la participación sea sostenible en el tiempo.
- **Slack se usará o explorará como canal principal para la coordinación continua entre sesiones en vivo.** — _Justificación:_ El grupo necesita un canal más interactivo para conversar, compartir enlaces y mantenerse conectado entre reuniones.

## Acciones

| Tarea                                                                                                                   | Responsable       | Fecha límite                 | Prioridad |
| ----------------------------------------------------------------------------------------------------------------------- | ----------------- | ---------------------------- | --------- |
| Compartir el repositorio de estudio y los materiales de la sesión con las personas participantes después de la reunión. | Victor Morales    | abierta                      | 🟡 media  |
| Explorar o crear un canal de Slack para el grupo de estudio y compartir las instrucciones de acceso.                    | Victor Morales    | abierta                      | 🟡 media  |
| Clonar el repositorio y enviar pull requests con mejoras de contenido o ampliaciones de temas específicos.              | abierto           | abierta                      | 🟡 media  |
| Proponer temas adicionales para futuras sesiones, incluyendo mayor profundidad sobre el API server.                     | abierto           | antes de la siguiente sesión | 🟢 baja   |
| Programar o anunciar la siguiente sesión mensual, tentativamente para finales de julio.                                 | Cassandra Valadez | abierta                      | 🟡 media  |

## Preguntas Abiertas

- ¿Qué temas técnicos deben priorizarse para la siguiente sesión además de reconciliación e internos del API server?
- ¿Quién tomará responsabilidad sobre secciones específicas de documentación dentro del repositorio compartido?
