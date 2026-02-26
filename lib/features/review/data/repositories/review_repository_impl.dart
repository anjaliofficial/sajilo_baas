import '../../domain/repositories/review_repository.dart';
import '../../domain/entities/review_entity.dart';
import '../datasource/remote/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
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
  Future<List<ReviewEntity>> getReviewsGiven() {
    return remote.getReviewsGiven();
  }

  @override
  Future<List<ReviewEntity>> getReviewsReceived(String userId) {
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
