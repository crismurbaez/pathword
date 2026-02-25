import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/word_model.dart';

class WordLocalDataSource {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String dbDirectory;

    if (kIsWeb) {
      // For web, sqflite_common_ffi_web manages the virtual path.
      return await databaseFactory.openDatabase(
        'pathword.db',
        options: OpenDatabaseOptions(
          version: 5,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop: Support directory is more stable and private than Documents.
      final directory = await getApplicationSupportDirectory();
      dbDirectory = directory.path;
    } else {
      // Mobile: Documents directory is standard for user data persistence.
      final directory = await getApplicationDocumentsDirectory();
      dbDirectory = directory.path;
    }

    String path = join(dbDirectory, 'pathword.db');
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 5,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS translations');
      await db.execute('DROP TABLE IF EXISTS words');
      await _onCreate(db, newVersion);
    } else if (oldVersion < 3) {
      // Migrate from v2 to v3
      await db.execute(
        'ALTER TABLE words ADD COLUMN is_known INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE words ADD COLUMN difficulty INTEGER DEFAULT 1',
      );

      await db.execute('''
        CREATE TABLE anchor_groups (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          detail TEXT NOT NULL,
          is_visible INTEGER DEFAULT 1
        )
      ''');

      await db.execute('''
        CREATE TABLE word_anchor_links (
          word_id INTEGER NOT NULL,
          group_id INTEGER NOT NULL,
          PRIMARY KEY (word_id, group_id),
          FOREIGN KEY (word_id) REFERENCES words (id) ON DELETE CASCADE,
          FOREIGN KEY (group_id) REFERENCES anchor_groups (id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 5) {
      // Migrate to v5: Add board state persistence with defensive checks
      final tableInfo = await db.rawQuery('PRAGMA table_info(words)');
      final columnNames = tableInfo.map((c) => c['name'] as String).toList();

      if (!columnNames.contains('is_on_board')) {
        await db.execute(
          'ALTER TABLE words ADD COLUMN is_on_board INTEGER DEFAULT 0',
        );
      }
      if (!columnNames.contains('x')) {
        await db.execute('ALTER TABLE words ADD COLUMN x REAL DEFAULT 0');
      }
      if (!columnNames.contains('y')) {
        await db.execute('ALTER TABLE words ADD COLUMN y REAL DEFAULT 0');
      }
    }
  }

  Future _onCreate(Database db, int version) async {
    if (kDebugMode) {
      print(
        'DB: _onCreate called (New Database instance created) - version $version',
      );
    }
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        english TEXT NOT NULL,
        image_path TEXT,
        is_known INTEGER DEFAULT 0,
        difficulty INTEGER DEFAULT 1,
        is_on_board INTEGER DEFAULT 0,
        x REAL DEFAULT 0,
        y REAL DEFAULT 0
      )
    ''');
    // ... translations, anchor_groups, word_anchor_links same as before
    await db.execute('''
      CREATE TABLE translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER NOT NULL,
        spanish TEXT NOT NULL,
        FOREIGN KEY (word_id) REFERENCES words (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE anchor_groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        detail TEXT NOT NULL,
        is_visible INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE word_anchor_links (
        word_id INTEGER NOT NULL,
        group_id INTEGER NOT NULL,
        PRIMARY KEY (word_id, group_id),
        FOREIGN KEY (word_id) REFERENCES words (id) ON DELETE CASCADE,
        FOREIGN KEY (group_id) REFERENCES anchor_groups (id) ON DELETE CASCADE
      )
    ''');

    await _seedData(db);
  }

  Future _seedData(Database db) async {
    // SECURITY GUARD: Only seed if database is empty
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM words'),
    );
    if (count != null && count > 0) return;

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
        'is_known': 0,
        'difficulty': 1,
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
    return _mapWords(db, wordMaps);
  }

  Future<List<WordModel>> searchWords(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> wordMaps = await db.query(
      'words',
      where: 'english LIKE ?',
      whereArgs: ['%$query%'],
    );
    return _mapWords(db, wordMaps);
  }

