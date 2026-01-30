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
    this.confirmPassword, // keep it optional
    required this.role,
  });

  /// Convert to JSON (for API POST/PUT)
  Map<String, dynamic> toJson() {
    final data = {
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "address": address,
      "password": password,
      "role": role,
    };

    // Only add confirmPassword if it exists
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
      // confirmPassword should never come from API response
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
      role: role, // ✅ confirmPassword is NOT stored
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
}
