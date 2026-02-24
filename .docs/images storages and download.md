# Estrategia de Descarga Masiva (Bulk Download) para Pathword

Esta documentación detalla cómo implementar un sistema de descarga de mazos de estudio utilizando **GitHub** como servidor gratuito y almacenamiento local en el dispositivo para garantizar velocidad y uso offline.

## 1. Arquitectura del Repositorio (Servidor)

Para servir los mazos, se utiliza un repositorio de GitHub que contiene las imágenes y un archivo `index.json` que actúa como manifiesto del mazo.

**Estructura de archivos:**

```text
/pathword-data (repo)
  └── /mazo_basico
      ├── index.json
      ├── apple.png
      ├── chair.png
      └── table.png

```

### El archivo `index.json`

Este archivo es crucial porque le indica a la app exactamente qué debe descargar.

```json
{
  "deck_name": "Objetos del Hogar",
  "id": "hogar_001",
  "items": [
    {
      "word": "Table",
      "translation": "Mesa",
      "image_url": "https://raw.githubusercontent.com/usuario/repo/main/mazo_basico/table.png"
    },
    {
      "word": "Chair",
      "translation": "Silla",
      "image_url": "https://raw.githubusercontent.com/usuario/repo/main/mazo_basico/chair.png"
    }
  ]
}

```

---

## 2. Implementación de la Descarga en Bloque

El proceso consiste en descargar el JSON, recorrer la lista de items y descargar cada imagen secuencialmente antes de habilitar el mazo.

### Código en Flutter

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeckService {
  
  // Función principal para descargar y registrar el mazo
  Future<void> syncFullDeck(String urlJson) async {
    try {
      // 1. Obtener el manifiesto del mazo
      final response = await http.get(Uri.parse(urlJson));
      final Map<String, dynamic> mazoData = jsonDecode(response.body);
      List items = mazoData['items'];

      // 2. Procesar cada palabra/imagen
      for (var item in items) {
        String urlImagen = item['image_url'];
        String word = item['word'];

        // 3. Descargar y guardar imagen físicamente (usa la función previa)
        // downloadAndSaveImage devuelve la ruta local (ej: /data/user/0/.../apple.png)
        String localPath = await downloadAndSaveImage(urlImagen, word);
        
        // 4. Persistencia en Base de Datos Local (SQLite)
        await db.insert('vocabulary', {
          'term': word,
          'translation': item['translation'],
          'local_path': localPath,
          'deck_id': mazoData['id']
        });
      }
      print("Sincronización de mazo completa.");
    } catch (e) {
      print("Error en la sincronización: $e");
    }
  }
}

```

---

## 3. Ventajas Técnicas y Económicas

1. **Cero Costo de Infraestructura:** Al usar GitHub y el almacenamiento del dispositivo, no hay gastos de servidor.
2. **Latencia Cero (Zero Latency):** Al estar las imágenes en el almacenamiento interno, la interfaz de usuario (UI) no presenta esperas ni "shimmer effects" al navegar.
3. **Resiliencia Offline:** La aplicación es 100% funcional sin conexión una vez realizada la primera descarga.

