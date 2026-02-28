class ReplyEntity {
  final String id;
  final String authorId;
  final String text;
  final DateTime createdAt;
  final Map<String, dynamic>? author;

  ReplyEntity({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
    this.author,
  });
}
