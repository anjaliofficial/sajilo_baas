import '../../domain/entities/auth_entity.dart';

/// Enum for Auth status
enum AuthStatus { initial, loading, registered, authenticated, error }

/// State class for Auth
class AuthState {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authEntity,
    this.errorMessage,
  });

  /// CopyWith method for updating state
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
