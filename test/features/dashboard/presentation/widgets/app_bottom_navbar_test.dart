import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/dashboard/presentation/widgets/app_bottom_navbar.dart';

void main() {
  testWidgets('renders AppBottomNavBar', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: AppBottomNavBar(currentIndex: 0, onTap: (_) {})),
    );
    expect(find.byType(AppBottomNavBar), findsOneWidget);
  });
}
