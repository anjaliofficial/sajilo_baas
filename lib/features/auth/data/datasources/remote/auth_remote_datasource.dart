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

  Future<bool> register(AuthApiModel model) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: model.toJson(),
      );

      print("REGISTER STATUS: ${response.statusCode}");
      print("REGISTER DATA: ${response.data}");

      // ✅ SUCCESS if backend returns 200 or 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      return false;
    } catch (e) {
      print("REGISTER ERROR: $e");
      return false;
    }
  }

  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {"email": email, "password": password},
      );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN DATA: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthApiModel.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return null;
    }
  }
}
