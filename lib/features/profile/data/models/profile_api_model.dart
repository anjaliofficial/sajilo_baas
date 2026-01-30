import '../../domain/entities/profile_entity.dart';

class ProfileApiModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String role;
  final String? profilePicture;

  ProfileApiModel({
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
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? '',
      profilePicture: json['profilePicture'],
    );
  }

  ProfileEntity toEntity() => ProfileEntity(
    id: id,
    fullName: fullName,
    email: email,
    phoneNumber: phoneNumber,
    address: address,
    role: role,
    profilePicture: profilePicture,
  );
}
