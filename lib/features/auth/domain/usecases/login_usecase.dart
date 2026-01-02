import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/core/error/failure.dart';
import 'package:sajilo_baas/core/usecases/usecase.dart';
import 'package:sajilo_baas/features/auth/domain/entities/auth_entity.dart';
import 'package:sajilo_baas/features/auth/domain/repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

class LoginUseCase implements UsecaseWithParams<AuthEntity, LoginParams> {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) {
    return repository.loginUser(params.email, params.password);
  }
}
