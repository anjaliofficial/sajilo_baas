import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository repository;
  RegisterUseCase(this.repository);

  /// Call use case with entity + confirmPassword
  Future<Either<Failure, bool>> call(
    AuthEntity entity, {
    required String confirmPassword,
  }) {
    return repository.register(entity, confirmPassword: confirmPassword);
  }
}
