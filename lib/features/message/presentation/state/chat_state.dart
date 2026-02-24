import 'package:sajilo_baas/features/message/domain/entities/message_entity.dart';

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
