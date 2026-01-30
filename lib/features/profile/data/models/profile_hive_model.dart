// features/profile/data/models/profile_hive_model.dart
import 'package:hive/hive.dart';
import '../../domain/entities/profile_entity.dart';

part 'profile_hive_model.g.dart';

@HiveType(typeId: 2) // make sure typeId is unique across your app
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

  ProfileEntity toEntity() => ProfileEntity(
    id: id,
    fullName: fullName,
    email: email,
    phoneNumber: phoneNumber,
    address: address,
    role: role,
    profilePicture: profilePicture,
  );

  factory ProfileHiveModel.fromEntity(ProfileEntity entity) {
    return ProfileHiveModel(
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
