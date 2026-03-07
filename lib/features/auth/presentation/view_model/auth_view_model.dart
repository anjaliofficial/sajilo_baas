// features/auth/presentation/view_model/auth_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/auth/domain/repositories/auth_repository.dart';
import '../../../../core/api/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/auth_entity.dart';
import '../state/auth_state.dart';
import '../../../profile/presentation/providers/profile_provider.dart'
    hide apiClientProvider;

class AuthViewModel extends Notifier<AuthState> {
  final IAuthRepository? _repoOverride;
  final bool fetchProfileAfterLogin;

  AuthViewModel([this._repoOverride, this.fetchProfileAfterLogin = true]);

  @override
  AuthState build() => const AuthState.initial();

  void reset() {
    state = const AuthState.initial();
  }

  IAuthRepository get _repo =>
      _repoOverride ?? ref.read(authRepositoryProvider);

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

    final authEntity = AuthEntity(
      authId: null,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      password: password,
      role: role,
      token: '',
    );

    final result = await _repo.register(
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
    final result = await _repo.login(email, password);
    if (result.isRight()) {
      final entity = result.getOrElse(() => throw Exception('Login failed'));
      final apiClient = ref.read(apiClientProvider);
      await apiClient.saveToken(entity.token);
      state = AuthState.authenticated(entity);
      if (fetchProfileAfterLogin) {
        ref.read(profileViewModelProvider.notifier).fetchProfile();
      }
    } else {
      final failure = result.fold((f) => f, (r) => null);
      state = AuthState.error(failure?.message ?? 'Login failed');
    }
  }

  Future<void> checkSession() async {
    state = const AuthState.loading();

    final result = await _repo.checkSession();

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
    final apiClient = ref.read(apiClientProvider);
    await apiClient.removeToken();
    final result = await _repo.logout();
    result.fold((failure) {
      state = const AuthState.loggedOut();
    }, (_) => state = const AuthState.loggedOut());
  }
}
