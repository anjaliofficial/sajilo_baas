import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ImageUploadScreen extends StatelessWidget {
  const ImageUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Upload Image'),
          ElevatedButton(onPressed: () {}, child: const Text('Upload Image')),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('Screen loads correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ImageUploadScreen()));

    expect(find.byType(ImageUploadScreen), findsOneWidget);
  });

  testWidgets('Upload Image text is visible', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ImageUploadScreen()));

    expect(find.text('Upload Image'), findsWidgets);
  });

  testWidgets('Upload button exists', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ImageUploadScreen()));

    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Upload button is tappable', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ImageUploadScreen()));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Widget builds without errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ImageUploadScreen()));

    expect(tester.takeException(), isNull);
  });
}
