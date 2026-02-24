import 'package:sajilo_baas/core/api/api_client.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import '../../model/message_model.dart';

class MessageApiDatasource {
  Future<void> deleteMessage(String messageId, String deleteType) async {
    final response = await apiClient.dio.delete(
      '${ApiEndpoints.deleteMessage}/$messageId',
      data: {'deleteType': deleteType},
    );
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to delete message');
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    final response = await apiClient.dio.put(
      '${ApiEndpoints.editMessage}/$messageId',
      data: {'content': newContent},
    );
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to edit message');
    }
  }

  final ApiClient apiClient;

  MessageApiDatasource(this.apiClient);

  Future<List<MessageModel>> getConversation({
    required String otherUserId,
    required String listingId,
    int limit = 20,
    String? cursor,
  }) async {
    final response = await apiClient.dio.get(
      '${ApiEndpoints.getConversation}/$otherUserId/$listingId',
      queryParameters: {'limit': limit, 'cursor': cursor},
    );

    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => MessageModel.fromJson(e)).toList();
  }

  Future<MessageModel> sendMessage({
    required String receiverId,
    required String listingId,
    required String content,
  }) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.sendMessage,
      data: {
        'receiverId': receiverId,
        'listingId': listingId,
        'content': content,
      },
    );
    return MessageModel.fromJson(response.data['data']);
  }

  Future<void> markRead(String conversationId) async {
    await apiClient.dio.post(
      ApiEndpoints.markConversationRead,
      data: {'conversationId': conversationId},
    );
  }
}
