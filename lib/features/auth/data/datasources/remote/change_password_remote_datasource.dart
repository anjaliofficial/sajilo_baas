import 'package:sajilo_baas/core/api/api_client.dart';

class ChangePasswordRemoteDatasource {
  final ApiClient apiClient;
  ChangePasswordRemoteDatasource(this.apiClient);

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/change-password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
