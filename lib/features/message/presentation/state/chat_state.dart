import 'package:sajilo_baas/features/message/domain/entities/message_entity.dart';

class ChatState {
  final List<MessageEntity> messages;
  final bool loading;
  final String? nextCursor;

  ChatState({required this.messages, required this.loading, this.nextCursor});

  ChatState copyWith({
    List<MessageEntity>? messages,
    bool? loading,
    String? nextCursor,
  }) => ChatState(
    messages: messages ?? this.messages,
    loading: loading ?? this.loading,
    nextCursor: nextCursor ?? this.nextCursor,
  );
}
