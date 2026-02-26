// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../state/review_state.dart';
import '../../domain/usecases/get_reviews_received_usecase.dart';
import '../../domain/usecases/add_reply_usecase.dart';
import '../../domain/entities/reply_entity.dart';

class ReviewViewModel extends StateNotifier<ReviewState> {
  final GetReviewsReceivedUsecase getReviewsReceived;
  final AddReplyUsecase addReplyUsecase;

  ReviewViewModel(this.getReviewsReceived, this.addReplyUsecase)
    : super(ReviewState());

  Future<void> loadReviews(String userId) async {
    state = state.copyWith(loading: true);
    final reviews = await getReviewsReceived(userId);
    state = state.copyWith(loading: false, reviews: reviews);
  }

  /// 🔁 OPTIMISTIC REPLY
  Future<void> addReplyOptimistic({
    required String reviewId,
    required String authorId,
    required String text,
  }) async {
    final optimisticReply = ReplyEntity(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      authorId: authorId,
      text: text,
      createdAt: DateTime.now(),
    );

    /// 1️⃣ Update UI immediately
    final optimisticReviews = state.reviews.map((review) {
      if (review.id == reviewId) {
        return review.copyWith(replies: [...review.replies, optimisticReply]);
      }
      return review;
    }).toList();

    state = state.copyWith(reviews: optimisticReviews);

    try {
      /// 2️⃣ Call backend
      final updatedReview = await addReplyUsecase(
        reviewId: reviewId,
        text: text,
      );

      /// 3️⃣ Replace optimistic with real backend data
      final syncedReviews = state.reviews.map((review) {
        if (review.id == reviewId) {
          return updatedReview;
        }
        return review;
      }).toList();

      state = state.copyWith(reviews: syncedReviews);
    } catch (e) {
      /// 4️⃣ Rollback if failed
      final rolledBack = state.reviews.map((review) {
        if (review.id == reviewId) {
          return review.copyWith(
            replies: review.replies
                .where((r) => r.id != optimisticReply.id)
                .toList(),
          );
        }
        return review;
      }).toList();

      state = state.copyWith(
        reviews: rolledBack,
        error: 'Failed to send reply',
      );
    }
  }
}
