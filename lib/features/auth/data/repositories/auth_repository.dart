import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth_api_model.dart';
import '../../../../core/error/failure.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final datasource = ref.read(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(datasource);
});

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  /// REGISTER
  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      // Convert to API model
      final apiModel = AuthApiModel.fromEntity(entity);
      // If you have confirmPassword, you can pass it here from the ViewModel
      // Example: final apiModelWithConfirm = apiModel.copyWith(confirmPassword: ...);

      final success = await datasource.register(apiModel);

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

  /// LOGIN
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

  /// SESSION CHECK
  @override
  Future<Either<Failure, AuthEntity?>> checkSession() async {
    return Right(null);
  }

  /// LOGOUT
  @override
  Future<Either<Failure, bool>> logout() async {
    return Right(true);
  }
}
