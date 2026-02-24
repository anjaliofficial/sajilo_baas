import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    super.listingId,
    required super.content,
    required super.type,
    required super.read,
    required super.status,
    required super.createdAt,
    super.media,
  });

  // Factory constructor for JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'],
      senderId: json['sender'],
      receiverId: json['receiver'],
      listingId: json['listing'],
      content: json['content'] ?? '',
      type: json['type'],
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

  // Convert model to entity
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
      media: media,
    );
  }
}
