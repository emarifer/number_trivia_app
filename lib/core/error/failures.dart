import 'package:equatable/equatable.dart';
// import 'package:meta/meta.dart';

// @immutable
abstract class Failure extends Equatable {
  // const Failure();

  const Failure([List properties = const <dynamic>[]]);
}

// Failures generales
class ServerFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class CacheFailure extends Failure {
  @override
  List<Object?> get props => [];
}

/**
 * Falta la implementación concreta 'getter Equatable'/problema con accesorios. VER:
 * https://stackoverflow.com/questions/60701509/missing-concrete-implementation-getter-equatable-issue-with-props
 */
