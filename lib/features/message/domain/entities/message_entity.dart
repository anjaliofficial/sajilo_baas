class MessageEntity {
  final String id;
  final String senderId;
  final String receiverId;
  final String? listingId;
  final String content;
  final String type; // 'text' | 'media'
  final bool read;
  final String status; // 'sent' | 'delivered' | 'read'
  final DateTime createdAt;
  final List<MessageMedia>? media;

  MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.listingId,
    required this.content,
    required this.type,
    required this.read,
    required this.status,
    required this.createdAt,
    this.media,
  });

  // Add copyWith for immutability
  MessageEntity copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? listingId,
    String? content,
    String? type,
    bool? read,
    String? status,
    DateTime? createdAt,
    List<MessageMedia>? media,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      listingId: listingId ?? this.listingId,
      content: content ?? this.content,
      type: type ?? this.type,
      read: read ?? this.read,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      media: media ?? this.media,
    );
  }
}

class MessageMedia {
  final String url;
  final String type;
  final String? fileName;

  MessageMedia({required this.url, required this.type, this.fileName});
}
