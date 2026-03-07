import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sajilo_baas/features/auth/domain/entities/auth_entity.dart';
import 'package:sajilo_baas/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/core/error/failure.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  test('should return AuthEntity when fetch user profile successful', () async {
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
      () => repository.checkSession(),
    ).thenAnswer((_) async => Right(authEntity));

    final result = await repository.checkSession();

    expect(result, Right(authEntity));
    verify(() => repository.checkSession()).called(1);
  });

  test('should return Failure when fetch user profile fails', () async {
    final failure = ApiFailure(message: "Session failed");
    when(
      () => repository.checkSession(),
    ).thenAnswer((_) async => Left(failure));

    final result = await repository.checkSession();

    expect(result, Left(failure));
    verify(() => repository.checkSession()).called(1);
  });
}
