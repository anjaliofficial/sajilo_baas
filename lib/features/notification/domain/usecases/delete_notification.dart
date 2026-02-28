import '../repositories/notification_repository.dart';

class DeleteNotification {
  final NotificationRepository repository;

  DeleteNotification(this.repository);

  Future<void> call(String id) async {
    await repository.deleteNotification(id);
  }
}
