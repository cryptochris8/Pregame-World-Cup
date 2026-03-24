import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/chatbot/presentation/widgets/chatbot_fab.dart';
import 'package:pregame_world_cup/features/chatbot/presentation/widgets/copa_avatar.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().contains('A RenderFlex overflowed by'),
          );
      if (isOverflowError) {
      } else {
        FlutterError.presentError(details);
      }
    };
  });

  testWidgets('renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChatbotFab(),
        ),
      ),
    );

    expect(find.byType(ChatbotFab), findsOneWidget);
  });

  testWidgets('is a FloatingActionButton', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChatbotFab(),
        ),
      ),
    );

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('contains CopaAvatar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChatbotFab(),
        ),
      ),
    );

    expect(find.byType(CopaAvatar), findsOneWidget);
  });
}
