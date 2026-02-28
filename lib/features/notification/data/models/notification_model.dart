// data/models/notification_model.dart
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.isRead,
    required super.createdAt,
    super.route,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      title: json['title'],
      body: json['body'],
      isRead: json['isRead'],
      createdAt: DateTime.parse(json['createdAt']),
      route: json['route'],
    );
  }
}
