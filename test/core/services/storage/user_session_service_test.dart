import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sajilo_baas/core/services/storage/user_session_service.dart';
import 'package:sajilo_baas/core/services/storage/storage_service.dart';
import 'package:sajilo_baas/features/auth/domain/entities/auth_entity.dart';
import 'dart:convert';

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockStorageService mockStorage;
  late UserSessionService sessionService;

  setUp(() {
    mockStorage = MockStorageService();
    sessionService = UserSessionService(storageService: mockStorage);
  });

  test('saveUser stores user and login flag', () async {
    final user = AuthEntity(
      authId: '1',
      fullName: 'Ram',
      email: 'ram@test.com',
      phoneNumber: '9800000000',
      address: 'Kathmandu',
      password: '',
      role: 'user',
      token: '',
    );
    final userJson = jsonEncode({
      'authId': user.authId,
      'fullName': user.fullName,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'address': user.address,
      'role': user.role,
    });
    when(
      () => mockStorage.setString('current_user', userJson),
    ).thenAnswer((_) async {});
    when(
      () => mockStorage.setBool('is_logged_in', true),
    ).thenAnswer((_) async {});
    await sessionService.saveUser(user);
    verify(() => mockStorage.setString('current_user', userJson)).called(1);
    verify(() => mockStorage.setBool('is_logged_in', true)).called(1);
  });

  test('getCurrentUser returns user when stored', () {
    final userJson = jsonEncode({
      'authId': '1',
      'fullName': 'Ram',
      'email': 'ram@test.com',
      'phoneNumber': '9800000000',
      'address': 'Kathmandu',
      'role': 'user',
    });
    when(() => mockStorage.getString('current_user')).thenReturn(userJson);
    final user = sessionService.getCurrentUser();
    expect(user, isA<AuthEntity>());
    expect(user?.authId, '1');
    expect(user?.fullName, 'Ram');
    expect(user?.email, 'ram@test.com');
    expect(user?.phoneNumber, '9800000000');
    expect(user?.address, 'Kathmandu');
    expect(user?.role, 'user');
    verify(() => mockStorage.getString('current_user')).called(1);
  });

  test('getCurrentUser returns null when not stored', () {
    when(() => mockStorage.getString('current_user')).thenReturn(null);
    final user = sessionService.getCurrentUser();
    expect(user, isNull);
    verify(() => mockStorage.getString('current_user')).called(1);
  });

  test('isLoggedIn returns value from storage', () {
    when(() => mockStorage.getBool('is_logged_in')).thenReturn(true);
    expect(sessionService.isLoggedIn(), true);
    verify(() => mockStorage.getBool('is_logged_in')).called(1);
  });

  test('logout removes user and login flag', () async {
    when(() => mockStorage.remove('current_user')).thenAnswer((_) async {});
    when(() => mockStorage.remove('is_logged_in')).thenAnswer((_) async {});
    await sessionService.logout();
    verify(() => mockStorage.remove('current_user')).called(1);
    verify(() => mockStorage.remove('is_logged_in')).called(1);
  });
}
