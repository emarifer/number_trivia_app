import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:number_trivia_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test Text');

  test('Debe ser una subclase de la entidad NumberTrivia', () async {
    // assert
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });

  group('fromJson', () {
    test(
        'Debe devolver un modelo válido cuando el número del JSON es un integer',
        () async {
      // arrange
      final Map<String, dynamic> jsonMap =
          json.decode(fixtureReader('trivia.json'));

      // act
      final result = NumberTriviaModel.fromJson(jsonMap);

      // assert
      expect(result, tNumberTriviaModel);
    });

    test(
        'Debe devolver un modelo válido cuando el número del JSON es un double',
        () async {
      // arrange
      final Map<String, dynamic> jsonMap =
          json.decode(fixtureReader('trivia_double.json'));

      // act
      final result = NumberTriviaModel.fromJson(jsonMap);

      // assert
      expect(result, tNumberTriviaModel);
    });
  });

  group('toJson', () {
    test('Debe devolver un mapa JSON que contiene los datos adecuados',
        () async {
          
      // act
      final result = tNumberTriviaModel.toJson();

      // assert
      final expectedMap = {
        'text': 'Test Text',
        'number': 1,
      };
      expect(result, expectedMap);
    });
  });
}
