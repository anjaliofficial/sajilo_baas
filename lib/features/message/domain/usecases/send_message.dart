import 'package:sajilo_baas/features/message/domain/repositories/message_repository.dart';

class SendMessage {
  final MessageRepository repository;

  SendMessage(this.repository);

  Future<void> call({
    required String receiverId,
    required String listingId,
    String? content,
    List<Map<String, dynamic>>? media,
  }) {
    return repository.sendMessage(
      receiverId: receiverId,
      listingId: listingId,
      content: content,
      media: media,
    );
  }
}
