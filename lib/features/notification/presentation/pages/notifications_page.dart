// presentation/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(notificationProvider.notifier).fetchNotifications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<NotificationState>(notificationProvider, (prev, next) {
      if (prev == null ||
          next.notifications.length > prev.notifications.length) {
        final newNotification = next.notifications.first;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New: ${newNotification.title}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    final state = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.notifications.isEmpty
          ? const Center(child: Text("No notifications"))
          : ListView.builder(
              itemCount: state.notifications.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return Dismissible(
                  key: ValueKey(notification.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref
                        .read(notificationProvider.notifier)
                        .delete(notification.id);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        if (notification.route != null) {
                          final route = notification.route!;
                          if (route.startsWith('/chat')) {
                            final uri = Uri.parse(route);
                            final hostId = uri.queryParameters['hostId'];
                            final listingId = uri.queryParameters['listingId'];
                            await Navigator.pushNamed(
                              context,
                              '/chat',
                              arguments: {
                                'hostId': hostId,
                                'listingId': listingId,
                              },
                            );
                          } else if (route == '/bookings') {
                            await Navigator.pushNamed(context, '/bookings');
                          } else if (route == '/messages') {
                            await Navigator.pushNamed(context, '/messages');
                          } else if (route == '/reviews') {
                            await Navigator.pushNamed(context, '/reviews');
                          } else {
                            await Navigator.pushNamed(context, route);
                          }
                        }
                        await ref
                            .read(notificationProvider.notifier)
                            .markAsRead(notification.id);
                        await ref
                            .read(notificationProvider.notifier)
                            .fetchNotifications();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (!notification.isRead)
                                  const Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: Colors.blue,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notification.body,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Received: ${notification.createdAt.toLocal().toString().substring(0, 19)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
