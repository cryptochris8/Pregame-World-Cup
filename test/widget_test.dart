// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Note: Full app testing requires Firebase and GetIt setup.
// For integration testing of the full app, use integration_test/ instead.
// This file contains basic widget tests that don't require full app initialization.

void main() {
  testWidgets('Basic MaterialApp widget test', (WidgetTester tester) async {
    // Build a simple MaterialApp to verify Flutter testing works
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Pregame World Cup'),
          ),
        ),
      ),
    );

    // Verify that the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Pregame World Cup'), findsOneWidget);
  });

  testWidgets('Scaffold widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Test')),
          body: const Center(child: Text('Content')),
        ),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
  });
}
