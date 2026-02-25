# Documentación Completa de PathWord 🕵️‍♂️📖

PathWord es una herramienta innovadora de aprendizaje de inglés diseñada bajo el concepto de **Gamificación de Investigación**. En lugar de aburridas listas de vocabulario, permite a los usuarios "investigar" palabras como si fueran pistas en un tablero de detective, creando redes de anclaje visuales y cognitivas.

---

## 🛠️ Arquitectura Técnica

La aplicación está construida sobre **Clean Architecture**, asegurando que la lógica de negocio esté completamente desacoplada de la interfaz y los detalles de implementación.

### Capas de la Aplicación
1.  **Dominio (`lib/domain`):** Contiene las Entidades (`Word`, `AnchorGroup`) y las definiciones de los Repositorios. Es código Dart puro sin dependencias de Flutter.
2.  **Datos (`lib/data`):** Implementa la persistencia mediante **SQLite**. Incluye los Modelos (extensión de entidades con JSON/Map) y las fuentes de datos locales.
3.  **Presentación (`lib/presentation`):** Gestión de estado mediante **flutter_bloc**.
    *   **WordBloc:** Orquestador de eventos (Cargar datos, Mover palabras, Crear hilos, Buscar).
    *   **Widgets:** Componentes personalizados como `FloatingWindow` y `RedThreadsPainter`.
4.  **Core (`lib/core`):** Servicios transversales como `AudioService` (TTS) y configuración de temas.

---

## 🏗️ El Tablero de Investigación (`Investigation Board`)

Es el corazón de PathWord. Simula una oficina de investigación donde las palabras son "evidencia".

### 1. Sistema de "Drag and Drop" (Arrastrar y Soltar)
- **Barra Lateral No Modal:** Permite abrir el inventario de palabras sin bloquear el tablero.
- **Interacción Fluida:** Las palabras se arrastran desde el menú deslizante y se posicionan libremente en el tablero. El sistema calcula la posición local exacta para persistirla.

### 2. Hilos Rojos de Conexión (`Red Threads`)
Basado en la metodología de **Redes de Anclaje**:
- **Conexión Visual:** Los usuarios pueden conectar palabras relacionadas mediante hilos rojos.
- **Interactividad:** Al tocar un hilo rojo, se detecta la colisión mediante cálculos geométricos y se abre una ventana de detalle del grupo de anclaje.
- **Pintor Personalizado:** Utiliza un `CustomPainter` optimizado que solo dibuja conexiones entre palabras presentes en el tablero.

### 3. Ventanas de Detalle Flotantes
- **Multitasking:** Se pueden abrir detalles de palabras o grupos de anclaje simultáneamente.
- **Flexibilidad:** Ventanas redimensionables con límites de seguridad para evitar errores de diseño.
- **Persistencia:** Incluyen botones de "Guardar" y "Descartar" para asegurar que las notas de memoria se guarden en la base de datos local.

---

## 📁 Gestión de Datos e Importación

PathWord facilita la alimentación de vocabulario mediante un sistema de importación robusto.

- **Formatos Soportados:** JSON y Excel (.xlsx).
- **Servicio de Parsea:** El `FileParserService` maneja la extracción de datos de forma asíncrona.
- **Base de Datos:** SQLite v3 con soporte para grupos de anclaje y relaciones de palabras.

---

## 🔊 Servicios Core

- **TTS (Text-To-Speech):** Integración con `flutter_tts` para permitir la pronunciación de cada palabra en el tablero.
- **Sistema de Temas:** Diseño oscuro y elegante inspirado en tableros de cine negro/investigación criminal.

---

## 🚀 Guía de Desarrollo

### Reglas de Oro
- **No Lógica en UI:** Todo cambio de estado debe pasar por el `WordBloc`.
- **Separación de Responsabilidades:** Nunca mezcles lógica de SQLite directamente en los Widgets.
- **Optimización de Assets:** Uso de formato **WebP** para fondos y iconos complejos para mantener la aplicación liviana.

### Cómo agregar nuevas características
1. Define la entidad en `lib/domain/entities`.
2. Crea el método en el repositorio (interface) en `lib/domain/repositories`.
3. Implementa en `lib/data/repositories` y añade el código de SQLite en `lib/data/datasources/word_local_data_source.dart`.
4. Añade el evento y la lógica en `lib/presentation/bloc/word_bloc.dart`.
5. Implementa la UI en `lib/presentation`.

---
*Ultima actualización: Febrero 2026*
