// domain/repositories/notification_repository.dart
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> sendDeviceToken(String token);
  Future<void> deleteNotification(String id);
}
