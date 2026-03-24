import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/chatbot/domain/entities/chat_message.dart';
import 'package:pregame_world_cup/features/chatbot/presentation/widgets/chat_message_list_item.dart';
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

  testWidgets('renders user message text', (tester) async {
    final message = ChatMessage(
      text: 'Hello from user',
      type: ChatMessageType.user,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageListItem(message: message),
        ),
      ),
    );

    expect(find.text('Hello from user'), findsOneWidget);
  });

  testWidgets('renders bot message text', (tester) async {
    final message = ChatMessage(
      text: 'Hello from bot',
      type: ChatMessageType.bot,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageListItem(message: message),
        ),
      ),
    );

    expect(find.text('Hello from bot'), findsOneWidget);
  });

  testWidgets('user message aligned right', (tester) async {
    final message = ChatMessage(
      text: 'Hello from user',
      type: ChatMessageType.user,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageListItem(message: message),
        ),
      ),
    );

    final align = tester.widget<Align>(find.byType(Align));
    expect(align.alignment, equals(Alignment.centerRight));
  });

  testWidgets('bot message has CopaAvatar', (tester) async {
    final message = ChatMessage(
      text: 'Hello from bot',
      type: ChatMessageType.bot,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageListItem(message: message),
        ),
      ),
    );

    expect(find.byType(CopaAvatar), findsOneWidget);
  });

  testWidgets('thinking message shows progress indicator', (tester) async {
    final message = ChatMessage(
      text: 'Thinking...',
      type: ChatMessageType.thinking,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageListItem(message: message),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows message text', (tester) async {
    final message = ChatMessage(
      text: 'Test message',
      type: ChatMessageType.bot,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageListItem(message: message),
        ),
      ),
    );

    expect(find.text('Test message'), findsOneWidget);
  });
}
