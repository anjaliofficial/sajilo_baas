import '../../domain/entities/reply_entity.dart';

class ReplyModel extends ReplyEntity {
  ReplyModel({
    required super.id,
    required super.authorId,
    required super.text,
    required super.createdAt,
    super.author,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    String parseAuthorId(dynamic value) {
      if (value is String) return value;
      if (value is Map && value.containsKey('_id')) {
        return value['_id'] as String;
      }
      return '';
    }

    return ReplyModel(
      id: json['_id'],
      authorId: parseAuthorId(json['author']),
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      author: json['author'] is Map<String, dynamic>
          ? json['author'] as Map<String, dynamic>
          : null,
    );
  }
}
