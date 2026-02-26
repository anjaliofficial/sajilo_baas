import '../../domain/entities/reply_entity.dart';

class ReplyModel extends ReplyEntity {
  ReplyModel({
    required super.id,
    required super.authorId,
    required super.text,
    required super.createdAt,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      id: json['_id'],
      authorId: json['author'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
