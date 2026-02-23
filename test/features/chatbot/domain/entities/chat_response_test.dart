import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/chatbot/domain/entities/chat_intent.dart';
import 'package:pregame_world_cup/features/chatbot/domain/entities/chat_response.dart';

void main() {
  group('ChatResponse', () {
    test('creates with required fields', () {
      const intent = ChatIntent(type: ChatIntentType.greeting);
      const response = ChatResponse(
        text: 'Hello!',
        resolvedIntent: intent,
      );
      expect(response.text, 'Hello!');
      expect(response.suggestionChips, isEmpty);
      expect(response.resolvedIntent.type, ChatIntentType.greeting);
    });

    test('creates with suggestion chips', () {
      const intent = ChatIntent(type: ChatIntentType.schedule);
      const response = ChatResponse(
        text: 'USA plays on June 12.',
        suggestionChips: ['USA squad', 'USA prediction'],
        resolvedIntent: intent,
      );
      expect(response.suggestionChips, hasLength(2));
      expect(response.suggestionChips.first, 'USA squad');
    });

    test('can be const', () {
      const response = ChatResponse(
        text: 'Test',
        suggestionChips: ['A', 'B'],
        resolvedIntent: ChatIntent(type: ChatIntentType.unknown),
      );
      expect(response.text, 'Test');
    });
  });
}
