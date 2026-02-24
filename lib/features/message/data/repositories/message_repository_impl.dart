import 'dart:async';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/remote/message_api_datasource.dart';
import '../datasources/remote/message_socket_datasource.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageApiDatasource api;
  final StreamController<MessageEntity> _liveController =
      StreamController.broadcast();

  MessageRepositoryImpl(this.api);

  // Socket.io
  late MessageSocketDatasource socket;

  void initSocket(String token) {
    socket = MessageSocketDatasource();
    socket.connect(token);
    socket.onReceiveMessage(emitLiveMessage);
  }

  void emitLiveMessage(MessageEntity message) {
    _liveController.add(message);
  }

  @override
  Stream<MessageEntity> liveMessages() => _liveController.stream;

  // ------------------------
  // Conversations
  // ------------------------
  @override
  Future<List<MessageEntity>> getConversation(
    String otherUserId,
    String listingId,
  ) async {
    final msgs = await api.getConversation(otherUserId, listingId);
    return msgs
        .map((m) => m.toEntity())
        .toList(); // convert MessageModel -> MessageEntity
  }

  @override
  Future<void> sendMessage({
    required String receiverId,
    required String listingId,
    String? content,
    List<Map<String, dynamic>>? media,
  }) async {
    final body = {
      'receiverId': receiverId,
      'listingId': listingId,
      'content': content ?? '',
      if (media != null) 'media': media,
    };
    await api.sendMessage(body);
  }

  @override
  Future<void> markConversationRead(String otherUserId, String listingId) {
    final body = {'otherUserId': otherUserId, 'listingId': listingId};
    return api.markRead(body);
  }

  @override
  Future<void> deleteMessage(String messageId, String deleteType) {
    final body = {'deleteType': deleteType};
    return api.deleteMessage(messageId, body);
  }
}
