import 'package:sajilo_baas/features/message/domain/entities/message_entity.dart';
import '../../domain/entities/thread_entity.dart';

abstract class MessageRepository {
  Future<List<MessageEntity>> getConversation(
    String otherUserId,
    String listingId,
  );

  Future<void> sendMessage({
    required String receiverId,
    required String listingId,
    String? content,
    List<Map<String, dynamic>>? media,
  });

  Future<void> markConversationRead(String otherUserId, String listingId);

  Future<void> deleteMessage(
    String messageId,
    String deleteType, // for_me | for_everyone
  );

  Future<void> editMessage(
    String messageId,
    String newContent,
  );

  Future<List<ThreadEntity>> getThreads();

  Stream<MessageEntity> liveMessages();
}
