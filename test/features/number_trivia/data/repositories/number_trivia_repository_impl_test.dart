import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_app/core/error/execeptions.dart';
import 'package:number_trivia_app/core/error/failures.dart';

import 'package:number_trivia_app/core/network/network_info.dart';
import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia_app/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';

// IMPORTANTE AQUI USAREMOS MOCKTAIL, QUE ES MAS COMODO QUE MOCKITO
// Y NO ES NECESARIO GENERAR CODIGO AUTOMATICO ANTES DE EJECUTAR EL TEST.
// VER NOTA ABAJO:

// Mockeamos las dependecuas del repositoryImpl:
class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NumberTriviaRepositoryImpl repositoryImpl;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repositoryImpl = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestOnline(Function body) {
    group('Dispostivo conectado', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestOffline(Function body) {
    group('Dispostivo desconectado', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcretNumberTrivia', () {
    // DATOS PARA LOS MOCKS Y ASERCIONES
    // Usaremos estas tres variables a lo largo de todas las pruebas
    const tNumber = 1;
    const tNumberTriviaModel =
        NumberTriviaModel(number: tNumber, text: 'test trivia');
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    // NOTA IMPORTANTE: HAY QUE IR AGREGANDO EN LOS ARRANGE
    // TODAS LA LLAMADAS QUE SE VAYAN HACIENDO EN EL PROCESO
    // ITERATIVO DE CONSTRUCCION

    test('Debe comprobar si el dispositivo está online', () async {
      //arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // Hay que llamar la DataSource Remote en el arrange si lo llama en produccion
      when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
          .thenAnswer((_) async => tNumberTriviaModel);
      // Hay que llamar la DataSource Local en el arrange si lo llama en produccion
      when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
          .thenAnswer((_) => Future<void>(() {}));
      // act
      repositoryImpl.getConcreteNumberTrivia(tNumber);
      // assert
      verify(() => mockNetworkInfo.isConnected);
      // Ha verificado que se ha llamodo a isConnected
    });

    runTestOnline(() {
      test(
          'Debe devolver datos remotos cuando la llamada a la fuente de datos remota es exitosa',
          () async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) => Future<void>(() {}));

        // act
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

        // assert
        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(const Right(tNumberTrivia)));
        // Comprueba que se ha llamdo a mockRemoteDataSource.getConcreteNumberTrivia
        // y que el resultado es el correcto
      });

      test(
          'Debe almacenar en caché los datos localmente cuando la llamada a la fuente de datos remota es exitosa',
          () async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
            .thenAnswer((_) async => tNumberTriviaModel);

        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) => Future<void>(() {}));

        // act
        await repositoryImpl.getConcreteNumberTrivia(tNumber);

        // assert
        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test(
          'Debe devolver una fallo del servidor cuando la llamada a la fuente de datos remota no tiene éxito',
          () async {
        // arrange
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
            .thenThrow(ServerException());

        // act
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

        // assert
        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    // group('Dispostivo conectado', () {
    //   setUp(() {
    //     when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    //   });
    // });

    runTestOffline(() {
      test(
          'Debe devolver los últimos datos almacenados en caché localmente cuando los datos almacenados en caché estén presentes',
          () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        // act
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test(
          'Debe devolver un CacheFailure cuando no hay datos en caché presentes',
          () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());

        // act
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });

    // group('Dispositivo desconectado', () {
    //   setUp(() {
    //     when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
    //   });
    // });
  });

  group('getRandomNumberTrivia', () {
    const tNumberTriviaModel =
        NumberTriviaModel(number: 123, text: 'test trivia');
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('Debe comprobar si el dispositivo está online', () async {
      //arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getRandomNumberTrivia())
          .thenAnswer((_) async => tNumberTriviaModel);
      when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
          .thenAnswer((_) => Future<void>(() {}));
      // act
      repositoryImpl.getRandomNumberTrivia();
      // assert
      verify(() => mockNetworkInfo.isConnected);
    });

    runTestOnline(() {
      test(
          'Debe devolver datos remotos cuando la llamada a la fuente de datos remota es exitosa',
          () async {
        // arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) => Future<void>(() {}));

        // act
        final result = await repositoryImpl.getRandomNumberTrivia();

        // assert
        verify(() => mockRemoteDataSource.getRandomNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test(
          'Debe almacenar en caché los datos localmente cuando la llamada a la fuente de datos remota es exitosa',
          () async {
        // arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) => Future<void>(() {}));

        // act
        await repositoryImpl.getRandomNumberTrivia();

        // assert
        verify(() => mockRemoteDataSource.getRandomNumberTrivia());
        verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test(
          'Debe devolver una fallo del servidor cuando la llamada a la fuente de datos remota no tiene éxito',
          () async {
        // arrange
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenThrow(ServerException());

        // act
        final result = await repositoryImpl.getRandomNumberTrivia();

        // assert
        verify(() => mockRemoteDataSource.getRandomNumberTrivia());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestOffline(() {
      test(
          'Debe devolver los últimos datos almacenados en caché localmente cuando los datos almacenados en caché estén presentes',
          () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        // act
        final result = await repositoryImpl.getRandomNumberTrivia();

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test(
          'Debe devolver un CacheFailure cuando no hay datos en caché presentes',
          () async {
        // arrange
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());

        // act
        final result = await repositoryImpl.getRandomNumberTrivia();

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });
}

/**
 * https://github.com/Abdullah104/flutter-clean-architecture
 * https://pub.dev/packages/mocktail
 * 
 * equals function. VER:
 * https://api.flutter.dev/flutter/package-matcher_matcher/equals.html
 */
