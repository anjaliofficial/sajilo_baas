import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/features/message/presentation/view_model/threads_view_modeldart'
    hide ThreadsViewModel;
import '../view_model/threads_view_model.dart';
import 'message_providers.dart';

final threadsViewModelProvider =
    StateNotifierProvider<ThreadsViewModel, ThreadsState>((ref) {
      final getThreads = ref.read(getThreadsProvider); // your usecase provider
      return ThreadsViewModel(getThreads);
    });
