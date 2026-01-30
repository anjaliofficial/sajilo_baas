// profile/data/models/profile_api_model.dart
import '../../domain/entities/profile_entity.dart';

class ProfileApiModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String role;
  final String? profilePicture;

  const ProfileApiModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.role,
    this.profilePicture,
  });

  factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileApiModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] ?? '',
      role: json['role'] as String,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "address": address,
      "role": role,
      "profilePicture": profilePicture,
    };
  }

  /// Convert API → Domain
  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      role: role,
      profilePicture: profilePicture,
    );
  }

  /// Convert Domain → API
  factory ProfileApiModel.fromEntity(ProfileEntity entity) {
    return ProfileApiModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      role: entity.role,
      profilePicture: entity.profilePicture,
    );
  }
}
