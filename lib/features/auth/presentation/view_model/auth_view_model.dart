import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/auth_entity.dart';
import '../state/auth_state.dart';

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();

  // REGISTER
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

    // Pass entity + confirmPassword to repository
    final result = await repo.register(
      authEntity,
      confirmPassword: confirmPassword,
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) => state = const AuthState.registered(),
    );
  }

  // LOGIN
  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();

    final repo = ref.read(authRepositoryProvider);

    final result = await repo.login(email, password);

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (entity) => state = AuthState.authenticated(entity),
    );
  }
}
