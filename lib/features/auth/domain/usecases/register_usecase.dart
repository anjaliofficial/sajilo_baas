import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/core/error/failure.dart';
import 'package:sajilo_baas/core/usecases/usecase.dart';
import 'package:sajilo_baas/features/auth/domain/entities/auth_entity.dart';
import 'package:sajilo_baas/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase implements UsecaseWithParams<void, AuthEntity> {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AuthEntity params) {
    return repository.registerUser(params);
  }
}
