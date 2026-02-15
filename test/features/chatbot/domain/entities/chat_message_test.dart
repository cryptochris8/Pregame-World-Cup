import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/chatbot/domain/entities/chat_message.dart';

void main() {
  group('ChatMessage', () {
    group('Constructor', () {
      test('creates user message with required fields', () {
        final message = ChatMessage(
          text: 'Hello, what games are on today?',
          type: ChatMessageType.user,
        );

        expect(message.text, equals('Hello, what games are on today?'));
        expect(message.type, equals(ChatMessageType.user));
        expect(message.timestamp, isNotNull);
      });

      test('creates bot message with required fields', () {
        final message = ChatMessage(
          text: 'There are 5 games scheduled for today!',
          type: ChatMessageType.bot,
        );

        expect(message.text, equals('There are 5 games scheduled for today!'));
        expect(message.type, equals(ChatMessageType.bot));
      });

      test('creates message with custom timestamp', () {
        final customTime = DateTime(2024, 10, 15, 14, 30);
        final message = ChatMessage(
          text: 'Test message',
          type: ChatMessageType.user,
          timestamp: customTime,
        );

        expect(message.timestamp, equals(customTime));
      });

      test('defaults timestamp to now when not provided', () {
        final before = DateTime.now();
        final message = ChatMessage(
          text: 'Test',
          type: ChatMessageType.user,
        );
        final after = DateTime.now();

        expect(message.timestamp.isAfter(before) || message.timestamp.isAtSameMomentAs(before), isTrue);
        expect(message.timestamp.isBefore(after) || message.timestamp.isAtSameMomentAs(after), isTrue);
      });
    });

    group('Message types', () {
      test('user type is correctly identified', () {
        final message = ChatMessage(
          text: 'User query',
          type: ChatMessageType.user,
        );

        expect(message.type, equals(ChatMessageType.user));
        expect(message.type, isNot(equals(ChatMessageType.bot)));
      });

      test('bot type is correctly identified', () {
        final message = ChatMessage(
          text: 'Bot response',
          type: ChatMessageType.bot,
        );

        expect(message.type, equals(ChatMessageType.bot));
        expect(message.type, isNot(equals(ChatMessageType.user)));
      });
    });

    group('Text content', () {
      test('handles empty text', () {
        final message = ChatMessage(
          text: '',
          type: ChatMessageType.user,
        );

        expect(message.text, isEmpty);
      });

      test('handles long text', () {
        final longText = 'A' * 1000;
        final message = ChatMessage(
          text: longText,
          type: ChatMessageType.bot,
        );

        expect(message.text.length, equals(1000));
      });

      test('handles special characters', () {
        const specialText = 'What\u0027s the score? & how\u0027s the weather?';
        final message = ChatMessage(
          text: specialText,
          type: ChatMessageType.user,
        );

        expect(message.text, contains('score'));
        expect(message.text, contains('weather'));
      });

      test('handles newlines', () {
        const multilineText = 'Line 1\nLine 2\nLine 3';
        final message = ChatMessage(
          text: multilineText,
          type: ChatMessageType.bot,
        );

        expect(message.text, contains('\n'));
        expect(message.text.split('\n').length, equals(3));
      });

      test('handles unicode and emojis', () {
        const emojiText = 'Vai Brasil! \u26BD\uD83C\uDDF3';
        final message = ChatMessage(
          text: emojiText,
          type: ChatMessageType.user,
        );

        expect(message.text, contains('\u26BD'));
        expect(message.text, contains('Brasil'));
      });
    });

    group('Timestamp', () {
      test('timestamps are preserved correctly', () {
        final specificTime = DateTime(2024, 11, 15, 10, 30, 45, 123);
        final message = ChatMessage(
          text: 'Test',
          type: ChatMessageType.user,
          timestamp: specificTime,
        );

        expect(message.timestamp.year, equals(2024));
        expect(message.timestamp.month, equals(11));
        expect(message.timestamp.day, equals(15));
        expect(message.timestamp.hour, equals(10));
        expect(message.timestamp.minute, equals(30));
        expect(message.timestamp.second, equals(45));
      });

      test('different messages have different timestamps', () {
        final message1 = ChatMessage(
          text: 'First',
          type: ChatMessageType.user,
          timestamp: DateTime(2024, 10, 15, 12, 0),
        );

        final message2 = ChatMessage(
          text: 'Second',
          type: ChatMessageType.bot,
          timestamp: DateTime(2024, 10, 15, 12, 1),
        );

        expect(message1.timestamp, isNot(equals(message2.timestamp)));
        expect(message2.timestamp.isAfter(message1.timestamp), isTrue);
      });
    });

    group('Conversation simulation', () {
      test('can create a conversation flow', () {
        final messages = [
          ChatMessage(
            text: 'What time is the Brazil match?',
            type: ChatMessageType.user,
            timestamp: DateTime(2024, 10, 15, 12, 0, 0),
          ),
          ChatMessage(
            text: 'Brazil plays at 3:30 PM EST against Argentina.',
            type: ChatMessageType.bot,
            timestamp: DateTime(2024, 10, 15, 12, 0, 2),
          ),
          ChatMessage(
            text: 'Where is it being played?',
            type: ChatMessageType.user,
            timestamp: DateTime(2024, 10, 15, 12, 0, 10),
          ),
          ChatMessage(
            text: 'The match is at MetLife Stadium in East Rutherford, New Jersey.',
            type: ChatMessageType.bot,
            timestamp: DateTime(2024, 10, 15, 12, 0, 12),
          ),
        ];

        expect(messages.length, equals(4));
        expect(messages[0].type, equals(ChatMessageType.user));
        expect(messages[1].type, equals(ChatMessageType.bot));
        expect(messages[2].type, equals(ChatMessageType.user));
        expect(messages[3].type, equals(ChatMessageType.bot));

        // Verify chronological order
        for (int i = 1; i < messages.length; i++) {
          expect(messages[i].timestamp.isAfter(messages[i - 1].timestamp), isTrue);
        }
      });

      test('can filter by message type', () {
        final messages = [
          ChatMessage(text: 'Q1', type: ChatMessageType.user),
          ChatMessage(text: 'A1', type: ChatMessageType.bot),
          ChatMessage(text: 'Q2', type: ChatMessageType.user),
          ChatMessage(text: 'A2', type: ChatMessageType.bot),
          ChatMessage(text: 'Q3', type: ChatMessageType.user),
        ];

        final userMessages = messages
            .where((m) => m.type == ChatMessageType.user)
            .toList();
        final botMessages = messages
            .where((m) => m.type == ChatMessageType.bot)
            .toList();

        expect(userMessages.length, equals(3));
        expect(botMessages.length, equals(2));
      });
    });
  });

  group('ChatMessageType', () {
    test('contains expected types', () {
      expect(ChatMessageType.values, contains(ChatMessageType.user));
      expect(ChatMessageType.values, contains(ChatMessageType.bot));
    });

    test('has exactly 3 types', () {
      expect(ChatMessageType.values.length, equals(3));
    });

    test('types can be compared', () {
      expect(ChatMessageType.user == ChatMessageType.user, isTrue);
      expect(ChatMessageType.user == ChatMessageType.bot, isFalse);
      expect(ChatMessageType.bot == ChatMessageType.bot, isTrue);
    });

    test('types have string representation', () {
      expect(ChatMessageType.user.toString(), contains('user'));
      expect(ChatMessageType.bot.toString(), contains('bot'));
    });
  });
}
