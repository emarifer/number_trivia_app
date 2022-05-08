import 'dart:convert';

import 'package:number_trivia_app/core/error/execeptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/number_trivia_model.dart';

abstract class NumberTriviaLocalDataSource {
  /// Obtiene el [NumberTriviaModel] almacenado en caché que se obtuvo la última vez
  /// que el usuario tenía conexión a internet.
  ///
  /// Lanza [CacheException] si no hay datos almacenados en caché.
  Future<NumberTriviaModel> getLastNumberTrivia();

  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}

const cachedNumberTrivia = 'CACHED_NUMBER_TRIVIA';

class NumberTriviaLocalDataSourceImpl implements NumberTriviaLocalDataSource {
  final SharedPreferences sharedPreferences;

  NumberTriviaLocalDataSourceImpl({
    required this.sharedPreferences,
  });

  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache) async {
    sharedPreferences.setString(
      cachedNumberTrivia,
      json.encode(
        triviaToCache.toJson(),
      ),
    );
  }

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() {
    final jsonString = sharedPreferences.getString(cachedNumberTrivia);

    // Future que se completa inmediatamente
    // return Future.value(NumberTriviaModel.fromJson(json.decode(jsonString!)));
    if (jsonString == null) {
      throw CacheException();
    } else {
      return Future.value(NumberTriviaModel.fromJson(json.decode(jsonString)));
    }
  }
}
