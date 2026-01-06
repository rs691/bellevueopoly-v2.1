import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../screens/image_upload_screen.dart';

void main() {
  testWidgets('Navigate to ImageUploadScreen', (WidgetTester tester) async {
    // Build your app and trigger a frame. 
    await tester.pumpWidget(MyApp());
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: IconButton(
            icon: Icon(Icons.upload),
            onPressed: null, // This would normally navigate to ImageUploadScreen
          ),
        ),
      ),
    )); 

    // Navigate to the ImageUploadScreen
    await tester.tap(find.byIcon(Icons.upload));
    await tester.pumpAndSettle();

    // Verify that ImageUploadScreen is displayed
    expect(find.byType(ImageUploadScreen), findsOneWidget);
  });
}