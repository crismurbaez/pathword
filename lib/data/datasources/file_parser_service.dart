// Note: To support Excel (.xlsx), we would need the 'excel' package.
// To support CSV, we would need the 'csv' package.
// For now, I'll implement a basic CSV parser logic or placeholders if packages aren't in pubspec.yaml.

class FileParserService {
  /// Parses a CSV string and returns a list of word data maps.
  /// Expected columns: English, Spanish, ImagePath (optional)
  List<Map<String, String>> parseCsv(String csvContent) {
    final List<Map<String, String>> words = [];
    final List<String> lines = csvContent.split('\n');

    if (lines.isEmpty) return words;

    // Assuming first line is header
    // English, Spanish, ImagePath
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = line.split(',');
      if (parts.length >= 2) {
        words.add({
          'english': parts[0].trim(),
          'spanish': parts[1].trim(),
          'image_path': parts.length > 2 ? parts[2].trim() : '',
        });
      }
    }

    return words;
  }
}
