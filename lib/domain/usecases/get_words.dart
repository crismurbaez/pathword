import '../entities/word.dart';
import '../repositories/word_repository.dart';

class GetWords {
  final WordRepository repository;

  GetWords(this.repository);

  Future<List<Word>> call() async {
    return await repository.getWords();
  }
}
