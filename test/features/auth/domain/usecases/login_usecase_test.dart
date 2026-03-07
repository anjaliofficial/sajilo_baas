import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sajilo_baas/features/auth/domain/usecases/login_usecase.dart';
import 'package:sajilo_baas/features/auth/domain/entities/auth_entity.dart';
import 'package:sajilo_baas/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/core/error/failure.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    usecase = LoginUseCase(repository);
  });

  test('should return AuthEntity when login successful', () async {
    final params = LoginParams(email: "ram@test.com", password: "123456");
    final authEntity = AuthEntity(
      authId: "1",
      fullName: "Ram",
      email: "ram@test.com",
      phoneNumber: "9800000000",
      address: "Kathmandu",
      password: "123456",
      role: "user",
      token: "token123",
    );

    when(
      () => repository.login(params.email, params.password),
    ).thenAnswer((_) async => Right(authEntity));

    final result = await usecase(params);

    expect(result, Right(authEntity));
    verify(() => repository.login(params.email, params.password)).called(1);
  });

  test('should return Failure when login fails', () async {
    final params = LoginParams(email: "ram@test.com", password: "wrong");
    final failure = ApiFailure(message: "Invalid credentials");

    when(
      () => repository.login(params.email, params.password),
    ).thenAnswer((_) async => Left(failure));

    final result = await usecase(params);

    expect(result, Left(failure));
    verify(() => repository.login(params.email, params.password)).called(1);
  });
}
