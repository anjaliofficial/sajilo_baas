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
    // Set default route based on notification type or fallback to dashboard
    String? route = json['route']?.toString();
    if (route == null || route.isEmpty) {
      // Try to infer route from message or type
      final msg = (json['message'] ?? '').toString().toLowerCase();
      if (msg.contains('booking')) {
        route = '/bookings';
      } else if (msg.contains('message')) {
        route = '/messages';
      } else if (msg.contains('review')) {
        route = '/reviews';
      } else {
        route = '/dashboard';
      }
    }
    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['message'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      isRead: (json['isRead'] ?? json['read'] ?? false) as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      route: route,
    );
  }
}
