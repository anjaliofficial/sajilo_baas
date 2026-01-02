import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/auth/presentation/providers/usecase_provider.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUseCase _registerUseCase;
  late final LoginUseCase _loginUseCase;

  @override
  AuthState build() {
    _registerUseCase = ref.read(registerUseCaseProvider);
    _loginUseCase = ref.read(loginUseCaseProvider);
    return const AuthState(); // initial state
  }

  // REGISTER
  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String address,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final entity = AuthEntity(
      authId: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      password: password,
      role: role,
    );

    final result = await _registerUseCase(entity);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(status: AuthStatus.registered);
      },
    );
  }

  // LOGIN
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUseCase(email, password);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }
}
