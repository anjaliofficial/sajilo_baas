// features/auth/presentation/view_model/auth_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/auth_entity.dart';
import '../state/auth_state.dart';
import '../../../profile/presentation/providers/profile_provider.dart'
    hide apiClientProvider;

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();

  void reset() {
    state = const AuthState.initial();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String address,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    state = const AuthState.loading();

    final repo = ref.read(authRepositoryProvider);
    final authEntity = AuthEntity(
      authId: null,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      password: password,
      role: role,
      token: '', // ✅ registration doesn’t return token yet
    );

    final result = await repo.register(
      authEntity,
      confirmPassword: confirmPassword,
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) => state = const AuthState.registered(),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.login(email, password);

    if (result.isRight()) {
      final entity = result.getOrElse(() => throw Exception('Login failed'));

      // ✅ Save token securely BEFORE any API calls
      final apiClient = ref.read(apiClientProvider);
      await apiClient.saveToken(entity.token);

      state = AuthState.authenticated(entity);

      // ✅ Trigger profile fetch after login (token is already saved)
      ref.read(profileViewModelProvider.notifier).fetchProfile();
    } else {
      final failure = result.fold((f) => f, (r) => null);
      state = AuthState.error(failure?.message ?? 'Login failed');
    }
  }

  Future<void> checkSession() async {
    state = const AuthState.loading();

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.checkSession();

    if (result.isRight()) {
      final entity = result.getOrElse(() => null);
      if (entity != null) {
        state = AuthState.authenticated(entity);
        ref.read(profileViewModelProvider.notifier).fetchProfile();
      } else {
        state = const AuthState.initial();
      }
    } else {
      final failure = result.fold((f) => f, (r) => null);
      state = AuthState.error(failure?.message ?? 'Session check failed');
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.logout();

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) => state = const AuthState.loggedOut(),
    );
  }
}
