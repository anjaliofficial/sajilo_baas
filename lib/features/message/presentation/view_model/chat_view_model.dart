// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/get_conversation.dart';
import '../../domain/usecases/send_message.dart';
import '../state/chat_state.dart';

class ChatViewModel extends StateNotifier<ChatState> {
  Future<void> sendMedia(
    String receiverId,
    String listingId,
    String fileUrl,
    String kind,
    String mimeType,
  ) async {
    // kind: 'image' or 'video', mimeType: e.g. 'image/png', 'video/mp4'
    final media = [
      {'url': fileUrl, 'kind': kind, 'mimeType': mimeType},
    ];
    await sendMessage(
      receiverId: receiverId,
      listingId: listingId,
      content: '',
      media: media,
    );
    await load(receiverId, listingId); // Refresh messages after sending
  }

  final GetConversation getConversation;
  final SendMessage sendMessage;
  final Future<void> Function(String messageId, String newContent)
  editMessageUseCase;
  final Future<void> Function(String messageId, String deleteType)
  deleteMessageUseCase;

  ChatViewModel(
    this.getConversation,
    this.sendMessage,
    this.editMessageUseCase,
    this.deleteMessageUseCase,
  ) : super(ChatState(messages: [], loading: true));
  Future<void> deleteMessage(
    String messageId,
    String deleteType,
    String otherUserId,
    String listingId,
  ) async {
    await deleteMessageUseCase(messageId, deleteType);
    await load(otherUserId, listingId);
  }

  Future<void> editMessage(
    String messageId,
    String newContent,
    String otherUserId,
    String listingId,
  ) async {
    await editMessageUseCase(messageId, newContent);
    await load(otherUserId, listingId);
  }

  Future<void> load(String otherUserId, String listingId) async {
    try {
      final msgs = await getConversation(otherUserId, listingId);
      print('Loaded messages: \\n${msgs.map((m) => m.content).toList()}');
      state = state.copyWith(messages: msgs, loading: false);
    } catch (_) {
      state = state.copyWith(messages: [], loading: false);
    }
  }

  Future<void> send(String receiverId, String listingId, String text) async {
    if (text.isEmpty) return;
    await sendMessage(
      receiverId: receiverId,
      listingId: listingId,
      content: text,
      media: null,
    );
    await load(receiverId, listingId); // Refresh messages after sending
  }

  void onIncoming(MessageEntity msg) {
    state = state.copyWith(messages: [...state.messages, msg]);
  }
}
