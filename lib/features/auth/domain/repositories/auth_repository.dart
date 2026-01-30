import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(
    AuthEntity entity, {
    required String confirmPassword,
  });
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity?>> checkSession();
  Future<Either<Failure, bool>> logout();
}
