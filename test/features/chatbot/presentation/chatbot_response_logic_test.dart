import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/chatbot/domain/entities/chat_message.dart';

/// Tests the chatbot fallback response logic.
///
/// Since `_generateSimpleResponse` is a private method in ChatScreen, we
/// replicate its rule-based logic here for testing. This tests the same keyword
/// matching patterns that the chatbot uses when the AI service is unavailable.
String generateSimpleResponse(String userInput) {
  if (userInput.contains('hello') || userInput.contains('hi')) {
    return "Hello! I'm here to help you with World Cup 2026 schedules, teams, venues, and predictions.";
  } else if (userInput.contains('game') ||
      userInput.contains('schedule') ||
      userInput.contains('match')) {
    return "You can view all 104 World Cup matches on the schedule screen. Tap on any match to see details and nearby venues!";
  } else if (userInput.contains('venue') ||
      userInput.contains('bar') ||
      userInput.contains('restaurant')) {
    return "To find venues near a match, select a game from the schedule and I'll show you nearby bars and restaurants for watch parties!";
  } else if (userInput.contains('team') || userInput.contains('group')) {
    return "All 48 qualified teams are listed in the World Cup section. You can set favorites and follow their group stage journey!";
  } else if (userInput.contains('predict') ||
      userInput.contains('winner') ||
      userInput.contains('who will win')) {
    return "Check the predictions feature for AI-powered match predictions! You can also make your own picks and compete with friends.";
  } else if (userInput.contains('help')) {
    return "I can help you with:\n- Match schedules and results\n- Team info and group standings\n- AI match predictions\n- Venue and watch party recommendations\n- World Cup 2026 general knowledge\n\nWhat would you like to know?";
  } else if (userInput.contains('thank')) {
    return "You're welcome! Enjoy the World Cup!";
  } else {
    return "I'm your World Cup 2026 assistant! Ask me about match schedules, team information, predictions, or finding venues to watch the games.";
  }
}

