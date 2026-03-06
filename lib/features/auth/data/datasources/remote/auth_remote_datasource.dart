import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/core/api/api_client.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import 'package:sajilo_baas/features/auth/data/models/auth_api_model.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class AuthRemoteDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// REGISTER
  Future<bool> register(AuthApiModel model) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: model.toJson(),
      );

      print("REGISTER STATUS: ${response.statusCode}");
      print("REGISTER DATA: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("REGISTER ERROR: $e");
      return false;
    }
  }

  /// LOGIN
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {"email": email, "password": password},
      );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN DATA: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userJson = response.data['user'] as Map<String, dynamic>;
        final token = response.data['token'] as String?;
        return AuthApiModel.fromJson(userJson).copyWith(token: token);
      }
      return null;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return null;
    }
  }

  /// CHECK SESSION (get current user)
  Future<AuthApiModel?> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.currentUser);

      print("SESSION STATUS: ${response.statusCode}");
      print("SESSION DATA: ${response.data}");

      if (response.statusCode == 200) {
        final userJson = response.data['user'] as Map<String, dynamic>;
        return AuthApiModel.fromJson(userJson);
      }
      return null;
    } catch (e) {
      print("SESSION ERROR: $e");
      return null;
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.logout);

      print("LOGOUT STATUS: ${response.statusCode}");

      // Handle 404 gracefully - backend might not have logout endpoint
      if (response.statusCode == 404) {
        print(
          "LOGOUT: Backend endpoint not found, continuing with local logout",
        );
        return;
      }

      print("LOGOUT DATA: ${response.data}");
    } catch (e) {
      print("LOGOUT ERROR: $e");
      // Don't throw - allow local logout to proceed
    }
  }
}
