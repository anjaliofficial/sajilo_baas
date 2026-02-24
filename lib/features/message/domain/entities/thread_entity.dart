import 'package:sajilo_baas/features/message/domain/entities/message_entity.dart';

class ThreadEntity {
  final String otherUserId;
  final String? listingId;
  final MessageEntity lastMessage;
  final int unreadCount;

  ThreadEntity({
    required this.otherUserId,
    this.listingId,
    required this.lastMessage,
    required this.unreadCount,
  });
}
