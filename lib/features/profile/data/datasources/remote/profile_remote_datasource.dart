import 'package:sajilo_baas/core/api/api_client.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import '../../models/profile_api_model.dart';
import '../../../domain/entities/profile_entity.dart';
import 'package:dio/dio.dart';

class ProfileRemoteDatasource {
  final ApiClient apiClient;
  ProfileRemoteDatasource(this.apiClient);

  /// Fetch current user profile
  Future<ProfileApiModel?> getCurrentUser() async {
    try {
      print(
        " Fetching profile from: ${ApiEndpoints.baseUrl}${ApiEndpoints.currentUser}",
      );
      final response = await apiClient.get(ApiEndpoints.currentUser);

      print("✅ Profile Response Status: ${response.statusCode}");
      print("📦 Profile Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ProfileApiModel.fromJson(response.data['user']);
      }

      print(" Profile fetch failed: ${response.statusCode} - ${response.data}");
      return null;
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['message'] ?? e.message ?? "Failed to fetch profile";
      print("🔴 Profile DioException: $errorMsg");
      print("   Status Code: ${e.response?.statusCode}");
      print("   Error: $e");
      throw Exception(errorMsg);
    } catch (e) {
      print("🔴 Profile Exception: $e");
      throw Exception("Failed to fetch profile: $e");
    }
  }

  /// Update user profile
  Future<ProfileApiModel> updateProfile(ProfileEntity entity) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.updateProfile,
        data: {
          "fullName": entity.fullName,
          "email": entity.email,
          "phoneNumber": entity.phoneNumber,
          "address": entity.address,
          "profilePicture": entity.profilePicture,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ProfileApiModel.fromJson(response.data['user']);
      } else {
        throw Exception(response.data['message'] ?? "Update failed");
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? "Update failed",
      );
    }
  }

  Future<String> uploadProfilePicture(String filePath) async {
    try {
      final form = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      final response = await apiClient.dio.post(
        ApiEndpoints.uploadFile,
        data: form,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        // Backend returns something like `/uploads/filename.jpg`
        // ✅ Use staticBaseUrl (no /api prefix) for serving files
        return "${ApiEndpoints.staticBaseUrl}${response.data['path']}";
      } else {
        throw Exception(response.data['message'] ?? "Upload failed");
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? "Upload failed",
      );
    }
  }
}
