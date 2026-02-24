import 'package:equatable/equatable.dart';
import '../../domain/entities/word.dart';
import '../../domain/entities/anchor_group.dart';

abstract class WordState extends Equatable {
  const WordState();

  @override
  List<Object?> get props => [];
}

class WordInitial extends WordState {}

class WordLoading extends WordState {}

class WordLoaded extends WordState {
  final List<Word> allWords;
  final List<Word> boardWords;
  final List<Word> sidebarWords;
  final List<Word> searchResults;
  final List<AnchorGroup> anchorGroups;
  final bool showThreads;

  const WordLoaded({
    required this.allWords,
    required this.boardWords,
    required this.sidebarWords,
    required this.anchorGroups,
    this.searchResults = const [],
    this.showThreads = true,
  });

  @override
  List<Object?> get props => [
    allWords,
    boardWords,
    sidebarWords,
    searchResults,
    anchorGroups,
    showThreads,
  ];

  WordLoaded copyWith({
    List<Word>? allWords,
    List<Word>? boardWords,
    List<Word>? sidebarWords,
    List<Word>? searchResults,
    List<AnchorGroup>? anchorGroups,
    bool? showThreads,
  }) {
    return WordLoaded(
      allWords: allWords ?? this.allWords,
      boardWords: boardWords ?? this.boardWords,
      sidebarWords: sidebarWords ?? this.sidebarWords,
      searchResults: searchResults ?? this.searchResults,
      anchorGroups: anchorGroups ?? this.anchorGroups,
      showThreads: showThreads ?? this.showThreads,
    );
  }
}

class WordError extends WordState {
  final String message;
  const WordError(this.message);

  @override
  List<Object?> get props => [message];
}
