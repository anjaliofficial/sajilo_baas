import 'package:flutter_riverpod/legacy.dart';
import '../../domain/usecases/change_password_usecase.dart';

class ChangePasswordViewModel extends StateNotifier<bool> {
  final ChangePasswordUseCase useCase;
  ChangePasswordViewModel(this.useCase) : super(false);

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final result = await useCase(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    state = result;
  }
}
