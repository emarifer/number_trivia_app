import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

// Los parámetros deben colocarse en un objeto contenedor para que puedan ser
// incluidos en esta definición de método de clase base abstracta.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Esto será utilizado por el código que llama al caso de uso siempre que el caso de uso
// no acepta ningún parámetro.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
