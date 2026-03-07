import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sajilo_baas/features/auth/domain/entities/auth_entity.dart';
import 'package:sajilo_baas/features/auth/domain/repositories/auth_repository.dart';
import 'package:sajilo_baas/features/auth/domain/usecases/register_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/core/error/failure.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUseCase usecase;
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    usecase = RegisterUseCase(repository);
  });

  test('should return true when register successful', () async {
    final entity = AuthEntity(
      authId: "1",
      fullName: "Ram",
      email: "ram@test.com",
      phoneNumber: "9800000000",
      address: "Kathmandu",
      password: "123456",
      role: "user",
      token: "token123",
    );
    const confirmPassword = "123456";

    when(
      () => repository.register(entity, confirmPassword: confirmPassword),
    ).thenAnswer((_) async => Right(true));

    final result = await usecase.call(entity, confirmPassword: confirmPassword);

    expect(result, Right(true));
    verify(
      () => repository.register(entity, confirmPassword: confirmPassword),
    ).called(1);
  });

  test('should return Failure when register fails', () async {
    final entity = AuthEntity(
      authId: "1",
      fullName: "Ram",
      email: "ram@test.com",
      phoneNumber: "9800000000",
      address: "Kathmandu",
      password: "123456",
      role: "user",
      token: "token123",
    );
    const confirmPassword = "123456";
    final failure = ApiFailure(message: "Registration failed");

    when(
      () => repository.register(entity, confirmPassword: confirmPassword),
    ).thenAnswer((_) async => Left(failure));

    final result = await usecase.call(entity, confirmPassword: confirmPassword);

    expect(result, Left(failure));
    verify(
      () => repository.register(entity, confirmPassword: confirmPassword),
    ).called(1);
  });
}
