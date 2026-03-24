import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/chat_empty_state.dart';

void main() {
  group('ChatEmptyState', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ChatEmptyState()),
        ),
      );

      expect(find.byType(ChatEmptyState), findsOneWidget);
    });

    testWidgets('displays chat bubble outline icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ChatEmptyState()),
        ),
      );

      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('displays "No messages yet" text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ChatEmptyState()),
        ),
      );

      expect(find.text('No messages yet'), findsOneWidget);
    });

    testWidgets('displays "Start the conversation!" text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ChatEmptyState()),
        ),
      );

      expect(find.text('Start the conversation!'), findsOneWidget);
    });

    testWidgets('contains Column with centered content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ChatEmptyState()),
        ),
      );

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Center), findsWidgets);
    });
  });
}
