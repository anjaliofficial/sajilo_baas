import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/core/error/failure.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthEntity>> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}
