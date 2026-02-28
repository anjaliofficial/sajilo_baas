import '../repositories/review_repository.dart';
import '../entities/review_entity.dart';

class AddReplyUsecase {
  final ReviewRepository repository;

  AddReplyUsecase(this.repository);

  Future<ReviewEntity> call({required String reviewId, required String text}) {
    return repository.addReply(reviewId: reviewId, text: text);
  }
}
