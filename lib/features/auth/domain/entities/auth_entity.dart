import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String password;
  final String role;

  AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    phoneNumber,
    address,
    password,
    role,
  ];
}
