import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/profile_entity.dart';
import '../repositories/i_profile_repository.dart';

class UpdateProfileUseCase {
  final IProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, ProfileEntity>> call(ProfileEntity entity) {
    return repository.updateProfile(entity);
  }
}
