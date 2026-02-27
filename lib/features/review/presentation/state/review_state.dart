import '../../domain/entities/review_entity.dart';

class ReviewState {
  final bool loading;
  final List<ReviewEntity> receivedReviews;
  final List<ReviewEntity> givenReviews;
  final String? error;

  ReviewState({
    this.loading = false,
    List<ReviewEntity>? receivedReviews,
    List<ReviewEntity>? givenReviews,
    this.error,
  })  : receivedReviews = receivedReviews ?? const [],
        givenReviews = givenReviews ?? const [];

  ReviewState copyWith({
    bool? loading,
    List<ReviewEntity>? receivedReviews,
    List<ReviewEntity>? givenReviews,
    String? error,
  }) {
    return ReviewState(
      loading: loading ?? this.loading,
      receivedReviews: receivedReviews ?? this.receivedReviews,
      givenReviews: givenReviews ?? this.givenReviews,
      error: error,
    );
  }
}
