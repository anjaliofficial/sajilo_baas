import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sajilo_baas/features/message/domain/entities/message_entity.dart';
import 'package:sajilo_baas/features/message/presentation/widgets/message_bubble.dart';

void main() {
  testWidgets('renders MessageBubble', (WidgetTester tester) async {
    final message = MessageEntity(
      id: 'msg1',
      senderId: 'user1',
      receiverId: 'user2',
      senderName: 'Alice',
      senderProfilePicture: '',
      receiverName: 'Bob',
      receiverProfilePicture: '',
      listingId: 'listing1',
      content: 'Hello!',
      type: 'text',
      read: true,
      status: 'sent',
      createdAt: DateTime.now(),
      media: [],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MessageBubble(
          message: message,
          isMe: true,
          otherUserId: 'user2',
          listingId: 'listing1',
          headerName: 'Bob',
          headerAvatar: '',
        ),
      ),
    );
    expect(find.byType(MessageBubble), findsOneWidget);
    expect(find.text('Hello!'), findsOneWidget);
  });
}
