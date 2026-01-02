import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository repository;
  RegisterUseCase(this.repository);

  Future<Either<Failure, bool>> call(AuthEntity entity) {
    return repository.register(entity);
  }
}
