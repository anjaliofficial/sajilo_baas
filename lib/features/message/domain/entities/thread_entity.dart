import 'package:sajilo_baas/features/message/domain/entities/message_entity.dart';

class ThreadEntity {
  final String otherUserId;
  final String? listingId;
  final String? otherUserName;
  final String? otherUserImage;
  final MessageEntity lastMessage;
  final int unreadCount;

  ThreadEntity({
    required this.otherUserId,
    this.listingId,
    this.otherUserName,
    this.otherUserImage,
    required this.lastMessage,
    required this.unreadCount,
  });

  ThreadEntity copyWith({MessageEntity? lastMessage, int? unreadCount}) {
    return ThreadEntity(
      otherUserId: otherUserId,
      listingId: listingId,
      otherUserName: otherUserName,
      otherUserImage: otherUserImage,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
