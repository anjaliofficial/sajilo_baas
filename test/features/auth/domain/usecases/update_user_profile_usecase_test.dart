import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sajilo_baas/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:sajilo_baas/features/profile/domain/entities/profile_entity.dart';
import 'package:sajilo_baas/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/core/error/failure.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late MockProfileRepository repository;
  late UpdateProfileUseCase usecase;

  setUp(() {
    repository = MockProfileRepository();
    usecase = UpdateProfileUseCase(repository);
  });

  test('should return ProfileEntity when update profile successful', () async {
    final profileEntity = ProfileEntity(
      id: "1",
      fullName: "Ram",
      email: "ram@test.com",
      phoneNumber: "9800000000",
      address: "Kathmandu",
      role: "user",
      profilePicture: "profile.jpg",
    );

    when(
      () => repository.updateProfile(profileEntity),
    ).thenAnswer((_) async => Right(profileEntity));

    final result = await usecase(profileEntity);

    expect(result, Right(profileEntity));
    verify(() => repository.updateProfile(profileEntity)).called(1);
  });

  test('should return Failure when update profile fails', () async {
    final profileEntity = ProfileEntity(
      id: "1",
      fullName: "Ram",
      email: "ram@test.com",
      phoneNumber: "9800000000",
      address: "Kathmandu",
      role: "user",
      profilePicture: "profile.jpg",
    );
    final failure = ApiFailure(message: "Update failed");

    when(
      () => repository.updateProfile(profileEntity),
    ).thenAnswer((_) async => Left(failure));

    final result = await usecase(profileEntity);

    expect(result, Left(failure));
    verify(() => repository.updateProfile(profileEntity)).called(1);
  });
}
