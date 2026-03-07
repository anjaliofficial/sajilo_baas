import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/message/presentation/providers/message_providers.dart';
import 'package:sajilo_baas/features/message/presentation/state/threads_state.dart';
import '../view_model/threads_view_model.dart';
import '../../domain/usecases/get_threads.dart';

final getThreadsProvider = Provider<GetThreads>((ref) {
  final repo = ref.read(messageRepositoryProvider); // your repo
  return GetThreads(repo);
});

final threadsViewModelProvider =
    StateNotifierProvider<ThreadsViewModel, ThreadsState>((ref) {
      final getThreads = ref.read(getThreadsProvider);
      return ThreadsViewModel(getThreads);
    });
