import '../../data/datasources/remote/media_upload_datasource.dart';
import '../../domain/usecases/delete_message.dart';
import '../../domain/usecases/edit_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart'; // <-- import ApiEndpoints
// Correct imports
import '../../data/datasources/remote/message_api_datasource.dart';
import '../../data/repositories/message_repository_impl.dart' as impl;
import '../../domain/repositories/message_repository.dart'; // DOMAIN ONLY

import '../../domain/usecases/get_conversation.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/get_threads.dart';

import '../../presentation/view_model/chat_view_model.dart';
import '../../presentation/view_model/threads_view_model.dart';
import '../../presentation/state/chat_state.dart';
import '../../presentation/state/threads_state.dart';

/// Media upload datasource provider
final mediaUploadDatasourceProvider = Provider<MediaUploadDatasource>((ref) {
  final dio = ref.read(dioProvider);
  return MediaUploadDatasource(dio);
});

final deleteMessageProvider = Provider<DeleteMessage>((ref) {
  final repo = ref.read(messageRepositoryProvider);
  return DeleteMessage(repo);
});

final editMessageProvider = Provider<EditMessage>((ref) {
  final repo = ref.read(messageRepositoryProvider);
  return EditMessage(repo);
});

/// Message API Datasource provider
final messageApiProvider = Provider<MessageApiDatasource>((ref) {
  final dio = ref.read(dioProvider);
  final apiClient = ApiClient(
    dio,
    baseUrl: ApiEndpoints.baseUrl,
  ); // <-- use ApiEndpoints
  return MessageApiDatasource(apiClient);
});

/// Message repository provider (implements domain repository)
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final datasource = ref.read(messageApiProvider);
  return impl.MessageRepositoryImpl(datasource: datasource);
});

/// Use case providers
final getConversationProvider = Provider<GetConversation>((ref) {
  final repo = ref.read(messageRepositoryProvider);
  return GetConversation(repo);
});

final sendMessageProvider = Provider<SendMessage>((ref) {
  final repo = ref.read(messageRepositoryProvider);
  return SendMessage(repo);
});

final getThreadsProvider = Provider<GetThreads>((ref) {
  final repo = ref.read(messageRepositoryProvider);
  return GetThreads(repo);
});

/// ViewModel providers
final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((
  ref,
) {
  final getConversation = ref.read(getConversationProvider);
  final sendMessage = ref.read(sendMessageProvider);
  final editMessage = ref.read(editMessageProvider);
  final deleteMessage = ref.read(deleteMessageProvider);
  return ChatViewModel(
    getConversation,
    sendMessage,
    (String messageId, String newContent) => editMessage(messageId, newContent),
    (String messageId, String deleteType) =>
        deleteMessage(messageId, deleteType),
  );
});

final threadsViewModelProvider =
    StateNotifierProvider<ThreadsViewModel, ThreadsState>((ref) {
      final getThreads = ref.read(getThreadsProvider);
      return ThreadsViewModel(getThreads);
    });
