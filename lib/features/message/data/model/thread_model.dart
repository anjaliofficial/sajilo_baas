import 'package:sajilo_baas/features/message/domain/entities/thread_entity.dart';

import '../../domain/entities/message_entity.dart';

class ThreadModel {
  final String otherUserId;
  final String? listingId;
  final MessageModel lastMessage;
  final int unreadCount;

  ThreadModel({
    required this.otherUserId,
    this.listingId,
    required this.lastMessage,
    required this.unreadCount,
  });

  factory ThreadModel.fromJson(Map<String, dynamic> json) {
    return ThreadModel(
      otherUserId: json['otherUser']?['_id'] ?? '',
      listingId: json['listing'],
      unreadCount: json['unreadCount'] ?? 0,
      lastMessage: MessageModel.fromJson(json['lastMessage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otherUserId': otherUserId,
      'listingId': listingId,
      'unreadCount': unreadCount,
      'lastMessage': lastMessage.toJson(),
    };
  }

  // Convert to Entity for Domain layer
  ThreadEntity toEntity() {
    return ThreadEntity(
      otherUserId: otherUserId,
      listingId: listingId,
      unreadCount: unreadCount,
      lastMessage: lastMessage.toEntity(),
    );
  }
}

// ------------------------
// MessageModel used in ThreadModel
// ------------------------
class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? listingId;
  final String content;
  final String type;
  final bool read;
  final String status;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.listingId,
    required this.content,
    required this.type,
    required this.read,
    required this.status,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      senderId: json['sender'] ?? '',
      receiverId: json['receiver'] ?? '',
      listingId: json['listing'],
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      read: json['read'] ?? false,
      status: json['status'] ?? 'sent',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'listingId': listingId,
      'content': content,
      'type': type,
      'read': read,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      listingId: listingId,
      content: content,
      type: type,
      read: read,
      status: status,
      createdAt: createdAt,
    );
  }
}
