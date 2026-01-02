import 'package:dartz/dartz.dart';
import '../error/failure.dart'; // Create a simple Failure class here

abstract class UsecaseWithParams<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class UsecaseWithoutParams<Type> {
  Future<Either<Failure, Type>> call();
}
