import '../../domain/repositories/change_password_repository.dart';
import '../datasources/remote/change_password_remote_datasource.dart';

class ChangePasswordRepositoryImpl implements IChangePasswordRepository {
  final ChangePasswordRemoteDatasource datasource;
  ChangePasswordRepositoryImpl(this.datasource);

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return datasource.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
