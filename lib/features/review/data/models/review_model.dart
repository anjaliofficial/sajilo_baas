import '../../domain/entities/review_entity.dart';
import 'reply_model.dart';
import '../../../user/data/models/user_model.dart';

class ReviewModel extends ReviewEntity {
  final UserModel? reviewer;
  final UserModel? reviewee;

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
    this.reviewer,
    this.reviewee,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic value) {
      if (value is String) return value;
      if (value is Map && value.containsKey('_id')) {
        return value['_id'] as String;
      }
      return '';
    }

    String? parseProfile(dynamic value) {
      if (value is Map && value['profilePicture'] != null) {
        return value['profilePicture'] as String;
      }
      return null;
    }

    final reviewerObj = json['reviewer'];
    final revieweeObj = json['reviewee'];

    String reviewerId = parseId(reviewerObj);
    String revieweeId = parseId(revieweeObj);
    String reviewerName = reviewerObj is Map && reviewerObj['fullName'] != null
        ? reviewerObj['fullName'] as String
        : reviewerId;
    String revieweeName = revieweeObj is Map && revieweeObj['fullName'] != null
        ? revieweeObj['fullName'] as String
        : revieweeId;

    UserModel? reviewerUser = reviewerObj is Map
        ? UserModel.fromJson(Map<String, dynamic>.from(reviewerObj))
        : null;
    UserModel? revieweeUser = revieweeObj is Map
        ? UserModel.fromJson(Map<String, dynamic>.from(revieweeObj))
        : null;

    return ReviewModel(
      id: json['_id'],
      bookingId: parseId(json['bookingId']),
      listingId: parseId(json['listingId']),
      reviewerId: reviewerId,
      revieweeId: revieweeId,
      rating: json['rating'],
      comment: json['comment'] ?? '',
      replies: (json['replies'] as List)
          .map((e) => ReplyModel.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      reviewerName: reviewerName,
      reviewerProfile: parseProfile(reviewerObj),
      revieweeName: revieweeName,
      reviewer: reviewerUser,
      reviewee: revieweeUser,
    );
  }
}
