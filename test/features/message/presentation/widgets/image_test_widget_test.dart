import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sajilo_baas/features/message/presentation/widgets/image_test_widget.dart';

void main() {
  testWidgets('renders ImageTestWidget', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ImageTestWidget(imageUrl: 'https://via.placeholder.com/200'),
      ),
    );
    expect(find.byType(ImageTestWidget), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
