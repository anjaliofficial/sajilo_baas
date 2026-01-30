import 'package:sajilo_baas/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String? password;
  final String? confirmPassword; // only for API requests
  final String role;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    this.password,
    this.confirmPassword, // optional
    required this.role,
  });

  /// Convert to JSON
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

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] as String?,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] ?? '',
      password: json['password'] as String?,
      role: json['role'] as String,
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

  /// copyWith to set confirmPassword dynamically
  AuthApiModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    String? password,
    String? confirmPassword,
    String? role,
  }) {
    return AuthApiModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      role: role ?? this.role,
    );
  }
}
