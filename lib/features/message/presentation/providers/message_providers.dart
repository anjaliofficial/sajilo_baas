import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/core/network/dio_provider.dart';
import 'package:sajilo_baas/features/message/data/datasources/remote/message_api_datasource.dart';
import 'package:sajilo_baas/features/message/data/repositories/message_repository_impl.dart';
import 'package:sajilo_baas/features/message/domain/usecases/get_conversation.dart';
import 'package:sajilo_baas/features/message/domain/usecases/send_message.dart';
import 'package:sajilo_baas/features/message/presentation/state/chat_state.dart';
import 'package:sajilo_baas/features/message/presentation/view_model/chat_view_model.dart';

final messageApiProvider = Provider((ref) {
  return MessageApiDatasource(ref.read(dioProvider));
});

final messageRepositoryProvider = Provider<MessageRepositoryImpl>((ref) {
  return MessageRepositoryImpl(ref.read(messageApiProvider));
});

final getConversationProvider = Provider((ref) {
  return GetConversation(ref.read(messageRepositoryProvider));
});

final sendMessageProvider = Provider((ref) {
  return SendMessage(ref.read(messageRepositoryProvider));
});

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((
  ref,
) {
  return ChatViewModel(
    ref.read(getConversationProvider),
    ref.read(sendMessageProvider),
  );
});
