import 'package:sajilo_baas/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String role;
  final String? profilePicture;
  final String? password;
  final String? confirmPassword; // only for API requests
  final String? token; // JWT token from login

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.role,
    this.profilePicture,
    this.password,
    this.confirmPassword,
    this.token,
  });

  /// Convert to JSON (for register)
  Map<String, dynamic> toJson() {
    final data = {
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "address": address,
      "password": password,
      "role": role,
    };

    if (confirmPassword != null) {
      data['confirmPassword'] = confirmPassword;
    }

    return data;
  }

  /// Parse from backend response
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['id'] as String?, // backend uses "id"
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] ?? '',
      role: json['role'] as String,
      profilePicture: json['profilePicture'] as String?,
      token:
          json['token'] as String?, // optional, only present in login response
    );
  }

  /// API → Domain
  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      password: password ?? '',
      role: role,
      token: token ?? '', // ✅ fallback empty string if backend didn’t send
    );
  }

  /// Domain → API
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      password: entity.password,
      role: entity.role,
    );
  }

  /// copyWith
  AuthApiModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    String? role,
    String? profilePicture,
    String? password,
    String? confirmPassword,
    String? token,
  }) {
    return AuthApiModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      token: token ?? this.token,
    );
  }
}
