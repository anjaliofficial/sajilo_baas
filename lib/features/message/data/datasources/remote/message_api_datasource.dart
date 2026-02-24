import 'package:dio/dio.dart';
import '../../model/message_model.dart';

class MessageApiDatasource {
  final Dio dio;

  MessageApiDatasource(this.dio);

  // ------------------------
  // GET conversation
  // ------------------------
  Future<List<MessageModel>> getConversation(
    String otherUserId,
    String listingId, {
    int limit = 20,
    String? cursor,
  }) async {
    final res = await dio.get(
      '/api/messages/$otherUserId/$listingId',
      queryParameters: {'limit': limit, 'cursor': cursor},
    );

    final List<dynamic> data = res.data['data'] ?? [];
    return data.map((e) => MessageModel.fromJson(e)).toList();
  }

  // ------------------------
  // SEND message
  // ------------------------
  Future<MessageModel> sendMessage(Map<String, dynamic> body) async {
    final res = await dio.post('/api/messages/', data: body);
    return MessageModel.fromJson(res.data['data']);
  }

  // ------------------------
  // MARK conversation read
  // ------------------------
  Future<void> markRead(Map<String, dynamic> body) async {
    await dio.patch('/api/messages/read', data: body);
  }

  // ------------------------
  // DELETE message
  // ------------------------
  Future<void> deleteMessage(
    String messageId,
    Map<String, dynamic> body,
  ) async {
    await dio.delete('/api/messages/$messageId', data: body);
  }

  // ------------------------
  // GET threads
  // ------------------------
  Future<List<Map<String, dynamic>>> getThreads() async {
    final res = await dio.get('/api/messages/threads');
    return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
  }
}
