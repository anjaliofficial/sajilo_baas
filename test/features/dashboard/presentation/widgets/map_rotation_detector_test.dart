import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/dashboard/presentation/widgets/map_rotation_detector.dart';

void main() {
  testWidgets('renders MapRotationDetector', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MapRotationDetector(
          child: const Text('Map'),
          onRotationUpdate: (rotation) {},
        ),
      ),
    );
    expect(find.byType(MapRotationDetector), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
  });
}
