import '../../domain/entities/review_entity.dart';
import 'reply_model.dart';

class ReviewModel extends ReviewEntity {
  ReviewModel({
    required super.id,
    required super.bookingId,
    required super.listingId,
    required super.reviewerId,
    required super.revieweeId,
    required super.rating,
    required super.comment,
    required super.replies,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'],
      bookingId: json['bookingId'],
      listingId: json['listingId'],
      reviewerId: json['reviewer'],
      revieweeId: json['reviewee'],
      rating: json['rating'],
      comment: json['comment'] ?? '',
      replies: (json['replies'] as List)
          .map((e) => ReplyModel.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
