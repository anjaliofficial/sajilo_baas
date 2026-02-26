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
}
