import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_api_model.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final remoteDatasource = ref.read(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(remoteDatasource);
});

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final model = AuthApiModel.fromEntity(entity);
      final success = await datasource.register(model);

      if (!success) {
        return Left(
          ApiFailure(message: "Registration failed. Please try again."),
        );
      }

      return Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final model = await datasource.login(email, password);

      if (model == null) {
        return Left(ApiFailure(message: "Invalid credentials"));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity?>> checkSession() async {
    return Right(null);
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    return Right(true);
  }
}
