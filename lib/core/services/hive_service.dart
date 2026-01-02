import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/hive_table_constant.dart';
import '../../features/auth/data/models/auth_hive_model.dart';

/// Riverpod provider for HiveService
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  /// Initialize Hive
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(directory.path);

    // Register Hive adapters if not registered
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

    // Open Auth Box
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  }

  /// Auth Box getter
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  // ================================= Auth Queries ===================================

  /// Register a new user
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  /// Login user
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  /// Check if email already exists
  Future<bool> isEmailExists(String email) async {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }

  /// Get the first/current user
  Future<AuthHiveModel?> getCurrentUser() async {
    return _authBox.values.isNotEmpty ? _authBox.values.first : null;
  }

  /// Logout user (clear all)
  Future<void> logout() async {
    await _authBox.clear();
  }
}
