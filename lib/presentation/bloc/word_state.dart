import 'package:equatable/equatable.dart';
import '../../domain/entities/word.dart';

abstract class WordState extends Equatable {
  const WordState();

  @override
  List<Object?> get props => [];
}

class WordInitial extends WordState {}

class WordLoading extends WordState {}

class WordLoaded extends WordState {
  final List<Word> words;
  const WordLoaded(this.words);

  @override
  List<Object?> get props => [words];
}

class WordError extends WordState {
  final String message;
  const WordError(this.message);

  @override
  List<Object?> get props => [message];
}
