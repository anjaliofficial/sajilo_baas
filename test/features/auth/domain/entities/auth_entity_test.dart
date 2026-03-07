import 'package:flutter_test/flutter_test.dart';
import 'package:sajilo_baas/features/auth/domain/entities/auth_entity.dart';

void main() {
  group('AuthEntity', () {
    test('constructor assigns values', () {
      const entity = AuthEntity(
        authId: '1',
        fullName: 'Ram',
        email: 'ram@test.com',
        phoneNumber: '9800000000',
        address: 'Kathmandu',
        password: '123456',
        role: 'user',
        token: 'token123',
      );
      expect(entity.authId, '1');
      expect(entity.fullName, 'Ram');
      expect(entity.email, 'ram@test.com');
      expect(entity.phoneNumber, '9800000000');
      expect(entity.address, 'Kathmandu');
      expect(entity.password, '123456');
      expect(entity.role, 'user');
      expect(entity.token, 'token123');
    });

    test('copyWith returns updated entity', () {
      const entity = AuthEntity(
        authId: '1',
        fullName: 'Ram',
        email: 'ram@test.com',
        phoneNumber: '9800000000',
        address: 'Kathmandu',
        password: '123456',
        role: 'user',
        token: 'token123',
      );
      final updated = entity.copyWith(fullName: 'Sita', email: 'sita@test.com');
      expect(updated.fullName, 'Sita');
      expect(updated.email, 'sita@test.com');
      expect(updated.authId, '1');
      expect(updated.token, 'token123');
    });

    test('props returns correct values', () {
      const entity = AuthEntity(
        authId: '1',
        fullName: 'Ram',
        email: 'ram@test.com',
        phoneNumber: '9800000000',
        address: 'Kathmandu',
        password: '123456',
        role: 'user',
        token: 'token123',
      );
      expect(entity.props.contains('1'), true);
      expect(entity.props.contains('Ram'), true);
      expect(entity.props.contains('ram@test.com'), true);
    });
  });
}
