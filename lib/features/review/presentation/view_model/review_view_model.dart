import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/features/auth/presentation/providers/auth_provider.dart';
import 'package:sajilo_baas/features/review/domain/entities/review_entity.dart';
import '../state/review_state.dart';
import '../../domain/usecases/get_reviews_received_usecase.dart';
import '../../domain/usecases/add_reply_usecase.dart';
import '../../domain/usecases/create_review_usecase.dart';
import '../../domain/entities/reply_entity.dart';

class ReviewViewModel extends StateNotifier<ReviewState> {
  final Ref ref;
  final GetReviewsReceivedUsecase getReviewsReceived;
  final AddReplyUsecase addReplyUsecase;
  final CreateReviewUsecase createReviewUsecase;

  ReviewViewModel(
    this.ref,
    this.getReviewsReceived,
    this.addReplyUsecase,
    this.createReviewUsecase,
  ) : super(ReviewState());

  /// Edit feedback (review comment)
  Future<void> editReviewOptimistic({
    required String reviewId,
    required String comment,
  }) async {
    // Optimistic update
    final optimisticReviews = state.reviews.map((review) {
      if (review.id == reviewId) {
        // ReviewEntity only has copyWith({List<ReplyEntity>? replies})
        // So we need to create a new ReviewEntity with updated comment
        return ReviewEntity(
          id: review.id,
          bookingId: review.bookingId,
          listingId: review.listingId,
          reviewerId: review.reviewerId,
          revieweeId: review.revieweeId,
          rating: review.rating,
          comment: comment,
          replies: review.replies,
          createdAt: review.createdAt,
          reviewerName: review.reviewerName,
          reviewerProfile: review.reviewerProfile,
        );
      }
      return review;
    }).toList();
    state = state.copyWith(reviews: optimisticReviews);
    try {
      final updated = await getReviewsReceived.repository.editReview(
        reviewId: reviewId,
        comment: comment,
      );
      final synced = state.reviews
          .map((review) => review.id == reviewId ? updated : review)
          .toList();
      state = state.copyWith(reviews: synced);
    } catch (e) {
      // Rollback
      state = state.copyWith(error: 'Failed to update feedback');
    }
  }

  /// Edit reply
  Future<void> editReplyOptimistic({
    required String reviewId,
    required String replyId,
    required String text,
  }) async {
    final optimisticReviews = state.reviews.map((review) {
      if (review.id == reviewId) {
        final updatedReplies = review.replies
            .map(
              (r) => r.id == replyId
                  ? ReplyEntity(
                      id: r.id,
                      authorId: r.authorId,
                      text: text,
                      createdAt: r.createdAt,
                    )
                  : r,
            )
            .toList();
        return review.copyWith(replies: updatedReplies);
      }
      return review;
    }).toList();
    state = state.copyWith(reviews: optimisticReviews);
    try {
      final updated = await getReviewsReceived.repository.editReply(
        reviewId: reviewId,
        replyId: replyId,
        text: text,
      );
      final synced = state.reviews
          .map((review) => review.id == reviewId ? updated : review)
          .toList();
      state = state.copyWith(reviews: synced);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update reply');
    }
  }

  /// Delete feedback (review)
  Future<void> deleteReviewOptimistic({required String reviewId}) async {
    final prevReviews = state.reviews;
    state = state.copyWith(
      reviews: prevReviews.where((r) => r.id != reviewId).toList(),
    );
    try {
      await getReviewsReceived.repository.deleteReview(reviewId: reviewId);
    } catch (e) {
      state = state.copyWith(
        reviews: prevReviews,
        error: 'Failed to delete feedback',
      );
    }
  }

  /// Delete reply
  Future<void> deleteReplyOptimistic({
    required String reviewId,
    required String replyId,
  }) async {
    final prevReviews = state.reviews;
    state = state.copyWith(
      reviews: prevReviews.map((review) {
        if (review.id == reviewId) {
          return review.copyWith(
            replies: review.replies.where((r) => r.id != replyId).toList(),
          );
        }
        return review;
      }).toList(),
    );
    try {
      await getReviewsReceived.repository.deleteReply(
        reviewId: reviewId,
        replyId: replyId,
      );
    } catch (e) {
      state = state.copyWith(
        reviews: prevReviews,
        error: 'Failed to delete reply',
      );
    }
  }

  Future<void> loadReviewsGiven() async {
    state = state.copyWith(loading: true);
    try {
      final reviews = await getReviewsReceived.repository.getReviewsGiven();
      state = state.copyWith(loading: false, reviews: reviews);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Failed to load given reviews',
      );
    }
  }

  // Duplicate fields and constructor removed above
  Future<void> createReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    await createReviewUsecase(
      bookingId: bookingId,
      rating: rating,
      comment: comment,
    );
  }

  Future<void> loadReviews(String userId) async {
    state = state.copyWith(loading: true);
    try {
      final reviews = await getReviewsReceived(userId);
      state = state.copyWith(loading: false, reviews: reviews);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Failed to load received reviews',
      );
    }
  }

  /// 🔁 OPTIMISTIC REPLY
  Future<void> addReplyOptimistic({
    required String reviewId,
    required String authorId,
    required String text,
  }) async {
    // Get current user fullName from AuthState
    final authState = ref.read(authViewModelProvider);
    Map<String, dynamic>? authorObj;
    if (authState.authEntity != null) {
      authorObj = {
        '_id': authState.authEntity!.authId ?? authorId,
        'fullName': authState.authEntity!.fullName,
        'email': authState.authEntity!.email,
        'profilePicture': null, // Add if available in AuthEntity
      };
    }
    final optimisticReply = ReplyEntity(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      authorId: authorId,
      text: text,
      createdAt: DateTime.now(),
      author: authorObj,
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
