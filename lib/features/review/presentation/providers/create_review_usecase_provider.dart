import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/create_review_usecase.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../data/datasource/remote/review_remote_datasource.dart';

final createReviewUsecaseProvider = Provider<CreateReviewUsecase>((ref) {
  final repo = ReviewRepositoryImpl(ReviewRemoteDatasource());
  return CreateReviewUsecase(repo);
});
