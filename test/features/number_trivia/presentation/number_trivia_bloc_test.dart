import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_app/core/error/failures.dart';
import 'package:number_trivia_app/core/usecases/usecase.dart';

import 'package:number_trivia_app/core/util/input_converter.dart';
import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  // El evento toma un String
  const tNumberString = '1';
  // Esta es la salida exitosa del InputConverter
  final tNumberParsed = int.parse(tNumberString);
  // También se necesita la instancia de NumberTrivia, por supuesto
  const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

  setUpAll(() {
    registerFallbackValue(Params(number: tNumberParsed));
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  void setUpMockInputConverterSuccess() {
    when(() => mockInputConverter.stringToUnsignedInteger(any()))
        .thenReturn(Right(tNumberParsed));
  }

  void setUpMockGetConcreteNumberTriviaSuccess() {
    when(() => mockGetConcreteNumberTrivia(any()))
        .thenAnswer((_) async => const Right(tNumberTrivia));
  }

  void setUpMockGetRandomNumberTriviaSuccess() {
    when(() => mockGetRandomNumberTrivia(any()))
        .thenAnswer((_) async => const Right(tNumberTrivia));
  }

  test('initialState debe ser Empty()', () {
    // assert
    expect(bloc.initialState, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    test(
        'Debe llamar a InputConverter para validar y convertir la cadena en un entero sin signo',
        () async {
      // arrange
      setUpMockInputConverterSuccess();
      setUpMockGetConcreteNumberTriviaSuccess();

      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));

      await untilCalled(
          () => mockInputConverter.stringToUnsignedInteger(any()));

      // assert
      verify(() => mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('Debe emitir [Error] cuando la entrada no es válida', () async {
      // arrange
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Left(InvalidInputFailure()));

      final expected = [const Error(message: invalidInputFailureMessage)];

      // assert later
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test('Debe obtener datos del usecase concreto', () async {
      // arrange
      setUpMockInputConverterSuccess();
      setUpMockGetConcreteNumberTriviaSuccess();

      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(() => mockGetConcreteNumberTrivia(any()));

      // assert
      verify(() => mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    });

    test('Debe emitir [Loading, Loaded] cuando los datos se obtienen con éxito',
        () async {
      // arrange
      setUpMockInputConverterSuccess();
      setUpMockGetConcreteNumberTriviaSuccess();

      // assert later
      final expected = [Loading(), const Loaded(trivia: tNumberTrivia)];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test(
        'Debe emitir [Loading, Error] con un mensaje adecuado para el error cuando falla la obtención de datos',
        () async {
      // arrange
      setUpMockInputConverterSuccess();

      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      //assert later
      final expected = [Loading(), const Error(message: serverFailureMessage)];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test(
        'Debe emitir [Loading, Error] con un mensaje adecuado para el error cuando falla la obtención de datos',
        () async {
      // arrange
      setUpMockInputConverterSuccess();

      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Left(CacheFailure()));

      //assert later
      final expected = [Loading(), const Error(message: cacheFailureMessage)];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group('GetTriviaForRandomNumber', () {
    test('Debe obtener datos del usecase random', () async {
      // arrange
      setUpMockGetRandomNumberTriviaSuccess();

      // act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(() => mockGetRandomNumberTrivia(any()));

      // assert
      verify(() => mockGetRandomNumberTrivia(NoParams()));
    });

    test('Debe emitir [Loading, Loaded] cuando los datos se obtienen con éxito',
        () async {
      // arrange
      setUpMockGetRandomNumberTriviaSuccess();

      // assert later
      final expected = [Loading(), const Loaded(trivia: tNumberTrivia)];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(GetTriviaForRandomNumber());
    });

    test(
        'Debe emitir [Loading, Error] con un mensaje adecuado para el error cuando falla la obtención de datos',
        () async {
      // arrange
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      //assert later
      final expected = [Loading(), const Error(message: serverFailureMessage)];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(GetTriviaForRandomNumber());
    });

    test(
        'Debe emitir [Loading, Error] con un mensaje adecuado para el error cuando falla la obtención de datos',
        () async {
      // arrange
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => Left(CacheFailure()));

      //assert later
      final expected = [Loading(), const Error(message: cacheFailureMessage)];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(GetTriviaForRandomNumber());
    });
  });
}
