part of 'number_trivia_bloc.dart';

@freezed
abstract class NumberTriviaState with _$NumberTriviaState {
  const factory NumberTriviaState.empty() = _Empty;
  const factory NumberTriviaState.loading() = _Loading;
  const factory NumberTriviaState.loaded({required NumberTrivia trivia}) =
      _Loaded;
  const factory NumberTriviaState.error({required String message}) = _Error;
}
