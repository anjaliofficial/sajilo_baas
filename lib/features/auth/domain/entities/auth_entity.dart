import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String password;
  final String role;
  final String token; // ✅ non-nullable

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.password,
    required this.role,
    required this.token, // ✅ required everywhere
  });

  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    phoneNumber,
    address,
    role,
    token,
  ];

  AuthEntity copyWith({
    String? authId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    String? password,
    String? role,
    String? token,
  }) {
    return AuthEntity(
      authId: authId ?? this.authId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      password: password ?? this.password,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
