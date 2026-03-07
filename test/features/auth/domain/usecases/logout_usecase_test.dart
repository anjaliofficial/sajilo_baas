import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sajilo_baas/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/core/error/failure.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  test('should return true when logout successful', () async {
    when(() => repository.logout()).thenAnswer((_) async => Right(true));

    final result = await repository.logout();

    expect(result, Right(true));
    verify(() => repository.logout()).called(1);
  });

  test('should return Failure when logout fails', () async {
    final failure = ApiFailure(message: "Logout failed");
    when(() => repository.logout()).thenAnswer((_) async => Left(failure));

    final result = await repository.logout();

    expect(result, Left(failure));
    verify(() => repository.logout()).called(1);
  });
}
