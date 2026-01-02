import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/hive_service.dart';
import '../../models/auth_hive_model.dart';
import '../auth_datasource.dart';

/// Local datasource provider
final authLocalDatasourceProvider = Provider<IAuthDatasource>((ref) {
  return AuthLocalDatasource(ref.read(hiveServiceProvider));
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService hiveService;

  AuthLocalDatasource(this.hiveService);

  @override
  Future<bool> register(AuthHiveModel model) async {
    await hiveService.registerUser(model);
    return true;
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    return hiveService.loginUser(email, password);
  }

  @override
  Future<bool> isEmailExists(String email) async {
    return hiveService.isEmailExists(email);
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    return hiveService.getCurrentUser();
  }

  @override
  Future<void> logout() async {
    await hiveService.logout();
  }
}
