class MessageEntity {
  final String id;
  final String senderId;
  final String receiverId;
  final String? listingId;
  final String content;
  final String type; // text | media
  final bool read;
  final String status; // sent | delivered | read
  final DateTime createdAt;

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
  });
}
