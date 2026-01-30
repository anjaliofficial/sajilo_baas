// profile/data/repositories/profile_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/remote/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final ProfileRemoteDatasource datasource;
  ProfileRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, ProfileEntity>> getCurrentUser() async {
    try {
      final model = await datasource.getCurrentUser();
      if (model == null) {
        return Left(ApiFailure(message: "No user found"));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
