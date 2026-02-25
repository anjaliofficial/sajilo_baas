import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import 'package:sajilo_baas/features/message/presentation/providers/message_providers.dart';
import 'package:sajilo_baas/features/message/presentation/pages/chat_page.dart';
import 'package:sajilo_baas/features/auth/presentation/providers/auth_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  String _search = '';
  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    // Force reload threads when screen is opened
    Future.microtask(
      () => ref.read(threadsViewModelProvider.notifier).loadThreads(),
    );
    final authState = ref.read(authViewModelProvider);
    final token = authState.authEntity?.token;
    if (token != null && token.isNotEmpty) {
      _socket = IO.io('http://10.205.75.20:5050', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {'token': token},
      });
      _socket!.connect();
      _socket!.onConnect((_) {
        debugPrint('Socket connected');
      });
      _socket!.on('receiveMessage', (data) {
        ref.read(threadsViewModelProvider.notifier).loadThreads();
      });
      // Optionally listen for other events (messageStatusUpdate, etc)
    }
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final threadsState = ref.watch(threadsViewModelProvider);
    final threads = threadsState.threads;
    final authState = ref.watch(authViewModelProvider);
    final currentUserId = authState.authEntity?.authId ?? '';
    // Group threads by otherUserId and keep only the latest (by lastMessage.createdAt)
    final Map<String, dynamic> latestThreadsMap = {};
    for (final thread in threads) {
      if (thread.otherUserId.isEmpty ||
          thread.listingId == null ||
          thread.listingId!.isEmpty) {
        continue;
      }
      final existing = latestThreadsMap[thread.otherUserId];
      if (existing == null ||
          thread.lastMessage.createdAt.isAfter(
            existing.lastMessage.createdAt,
          )) {
        latestThreadsMap[thread.otherUserId] = thread;
      }
    }
    List filteredThreads = latestThreadsMap.values.toList();
    // Optionally, apply search
    if (_search.isNotEmpty) {
      filteredThreads = filteredThreads.where((thread) {
        final name = thread.otherUserName ?? '';
        final content = thread.lastMessage.content;
        return name.toLowerCase().contains(_search.toLowerCase()) ||
            content.toLowerCase().contains(_search.toLowerCase());
      }).toList();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: threadsState.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search conversations...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _search = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: filteredThreads.isEmpty
                      ? const Center(
                          child: Text(
                            'No conversations yet.',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredThreads.length,
                          separatorBuilder: (_, __) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            final thread = filteredThreads[index];
                            final lastMsg = thread.lastMessage;
                            final name = thread.otherUserName ?? 'User';
                            String? avatar = thread.otherUserImage;
                            if (avatar != null &&
                                avatar.isNotEmpty &&
                                !avatar.startsWith('http')) {
                              avatar = ApiEndpoints.staticBaseUrl + avatar;
                            }
                            final keyString =
                                '${thread.otherUserId}_${thread.listingId ?? ''}_${lastMsg.id}';
                            return Dismissible(
                              key: Key(keyString),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (direction) {
                                // TODO: Implement delete thread logic (API call or local remove)
                                // For now, just show a snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Conversation deleted'),
                                  ),
                                );
                                // Optionally, remove from provider/state
                                // You should implement a method in your ViewModel to remove the thread
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      (avatar != null && avatar.isNotEmpty)
                                      ? NetworkImage(avatar)
                                      : const AssetImage(
                                              'assets/images/default_avatar.jpg',
                                            )
                                            as ImageProvider,
                                ),
                                title: Text(name),
                                subtitle: Text(
                                  lastMsg.content,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: thread.unreadCount > 0
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 20,
                                          minHeight: 20,
                                        ),
                                        child: Text(
                                          thread.unreadCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
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
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
