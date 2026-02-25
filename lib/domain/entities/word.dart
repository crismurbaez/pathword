import 'package:equatable/equatable.dart';

enum WordDifficulty { easy, medium, hard }

class Word extends Equatable {
  final int? id;
  final String english;
  final String? imagePath;
  final List<String> translations;
  final bool isKnown;
  final WordDifficulty difficulty;
  final bool isOnBoard;
  final double x;
  final double y;

  const Word({
    this.id,
    required this.english,
    this.imagePath,
    required this.translations,
    this.isKnown = false,
    this.difficulty = WordDifficulty.medium,
    this.isOnBoard = false,
    this.x = 0,
    this.y = 0,
  });

  @override
  List<Object?> get props => [
    id,
    english,
    imagePath,
    translations,
    isKnown,
    difficulty,
    isOnBoard,
    x,
    y,
  ];

  Word copyWith({
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
    return Word(
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
}
