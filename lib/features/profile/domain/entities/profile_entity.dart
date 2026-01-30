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

  // ✅ Add copyWith
  ProfileEntity copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    String? role,
    String? profilePicture,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
