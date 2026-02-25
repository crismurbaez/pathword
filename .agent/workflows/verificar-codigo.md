---
description: Pasos para verificar que el código cumple con los estándares del proyecto
---

Antes de realizar un commit o finalizar una tarea, realiza estas comprobaciones:

// turbo
1. Ejecuta el análisis estático para detectar lints o errores:
   ```bash
   flutter analyze
   ```
2. Asegúrate de que no haya errores de compilación para tu plataforma local:
   ```bash
   flutter build windows  # O la plataforma que estés usando
   ```
3. Verifica que la estructura de carpetas siga la **Clean Architecture**.
4. Comprueba que las imágenes añadidas estén en formato **WebP**.
5. Asegúrate de que los cambios importantes estén reflejados en `DOCUMENTACION_COMPLETA.md`.
