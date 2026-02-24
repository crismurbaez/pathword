import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/word_bloc.dart';
import '../../data/datasources/file_parser_service.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final TextEditingController _controller = TextEditingController();
  final FileParserService _parser = FileParserService();

  void _handleImport() {
    final csvContent = _controller.text;
    if (csvContent.isEmpty) return;

    final words = _parser.parseCsv(csvContent);
    if (words.isNotEmpty) {
      context.read<WordBloc>().add(ImportWords(words));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Imported ${words.length} words')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Words (CSV)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Paste your CSV content below.\nFormat: English, Spanish, ImagePath (optional)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'word, palabra, assets/image.webp\n...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _handleImport,
              icon: const Icon(Icons.upload_file),
              label: const Text('Import Now'),
            ),
          ],
        ),
      ),
    );
  }
}
