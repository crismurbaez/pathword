# Vista General del Proyecto - PathWord

Este documento describe la arquitectura global, las tecnologías utilizadas y las decisiones de diseño del proyecto PathWord.

## 🚀 Tecnologías y Frameworks
- **Framework:** Flutter (Mobile/Web)
- **Lenguaje:** Dart
- **Base de Datos:** SQLite (`sqlite3` / `sqflite`)
- **Gestión de Estado:** BLoC (Business Logic Component)
- **Manejo de Imágenes:** WebP para alta eficiencia volumétrica.

## 🏗️ Arquitectura (Clean Architecture)
El proyecto se rige estrictamente por la arquitectura de capas, asegurando la separación de responsabilidades:

### 1. Capa de Presentación (`lib/presentation`)
- **Widgets:** Componentes visuales reutilizables.
- **Pages:** Pantallas completas de la aplicación.
- **BLoC:** Gestión del flujo de estados de la interfaz.

### 2. Capa de Dominio (`lib/domain`)
> [!NOTE]
> Es el corazón del sistema, independiente de frameworks externos.
- **Entities:** Objetos de negocio básicos (e.g., `Word`).
- **Use Cases:** Lógica de negocio específica (e.g., `GetEnglishWords`).
- **Repositories (Interfaces):** Definición de contratos para la persistencia de datos.

### 3. Capa de Datos (`lib/data`)
- **Models:** Implementaciones de entidades con lógica de serialización (JSON/Map).
- **Data Sources:** Orígenes de datos (Local SQLite, Assets).
- **Repositories (Implementaciones):** Lógica para decidir de qué fuente obtener la información.

### 4. Capa Core (`lib/core`)
- Utilidades genéricas, configuración de base de datos y constantes globales.

## 📸 Gestión de Recursos
- Las imágenes se encuentran en `assets/images_words/`.
- Se utiliza el formato **WebP** por defecto para balancear calidad visual y peso de la aplicación (~35MB proyectados para 1000 imágenes).

## 🛠️ Reglas de Oro
1. **Separación de Lógica:** No se permite lógica de base de datos o de negocio en los Widgets.
2. **Inyección de Dependencias:** Se debe propiciar un bajo acoplamiento entre capas.
3. **Optimización:** Todo recurso visual nuevo debe ser analizado para minimizar su impacto en el peso final.
