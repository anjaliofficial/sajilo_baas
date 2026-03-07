import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/dashboard/presentation/widgets/listing_list_item.dart';

void main() {
  testWidgets('renders ListingListItem', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ListingListItem(
          imageUrl: 'assets/images/test_image.png',
          title: 'Test Listing',
          location: 'Test Location',
          price: '1000',
          rating: 4.5,
        ),
      ),
    );
    expect(find.byType(ListingListItem), findsOneWidget);
    expect(find.text('Test Listing'), findsOneWidget);
  });
}
