import '../../domain/entities/auth_entity.dart';

enum AuthStatus { initial, loading, registered, authenticated, error }

class AuthState {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authEntity,
    this.errorMessage,
  });

  // ✨ Named constructors for easy state changes
  const AuthState.initial() : this(status: AuthStatus.initial);

  const AuthState.loading() : this(status: AuthStatus.loading);

  const AuthState.registered() : this(status: AuthStatus.registered);

  const AuthState.authenticated(AuthEntity entity)
    : this(status: AuthStatus.authenticated, authEntity: entity);

  const AuthState.error(String message)
    : this(status: AuthStatus.error, errorMessage: message);

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? authEntity,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      authEntity: authEntity ?? this.authEntity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() =>
      'AuthState(status: $status, authEntity: $authEntity, errorMessage: $errorMessage)';
}
