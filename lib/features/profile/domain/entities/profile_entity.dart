// profile/domain/entities/profile_entity.dart
class ProfileEntity {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String role;
  final String? profilePicture;

  const ProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.role,
    this.profilePicture,
  });
}
