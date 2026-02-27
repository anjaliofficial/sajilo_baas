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
    required List<ReplyModel> super.replies,
    required super.createdAt,
    super.reviewerName,
    super.reviewerProfile,
    super.revieweeName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic value) {
      if (value is String) return value;
      if (value is Map && value.containsKey('_id')) {
        return value['_id'] as String;
      }
      return '';
    }

    String? parseName(dynamic value) {
      if (value is Map && value['fullName'] != null) {
        return value['fullName'] as String;
      }
      return null;
    }

    String? parseProfile(dynamic value) {
      if (value is Map && value['profilePicture'] != null) {
        return value['profilePicture'] as String;
      }
      return null;
    }

    final reviewerObj = json['reviewer'];
    final revieweeObj = json['reviewee'];
    return ReviewModel(
      id: json['_id'],
      bookingId: parseId(json['bookingId']),
      listingId: parseId(json['listingId']),
      reviewerId: parseId(reviewerObj),
      revieweeId: parseId(revieweeObj),
      rating: json['rating'],
      comment: json['comment'] ?? '',
      replies: (json['replies'] as List)
          .map((e) => ReplyModel.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      reviewerName: parseName(reviewerObj),
      reviewerProfile: parseProfile(reviewerObj),
      revieweeName: parseName(revieweeObj),
    );
  }
}
