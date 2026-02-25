import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  /// Empty message for threads without messages
  static MessageModel empty() {
    return MessageModel(
      id: '',
      senderId: '',
      receiverId: '',
      content: '',
      type: 'text',
      read: true,
      status: 'sent',
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'senderProfilePicture': senderProfilePicture,
      'receiverName': receiverName,
      'receiverProfilePicture': receiverProfilePicture,
      'listingId': listingId,
      'content': content,
      'type': type,
      'read': read,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'media': media
          ?.map(
            (m) => {
              'url': m.url,
              'kind': m.type, // keep using m.type for now, but send as 'kind'
              'mimeType': m.mimeType,
              'fileName': m.fileName,
            },
          )
          .toList(),
    };
  }

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
                    type: m['kind'] ?? m['type'],
                    mimeType: m['mimeType'] ?? '',
                    fileName: m['fileName'],
                  ),
                )
                .toList()
          : null,
    );
  }

  MessageEntity toEntity() => this;
}
