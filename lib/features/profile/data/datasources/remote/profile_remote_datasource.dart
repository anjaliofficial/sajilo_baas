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
      final response = await apiClient.get(ApiEndpoints.currentUser);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ProfileApiModel.fromJson(response.data['user']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? "Failed to fetch profile",
      );
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

  /// Upload profile picture
  Future<String> uploadProfilePicture(String filePath) async {
    try {
      final response = await apiClient.uploadFile(
        ApiEndpoints.uploadFile,
        filePath,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        // Backend returns something like `/uploads/filename.jpg`
        return "${ApiEndpoints.baseUrl}${response.data['path']}";
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
