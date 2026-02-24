import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/get_conversation.dart';
import '../../domain/usecases/send_message.dart';
import '../state/chat_state.dart';

class ChatViewModel extends StateNotifier<ChatState> {
  final GetConversation getConversation;
  final SendMessage sendMessage;

  ChatViewModel(this.getConversation, this.sendMessage)
    : super(ChatState(messages: [], loading: true));

  Future<void> load(String otherUserId, String listingId) async {
    final msgs = await getConversation(otherUserId, listingId);
    state = state.copyWith(messages: msgs, loading: false);
  }

  Future<void> send(String receiverId, String listingId, String text) async {
    await sendMessage(
      receiverId: receiverId,
      listingId: listingId,
      content: text,
    );
  }

  void onIncoming(MessageEntity msg) {
    state = state.copyWith(messages: [...state.messages, msg]);
  }
}