void main() {
  group('Chatbot fallback response logic', () {
    group('Greeting responses', () {
      test('responds to "hello"', () {
        final response = generateSimpleResponse('hello');
        expect(response, contains('Hello'));
        expect(response, contains('World Cup 2026'));
      });

      test('responds to "hi"', () {
        final response = generateSimpleResponse('hi');
        expect(response, contains('Hello'));
      });

      test('responds to "hi there"', () {
        final response = generateSimpleResponse('hi there');
        expect(response, contains('Hello'));
      });

      test('responds to "hello world"', () {
        final response = generateSimpleResponse('hello world');
        expect(response, contains('Hello'));
      });
    });

    group('Game/Schedule responses', () {
      test('responds to "game" keyword', () {
        final response = generateSimpleResponse('what game is on today');
        expect(response, contains('104 World Cup matches'));
      });

      test('responds to "schedule" keyword', () {
        final response = generateSimpleResponse('show me the schedule');
        expect(response, contains('schedule screen'));
      });

      test('responds to "match" keyword', () {
        final response = generateSimpleResponse('when is the next match');
        expect(response, contains('match'));
      });
    });

    group('Venue responses', () {
      test('responds to "venue" keyword', () {
        final response = generateSimpleResponse('find a venue');
        expect(response, contains('venues'));
      });

      test('responds to "bar" keyword', () {
        final response = generateSimpleResponse('any bar nearby');
        expect(response, contains('bars'));
      });

      test('responds to "restaurant" keyword', () {
        final response = generateSimpleResponse('restaurant to watch');
        expect(response, contains('restaurants'));
      });
    });

    group('Team responses', () {
      test('responds to "team" keyword', () {
        final response = generateSimpleResponse('tell me about teams');
        expect(response, contains('48 qualified teams'));
      });

      test('responds to "group" keyword', () {
        final response = generateSimpleResponse('what are the groups');
        expect(response, contains('group stage'));
      });
    });

    group('Prediction responses', () {
      test('responds to "predict" keyword', () {
        final response = generateSimpleResponse('predict the winner');
        expect(response, contains('predictions'));
      });

      test('responds to "winner" keyword', () {
        final response = generateSimpleResponse('who is the winner');
        expect(response, contains('predictions'));
      });

      test('responds to "who will win" phrase', () {
        final response = generateSimpleResponse('who will win the world cup');
        expect(response, contains('predictions'));
      });
    });

    group('Help responses', () {
      test('responds to "help" keyword', () {
        final response = generateSimpleResponse('help');
        expect(response, contains('Match schedules'));
        expect(response, contains('Team info'));
        expect(response, contains('AI match predictions'));
        expect(response, contains('Venue'));
        expect(response, contains('World Cup 2026'));
      });

      test('help response contains newlines for formatting', () {
        final response = generateSimpleResponse('i need help');
        expect(response, contains('\n'));
      });
    });

    group('Thank you responses', () {
      test('responds to "thank" keyword', () {
        final response = generateSimpleResponse('thank you');
        expect(response, contains("You're welcome"));
      });

      test('responds to "thanks"', () {
        final response = generateSimpleResponse('thanks a lot');
        expect(response, contains("You're welcome"));
      });
    });

    group('Default response', () {
      test('gives generic response for unrecognized input', () {
        final response = generateSimpleResponse('what is the weather');
        expect(response, contains('World Cup 2026 assistant'));
      });

      test('gives generic response for random text', () {
        final response = generateSimpleResponse('asdf1234');
        expect(response, contains('World Cup 2026 assistant'));
      });

      test('gives generic response for empty string', () {
        final response = generateSimpleResponse('');
        expect(response, contains('World Cup 2026 assistant'));
      });
    });

    group('Keyword priority', () {
      test('"hi" takes priority over other keywords in same input', () {
        // "hi" appears before other keywords so greeting response wins
        final response = generateSimpleResponse('hi what game is on');
        expect(response, contains('Hello'));
      });

      test('"game" takes priority over "venue" when game appears first', () {
        final response = generateSimpleResponse('game at a venue');
        expect(response, contains('104 World Cup matches'));
      });

      test('"help" takes priority over default', () {
        final response = generateSimpleResponse('please help');
        expect(response, contains('Match schedules'));
      });
    });
  });

  group('ChatMessage entity - extended tests', () {
    group('ChatMessageType.thinking', () {
      test('thinking type exists', () {
        expect(ChatMessageType.values, contains(ChatMessageType.thinking));
      });

      test('creates thinking message', () {
        final message = ChatMessage(
          text: 'Thinking...',
          type: ChatMessageType.thinking,
        );

        expect(message.type, equals(ChatMessageType.thinking));
        expect(message.text, equals('Thinking...'));
      });

      test('has exactly 3 message types', () {
        expect(ChatMessageType.values.length, equals(3));
      });

      test('all three types are distinct', () {
        expect(ChatMessageType.user, isNot(equals(ChatMessageType.bot)));
        expect(ChatMessageType.user, isNot(equals(ChatMessageType.thinking)));
        expect(ChatMessageType.bot, isNot(equals(ChatMessageType.thinking)));
      });
    });

    group('Message filtering by type', () {
      test('can separate user, bot, and thinking messages', () {
        final messages = [
          ChatMessage(text: 'User question', type: ChatMessageType.user),
          ChatMessage(text: 'Thinking...', type: ChatMessageType.thinking),
          ChatMessage(text: 'Bot answer', type: ChatMessageType.bot),
          ChatMessage(text: 'Follow up', type: ChatMessageType.user),
          ChatMessage(text: 'Thinking...', type: ChatMessageType.thinking),
          ChatMessage(text: 'Another answer', type: ChatMessageType.bot),
        ];

        final userMessages = messages.where((m) => m.type == ChatMessageType.user).toList();
        final botMessages = messages.where((m) => m.type == ChatMessageType.bot).toList();
        final thinkingMessages = messages.where((m) => m.type == ChatMessageType.thinking).toList();

        expect(userMessages.length, equals(2));
        expect(botMessages.length, equals(2));
        expect(thinkingMessages.length, equals(2));
      });

      test('can remove thinking messages from conversation', () {
        final messages = [
          ChatMessage(text: 'Question', type: ChatMessageType.user),
          ChatMessage(text: 'Thinking...', type: ChatMessageType.thinking),
          ChatMessage(text: 'Answer', type: ChatMessageType.bot),
        ];

        final withoutThinking = messages
            .where((m) => m.type != ChatMessageType.thinking)
            .toList();

        expect(withoutThinking.length, equals(2));
        expect(withoutThinking.every((m) => m.type != ChatMessageType.thinking), isTrue);
      });
    });

    group('Message ordering', () {
      test('can sort messages by timestamp', () {
        final msg1 = ChatMessage(
          text: 'First',
          type: ChatMessageType.user,
          timestamp: DateTime(2026, 6, 15, 10, 0, 0),
        );
        final msg2 = ChatMessage(
          text: 'Second',
          type: ChatMessageType.bot,
          timestamp: DateTime(2026, 6, 15, 10, 0, 5),
        );
        final msg3 = ChatMessage(
          text: 'Third',
          type: ChatMessageType.user,
          timestamp: DateTime(2026, 6, 15, 10, 0, 10),
        );

        final unsorted = [msg3, msg1, msg2];
        unsorted.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        expect(unsorted[0].text, equals('First'));
        expect(unsorted[1].text, equals('Second'));
        expect(unsorted[2].text, equals('Third'));
      });
    });

    group('Edge cases', () {
      test('handles very long message text', () {
        final longText = 'A' * 10000;
        final message = ChatMessage(text: longText, type: ChatMessageType.user);
        expect(message.text.length, equals(10000));
      });

      test('handles multiline messages', () {
        const multiline = 'Line 1\nLine 2\nLine 3\nLine 4\nLine 5';
        final message = ChatMessage(text: multiline, type: ChatMessageType.bot);
        expect(message.text.split('\n').length, equals(5));
      });

      test('handles messages with special characters', () {
        const special = 'Score: 3-2 (ET) @ Stadium #1! <Winner>';
        final message = ChatMessage(text: special, type: ChatMessageType.bot);
        expect(message.text, equals(special));
      });
    });
  });
}
