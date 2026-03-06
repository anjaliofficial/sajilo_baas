abstract class IChangePasswordRepository {
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
