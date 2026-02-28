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
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['message'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      isRead: (json['isRead'] ?? json['read'] ?? false) as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      route: json['route']?.toString(),
    );
  }
}
