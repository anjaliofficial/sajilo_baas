import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';

class GetConversation {
  final MessageRepository repository;

  GetConversation(this.repository);

  Future<List<MessageEntity>> call(String otherUserId, String listingId) {
    return repository.getConversation(otherUserId, listingId);
  }
}
