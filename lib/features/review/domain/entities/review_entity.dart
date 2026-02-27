import 'reply_entity.dart';

class ReviewEntity {
  /// Returns the author name or id (customize as needed)
  String get authorName =>
      reviewerName?.isNotEmpty == true ? reviewerName! : reviewerId;
  final String id;
  final String bookingId;
  final String listingId;
  final String reviewerId;
  final String revieweeId;
  final int rating;
  final String comment;
  final List<ReplyEntity> replies;
  final DateTime createdAt;
  final String? reviewerName;
  final String? reviewerProfile;
  final String? revieweeName;

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
    this.reviewerName,
    this.reviewerProfile,
    this.revieweeName,
  });

  ReviewEntity copyWith({List<ReplyEntity>? replies, String? revieweeName}) {
    return ReviewEntity(
      id: id,
      bookingId: bookingId,
      listingId: listingId,
      reviewerId: reviewerId,
      revieweeId: revieweeId,
      rating: rating,
      comment: comment,
      replies: replies ?? this.replies,
      createdAt: createdAt,
      reviewerName: reviewerName,
      reviewerProfile: reviewerProfile,
      revieweeName: revieweeName ?? this.revieweeName,
    );
  }
}
