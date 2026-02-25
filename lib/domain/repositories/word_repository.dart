import '../entities/word.dart';
import '../entities/anchor_group.dart';

abstract class WordRepository {
  Future<List<Word>> getWords();
  Future<List<Word>> searchWords(String query);
  Future<List<Word>> getWordsByOrder(int limit, int offset);
  Future<void> updateWordStatus({
    required int id,
    bool? isKnown,
    WordDifficulty? difficulty,
  });
  Future<void> updateWordBoardState({
    required int id,
    required bool isOnBoard,
    double? x,
    double? y,
  });
  Future<void> importWords(List<Map<String, String>> words);

  // Anchor Group methods
  Future<List<AnchorGroup>> getAnchorGroups();
  Future<void> createAnchorGroup(String detail, List<int> wordIds);
  Future<void> updateAnchorGroup(AnchorGroup group);
  Future<void> deleteAnchorGroup(int id);
  Future<void> addWordToGroup(int wordId, int groupId);
  Future<void> removeWordFromGroup(int wordId, int groupId);
}
