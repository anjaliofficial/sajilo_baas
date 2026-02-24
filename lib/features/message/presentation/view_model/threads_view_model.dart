import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/features/message/domain/entities/message_entity.dart';
import 'package:sajilo_baas/features/message/presentation/view_model/threads_view_modeldart';
import '../../domain/entities/thread_entity.dart';
import '../../domain/usecases/get_threads.dart';

class ThreadsViewModel extends StateNotifier<ThreadsState> {
  final GetThreads getThreads;

  ThreadsViewModel(this.getThreads)
    : super(ThreadsState(threads: [], loading: true)) {
    loadThreads();
  }

  Future<void> loadThreads() async {
    state = state.copyWith(loading: true);
    try {
      final threadsList = await getThreads();
      state = state.copyWith(threads: threadsList, loading: false);
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  /// Called when a new message arrives
  void onIncomingMessage(
    String otherUserId,
    String? listingId,
    String content,
  ) {
    final threads = state.threads;
    final index = threads.indexWhere(
      (t) => t.otherUserId == otherUserId && t.listingId == listingId,
    );

    if (index != -1) {
      final oldThread = threads[index];
      final updatedThread = ThreadEntity(
        otherUserId: oldThread.otherUserId,
        listingId: oldThread.listingId,
        lastMessage: oldThread.lastMessage.copyWith(
          content: content,
          read: false,
        ),
        unreadCount: oldThread.unreadCount + 1,
      );

      final updatedThreads = [...threads];
      updatedThreads.removeAt(index);
      updatedThreads.insert(0, updatedThread); // move updated to top
      state = state.copyWith(threads: updatedThreads);
    } else {
      // New thread
      final newThread = ThreadEntity(
        otherUserId: otherUserId,
        listingId: listingId,
        lastMessage: oldThreadFallback(content), // fallback message
        unreadCount: 1,
      );
      state = state.copyWith(threads: [newThread, ...threads]);
    }
  }

  // Helper: fallback MessageEntity for new thread
  MessageEntity oldThreadFallback(String content) {
    return MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: otherUserIdFallback(),
      receiverId: "ME",
      content: content,
      type: "text",
      read: false,
      status: "sent",
      createdAt: DateTime.now(),
    );
  }

  String otherUserIdFallback() => "Unknown"; // replace if needed
}
