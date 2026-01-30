import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/core/error/failure.dart';
import '../entities/profile_entity.dart';

abstract class IProfileRepository {
  Future<Either<Failure, ProfileEntity>> getCurrentUser();
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileEntity entity);
}
