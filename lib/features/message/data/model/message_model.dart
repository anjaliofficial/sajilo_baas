import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    super.senderName,
    super.senderProfilePicture,
    super.receiverName,
    super.receiverProfilePicture,
    super.listingId,
    required super.content,
    required super.type,
    required super.read,
    required super.status,
    required super.createdAt,
    super.media,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    final receiver = json['receiver'];
    return MessageModel(
      id: json['_id'] ?? '',
      senderId: sender is Map ? sender['_id'] ?? '' : (sender ?? ''),
      senderName: sender is Map ? sender['fullName'] ?? '' : null,
      senderProfilePicture: sender is Map
          ? sender['profilePicture'] ?? ''
          : null,
      receiverId: receiver is Map ? receiver['_id'] ?? '' : (receiver ?? ''),
      receiverName: receiver is Map ? receiver['fullName'] ?? '' : null,
      receiverProfilePicture: receiver is Map
          ? receiver['profilePicture'] ?? ''
          : null,
      listingId: json['listing'] is Map
          ? json['listing']['_id'] ?? ''
          : (json['listing'] ?? ''),
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      read: json['read'] ?? false,
      status: json['status'] ?? 'sent',
      createdAt: DateTime.parse(json['createdAt']),
      media: json['media'] != null
          ? (json['media'] as List<dynamic>)
                .map(
                  (m) => MessageMedia(
                    url: m['url'],
                    type: m['kind'],
                    fileName: m['fileName'],
                  ),
                )
                .toList()
          : null,
    );
  }

  MessageEntity toEntity() => this;
}
