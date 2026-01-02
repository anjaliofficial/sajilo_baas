import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_entity.dart';

abstract class IAuthRepository {
  Future<Either<Failure, void>> registerUser(AuthEntity user);
  Future<Either<Failure, AuthEntity>> loginUser(String email, String password);
}
