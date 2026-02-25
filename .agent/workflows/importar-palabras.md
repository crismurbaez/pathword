---
description: Cómo importar palabras desde un archivo externo (JSON o Excel)
---

Sigue estos pasos para añadir nuevo vocabulario a la base de datos de PathWord:

1. Asegúrate de que el archivo tenga el formato correcto:
   - **JSON:** Una lista de objetos con las llaves `english` y `spanish`.
   - **Excel:** Una hoja con columnas tituladas `english` y `spanish`.
2. Ejecuta la aplicación y navega a la página de **Importación**.
3. Selecciona el archivo desde tu dispositivo.
4. El sistema procesará el archivo mediante el `FileParserService`.
5. Una vez completado, verás el mensaje de éxito y las palabras estarán disponibles en el diccionario y en el tablero de investigación.

> [!NOTE]
> Las palabras duplicadas (por su ID o texto en inglés) serán ignoradas por defecto para evitar redundancia.
