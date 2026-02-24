import '../repositories/message_repository.dart';

class DeleteMessage {
  final MessageRepository repository;

  DeleteMessage(this.repository);

  Future<void> call(String messageId, String deleteType) {
    return repository.deleteMessage(messageId, deleteType);
  }
}
