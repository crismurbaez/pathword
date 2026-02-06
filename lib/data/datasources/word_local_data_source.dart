import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word_model.dart';

class WordLocalDataSource {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'pathword.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS translations');
      await db.execute('DROP TABLE IF EXISTS words');
      await _onCreate(db, newVersion);
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        english TEXT NOT NULL,
        image_path TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER NOT NULL,
        spanish TEXT NOT NULL,
        FOREIGN KEY (word_id) REFERENCES words (id) ON DELETE CASCADE
      )
    ''');

    await _seedData(db);
  }

  Future _seedData(Database db) async {
    final List<Map<String, dynamic>> wordsToSeed = [
      {
        'english': 'sock',
        'image_path': 'assets/images_words/sock.webp',
        'translations': ['calcetín', 'media'],
      },
      {
        'english': 'sour',
        'image_path': 'assets/images_words/sour.webp',
        'translations': ['agrio', 'ácido'],
      },
      {
        'english': 'spoon',
        'image_path': 'assets/images_words/spoon.webp',
        'translations': ['cuchara'],
      },
      {
        'english': 'stain',
        'image_path': 'assets/images_words/stain.webp',
        'translations': ['mancha'],
      },
      {
        'english': 'stair',
        'image_path': 'assets/images_words/stair.webp',
        'translations': ['escalón', 'escalera'],
      },
    ];

    for (var word in wordsToSeed) {
      int wordId = await db.insert('words', {
        'english': word['english'],
        'image_path': word['image_path'],
      });

      for (String translation in word['translations'] as List<String>) {
        await db.insert('translations', {
          'word_id': wordId,
          'spanish': translation,
        });
      }
    }
  }

  Future<List<WordModel>> getAllWords() async {
    final db = await database;
    final List<Map<String, dynamic>> wordMaps = await db.query('words');

    List<WordModel> words = [];
    for (var wordMap in wordMaps) {
      final List<Map<String, dynamic>> translationMaps = await db.query(
        'translations',
        where: 'word_id = ?',
        whereArgs: [wordMap['id']],
      );

      final translations = translationMaps
          .map((t) => t['spanish'] as String)
          .toList();
      words.add(WordModel.fromMap(wordMap, translations));
    }

    return words;
  }
}
