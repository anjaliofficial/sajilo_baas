import '../../domain/repositories/review_repository.dart';
import '../../domain/entities/review_entity.dart';
import '../models/review_model.dart';
import '../datasource/remote/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  @override
  Future<ReviewEntity> editReview({
    required String reviewId,
    required String comment,
  }) {
    return remote.editReview(reviewId, comment);
  }

  @override
  Future<ReviewEntity> editReply({
    required String reviewId,
    required String replyId,
    required String text,
  }) {
    return remote.editReply(reviewId, replyId, text);
  }

  @override
  Future<void> deleteReview({required String reviewId}) {
    return remote.deleteReview(reviewId);
  }

  @override
  Future<ReviewEntity> deleteReply({
    required String reviewId,
    required String replyId,
  }) {
    return remote.deleteReply(reviewId, replyId);
  }

  final ReviewRemoteDatasource remote;

  ReviewRepositoryImpl(this.remote);

  @override
  Future<ReviewEntity> createReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) {
    return remote.createReview(bookingId, rating, comment);
  }

  @override
  Future<List<ReviewModel>> getReviewsGiven() {
    return remote.getReviewsGiven();
  }

  @override
  Future<List<ReviewModel>> getReviewsReceived(String userId) {
    return remote.getReviewsReceived(userId);
  }

  @override
  Future<ReviewEntity> addReply({
    required String reviewId,
    required String text,
  }) {
    return remote.addReply(reviewId, text);
  }
}
