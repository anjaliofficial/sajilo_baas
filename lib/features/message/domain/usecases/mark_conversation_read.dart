import '../repositories/message_repository.dart';

class MarkConversationRead {
  final MessageRepository repository;

  MarkConversationRead(this.repository);

  Future<void> call(String otherUserId, String listingId) {
    return repository.markConversationRead(otherUserId, listingId);
  }
}
