import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/review/presentation/widgets/average_rating.dart';

void main() {
  testWidgets('renders AverageRating', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AverageRating()));
    expect(find.byType(AverageRating), findsOneWidget);
  });
}
