final reviewProvider = StateNotifierProvider<ReviewViewModel, ReviewState>((
  ref,
) {
  return ReviewViewModel(
    ref.read(getReviewsReceivedUsecaseProvider),
    ref.read(addReplyUsecaseProvider),
  );
});
