import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/core/error/failure.dart';
// import 'package:sajilo_baas/core/usecases/usecase.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:sajilo_baas/features/auth/domain/entities/auth_entity.dart';
import 'package:sajilo_baas/features/auth/domain/repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

class LoginUseCase {
  final IAuthRepository repository;
  LoginUseCase(this.repository);

  Future<Either<Failure, AuthEntity>> call(String email, String password) {
    return repository.login(email, password);
  }
}
