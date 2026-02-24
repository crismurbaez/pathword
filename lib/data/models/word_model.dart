import '../../domain/entities/word.dart';

class WordModel extends Word {
  const WordModel({
    super.id,
    required super.english,
    super.imagePath,
    required super.translations,
    super.isKnown = false,
    super.difficulty = WordDifficulty.medium,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english': english,
      'image_path': imagePath,
      'is_known': isKnown ? 1 : 0,
      'difficulty': _difficultyToInt(difficulty),
    };
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
