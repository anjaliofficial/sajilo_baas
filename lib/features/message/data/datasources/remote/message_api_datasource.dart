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
    final url = '/api/messages/$otherUserId/$listingId';
    final params = {'limit': limit, 'cursor': cursor};
    print('🔗 GET Conversation URL: $url');
    print('🔗 GET Conversation Params: $params');
    final res = await dio.get(
      url,
      queryParameters: params,
    );

    final List<dynamic> data = res.data['data'] ?? [];
    return data.map((e) => MessageModel.fromJson(e)).toList();
  }

  // ------------------------
  // SEND message
  // ------------------------
  Future<MessageModel> sendMessage(Map<String, dynamic> body) async {
    print('🔗 SEND Message URL: /api/messages/');
    print('🔗 SEND Message Body: $body');
    final res = await dio.post('/api/messages/', data: body);
    return MessageModel.fromJson(res.data['data']);
  }

  // ------------------------
  // MARK conversation read
  // ------------------------
  Future<void> markRead(Map<String, dynamic> body) async {
    print('🔗 MARK Read URL: /api/messages/read');
    print('🔗 MARK Read Body: $body');
    await dio.patch('/api/messages/read', data: body);
  }

  // ------------------------
  // DELETE message
  // ------------------------
  Future<void> deleteMessage(
    String messageId,
    Map<String, dynamic> body,
  ) async {
    print('🔗 DELETE Message URL: /api/messages/$messageId');
    print('🔗 DELETE Message Body: $body');
    await dio.delete('/api/messages/$messageId', data: body);
  }

  // ------------------------
  // GET threads
  // ------------------------
  Future<List<Map<String, dynamic>>> getThreads() async {
    print('🔗 GET Threads URL: /api/messages/threads');
    final res = await dio.get('/api/messages/threads');
    return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
  }
}
