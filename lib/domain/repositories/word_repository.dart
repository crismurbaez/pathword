import '../entities/word.dart';

abstract class WordRepository {
  Future<List<Word>> getWords();
}
