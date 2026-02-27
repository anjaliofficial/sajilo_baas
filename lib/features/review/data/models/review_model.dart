import '../../domain/entities/review_entity.dart';
import 'reply_model.dart';

class ReviewModel extends ReviewEntity {
  ReviewModel({
    required String id,
    required String bookingId,
    required String listingId,
    required String reviewerId,
    required String revieweeId,
    required int rating,
    required String comment,
    required List<ReplyModel> replies,
    required DateTime createdAt,
    String? reviewerName,
    String? reviewerProfile,
  }) : super(
         id: id,
         bookingId: bookingId,
         listingId: listingId,
         reviewerId: reviewerId,
         revieweeId: revieweeId,
         rating: rating,
         comment: comment,
         replies: replies,
         createdAt: createdAt,
         reviewerName: reviewerName,
         reviewerProfile: reviewerProfile,
       );

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic value) {
      if (value is String) return value;
      if (value is Map && value.containsKey('_id'))
        return value['_id'] as String;
      return '';
    }

    String? parseName(dynamic value) {
      if (value is Map && value['fullName'] != null)
        return value['fullName'] as String;
      return null;
    }

    String? parseProfile(dynamic value) {
      if (value is Map && value['profilePicture'] != null)
        return value['profilePicture'] as String;
      return null;
    }

    final reviewerObj = json['reviewer'];
    return ReviewModel(
      id: json['_id'],
      bookingId: parseId(json['bookingId']),
      listingId: parseId(json['listingId']),
      reviewerId: parseId(reviewerObj),
      revieweeId: parseId(json['reviewee']),
      rating: json['rating'],
      comment: json['comment'] ?? '',
      replies: (json['replies'] as List)
          .map((e) => ReplyModel.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      reviewerName: parseName(reviewerObj),
      reviewerProfile: parseProfile(reviewerObj),
    );
  }
}
