import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/features/review/presentation/state/review_state.dart';
import 'package:sajilo_baas/features/review/presentation/view_model/review_view_model.dart';

import 'usecase_providers.dart';
import 'create_review_usecase_provider.dart';

final reviewProvider = StateNotifierProvider<ReviewViewModel, ReviewState>((
  ref,
) {
  return ReviewViewModel(
    ref.read(getReviewsReceivedUsecaseProvider),
    ref.read(addReplyUsecaseProvider),
    ref.read(createReviewUsecaseProvider),
  );
});
