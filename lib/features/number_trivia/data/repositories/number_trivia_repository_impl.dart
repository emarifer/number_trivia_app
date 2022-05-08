import 'package:dartz/dartz.dart';

import '../../../../core/error/execeptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/repositories/number_trivia_repository.dart';
import '../datasources/number_trivia_local_data_source.dart';
import '../datasources/number_trivia_remote_data_source.dart';
import '../models/number_trivia_model.dart';

// Definicion de tipo: «El tipo de una funcion que puede aceptar
// parametros o no y que retorna Future<NumberTriviaModel>». VER NOTA ABAJO.
typedef _ConcreteOrRandomChooser = Future<NumberTriviaModel> Function();

// En esta clase los comentarios corresponden al proceso TDD
class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
    int number,
  ) async {
    // Para probar que hay conexion y que devuelve lo correcto la primera vez
    // networkInfo.isConnected;
    // return Right(NumberTrivia(number: number, text: 'test trivia'));
    // final remoteTrivia = await remoteDataSource.getConcreteNumberTrivia(number);
    // Almacenamos en cache la ultima respuesta de la API
    // await localDataSource.cacheNumberTrivia(remoteTrivia);
    // return Right(remoteTrivia);
    // try {
    //   final remoteTrivia =
    //       await remoteDataSource.getConcreteNumberTrivia(number);
    //   localDataSource.cacheNumberTrivia(remoteTrivia);
    //   return Right(remoteTrivia);
    // } on ServerException {
    //   return Left(ServerFailure());
    // }

    // if (await networkInfo.isConnected) {
    //   try {
    //     final remoteTrivia =
    //         await remoteDataSource.getConcreteNumberTrivia(number);
    //     localDataSource.cacheNumberTrivia(remoteTrivia);
    //     return Right(remoteTrivia);
    //   } on ServerException {
    //     return Left(ServerFailure());
    //   }
    // } else {
    //   // final localTrivia = await localDataSource.getLastNumberTrivia();
    //   // return Right(localTrivia);
    //   try {
    //     final localTrivia = await localDataSource.getLastNumberTrivia();
    //     return Right(localTrivia);
    //   } on CacheException {
    //     return Left(CacheFailure());
    //   }
    // }
    return await _getTrivia(
      () => remoteDataSource.getConcreteNumberTrivia(number),
    );
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    // networkInfo.isConnected;
    // // return const Right(NumberTrivia(number: 123, text: 'test trivia'));
    // final remoteTrivia = await remoteDataSource.getRandomNumberTrivia();
    // await localDataSource.cacheNumberTrivia(remoteTrivia);
    // return Right(remoteTrivia);

    // try {
    //   networkInfo.isConnected;
    //   final remoteTrivia = await remoteDataSource.getRandomNumberTrivia();
    //   localDataSource.cacheNumberTrivia(remoteTrivia);
    //   return Right(remoteTrivia);
    // } on ServerException {
    //   return Left(ServerFailure());
    // }

    // if (await networkInfo.isConnected) {
    //   try {
    //     final remoteTrivia = await remoteDataSource.getRandomNumberTrivia();
    //     localDataSource.cacheNumberTrivia(remoteTrivia);
    //     return Right(remoteTrivia);
    //   } on ServerException {
    //     return Left(ServerFailure());
    //   }
    // } else {
    //   // final localTrivia = await localDataSource.getLastNumberTrivia();
    //   // return Right(localTrivia);
    //   try {
    //     final localTrivia = await localDataSource.getLastNumberTrivia();
    //     return Right(localTrivia);
    //   } on CacheException {
    //     return Left(CacheFailure());
    //   }
    // }
    return await _getTrivia(() => remoteDataSource.getRandomNumberTrivia());
  }

  Future<Either<Failure, NumberTrivia>> _getTrivia(
    _ConcreteOrRandomChooser getConcreteOrRandom,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia = await getConcreteOrRandom();
        localDataSource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia = await localDataSource.getLastNumberTrivia();
        return Right(localTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}

/**
 * ¿Qué son los typedefs de función / alias de tipo de función en Dart?. VER:
 * https://stackoverflow.com/questions/12545762/what-are-function-typedefs-function-type-aliases-in-dart
 * 
 * ¿Cómo uso Type Aliases / Typedefs (también sin función) en Dart?. VER:
 * https://stackoverflow.com/questions/66847006/how-do-i-use-type-aliases-typedefs-also-non-function-in-dart
 */
