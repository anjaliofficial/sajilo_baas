// features/auth/presentation/view_model/auth_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/auth_entity.dart';
import '../state/auth_state.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();

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

    result.fold((failure) => state = AuthState.error(failure.message), (
      entity,
    ) {
      state = AuthState.authenticated(entity);
      // ✅ Trigger profile fetch after login
      ref.read(profileViewModelProvider.notifier).fetchProfile();
    });
  }

  Future<void> checkSession() async {
    state = const AuthState.loading();

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.checkSession();

    result.fold((failure) => state = AuthState.error(failure.message), (
      entity,
    ) {
      if (entity != null) {
        state = AuthState.authenticated(entity);
        ref.read(profileViewModelProvider.notifier).fetchProfile();
      } else {
        state = const AuthState.initial();
      }
    });
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
