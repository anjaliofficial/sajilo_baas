import 'reply_entity.dart';

class ReviewEntity {
  final String id;
  final String bookingId;
  final String listingId;
  final String reviewerId;
  final String revieweeId;
  final int rating;
  final String comment;
  final List<ReplyEntity> replies;
  final DateTime createdAt;

  ReviewEntity({
    required this.id,
    required this.bookingId,
    required this.listingId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.replies,
    required this.createdAt,
  });
}
