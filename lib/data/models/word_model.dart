import '../../domain/entities/word.dart';

class WordModel extends Word {
  const WordModel({
    int? id,
    required String english,
    required String imagePath,
    required List<String> translations,
  }) : super(
         id: id,
         english: english,
         imagePath: imagePath,
         translations: translations,
       );

  factory WordModel.fromMap(
    Map<String, dynamic> map,
    List<String> translations,
  ) {
    return WordModel(
      id: map['id'],
      english: map['english'],
      imagePath: map['image_path'],
      translations: translations,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'english': english, 'image_path': imagePath};
  }
}
