send_message.dartclass SendMessage {
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