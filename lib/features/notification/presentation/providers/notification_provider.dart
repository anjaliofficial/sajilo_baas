import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/core/network/dio_provider.dart';

import '../../data/datasources/remote/notification_remote_datasource.dart';
import '../../data/datasources/remote/notification_socket_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_notification_read.dart';
import '../../domain/usecases/delete_notification.dart';

// ------------------------
// Repository Provider (Remote Only)
// ------------------------
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final remote = NotificationRemoteDataSourceImpl(dio);
  return NotificationRepositoryImpl(remote);
});

// ------------------------
// Notification State
// ------------------------
class NotificationState {
  final bool isLoading;
  final List<NotificationEntity> notifications;

  NotificationState({this.isLoading = false, this.notifications = const []});

  NotificationState copyWith({
    bool? isLoading,
    List<NotificationEntity>? notifications,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
    );
  }
}

// ------------------------
// Notification Notifier
// ------------------------
class NotificationNotifier extends StateNotifier<NotificationState> {
  final GetNotifications getNotifications;
  final MarkNotificationRead markRead;
  final DeleteNotification deleteNotification;
  NotificationSocketDataSource? socketDataSource;

  NotificationNotifier(
    this.getNotifications,
    this.markRead,
    this.deleteNotification, {
    this.socketDataSource,
  }) : super(NotificationState()) {
    _listenToSocket();
  }

  void _listenToSocket() {
    if (socketDataSource == null) return;
    socketDataSource!.listenNotifications().listen(
      (notification) {
        print(
          '[NotificationProvider] WebSocket received notification: ${notification.title}',
        );
        state = state.copyWith(
          notifications: [notification, ...state.notifications],
        );
      },
      onError: (error) {
        print('[NotificationProvider] WebSocket error: $error');
      },
      onDone: () {
        print('[NotificationProvider] WebSocket connection closed');
      },
    );
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await getNotifications();
      print(
        '[NotificationProvider] REST API fetched notifications: count=${data.length}',
      );
      state = state.copyWith(isLoading: false, notifications: data);
    } catch (e) {
      print('[NotificationProvider] REST API error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> markAsRead(String id) async {
    await markRead(id);

    state = state.copyWith(
      notifications: state.notifications.map((n) {
        if (n.id == id) {
          return NotificationEntity(
            id: n.id,
            title: n.title,
            body: n.body,
            isRead: true,
            createdAt: n.createdAt,
            route: n.route,
          );
        }
        return n;
      }).toList(),
    );
  }

  Future<void> delete(String id) async {
    await deleteNotification(id);
    state = state.copyWith(
      notifications: state.notifications.where((n) => n.id != id).toList(),
    );
  }
}

// ------------------------
// StateNotifier Provider
// ------------------------
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      final repo = ref.watch(notificationRepositoryProvider);
      // Replace with your actual socket URL
      final socketUrl = 'ws://10.0.2.2:5050/notifications';
      final socketDataSource = NotificationSocketDataSource(socketUrl);
      return NotificationNotifier(
        GetNotifications(repo),
        MarkNotificationRead(repo),
        DeleteNotification(repo),
        socketDataSource: socketDataSource,
      );
    });
