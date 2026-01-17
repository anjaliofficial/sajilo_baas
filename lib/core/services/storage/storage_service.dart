import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/core/providers/shared_pref_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Add this

/// Riverpod provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.read(
    sharedPreferencesProvider,
  ); // comes from shared_preferences_provider.dart
  return StorageService(prefs);
});

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // ======== String ========
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  // ======== Bool ========
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  bool getBool(String key) => _prefs.getBool(key) ?? false;

  // ======== Remove ========
  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> clear() => _prefs.clear();
}
