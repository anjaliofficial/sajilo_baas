import '../../domain/entities/review_entity.dart';

class ReviewState {
  final bool loading;
  final List<ReviewEntity> reviews;
  final String? error;

  ReviewState({this.loading = false, this.reviews = const [], this.error});

  ReviewState copyWith({
    bool? loading,
    List<ReviewEntity>? reviews,
    String? error,
  }) {
    return ReviewState(
      loading: loading ?? this.loading,
      reviews: reviews ?? this.reviews,
      error: error,
    );
  }
}
