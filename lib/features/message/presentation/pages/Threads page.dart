import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/message/presentation/pages/chat_page.dart';
import '../providers/threads_provider.dart';

class ThreadsPage extends ConsumerWidget {
  const ThreadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsState = ref.watch(threadsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: threadsState.loading
          ? const Center(child: CircularProgressIndicator())
          : threadsState.threads.isEmpty
          ? const Center(child: Text('No chats yet'))
          : ListView.builder(
              itemCount: threadsState.threads.length,
              itemBuilder: (context, index) {
                final thread = threadsState.threads[index];
                final lastMsg = thread.lastMessage;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(thread.otherUserId[0].toUpperCase()),
                  ),
                  title: Text(thread.otherUserId),
                  subtitle: Text(
                    lastMsg.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: thread.unreadCount > 0
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Text(
                            '${thread.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          otherUserId: thread.otherUserId,
                          listingId: thread.listingId ?? '',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
