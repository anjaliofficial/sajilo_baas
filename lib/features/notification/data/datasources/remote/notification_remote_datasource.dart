// data/datasources/remote/notification_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> sendDeviceToken(String token);
  Future<void> deleteNotification(String id);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSourceImpl(this.dio);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await dio.get('/notifications');
    return (response.data as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    await dio.patch('/notifications/$id/read');
  }

  @override
  Future<void> sendDeviceToken(String token) async {
    await dio.post('/notifications/token', data: {"token": token});
  }

  @override
  Future<void> deleteNotification(String id) async {
    await dio.delete('/notifications/$id');
  }
}
