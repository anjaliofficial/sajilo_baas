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
                  child: ListTile(
                    title: Text(notification.title),
                    subtitle: Text(notification.body),
                    trailing: notification.isRead
                        ? null
                        : const Icon(
                            Icons.circle,
                            size: 10,
                            color: Colors.blue,
                          ),
                    onTap: () {
                      ref
                          .read(notificationProvider.notifier)
                          .markAsRead(notification.id);
                      if (notification.route != null) {
                        Navigator.pushNamed(context, notification.route!);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
