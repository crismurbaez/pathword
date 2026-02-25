# Reglas de Desarrollo de PathWord 🕵️‍♂️📜

Estas reglas deben seguirse estrictamente durante todo el desarrollo para garantizar la calidad y coherencia del proyecto.

## 1. Arquitectura y Estructura
- **Clean Architecture:** Respetar la separación en capas: `domain`, `data` y `presentation`.
- **Independencia del Dominio:** La capa de `domain` no debe depender de paquetes externos o de Flutter.
- **Single Responsibility:** Cada clase y función debe tener una única responsabilidad clara.

## 2. Desarrollo de UI (Flutter)
- **Cero Lógica en Widgets:** Los widgets solo deben encargarse de la visualización y disparar eventos al BLoC.
- **Gestión de Estado:** Usar `flutter_bloc` para todo el manejo de estado de la aplicación.
- **Temas:** Centralizar colores y estilos en `app_theme.dart`. No usar colores "hardcoded" en los widgets.
- **Optimización de Recursos:** Todas las imágenes nuevas deben estar en formato WebP para minimizar el peso de la app.

## 3. Calidad de Código (Clean Code)
- **Nombres Descriptivos:** Usar nombres claros para variables, funciones y archivos (e.g., `_buildAnchorWindow` en lugar de `_buildWindow`).
- **Análisis Estático:** Ejecutar `flutter analyze` frecuentemente y corregir todos los warnings y errores de linting.
- **Evitar Placeholders:** No usar datos falsos o placeholders permanentes; usar el sistema de assets o generación dinámica.

## 4. Persistencia y Datos
- **Versión de Base de Datos:** Mantener actualizado el esquema de SQLite y manejar migraciones si es necesario.
- **Modelos de Datos:** Separar `Entity` (Dominio) de `Model` (Data) para manejar la serialización de forma limpia.

## 5. Comunicación y Flujo
- **Aprobación del Usuario:** No realizar cambios significativos en el código sin explicar el plan y obtener aprobación previa.
- **Documentación:** Mantener `DOCUMENTACION_COMPLETA.md` actualizada al añadir nuevas características importantes.
