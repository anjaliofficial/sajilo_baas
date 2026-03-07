import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/message/presentation/widgets/media_bubble.dart';

void main() {
  testWidgets('renders MediaBubble', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaBubble(
          url: 'https://via.placeholder.com/180x150',
          kind: 'image',
        ),
      ),
    );
    expect(find.byType(MediaBubble), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
