import 'package:equatable/equatable.dart';

class Word extends Equatable {
  final int? id;
  final String english;
  final String imagePath;
  final List<String> translations;

  const Word({
    this.id,
    required this.english,
    required this.imagePath,
    required this.translations,
  });

  @override
  List<Object?> get props => [id, english, imagePath, translations];
}
