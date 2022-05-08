import 'package:dartz/dartz.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia_app/core/util/input_converter.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () {
    test(
        'Debe devolver un número entero cuando la cadena representa un número entero sin signo',
        () async {
      // arrange
      const str = '123';

      // act
      final result = inputConverter.stringToUnsignedInteger(str);

      // assert
      expect(result, equals(const Right(123)));
    });

    test('Debe devolver un error cuando la cadena no es un número entero',
        () async {
      // arrange
      const str = 'abc';

      // act
      final result = inputConverter.stringToUnsignedInteger(str);

      // assert
      expect(result, equals(Left(InvalidInputFailure())));
    });

    test('Deber devolver un error cuando la cadena es un entero negativo',
        () async {
      // arrange
      const str = '-123';

      // act
      final result = inputConverter.stringToUnsignedInteger(str);

      // assert
      expect(result, equals(Left(InvalidInputFailure())));
    });
  });
}
