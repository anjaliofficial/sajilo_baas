import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/data/models/user_hive_model.dart';
import '../constants/hive_table_constant.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapter only if not already registered
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

    // Open auth box and keep it open for the app lifecycle
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authBox);
  }

  // Helper method to get the open box safely
  Box<AuthHiveModel> _getAuthBox() {
    return Hive.box<AuthHiveModel>(HiveTableConstant.authBox);
  }

  // --- SIGNUP LOGIC ---
  Future<void> createUser(AuthHiveModel authHiveModel) async {
    var box = _getAuthBox();

    // Check if user with same email already exists
    bool exists = box.values.any((user) => user.email == authHiveModel.email);

    if (exists) {
      throw Exception("User already exists with this email");
    }

    // Use authId as the key for better retrieval
    await box.put(authHiveModel.authId, authHiveModel);
  }

  // --- LOGIN LOGIC ---
  Future<AuthHiveModel?> login(String email, String password) async {
    var box = _getAuthBox();

    try {
      // firstWhere throws a StateError if nothing is found
      return box.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      // If no user matches, we return null
      return null;
    }
  }

  // --- DELETE ALL (Useful for testing) ---
  Future<void> clearAll() async {
    var box = _getAuthBox();
    await box.clear();
  }
}
