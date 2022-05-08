import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:number_trivia_app/core/usecases/usecase.dart';
import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

import 'get_random_number_trivia_test.mocks.dart';

// flutter pub run build_runner build

@GenerateMocks([NumberTriviaRepository])
void main() {
  late MockNumberTriviaRepository mockNumberTriviaRepository;
  late GetRandomNumberTrivia usecase;
  late NumberTrivia tNumberTrivia;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(repository: mockNumberTriviaRepository);
    tNumberTrivia = const NumberTrivia(number: 1, text: 'test');
  });

  test('Debe obtenerse una «curiosidad» de un número aleatorio desde el repositorio',
      () async {
    // arrange
    when(mockNumberTriviaRepository.getRandomNumberTrivia())
        .thenAnswer((_) async => Right(tNumberTrivia));
    // act
    final result = await usecase(NoParams());
    // UseCase should simply return whatever was returned from the Repository
    // assert
    expect(result, Right(tNumberTrivia));
    // Verify that the method has been called on the Repository
    verify(mockNumberTriviaRepository.getRandomNumberTrivia());
    // Only the above method should be called and nothing more.
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
