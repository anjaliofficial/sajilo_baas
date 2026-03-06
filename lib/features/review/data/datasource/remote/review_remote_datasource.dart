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
    await dio.delete('/reviews/$reviewId');
  }

  Future<ReviewModel> deleteReply(String reviewId, String replyId) async {
    final res = await dio.delete('/reviews/$reviewId/replies/$replyId');
    return ReviewModel.fromJson(res.data['data']);
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

    // Handle non-200/201 responses
    if (res.statusCode != 200 && res.statusCode != 201) {
      final message = res.data['message'] ?? 'Failed to create review';
      throw Exception(message);
    }

    if (res.data == null || res.data['data'] == null) {
      final message = res.data != null && res.data['message'] != null
          ? res.data['message']
          : 'No review data returned';
      throw Exception(message);
    }

    return ReviewModel.fromJson(res.data['data']);
  }

  Future<List<ReviewModel>> getReviewsGiven() async {
    final res = await dio.get('/reviews/given');
    final reviewsRaw = res.data['reviews'];
    if (reviewsRaw == null || reviewsRaw is! List) {
      return <ReviewModel>[];
    }
    return reviewsRaw.map((e) => ReviewModel.fromJson(e)).toList();
  }

  Future<List<ReviewModel>> getReviewsReceived(String userId) async {
    final res = await dio.get('/reviews/received/$userId');
    final reviewsRaw = res.data['reviews'];
    if (reviewsRaw == null || reviewsRaw is! List) {
      return <ReviewModel>[];
    }
    return reviewsRaw.map((e) => ReviewModel.fromJson(e)).toList();
  }

  Future<ReviewModel> addReply(String reviewId, String text) async {
    final res = await dio.post(
      '/reviews/$reviewId/replies',
      data: {'text': text},
    );
    final payload = res.data;
    if (payload is Map<String, dynamic>) {
      dynamic reviewJson =
          payload['data'] ?? payload['review'] ?? payload['result'];

      // Handle nested response like { data: { review: {...} } }
      if (reviewJson is Map<String, dynamic>) {
        reviewJson = reviewJson['review'] ?? reviewJson['data'] ?? reviewJson;
      }

      // Handle top-level review object response
      if (reviewJson == null &&
          (payload['_id'] != null || payload['id'] != null)) {
        reviewJson = payload;
      }

      if (reviewJson is Map<String, dynamic>) {
        return ReviewModel.fromJson(reviewJson);
      }
      if (reviewJson is Map) {
        return ReviewModel.fromJson(Map<String, dynamic>.from(reviewJson));
      }
    }

    throw Exception('Unexpected response while adding reply');
  }
}
