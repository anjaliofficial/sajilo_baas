import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/review/presentation/widgets/reply_widget.dart';
import 'package:sajilo_baas/features/review/domain/entities/reply_entity.dart';

void main() {
  testWidgets('renders ReplyWidget', (WidgetTester tester) async {
    final reply = ReplyEntity(
      id: 'temp-1',
      authorId: 'user123',
      text: 'Test reply',
      createdAt: DateTime.now(),
      author: {'name': 'Test User'},
    );
    await tester.pumpWidget(
      MaterialApp(home: ReplyWidget(reply: reply, isMe: true)),
    );
    expect(find.byType(ReplyWidget), findsOneWidget);
    expect(find.text('Test reply'), findsOneWidget);
  });
}
