import 'package:sajilo_baas/features/message/data/datasources/remote/message_api_datasource.dart';
import 'package:sajilo_baas/features/message/data/datasources/remote/message_socket_datasource.dart';
import 'package:sajilo_baas/features/message/domain/entities/message_entity.dart';
import 'package:sajilo_baas/features/message/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageApiDatasource api;
  final MessageSocketDatasource socket;

  MessageRepositoryImpl(this.api, this.socket);

  @override
  Stream<MessageEntity> liveMessages() => socket.onMessage();

  @override
  Future<List<MessageEntity>> getConversation(
    String otherUserId,
    String listingId,
  ) {
    return api.getConversation(otherUserId, listingId);
  }

  @override
  Future<void> sendMessage({
    required String receiverId,
    required String listingId,
    String? content,
    List<Map<String, dynamic>>? media,
  }) {
    return api.sendMessage({
      'receiverId': receiverId,
      'listingId': listingId,
      'content': content,
      'media': media,
    });
  }

  @override
  Future<void> markConversationRead(String otherUserId, String listingId) {
    return api.markRead({'otherUserId': otherUserId, 'listingId': listingId});
  }

  @override
  Future<void> deleteMessage(String messageId, String deleteType) {
    return api.deleteMessage(messageId, deleteType);
  }
}
