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
    bool isLikelyMongoId(String value) {
      return RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(value);
    }

    String parseId(dynamic value) {
      if (value is String) return value;
      if (value is Map && value.containsKey('_id')) {
        return value['_id'] as String;
      }
      return '';
    }

    String? parseDisplayName(dynamic primary, dynamic fallback) {
      String? fromValue(dynamic value) {
        if (value is Map && value['fullName'] != null) {
          final fullName = value['fullName'].toString().trim();
          if (fullName.isNotEmpty) return fullName;
        }
        if (value is String) {
          final text = value.trim();
          if (text.isNotEmpty && !isLikelyMongoId(text)) return text;
        }
        return null;
      }

      return fromValue(primary) ?? fromValue(fallback);
    }

    String? parseProfile(dynamic value) {
      if (value is Map && value['profilePicture'] != null) {
        return value['profilePicture'] as String;
      }
      return null;
    }

    final reviewerObj = json['reviewer'] ?? json['reviewerId'];
    final revieweeObj = json['reviewee'] ?? json['revieweeId'];

    String reviewerId = parseId(reviewerObj);
    String revieweeId = parseId(revieweeObj);
    final String? reviewerName = parseDisplayName(
      reviewerObj,
      json['reviewerName'] ?? json['reviewerFullName'],
    );
    final String? revieweeName = parseDisplayName(
      revieweeObj,
      json['revieweeName'] ?? json['revieweeFullName'],
    );

    UserModel? reviewerUser = reviewerObj is Map
        ? UserModel.fromJson(Map<String, dynamic>.from(reviewerObj))
        : null;
    UserModel? revieweeUser = revieweeObj is Map
        ? UserModel.fromJson(Map<String, dynamic>.from(revieweeObj))
        : null;

    return ReviewModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      bookingId: parseId(json['bookingId']),
      listingId: parseId(json['listingId']),
      reviewerId: reviewerId,
      revieweeId: revieweeId,
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toInt()
          : int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      comment: json['comment'] ?? '',
      replies: ((json['replies'] as List?) ?? const [])
          .map((e) => ReplyModel.fromJson(e))
          .toList(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      reviewerName: reviewerName,
      reviewerProfile: parseProfile(reviewerObj),
      revieweeName: revieweeName,
      reviewer: reviewerUser,
      reviewee: revieweeUser,
    );
  }
}
