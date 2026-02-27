import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<ReviewEntity> createReview({
    required String bookingId,
    required int rating,
    String? comment,
  });

  Future<List<ReviewEntity>> getReviewsGiven();
  Future<List<ReviewEntity>> getReviewsReceived(String userId);

  Future<ReviewEntity> addReply({
    required String reviewId,
    required String text,
  });

  Future<ReviewEntity> editReview({
    required String reviewId,
    required String comment,
  });

  Future<ReviewEntity> editReply({
    required String reviewId,
    required String replyId,
    required String text,
  });

  Future<void> deleteReview({required String reviewId});

  Future<ReviewEntity> deleteReply({
    required String reviewId,
    required String replyId,
  });
}
