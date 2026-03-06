import '../repositories/change_password_repository.dart';

class ChangePasswordUseCase {
  final IChangePasswordRepository repository;
  ChangePasswordUseCase(this.repository);

  Future<bool> call({
    required String oldPassword,
    required String newPassword,
  }) {
    return repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
