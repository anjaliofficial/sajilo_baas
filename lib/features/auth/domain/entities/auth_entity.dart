class AuthEntity {
  final String authId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String password;
  final String role; // customer / host

  AuthEntity({
    required this.authId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.password,
    required this.role,
  });
}
