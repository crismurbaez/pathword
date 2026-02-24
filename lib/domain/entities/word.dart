import 'package:equatable/equatable.dart';

enum WordDifficulty { easy, medium, hard }

class Word extends Equatable {
  final int? id;
  final String english;
  final String? imagePath;
  final List<String> translations;
  final bool isKnown;
  final WordDifficulty difficulty;

  const Word({
    this.id,
    required this.english,
    this.imagePath,
    required this.translations,
    this.isKnown = false,
    this.difficulty = WordDifficulty.medium,
  });

  @override
  List<Object?> get props => [
    id,
    english,
    imagePath,
    translations,
    isKnown,
    difficulty,
  ];

  Word copyWith({
    int? id,
    String? english,
    String? imagePath,
    List<String>? translations,
    bool? isKnown,
    WordDifficulty? difficulty,
  }) {
    return Word(
      id: id ?? this.id,
      english: english ?? this.english,
      imagePath: imagePath ?? this.imagePath,
      translations: translations ?? this.translations,
      isKnown: isKnown ?? this.isKnown,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
