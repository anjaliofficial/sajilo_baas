import '../repositories/review_repository.dart';
import '../entities/review_entity.dart';

class CreateReviewUsecase {
  final ReviewRepository repository;

  CreateReviewUsecase(this.repository);

  Future<ReviewEntity> call({
    required String bookingId,
    required int rating,
    String? comment,
  }) {
    return repository.createReview(
      bookingId: bookingId,
      rating: rating,
      comment: comment,
    );
  }
}
