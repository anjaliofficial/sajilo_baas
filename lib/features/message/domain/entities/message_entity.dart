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

  MessageEntity copyWith({
    String? content,
    bool? read,
    String? status,
    List<MessageMedia>? media,
  }) {
    return MessageEntity(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      listingId: listingId,
      content: content ?? this.content,
      type: type,
      read: read ?? this.read,
      status: status ?? this.status,
      createdAt: createdAt,
      media: media ?? this.media,
    );
  }
}

class MessageMedia {
  final String url;
  final String type; // 'image' | 'video'
  final String? fileName;

  MessageMedia({required this.url, required this.type, this.fileName});
}
