import '../../domain/entities/thread_entity.dart';
import 'message_model.dart';

/// ========================
/// THREAD MODEL
/// ========================
class ThreadModel {
  final String otherUserId;
  final String? listingId;
  final String? otherUserName;
  final String? otherUserImage;
  final MessageModel lastMessage;
  final int unreadCount;

  ThreadModel({
    required this.otherUserId,
    this.listingId,
    this.otherUserName,
    this.otherUserImage,
    required this.lastMessage,
    required this.unreadCount,
  });

  factory ThreadModel.fromJson(Map<String, dynamic> json) {
    return ThreadModel(
      otherUserId: json['otherUserId'] ?? '',
      listingId: json['listingId'],
      otherUserName: json['otherUserName'],
      otherUserImage: json['otherUserImage'],
      unreadCount: json['unreadCount'] ?? 0,
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'])
          : MessageModel.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otherUserId': otherUserId,
      'listingId': listingId,
      'otherUserName': otherUserName,
      'otherUserImage': otherUserImage,
      'unreadCount': unreadCount,
      'lastMessage': lastMessage.toJson(),
    };
  }

  ThreadEntity toEntity() {
    return ThreadEntity(
      otherUserId: otherUserId,
      listingId: listingId,
      otherUserName: otherUserName,
      otherUserImage: otherUserImage,
      unreadCount: unreadCount,
      lastMessage: lastMessage.toEntity(),
    );
  }
}

// MessageModel and MessageMedia are now imported from message_model.dart
