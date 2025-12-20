import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart' as test;
import 'package:videocalling/features/myapp_screen.dart';

void main() {
  testWidgets('App starts and MyApp is present', (WidgetTester tester) async {
    // Run the app
    await tester.pumpWidget(const MyApp());

    // Verify that MyApp is present in the widget tree
    expect(find.byType(MyApp), findsOneWidget);
  });
}
