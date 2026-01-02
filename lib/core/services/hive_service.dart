import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/data/models/user_hive_model.dart';
import '../constants/hive_table_constant.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserHiveModelAdapter());
    await Hive.openBox<UserHiveModel>(HiveTableConstant.userBox);
  }
}
