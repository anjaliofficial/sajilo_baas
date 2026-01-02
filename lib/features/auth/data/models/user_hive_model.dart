import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/hive_table_constant.dart';
import '../../domain/entities/auth_entity.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String authId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String phoneNumber;

  @HiveField(4)
  final String address;

  @HiveField(5)
  final String password;

  @HiveField(6)
  final String role;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.password,
    required this.role,
  }) : authId = authId ?? const Uuid().v4();

  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      password: entity.password,
      role: entity.role,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      password: password,
      role: role,
    );
  }
}
