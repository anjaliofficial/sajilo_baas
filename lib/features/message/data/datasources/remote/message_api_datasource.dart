import 'package:dio/dio.dart';
import '../../model/message_model.dart';

class MessageApiDatasource {
  final Dio dio;
  MessageApiDatasource(this.dio);

  Future<List<MessageModel>> getConversation(
    String otherUserId,
    String listingId,
  ) async {
    final res = await dio.get('/messages/$otherUserId/$listingId');
    return (res.data['data'] as List)
        .map((e) => MessageModel.fromJson(e))
        .toList();
  }

  Future<void> sendMessage(Map<String, dynamic> body) async {
    await dio.post('/messages', data: body);
  }

  Future<void> markRead(Map<String, dynamic> body) async {
    await dio.patch('/messages/read', data: body);
  }

  Future<void> deleteMessage(String id, String deleteType) async {
    await dio.delete('/messages/$id', data: {'deleteType': deleteType});
  }
}
