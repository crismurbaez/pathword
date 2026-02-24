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

class WordBloc extends Bloc<WordEvent, WordState> {
  final WordRepository repository;

  WordBloc({required this.repository}) : super(WordInitial()) {
    on<LoadInitialData>((event, emit) async {
      emit(WordLoading());
      try {
        final allWords = await repository.getWords();
        final sidebarWords = allWords.take(20).toList();
        final boardWords = sidebarWords.take(5).toList();
        final remainingSidebar = sidebarWords.skip(5).toList();
        final anchorGroups = await repository.getAnchorGroups();

        emit(
          WordLoaded(
            allWords: allWords,
            boardWords: boardWords,
            sidebarWords: remainingSidebar,
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

    on<MoveWordToBoard>((event, emit) {
      final currentState = state;
      if (currentState is WordLoaded) {
        if (currentState.boardWords.length >= 12) return;
        if (currentState.boardWords.any((w) => w.id == event.word.id)) return;

        final newBoard = List<Word>.from(currentState.boardWords)
          ..add(event.word);
        final newSidebar = List<Word>.from(currentState.sidebarWords)
          ..removeWhere((w) => w.id == event.word.id);

        emit(
          currentState.copyWith(boardWords: newBoard, sidebarWords: newSidebar),
        );
      }
    });

    on<RemoveWordFromBoard>((event, emit) {
      final currentState = state;
      if (currentState is WordLoaded) {
        final newBoard = List<Word>.from(currentState.boardWords)
          ..removeWhere((w) => w.id == event.word.id);
        final newSidebar = List<Word>.from(currentState.sidebarWords);
        if (!newSidebar.any((w) => w.id == event.word.id) &&
            newSidebar.length < 20) {
          newSidebar.add(event.word);
        }

        emit(
          currentState.copyWith(boardWords: newBoard, sidebarWords: newSidebar),
        );
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