  Future<List<WordModel>> getWordsByOrder(int limit, int offset) async {
    final db = await database;
    final List<Map<String, dynamic>> wordMaps = await db.query(
      'words',
      limit: limit,
      offset: offset,
      orderBy: 'id ASC',
    );
    return _mapWords(db, wordMaps);
  }

  Future<void> updateWordStatus(
    int id, {
    bool? isKnown,
    int? difficulty,
  }) async {
    final db = await database;
    final Map<String, dynamic> values = {};
    if (isKnown != null) values['is_known'] = isKnown ? 1 : 0;
    if (difficulty != null) values['difficulty'] = difficulty;

    if (values.isNotEmpty) {
      await db.update('words', values, where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> updateWordBoardState(
    int id, {
    required bool isOnBoard,
    double? x,
    double? y,
  }) async {
    final db = await database;
    final Map<String, dynamic> values = {'is_on_board': isOnBoard ? 1 : 0};
    if (x != null) values['x'] = x;
    if (y != null) values['y'] = y;

    if (kDebugMode) {
      print('DB: Updating Word $id - isOnBoard: $isOnBoard, x: $x, y: $y');
    }

    final result = await db.update(
      'words',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (kDebugMode) {
      print('DB: Update result: $result row(s) updated');
    }
  }

  Future<void> insertWord(Map<String, String> wordData) async {
    final db = await database;
    await db.transaction((txn) async {
      int wordId = await txn.insert('words', {
        'english': wordData['english'],
        'image_path': wordData['image_path'],
        'is_known': 0,
        'difficulty': 1,
      });

      if (wordData['spanish'] != null) {
        await txn.insert('translations', {
          'word_id': wordId,
          'spanish': wordData['spanish'],
        });
      }
    });
  }

  Future<List<WordModel>> _mapWords(
    Database db,
    List<Map<String, dynamic>> wordMaps,
  ) async {
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

      final word = WordModel.fromMap(wordMap, translations);
      if (kDebugMode) {
        print(
          'DB: Loaded Word ${word.english} (${word.id}) - isOnBoard: ${word.isOnBoard}, x: ${word.x}, y: ${word.y}',
        );
      }
      words.add(word);
    }
    return words;
  }

  // Anchor Groups
  Future<List<Map<String, dynamic>>> getAnchorGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> groupMaps = await db.query(
      'anchor_groups',
    );
    List<Map<String, dynamic>> groups = [];

    for (var groupMap in groupMaps) {
      final List<Map<String, dynamic>> linkMaps = await db.query(
        'word_anchor_links',
        where: 'group_id = ?',
        whereArgs: [groupMap['id']],
      );
      final wordIds = linkMaps.map((l) => l['word_id'] as int).toList();
      groups.add({...groupMap, 'wordIds': wordIds});
    }
    return groups;
  }

  Future<void> createAnchorGroup(String detail, List<int> wordIds) async {
    final db = await database;
    await db.transaction((txn) async {
      int groupId = await txn.insert('anchor_groups', {
        'detail': detail,
        'is_visible': 1,
      });

      for (var wordId in wordIds) {
        await txn.insert('word_anchor_links', {
          'word_id': wordId,
          'group_id': groupId,
        });
      }
    });
  }

  Future<void> updateAnchorGroup(
    int id, {
    String? detail,
    bool? isVisible,
  }) async {
    final db = await database;
    final Map<String, dynamic> values = {};
    if (detail != null) values['detail'] = detail;
    if (isVisible != null) values['is_visible'] = isVisible ? 1 : 0;

    if (values.isNotEmpty) {
      await db.update(
        'anchor_groups',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> deleteAnchorGroup(int id) async {
    final db = await database;
    await db.delete('anchor_groups', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addWordToGroup(int wordId, int groupId) async {
    final db = await database;
    await db.insert('word_anchor_links', {
      'word_id': wordId,
      'group_id': groupId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeWordFromGroup(int wordId, int groupId) async {
    final db = await database;
    await db.delete(
      'word_anchor_links',
      where: 'word_id = ? AND group_id = ?',
      whereArgs: [wordId, groupId],
    );
  }
}
