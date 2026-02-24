# Estrategia de Aprendizaje de Inglés Personalizada: "English Case"

Esta estrategia se fundamenta en la **codificación elaborativa**, un principio de la psicología cognitiva que establece que recordamos mejor la información nueva cuando la "anclamos" a conocimientos previos. A continuación, se detalla la propuesta de **Redes de Anclaje Personalizadas** para el juego.

## 1. El Concepto: "The Anchor Map" (Mapa de Anclajes)

En lugar de una simple lista de vocabulario, cada jugador construye su propio "bosque" de conexiones. Cuando el sistema presenta una palabra nueva, se abre un **Slot de Anclaje**.

### Tipos de Anclajes
El jugador decide cómo "atar" la palabra nueva seleccionando una de estas categorías:

* **Anclaje Fonético (Suena como...):** Ej. *"Subway"* me suena a *"Subir"*. Asociación: *Subir al Subway*.
* **Anclaje Visual (Se parece a...):** Ej. La palabra *"Eye"* (ojo) parece una cara con dos ojos y una nariz en medio.
* **Anclaje de Experiencia (Me recuerda a...):** Ej. *"Blue"* me recuerda a la camiseta de mi equipo favorito.
* **Anclaje Conceptual (Es parte de...):** Ej. *"Leaf"* (hoja) se une al concepto previo de *"Tree"* (árbol).

---

## 2. Mecánica de Juego: "The Investigation Board"

Dado que el juego tiene una temática de detective, se propone un **Tablero de Evidencias** (el clásico tablero con hilos rojos):

1. **Descubrimiento:** El detective encuentra una "pista" (la palabra *Target*).
2. **Interrogatorio:** El sistema pregunta: *“¿A qué te recuerda esta pista?”*.
3. **Conexión:** El usuario escribe o selecciona un concepto que ya domina.
4. **El Hilo Rojo:** El juego crea una línea visual en el mapa que une la palabra nueva con el conocimiento previo.

---

## 3. Sistema de Repetición Espaciada Dinámica

El objetivo es reforzar el lazo creado. Si el usuario olvida una palabra, el juego no entrega la respuesta directamente, sino que muestra su **propio anclaje**:

> "Detective, ¿no recuerdas qué es 'Subway'? Recuerda que dijiste que te sonaba a 'Subir'." 

Este proceso obliga al cerebro a recorrer el camino neuronal construido por el propio usuario, fortaleciendo la memoria a largo plazo.

---

## 4. Implementación Técnica (Flutter)

Para estructurar esto en la base de datos (SQL), cada palabra del usuario debe contar con campos específicos:

### Tabla de Progreso (Ejemplo)

| Campo | Ejemplo |
| :--- | :--- |
| **word_id** | "Bread" |
| **user_anchor** | "El olor de la panadería de mi abuela" |
| **strength** | (Nivel de memorización) |

Para la interfaz en Flutter, se sugiere utilizar un **widget de Graph** para que el usuario visualice el crecimiento de su red de conocimientos.
