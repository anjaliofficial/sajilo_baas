import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/notification/domain/repositories/notification_repository.dart';
import 'package:sajilo_baas/features/notification/domain/usecases/delete_notification.dart';
import 'package:sajilo_baas/features/notification/domain/usecases/get_notifications.dart';
import 'package:sajilo_baas/features/notification/domain/usecases/mark_notification_read.dart';
import 'package:sajilo_baas/features/notification/presentation/pages/notifications_page.dart';
import 'package:sajilo_baas/features/notification/presentation/providers/notification_provider.dart';
import 'package:sajilo_baas/features/notification/domain/entities/notification_entity.dart';

/// Fake Notifier to avoid network calls during testing
class FakeNotificationRepository implements NotificationRepository {
  @override
  Future<List<NotificationEntity>> getNotifications() async => [
    NotificationEntity(
      id: '1',
      title: 'Test Notification',
      body: 'This is a test.',
      isRead: false,
      createdAt: DateTime.now(),
    ),
  ];
  @override
  Future<void> markAsRead(String id) async {}
  @override
  Future<void> sendDeviceToken(String token) async {}
  @override
  Future<void> deleteNotification(String id) async {}
}

class FakeNotificationNotifier extends NotificationNotifier {
  FakeNotificationNotifier()
    : super(
        GetNotifications(FakeNotificationRepository()),
        MarkNotificationRead(FakeNotificationRepository()),
        DeleteNotification(FakeNotificationRepository()),
      ) {
    state = NotificationState(
      isLoading: false,
      notifications: [
        NotificationEntity(
          id: '1',
          title: 'Test Notification',
          body: 'This is a test.',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  @override
  Future<void> fetchNotifications() async {
    // Do nothing to avoid API calls
  }
}

void main() {
  testWidgets('Notifications page loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWith(
            (ref) => FakeNotificationNotifier(),
          ),
        ],
        child: const MaterialApp(home: NotificationsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('Notification list is present', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWith(
            (ref) => FakeNotificationNotifier(),
          ),
        ],
        child: const MaterialApp(home: NotificationsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Test Notification'), findsOneWidget);
  });
}
