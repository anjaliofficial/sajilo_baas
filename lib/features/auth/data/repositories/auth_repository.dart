import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/features/auth/data/datasources/auth_datasource.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../models/auth_hive_model.dart';

/// Repository provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authLocalDatasourceProvider));
});

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      await datasource.register(AuthHiveModel.fromEntity(entity));
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    final model = await datasource.login(email, password);
    if (model == null) {
      return Left(LocalDatabaseFailure(message: "Invalid credentials"));
    }
    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, AuthEntity?>> checkSession() async {
    final model = await datasource.getCurrentUser();
    return Right(model?.toEntity());
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    await datasource.logout();
    return const Right(true);
  }
}
