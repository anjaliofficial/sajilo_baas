import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_reviews_received_usecase.dart';
import '../../domain/usecases/add_reply_usecase.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../data/datasource/remote/review_remote_datasource.dart';

final getReviewsReceivedUsecaseProvider = Provider<GetReviewsReceivedUsecase>((
  ref,
) {
  final repo = ReviewRepositoryImpl(ReviewRemoteDatasource());
  return GetReviewsReceivedUsecase(repo);
});

final addReplyUsecaseProvider = Provider<AddReplyUsecase>((ref) {
  final repo = ReviewRepositoryImpl(ReviewRemoteDatasource());
  return AddReplyUsecase(repo);
});
