import '../repositories/review_repository.dart';
import '../entities/review_entity.dart';

class GetReviewsReceivedUsecase {
  final ReviewRepository repository;

  GetReviewsReceivedUsecase(this.repository);

  Future<List<ReviewEntity>> call(String userId) {
    return repository.getReviewsReceived(userId);
  }
}
