import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:sajilo_baas/features/profile/domain/entities/profile_entity.dart';

void main() {
  final testProfile = ProfileEntity(
    id: '1',
    fullName: 'Test User',
    email: 'test@example.com',
    phoneNumber: '1234567890',
    address: 'Test Address',
    role: 'user',
    profilePicture: null,
  );

  testWidgets('Edit profile form loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: EditProfilePage(profile: testProfile)),
    );
    expect(find.byType(TextFormField), findsWidgets);
  });

  testWidgets('Save button is present', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: EditProfilePage(profile: testProfile)),
    );
    expect(find.text('Save'), findsOneWidget);
  });
}
