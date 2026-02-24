// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifier;
import 'package:sajilo_baas/features/message/domain/entities/thread_entity.dart';
import '../../domain/usecases/get_threads.dart';
import '../state/threads_state.dart';
import '../../domain/entities/message_entity.dart';

class ThreadsViewModel extends StateNotifier<ThreadsState> {
  final GetThreads getThreads;

  ThreadsViewModel(this.getThreads)
    : super(ThreadsState(threads: [], loading: true)) {
    loadThreads();
  }

  Future<void> loadThreads() async {
    state = state.copyWith(loading: true);
    try {
      final threads = await getThreads();
      state = state.copyWith(threads: threads, loading: false);
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  void onIncomingMessage(
    MessageEntity msg,
    String otherUserId,
    String? listingId,
  ) {
    final threads = state.threads;
    final index = threads.indexWhere(
      (t) => t.otherUserId == otherUserId && t.listingId == listingId,
    );

    if (index != -1) {
      final oldThread = threads[index];
      final updatedThread = oldThread.copyWith(
        lastMessage: msg,
        unreadCount: oldThread.unreadCount + 1,
      );

      final updatedThreads = [...threads];
      updatedThreads[index] = updatedThread;
      // Move updated thread to the front
      final reorderedThreads = <ThreadEntity>[
        updatedThread,
        ...updatedThreads.where((t) => t != updatedThread),
      ];
      state = state.copyWith(threads: reorderedThreads);
    } else {
      final newThread = ThreadEntity(
        otherUserId: otherUserId,
        listingId: listingId,
        lastMessage: msg,
        unreadCount: 1,
      );
      state = state.copyWith(threads: [newThread, ...threads]);
    }
  }
}
