import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mocktail/mocktail.dart';

import 'package:number_trivia_app/core/network/network_info.dart';

class MockInternetConnectionChecker extends Mock
    implements InternetConnectionChecker {}

void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnectionChecker mockInternetConnectionChecker;

  setUp(() {
    mockInternetConnectionChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(mockInternetConnectionChecker);
  });

  group('Está conectado', () {
    test('Debe «reenviar» la llamada a InternetConnectionChecker.hasConnection',
        () async {
      // arrange
      final Future<bool> tHasConnectionFuture = Future.value(true);

      when(() => mockInternetConnectionChecker.hasConnection)
          .thenAnswer((_) => tHasConnectionFuture);

      // act
      // AVISO: NO estamos esperando el resultado
      final result = networkInfo.isConnected;

      // assert
      verify(() => mockInternetConnectionChecker.hasConnection);
      // Utilizando la igualdad referencial (predeterminada de Dart).
      // Solo las referencias al mismo objeto son iguales.
      // Es decir, misma posicion en memoria (misma referencia).
      expect(result, tHasConnectionFuture);
    });
  });
}

/**
 * NOTA IMPORTANTE: LO QUE PRETENDEMOS HACER CON ESTE TEST (DE LA METODOLOGIA TDD)
 * ES HACER QUE OCULTEMOS LA CLASE QUE MOCKEAMOS (INTERNET_CONNECTION_CHECKER) DETRAS
 * DE UNA INTERFAZ PARA QUE, SI CAMBIAMOS DE PAQUETE, NO SE VEA ALTERADO EL CODIGO.
 * POR ELLO, VAMOS BUSCANDO PROBAR EL «REENVIO»  DE LA LLAMADA A NETWORKINFO.ISCONNECTED
 * A INTERNETCONNECTIONCHECKER.HASCONNECTION
 */
