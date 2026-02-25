import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/word.dart';
import '../../domain/entities/anchor_group.dart';
import '../../domain/repositories/word_repository.dart';
import 'word_state.dart';

abstract class WordEvent extends Equatable {
  const WordEvent();
  @override
  List<Object?> get props => [];
}

class LoadInitialData extends WordEvent {}

class SearchWords extends WordEvent {
  final String query;
  const SearchWords(this.query);
  @override
  List<Object?> get props => [query];
}

class MoveWordToBoard extends WordEvent {
  final Word word;
  const MoveWordToBoard(this.word);
  @override
  List<Object?> get props => [word];
}

class RemoveWordFromBoard extends WordEvent {
  final Word word;
  const RemoveWordFromBoard(this.word);
  @override
  List<Object?> get props => [word];
}

class ToggleThreadsVisibility extends WordEvent {}

class CreateAnchor extends WordEvent {
  final String detail;
  final List<int> wordIds;
  const CreateAnchor(this.detail, this.wordIds);
  @override
  List<Object?> get props => [detail, wordIds];
}

class UpdateAnchor extends WordEvent {
  final AnchorGroup group;
  const UpdateAnchor(this.group);
  @override
  List<Object?> get props => [group];
}

class ImportWords extends WordEvent {
  final List<Map<String, String>> words;
  const ImportWords(this.words);
  @override
  List<Object?> get props => [words];
}

class UpdateWordPosition extends WordEvent {
  final int wordId;
  final double x;
  final double y;
  const UpdateWordPosition(this.wordId, this.x, this.y);
  @override
  List<Object?> get props => [wordId, x, y];
}

class WordBloc extends Bloc<WordEvent, WordState> {
  final WordRepository repository;

  WordBloc({required this.repository}) : super(WordInitial()) {
    on<LoadInitialData>((event, emit) async {
      emit(WordLoading());
      try {
        final List<Word> allWords = await repository.getWords();

        // Populate board and sidebar based on persistence
        final List<Word> boardWords = List<Word>.from(
          allWords.where((w) => w.isOnBoard),
        );
        final List<Word> sidebarWords = List<Word>.from(
          allWords.where((w) => !w.isOnBoard),
        );

        // If board is empty (first run or reset), take some defaults and persist them
        if (boardWords.isEmpty && sidebarWords.isNotEmpty) {
          final initialSelection = sidebarWords.take(5).toList();
          for (int i = 0; i < initialSelection.length; i++) {
            final word = initialSelection[i];
            final defaultX = 100.0 + (i * 200) % 600;
            final defaultY = 100.0 + (i * 150) % 400;

            await repository.updateWordBoardState(
              id: word.id!,
              isOnBoard: true,
              x: defaultX,
              y: defaultY,
            );

            final updatedWord = word.copyWith(
              isOnBoard: true,
              x: defaultX,
              y: defaultY,
            );
            boardWords.add(updatedWord);
            sidebarWords.removeWhere((w) => w.id == word.id);
          }
        }

        final anchorGroups = await repository.getAnchorGroups();

        emit(
          WordLoaded(
            allWords: allWords,
            boardWords: boardWords,
            sidebarWords: sidebarWords,
            anchorGroups: anchorGroups,
          ),
        );
      } catch (e) {
        emit(WordError(e.toString()));
      }
    });

    on<SearchWords>((event, emit) async {
      final currentState = state;
      if (currentState is WordLoaded) {
        if (event.query.isEmpty) {
          emit(currentState.copyWith(searchResults: []));
          return;
        }
        try {
          final results = await repository.searchWords(event.query);
          emit(currentState.copyWith(searchResults: results));
        } catch (e) {
          emit(WordError(e.toString()));
        }
      }
    });

    on<MoveWordToBoard>((event, emit) async {
      final currentState = state;
      if (currentState is WordLoaded) {
        if (currentState.boardWords.length >= 24) return; // Allow more words
        if (currentState.boardWords.any((w) => w.id == event.word.id)) return;

        try {
          // Persist to DB
          await repository.updateWordBoardState(
            id: event.word.id!,
            isOnBoard: true,
            x: event.word.x,
            y: event.word.y,
          );

          final newWord = event.word.copyWith(isOnBoard: true);
          final newBoard = List<Word>.from(currentState.boardWords)
            ..add(newWord);
          final newSidebar = List<Word>.from(currentState.sidebarWords)
            ..removeWhere((w) => w.id == event.word.id);

          emit(
            currentState.copyWith(
              boardWords: newBoard,
              sidebarWords: newSidebar,
            ),
          );
        } catch (e) {
          emit(WordError(e.toString()));
        }
      }
    });

    on<RemoveWordFromBoard>((event, emit) async {
      final currentState = state;
      if (currentState is WordLoaded) {
        try {
          // Persist to DB
          await repository.updateWordBoardState(
            id: event.word.id!,
            isOnBoard: false,
          );

          final newBoard = List<Word>.from(currentState.boardWords)
            ..removeWhere((w) => w.id == event.word.id);
          final newSidebar = List<Word>.from(currentState.sidebarWords);

          final removedWord = event.word.copyWith(isOnBoard: false);
          if (!newSidebar.any((w) => w.id == event.word.id)) {
            newSidebar.add(removedWord);
          }

          emit(
            currentState.copyWith(
              boardWords: newBoard,
              sidebarWords: newSidebar,
            ),
          );
        } catch (e) {
          emit(WordError(e.toString()));
        }
      }
    });

    on<UpdateWordPosition>((event, emit) async {
      final currentState = state;
      if (currentState is WordLoaded) {
        try {
          await repository.updateWordBoardState(
            id: event.wordId,
            isOnBoard: true,
            x: event.x,
            y: event.y,
          );
          // We don't necessarily need to emit a new state here if the UI
          // is already managing the local position for smoothness.
          // But we update the internal list to keep it in sync.
          final newBoard = currentState.boardWords.map((w) {
            if (w.id == event.wordId) {
              return w.copyWith(x: event.x, y: event.y);
            }
            return w;
          }).toList();

          emit(currentState.copyWith(boardWords: newBoard));
        } catch (e) {
          // Silently handle position update errors or log them
        }
      }
    });

    on<ToggleThreadsVisibility>((event, emit) {
      final currentState = state;
      if (currentState is WordLoaded) {
        emit(currentState.copyWith(showThreads: !currentState.showThreads));
      }
    });

    on<CreateAnchor>((event, emit) async {
      final currentState = state;
      if (currentState is WordLoaded) {
        try {
          await repository.createAnchorGroup(event.detail, event.wordIds);
          final anchorGroups = await repository.getAnchorGroups();
          emit(currentState.copyWith(anchorGroups: anchorGroups));
        } catch (e) {
          emit(WordError(e.toString()));
        }
      }
    });

    on<UpdateAnchor>((event, emit) async {
      final currentState = state;
      if (currentState is WordLoaded) {
        try {
          await repository.updateAnchorGroup(event.group);
          final anchorGroups = await repository.getAnchorGroups();
          emit(currentState.copyWith(anchorGroups: anchorGroups));
        } catch (e) {
          emit(WordError(e.toString()));
        }
      }
    });

    on<ImportWords>((event, emit) async {
      final currentState = state;
      if (currentState is WordLoaded) {
        try {
          await repository.importWords(event.words);
          final allWords = await repository.getWords();
          emit(currentState.copyWith(allWords: allWords));
        } catch (e) {
          emit(WordError(e.toString()));
        }
      }
    });
  }
}
