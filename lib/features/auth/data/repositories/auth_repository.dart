import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth_api_model.dart';
import '../../../../core/error/failure.dart';

/// Riverpod provider for dependency injection
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final remoteDatasource = ref.read(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(remoteDatasource);
});

/// Implementation of IAuthRepository
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, bool>> register(
    AuthEntity entity, {
    required String confirmPassword,
  }) async {
    try {
      // Convert domain entity → API model and add confirmPassword
      final apiModel = AuthApiModel.fromEntity(
        entity,
      ).copyWith(confirmPassword: confirmPassword);

      final success = await datasource.register(apiModel);

      if (!success) {
        return Left(
          ApiFailure(message: "Registration failed. Please try again."),
        );
      }

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
    try {
      final model = await datasource.login(email, password);

      if (model == null) {
        return Left(ApiFailure(message: "Invalid credentials"));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: "Login failed: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, AuthEntity?>> checkSession() async {
    try {
      final model = await datasource.getCurrentUser();
      return Right(model?.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await datasource.logout();
      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: "Logout failed: ${e.toString()}"));
    }
  }
}
