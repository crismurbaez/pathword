import '../../domain/entities/anchor_group.dart';
import '../../domain/entities/word.dart';
import '../../domain/repositories/word_repository.dart';
import '../datasources/word_local_data_source.dart';

class WordRepositoryImpl implements WordRepository {
  final WordLocalDataSource localDataSource;

  WordRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Word>> getWords() async {
    return await localDataSource.getAllWords();
  }

  @override
  Future<List<Word>> searchWords(String query) async {
    return await localDataSource.searchWords(query);
  }

  @override
  Future<List<Word>> getWordsByOrder(int limit, int offset) async {
    return await localDataSource.getWordsByOrder(limit, offset);
  }

  @override
  Future<void> updateWordStatus({
    required int id,
    bool? isKnown,
    WordDifficulty? difficulty,
  }) async {
    int? diffInt;
    if (difficulty != null) {
      switch (difficulty) {
        case WordDifficulty.easy:
          diffInt = 0;
          break;
        case WordDifficulty.medium:
          diffInt = 1;
          break;
        case WordDifficulty.hard:
          diffInt = 2;
          break;
      }
    }
    await localDataSource.updateWordStatus(
      id,
      isKnown: isKnown,
      difficulty: diffInt,
    );
  }

  @override
  Future<void> importWords(List<Map<String, String>> words) async {
    for (var wordMap in words) {
      await localDataSource.insertWord(wordMap);
    }
  }

  @override
  Future<List<AnchorGroup>> getAnchorGroups() async {
    final groupsData = await localDataSource.getAnchorGroups();
    return groupsData.map((data) {
      return AnchorGroup(
        id: data['id'] as int,
        detail: data['detail'] as String,
        wordIds: data['wordIds'] as List<int>,
        isVisible: (data['is_visible'] as int? ?? 1) == 1,
      );
    }).toList();
  }

  @override
  Future<void> createAnchorGroup(String detail, List<int> wordIds) async {
    await localDataSource.createAnchorGroup(detail, wordIds);
  }

  @override
  Future<void> updateAnchorGroup(AnchorGroup group) async {
    await localDataSource.updateAnchorGroup(
      group.id!,
      detail: group.detail,
      isVisible: group.isVisible,
    );
  }

  @override
  Future<void> deleteAnchorGroup(int id) async {
    await localDataSource.deleteAnchorGroup(id);
  }

  @override
  Future<void> addWordToGroup(int wordId, int groupId) async {
    await localDataSource.addWordToGroup(wordId, groupId);
  }

  @override
  Future<void> removeWordFromGroup(int wordId, int groupId) async {
    await localDataSource.removeWordFromGroup(wordId, groupId);
  }
}
