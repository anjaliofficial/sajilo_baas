import 'package:dio/dio.dart';
import 'package:sajilo_baas/core/api/api_client.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import 'package:sajilo_baas/features/review/data/models/review_model.dart';

class ReviewRemoteDatasource {
  Future<ReviewModel> editReview(String reviewId, String comment) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  Future<ReviewModel> editReply(
    String reviewId,
    String replyId,
    String text,
  ) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  Future<void> deleteReview(String reviewId) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  Future<ReviewModel> deleteReply(String reviewId, String replyId) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  final Dio dio;

  ReviewRemoteDatasource()
    : dio = ApiClient(Dio(), baseUrl: ApiEndpoints.baseUrl).dio;

  Future<ReviewModel> createReview(
    String bookingId,
    int rating,
    String? comment,
  ) async {
    final res = await dio.post(
      '/reviews',
      data: {'bookingId': bookingId, 'rating': rating, 'comment': comment},
    );

    return ReviewModel.fromJson(res.data['data']);
  }

  Future<List<ReviewModel>> getReviewsGiven() async {
    final res = await dio.get('/reviews/given');

    return (res.data['reviews'] as List)
        .map((e) => ReviewModel.fromJson(e))
        .toList();
  }

  Future<List<ReviewModel>> getReviewsReceived(String userId) async {
    final res = await dio.get('/reviews/received/$userId');

    return (res.data['reviews'] as List)
        .map((e) => ReviewModel.fromJson(e))
        .toList();
  }

  Future<ReviewModel> addReply(String reviewId, String text) async {
    final res = await dio.post(
      '/reviews/$reviewId/replies',
      data: {'text': text},
    );

    return ReviewModel.fromJson(res.data['data']);
  }
}
