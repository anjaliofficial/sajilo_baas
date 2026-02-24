import '../repositories/message_repository.dart';

class EditMessage {
  final MessageRepository repository;

  EditMessage(this.repository);

  Future<void> call(String messageId, String newContent) {
    return repository.editMessage(messageId, newContent);
  }
}
