import 'package:sajilo_baas/features/message/presentation/state/chat_state.dart';

class ChatViewModel extends StateNotifier<ChatState> {
  final GetConversation getConversation;
  final SendMessage sendMessage;
  final MessageRepository repository;

  ChatViewModel(this.getConversation, this.sendMessage, this.repository)
    : super(ChatState(messages: [], loading: true)) {
    repository.liveMessages().listen(_onNewMessage);
  }

  Future<void> load(String otherUserId, String listingId) async {
    final msgs = await getConversation(otherUserId, listingId);
    state = state.copyWith(messages: msgs, loading: false);
  }

  void _onNewMessage(MessageEntity msg) {
    state = state.copyWith(messages: [...state.messages, msg]);
  }
}
