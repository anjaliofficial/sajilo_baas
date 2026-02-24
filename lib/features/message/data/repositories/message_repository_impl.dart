import 'package:sajilo_baas/features/message/data/datasources/remote/message_api_datasource.dart';

import 'package:sajilo_baas/features/message/domain/entities/message_entity.dart';
import '../../domain/entities/thread_entity.dart';
import '../../domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  @override
  Future<void> editMessage(String messageId, String newContent) async {
    await datasource.editMessage(messageId, newContent);
  }

  final MessageApiDatasource datasource;

  MessageRepositoryImpl({required this.datasource});

  @override
  Future<List<MessageEntity>> getConversation(
    String otherUserId,
    String listingId,
  ) async {
    final models = await datasource.getConversation(
      otherUserId: otherUserId,
      listingId: listingId,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> sendMessage({
    required String receiverId,
    required String listingId,
    String? content,
    List<Map<String, dynamic>>? media,
  }) async {
    await datasource.sendMessage(
      receiverId: receiverId,
      listingId: listingId,
      content: content ?? '',
      // Add media support if needed in datasource
    );
  }

  @override
  Future<void> markConversationRead(
    String otherUserId,
    String listingId,
  ) async {
    // Implement this in datasource if needed
    // await datasource.markConversationRead(otherUserId, listingId);
  }

  @override
  Future<void> deleteMessage(String messageId, String deleteType) async {
    await datasource.deleteMessage(messageId, deleteType);
  }

  @override
  Future<List<ThreadEntity>> getThreads() async {
    // Implement this in datasource if needed
    // final threads = await datasource.getThreads();
    // return threads.map((t) => t.toEntity()).toList();
    return [];
  }

  @override
  Stream<MessageEntity> liveMessages() {
    // Implement this if you have a stream source
    return const Stream.empty();
  }
}
