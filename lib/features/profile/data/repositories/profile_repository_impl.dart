// features/profile/data/repositories/profile_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/remote/profile_remote_datasource.dart';
import '../models/profile_hive_model.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final ProfileRemoteDatasource datasource;
  ProfileRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, ProfileEntity>> getCurrentUser() async {
    try {
      // Try local cache first
      final box = await Hive.openBox<ProfileHiveModel>('profileBox');
      final cached = box.get('user');
      if (cached != null) {
        return Right(cached.toEntity());
      }

      // Otherwise fetch from API
      final model = await datasource.getCurrentUser();
      if (model == null) {
        return Left(ApiFailure(message: "No user found"));
      }

      final entity = model.toEntity();

      // Save to Hive
      await box.put('user', ProfileHiveModel.fromEntity(entity));

      return Right(entity);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
