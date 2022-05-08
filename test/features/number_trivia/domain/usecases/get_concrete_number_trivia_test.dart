import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';

import 'get_concrete_number_trivia_test.mocks.dart';

// El mock de Repositoty es generado por el comando: flutter pub run build_runner build
// class MockNumberTriviaRepository extends Mock
//     implements NumberTriviaRepository {}

@GenerateMocks([NumberTriviaRepository])
void main() {
  late MockNumberTriviaRepository mockNumberTriviaRepository;
  late GetConcreteNumberTrivia usecase;
  late int tNumber;
  late NumberTrivia tNumberTrivia;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(repository: mockNumberTriviaRepository);
    tNumberTrivia = const NumberTrivia(number: 1, text: 'test');
    tNumber = 1;
  });

  test('Debe obtenerse una «curiosidad» del número dado desde el repositorio',
      () async {
    // "On the fly" implementation of the Repository using the Mockito package.
    // When getConcreteNumberTrivia is called with any argument, always answer with
    // the Right "side" of Either containing a test NumberTrivia object.
    // Valor de 1, p.ej.
    // arrange
    when(mockNumberTriviaRepository.getConcreteNumberTrivia(tNumber))
        .thenAnswer((_) async => Right(tNumberTrivia));
    // The "act" phase of the test. Call the not-yet-existent method.
    // act
    final result = await usecase(Params(number: tNumber));
    // UseCase should simply return whatever was returned from the Repository
    // assert
    expect(result, Right(tNumberTrivia));
    // Verify that the method has been called on the Repository
    verify(mockNumberTriviaRepository.getConcreteNumberTrivia(tNumber));
    // Only the above method should be called and nothing more.
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}

/**
 * PARA EL USO DE MOCKITO CON NULL SAFETY. VER: * 
 * (El video https://www.youtube.com/watch?v=lPkWX8xFthE, la respuesta de Ayush Pawar)
 * 
 * EL REPOSITORIO COMPLETO DE LA APLICACION ESTA AQUI:
 * https://github.com/ResoCoder/flutter-tdd-clean-architecture-course
 * 
 * CORRECCION DE ERRORES AL PASAR A NULL SAFETY. VER;
 * 'Null' is not a subtype of type 'Future<Either<Failure, NumberTrivia>>'. VER:
 * https://stackoverflow.com/questions/68843478/null-is-not-a-subtype-of-type-futureeitherfailure-numbertrivia
 * clean_architecture_tdd Reso Coder (Null-safety). VER:
 * https://github.com/thomasviana/clean_architecture_TDD
 * 
 * Dart: el tipo 'Null' no es un subtipo del tipo 'Future<String?>' en Mockito:
 * https://stackoverflow.com/questions/67371802/dart-type-null-is-not-a-subtype-of-type-futurestring-in-mockito
 * 
 * DOCUMENTACION DE MOCKITO (Null Safety):
 * https://github.com/dart-lang/mockito/blob/master/NULL_SAFETY_README.md#null-safety
 */
