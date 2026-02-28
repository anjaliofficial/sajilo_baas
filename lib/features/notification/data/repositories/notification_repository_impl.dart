import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/remote/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    return await remoteDataSource.getNotifications();
  }

  @override
  Future<void> markAsRead(String id) async {
    await remoteDataSource.markAsRead(id);
  }

  @override
  Future<void> sendDeviceToken(String token) async {
    await remoteDataSource.sendDeviceToken(token);
  }

  @override
  Future<void> deleteNotification(String id) async {
    await remoteDataSource.deleteNotification(id);
  }
}
