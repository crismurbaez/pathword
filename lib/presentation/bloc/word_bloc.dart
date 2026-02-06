import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_words.dart';
import 'word_state.dart';

abstract class WordEvent extends Equatable {
  const WordEvent();
  @override
  List<Object?> get props => [];
}

class LoadWords extends WordEvent {}

class WordBloc extends Bloc<WordEvent, WordState> {
  final GetWords getWords;

  WordBloc({required this.getWords}) : super(WordInitial()) {
    on<LoadWords>((event, emit) async {
      emit(WordLoading());
      try {
        final words = await getWords();
        emit(WordLoaded(words));
      } catch (e) {
        emit(WordError(e.toString()));
      }
    });
  }
}
