
# Guía: Descarga y Almacenamiento Local de Imágenes en Flutter

Esta guía describe el flujo de trabajo para descargar mazos de cartas (decks) desde **Firebase** y almacenarlos localmente para permitir el uso **offline** de la aplicación.

## 1. Arquitectura del Flujo

Para que **Pathword** sea eficiente, no guardamos los bytes de la imagen directamente en la base de datos, sino que gestionamos archivos físicos.

1. **Firebase Storage:** Almacena los archivos de imagen originales.
2. **Firestore / Realtime DB:** Almacena la `URL` de descarga de cada imagen.
3. **App Flutter:** Descarga la imagen mediante la URL y la guarda en el sistema de archivos del dispositivo.
4. **Base de Datos Local (SQLite/Hive):** Guarda la **ruta local** (`path`) absoluta o relativa hacia ese archivo.

---

## 2. Requisitos (Dependencies)

Agrega las siguientes dependencias en tu archivo `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0          # Para realizar la petición de descarga
  path_provider: ^2.1.0 # Para encontrar las carpetas seguras en Android/iOS
  path: ^1.8.3          # Para manipular rutas de archivos fácilmente

```

---

## 3. Implementación del Servicio de Descarga

Este método toma la URL de Firebase, descarga los bytes y los escribe en la carpeta de documentos de la aplicación.

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageDownloadService {
  
  Future<String> downloadAndSaveImage(String url, String fileName) async {
    try {
      // 1. Obtener la carpeta de documentos privada de la app
      final directory = await getApplicationDocumentsDirectory();
      
      // 2. Construir la ruta completa (ej: .../app_flutter/apple.png)
      final String filePath = p.join(directory.path, '$fileName.png');

      // 3. Descarga de bytes mediante HTTP
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 4. Escribir el archivo en el almacenamiento local
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        return filePath; // Retornamos la ruta para guardarla en SQL
      } else {
        throw Exception('Error en la descarga');
      }
    } catch (e) {
      print('Error en downloadAndSaveImage: $e');
      return '';
    }
  }
}

```

---

## 4. Visualización en la Interfaz (UI)

Para mostrar la imagen guardada en el disco, utilizamos el constructor `Image.file`.

```dart
// Suponiendo que 'pathFromDB' es el String que recuperaste de tu SQLite
String pathFromDB = "/data/user/0/com.tuapp.pathword/app_flutter/apple.png";

Image.file(
  File(pathFromDB),
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return const Icon(Icons.image_not_supported); // En caso de que el archivo no exista
  },
)

```

---

## 5. Ventajas para Pathword

* **Offline Ready:** El usuario puede estudiar sus palabras en inglés sin conexión a internet (ideal para cuando viajas).
* **Performance:** Cargar archivos desde el almacenamiento local es mucho más rápido que hacer peticiones de red constantes.
* **Ahorro de Datos:** Solo se consume ancho de banda una vez por cada mazo (deck) descargado.

