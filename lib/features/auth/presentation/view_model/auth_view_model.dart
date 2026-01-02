import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/features/auth/presentation/providers/usecase_provider.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../state/auth_state.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel(
    ref.read(registerUseCaseProvider),
    ref.read(loginUseCaseProvider),
  );
});

class AuthViewModel extends StateNotifier<AuthState> {
  final RegisterUseCase _registerUseCase;
  final LoginUseCase _loginUseCase;

  AuthViewModel(this._registerUseCase, this._loginUseCase)
    : super(const AuthState());

  // ✅ REGISTER
  Future<void> register(AuthEntity entity) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUseCase.call(entity);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  // ✅ LOGIN
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUseCase.call(email, password);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (entity) => state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: entity,
      ),
    );
  }
}
