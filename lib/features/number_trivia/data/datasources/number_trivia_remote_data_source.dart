import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:number_trivia_app/core/error/execeptions.dart';

import '../models/number_trivia_model.dart';

abstract class NumberTriviaRemoteDataSource {
  /// Llama al endpoint http://numbersapi.com/{number}.
  ///
  /// Lanza una [ServerException] para todos los códigos de error.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  /// Llama al endpoint http://numbersapi.com/random.
  ///
  /// Lanza una [ServerException] para todos los códigos de error.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) =>
      _getTriviaFromUrl('http://numbersapi.com/$number');

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() =>
      _getTriviaFromUrl('http://numbersapi.com/random');

  Future<NumberTriviaModel> _getTriviaFromUrl(String url) async {
    final Uri uri = Uri.parse(url);
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return NumberTriviaModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}
