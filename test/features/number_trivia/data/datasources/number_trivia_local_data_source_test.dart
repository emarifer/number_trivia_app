import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_app/core/error/execeptions.dart';
import 'package:number_trivia_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedProferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDataSourceImpl dataSourceImpl;
  late MockSharedProferences mockSharedProferences;

  setUp(() {
    mockSharedProferences = MockSharedProferences();
    dataSourceImpl = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedProferences,
    );
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode(fixtureReader('trivia_cached.json')),
    );

    test(
        "Debería devolver un NumberTriviaModel de SharedPreferences cuando haya uno en el caché",
        () async {
      // arrange
      when(() => mockSharedProferences.getString(any()))
          .thenReturn(fixtureReader('trivia_cached.json'));

      // act
      final result = await dataSourceImpl.getLastNumberTrivia();

      // assert
      verify(() => mockSharedProferences.getString(cachedNumberTrivia));
      expect(result, equals(tNumberTriviaModel));
    });

    test('Debe lanzar una CacheException cuando no hay un valor en caché',
        () async {
      // arrange
      when(() => mockSharedProferences.getString(any())).thenReturn(null);

      // act
      // No llamaremos al método aquí, solo lo almacenaremos
      // dentro de una variable de llamada
      final call = dataSourceImpl.getLastNumberTrivia;

      // assert
      // La llamada al método ocurre desde una función de orden superior pasada.
      // Esto es necesario para probar si llamar a un método genera una excepción.
      // throwsA lanza la excepcion, si se produce, de forma asincrona
      expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel = NumberTriviaModel(
      number: 1,
      text: 'test trivia',
    );

    test('Debe llamar a SharedPreferences para almacenar en caché los datos',
        () async {
      // arrange
      when(() => mockSharedProferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // act
      dataSourceImpl.cacheNumberTrivia(tNumberTriviaModel);

      // assert
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());

      verify(
        () => mockSharedProferences.setString(
          cachedNumberTrivia,
          expectedJsonString,
        ),
      );
    });
  });
}
