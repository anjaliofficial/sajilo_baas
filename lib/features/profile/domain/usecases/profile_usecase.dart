// profile/domain/usecases/get_profile_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/profile_entity.dart';
import '../repositories/i_profile_repository.dart';

class GetProfileUseCase {
  final IProfileRepository repository;
  GetProfileUseCase(this.repository);

  Future<Either<Failure, ProfileEntity>> call() {
    return repository.getCurrentUser();
  }
}
