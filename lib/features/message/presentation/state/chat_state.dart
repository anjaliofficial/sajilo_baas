class ChatState {
  final List<MessageEntity> messages;
  final bool loading;

  ChatState({required this.messages, required this.loading});

  ChatState copyWith({List<MessageEntity>? messages, bool? loading}) {
    return ChatState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
    );
  }
}
