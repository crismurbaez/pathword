import '../../domain/entities/word.dart';

class WordModel extends Word {
  const WordModel({
    super.id,
    required super.english,
    super.imagePath,
    required super.translations,
    super.isKnown = false,
    super.difficulty = WordDifficulty.medium,
    super.isOnBoard = false,
    super.x = 0,
    super.y = 0,
  });

  factory WordModel.fromMap(
    Map<String, dynamic> map,
    List<String> translations,
  ) {
    return WordModel(
      id: map['id'] as int?,
      english: map['english'] as String,
      imagePath: map['image_path'] as String?,
      translations: translations,
      isKnown: (map['is_known'] as int? ?? 0) == 1,
      difficulty: _difficultyFromInt(map['difficulty'] as int?),
      isOnBoard: (map['is_on_board'] as int? ?? 0) == 1,
      x: (map['x'] as num? ?? 0).toDouble(),
      y: (map['y'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english': english,
      'image_path': imagePath,
      'is_known': isKnown ? 1 : 0,
      'difficulty': _difficultyToInt(difficulty),
      'is_on_board': isOnBoard ? 1 : 0,
      'x': x,
      'y': y,
    };
  }

  @override
  WordModel copyWith({
    int? id,
    String? english,
    String? imagePath,
    List<String>? translations,
    bool? isKnown,
    WordDifficulty? difficulty,
    bool? isOnBoard,
    double? x,
    double? y,
  }) {
    return WordModel(
      id: id ?? this.id,
      english: english ?? this.english,
      imagePath: imagePath ?? this.imagePath,
      translations: translations ?? this.translations,
      isKnown: isKnown ?? this.isKnown,
      difficulty: difficulty ?? this.difficulty,
      isOnBoard: isOnBoard ?? this.isOnBoard,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  static WordDifficulty _difficultyFromInt(int? value) {
    switch (value) {
      case 0:
        return WordDifficulty.easy;
      case 2:
        return WordDifficulty.hard;
      case 1:
      default:
        return WordDifficulty.medium;
    }
  }

  static int _difficultyToInt(WordDifficulty difficulty) {
    switch (difficulty) {
      case WordDifficulty.easy:
        return 0;
      case WordDifficulty.medium:
        return 1;
      case WordDifficulty.hard:
        return 2;
    }
  }
}
