import '../../../../../core/services/hive_service.dart';
import '../../models/user_hive_model.dart';

abstract class IAuthLocalDataSource {
  Future<void> registerUser(AuthHiveModel user);
  Future<AuthHiveModel> loginUser(String email, String password);
}

class AuthLocalDataSource implements IAuthLocalDataSource {
  final HiveService _hiveService;

  AuthLocalDataSource(this._hiveService);

  @override
  Future<AuthHiveModel> loginUser(String email, String password) async {
    final user = await _hiveService.login(email, password);
    if (user != null) {
      return user;
    } else {
      throw Exception("Invalid email or password");
    }
  }

  @override
  Future<void> registerUser(AuthHiveModel user) async {
    return await _hiveService.createUser(user);
  }
}
