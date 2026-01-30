import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/core/services/hive/hive_service.dart';
import 'package:sajilo_baas/features/auth/data/datasources/auth_datasource.dart';
import 'package:sajilo_baas/features/auth/data/models/auth_hive_model.dart';

/// Provider
final authLocalDatasourceProvider = Provider<IAuthDatasource>((ref) {
  return AuthLocalDatasource(hiveService: ref.read(hiveServiceProvider));
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<bool> register(AuthHiveModel model) async {
    await _hiveService.registerUser(model);
    return true;
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    return _hiveService.loginUser(email, password);
  }

  @override
  Future<bool> isEmailExists(String email) async {
    return _hiveService.isEmailExists(email);
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    return _hiveService.getCurrentUser();
  }

  @override
  Future<void> logout() async {
    await _hiveService.logout();
  }
}
