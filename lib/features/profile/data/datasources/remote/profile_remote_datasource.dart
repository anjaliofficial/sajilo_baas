import 'package:sajilo_baas/core/api/api_client.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import 'package:sajilo_baas/features/profile/data/models/profile_api_model.dart';

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
}
