import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sajilo_baas/features/review/presentation/widgets/star_rating_widget.dart';

void main() {
  testWidgets('renders StarRatingWidget', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: StarRatingWidget(rating: 3)));
    expect(find.byType(StarRatingWidget), findsOneWidget);
  });

  testWidgets('calls onChanged when star tapped', (WidgetTester tester) async {
    int? tappedRating;
    await tester.pumpWidget(
      MaterialApp(
        home: StarRatingWidget(
          rating: 2,
          onChanged: (value) {
            tappedRating = value;
          },
        ),
      ),
    );
    // Tap the third star (index 2)
    await tester.tap(find.byType(IconButton).at(2));
    await tester.pump();
    expect(tappedRating, 3);
  });
}
