// profile/domain/repositories/i_profile_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/profile_entity.dart';

abstract class IProfileRepository {
  Future<Either<Failure, ProfileEntity>> getCurrentUser();

  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileEntity entity);
}
