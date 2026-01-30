import 'package:sajilo_baas/core/api/api_client.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import '../../models/profile_api_model.dart';
import '../../../domain/entities/profile_entity.dart';

class ProfileRemoteDatasource {
  final ApiClient apiClient;
  ProfileRemoteDatasource(this.apiClient);

  Future<ProfileApiModel?> getCurrentUser() async {
    final response = await apiClient.get(ApiEndpoints.currentUser);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return ProfileApiModel.fromJson(response.data['user']);
    }
    return null;
  }

  Future<ProfileApiModel> updateProfile(ProfileEntity entity) async {
    final response = await apiClient.put(
      ApiEndpoints.updateProfile, // adjust to your backend route
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
  }
}
