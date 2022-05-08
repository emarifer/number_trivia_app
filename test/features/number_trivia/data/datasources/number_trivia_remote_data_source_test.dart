import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_app/core/error/execeptions.dart';

import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSourceImpl;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSourceImpl = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    final trivia = fixtureReader('trivia.json');
    const responseCode = 200;
    final response = http.Response(trivia, responseCode);

    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => response);
  }

  void setUpMockHttpClientFailure404() {
    const responseBody = 'Algo salió mal';
    const statusCode = 404;
    final response = http.Response(responseBody, statusCode);

    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => response);
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;

    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixtureReader('trivia.json')));

    test(
        'Debe realizar una solicitud GET en una URL con el número como endpoint y con el encabezado application/json',
        () async {
      // arrange
      setUpMockHttpClientSuccess200();

      // act
      dataSourceImpl.getConcreteNumberTrivia(tNumber);

      // assert
      final Uri uri = Uri.parse('http://numbersapi.com/$tNumber');
      final Map<String, String> headers = {'Content-Type': 'application/json'};

      verify(() => mockHttpClient.get(uri, headers: headers));
    });

    test(
        'Debe devolver NumberTriviaModel cuando el código de respuesta es 200 (success)',
        () async {
      // arrange
      setUpMockHttpClientSuccess200();

      // act
      final result = await dataSourceImpl.getConcreteNumberTrivia(tNumber);

      // assert
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'Debe lanzar una ServerException cuando el código de respuesta es 404 u otro',
        () async {
      // arrange
      setUpMockHttpClientFailure404();

      // act
      final call = dataSourceImpl.getConcreteNumberTrivia;

      // assert
      expect(
          () => call(tNumber), throwsA(const TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixtureReader('trivia.json')));

    test(
        'Debe realizar una solicitud GET en una URL con el endpoint «aleatorio» y con el encabezado application/json',
        () async {
      // arrange
      setUpMockHttpClientSuccess200();

      // act
      dataSourceImpl.getRandomNumberTrivia();

      // assert
      final Uri uri = Uri.parse('http://numbersapi.com/random');
      final Map<String, String> headers = {'Content-Type': 'application/json'};

      verify(() => mockHttpClient.get(uri, headers: headers));
    });

    test(
        'Debe devolver NumberTriviaModel cuando el código de respuesta es 200 (success)',
        () async {
      // arrange
      setUpMockHttpClientSuccess200();

      // act
      final result = await dataSourceImpl.getRandomNumberTrivia();

      // assert
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'Debe lanzar una ServerException cuando el código de respuesta es 404 u otro',
        () async {
      // arrange
      setUpMockHttpClientFailure404();

      // act
      final call = dataSourceImpl.getRandomNumberTrivia;

      // assert
      expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
    });
  });
}
