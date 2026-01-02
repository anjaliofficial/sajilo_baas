import 'package:sajilo_baas/features/auth/data/models/auth_hive_model.dart';

abstract class IAuthDatasource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<bool> isEmailExists(String email);
  Future<AuthHiveModel?> getCurrentUser();
  Future<void> logout();
}
