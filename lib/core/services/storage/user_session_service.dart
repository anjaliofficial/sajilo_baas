import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/core/services/storage/storage_service.dart';
import 'package:sajilo_baas/features/auth/domain/entities/auth_entity.dart';

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService(storageService: ref.read(storageServiceProvider));
});

class UserSessionService {
  final StorageService _storageService;

  static const _userKey = 'current_user';
  static const _loginKey = 'is_logged_in';

  UserSessionService({required StorageService storageService})
    : _storageService = storageService;

  Future<void> saveUser(AuthEntity user) async {
    final userJson = jsonEncode({
      'authId': user.authId,
      'fullName': user.fullName,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'address': user.address,
      'role': user.role,
    });
    await _storageService.setString(_userKey, userJson);
    await _storageService.setBool(_loginKey, true);
  }

  AuthEntity? getCurrentUser() {
    final data = _storageService.getString(_userKey);
    if (data == null) return null;
    final json = jsonDecode(data);
    return AuthEntity(
      authId: json['authId'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      password: '',
      role: json['role'],
    );
  }

  bool isLoggedIn() => _storageService.getBool(_loginKey);

  Future<void> logout() async {
    await _storageService.remove(_userKey);
    await _storageService.remove(_loginKey);
  }
}
