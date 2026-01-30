// profile/data/models/profile_hive_model.dart
import 'package:hive/hive.dart';

part 'profile_hive_model.g.dart';

@HiveType(typeId: 1) // make sure typeId is unique across your app
class ProfileHiveModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String phoneNumber;

  @HiveField(4)
  final String address;

  @HiveField(5)
  final String role;

  @HiveField(6)
  final String? profilePicture;

  const ProfileHiveModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.role,
    this.profilePicture,
  });
}
