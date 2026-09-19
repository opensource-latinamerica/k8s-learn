---
layout: home
okf_version: "0.2"
title: k8s-learn
nav_order: 1
---

Guía colaborativa para aprender Kubernetes estudiando su código fuente, con énfasis en el patrón de **reconciliación** y la arquitectura de los controladores integrados.

## ¿Qué encontrarás aquí?

Una ruta de aprendizaje estructurada en 4 módulos, cubriendo:

- **Módulo 1**: Fundamentos del patrón de reconciliación
  - Bucle de control, informers, listers, workqueues, utilidades de controladores

- **Módulo 2**: Controladores básicos
  - Namespace, ServiceAccount, Garbage Collection

- **Módulo 3**: Deployment a profundidad
  - Relación Deployment ↔ ReplicaSet, rollout strategies, rollback y revisiones

- **Módulo 4**: Reconciliación basada en grafo
  - GraphBuilder, ownerReferences, políticas de cascada

## Cómo usar esta documentación

1. **Comienza con [Sesión 01](./session01/)** si es tu primera vez
2. Cada módulo tiene un **README** con objetivos y mapa conceptual
3. Los artículos incluyen **diagramas interactivos** (.drawio) y conceptos clave
4. Los vínculos entre temas están claramente marcados

## Participa

Este es un grupo de estudio colaborativo. Si encuentras errores, ambigüedades o tienes mejoras, comparte tus hallazgos.

---

**Última actualización**: 2026-06-18
**Participantes iniciales**: Victor Morales, Cassandra Valadez, Luis Pineda, Abraham Alfaro
