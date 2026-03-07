import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/dashboard/presentation/widgets/compass_button.dart';

void main() {
  group('CompassButton Widget', () {
    testWidgets('renders when rotation is not near zero', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CompassButton(rotation: 45.0, onResetRotation: () {}),
        ),
      );
      expect(find.byType(CompassButton), findsOneWidget);
      expect(find.byIcon(Icons.navigation), findsOneWidget);
    });

    testWidgets('does not render when rotation is near zero', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CompassButton(rotation: 0.05, onResetRotation: () {}),
        ),
      );
      // Since CompassButton returns Container, check for that
      expect(find.byType(Container), findsOneWidget);
      // The CompassButton widget is still present in the tree, but visually empty
      expect(find.byType(CompassButton), findsOneWidget);
    });

    testWidgets('calls onResetRotation when tapped', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: CompassButton(
            rotation: 90.0,
            onResetRotation: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });
}
