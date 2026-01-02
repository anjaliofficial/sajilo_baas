import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/features/auth/domain/repositories/auth_repository.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_entity.dart';
// import '../../domain/repository/auth_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';
// import '../data_source/local_datasource/auth_local_data_source.dart';
import '../datasources/local/auth_local_datasource.dart';
// import '../models/auth_hive_model.dart';
import '../models/user_hive_model.dart';

class AuthLocalRepository implements IAuthRepository {
  final IAuthLocalDataSource _authLocalDataSource;

  AuthLocalRepository(this._authLocalDataSource);

  @override
  Future<Either<Failure, void>> registerUser(AuthEntity user) async {
    try {
      final hiveModel = AuthHiveModel.fromEntity(user);
      await _authLocalDataSource.registerUser(hiveModel);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> loginUser(
    String email,
    String password,
  ) async {
    try {
      final userModel = await _authLocalDataSource.loginUser(email, password);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(LocalFailure(message: e.toString()));
    }
  }
}
