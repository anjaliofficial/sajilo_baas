import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/review/presentation/widgets/review_card.dart';

void main() {
  testWidgets('renders ReplyButton', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReplyButton(
          reviewId: 'review1',
          authorId: 'author1',
          replyController: TextEditingController(),
        ),
      ),
    );
    expect(find.byType(ReplyButton), findsOneWidget);
    expect(find.text('Reply'), findsOneWidget);
  });
}
