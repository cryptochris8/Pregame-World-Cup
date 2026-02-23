import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/chatbot/domain/entities/chat_intent.dart';

void main() {
  group('ChatIntentType', () {
    test('has 16 intent types', () {
      expect(ChatIntentType.values.length, 16);
    });

    test('contains all expected types', () {
      expect(ChatIntentType.values, contains(ChatIntentType.greeting));
      expect(ChatIntentType.values, contains(ChatIntentType.schedule));
      expect(ChatIntentType.values, contains(ChatIntentType.team));
      expect(ChatIntentType.values, contains(ChatIntentType.player));
      expect(ChatIntentType.values, contains(ChatIntentType.headToHead));
      expect(ChatIntentType.values, contains(ChatIntentType.matchPreview));
      expect(ChatIntentType.values, contains(ChatIntentType.prediction));
      expect(ChatIntentType.values, contains(ChatIntentType.venue));
      expect(ChatIntentType.values, contains(ChatIntentType.history));
      expect(ChatIntentType.values, contains(ChatIntentType.odds));
      expect(ChatIntentType.values, contains(ChatIntentType.standings));
      expect(ChatIntentType.values, contains(ChatIntentType.manager));
      expect(ChatIntentType.values, contains(ChatIntentType.injury));
      expect(ChatIntentType.values, contains(ChatIntentType.appHelp));
      expect(ChatIntentType.values, contains(ChatIntentType.thanks));
      expect(ChatIntentType.values, contains(ChatIntentType.unknown));
    });
  });

  group('ChatIntent', () {
    test('creates with required fields', () {
      const intent = ChatIntent(type: ChatIntentType.greeting);
      expect(intent.type, ChatIntentType.greeting);
      expect(intent.confidence, 1.0);
      expect(intent.entities, isEmpty);
    });

    test('creates with custom confidence and entities', () {
      const intent = ChatIntent(
        type: ChatIntentType.schedule,
        confidence: 0.85,
        entities: {'team': 'USA'},
      );
      expect(intent.type, ChatIntentType.schedule);
      expect(intent.confidence, 0.85);
      expect(intent.entities, {'team': 'USA'});
    });

    test('entity convenience getters return correct values', () {
      const intent = ChatIntent(
        type: ChatIntentType.headToHead,
        entities: {
          'team': 'ARG',
          'team1': 'ARG',
          'team2': 'BRA',
          'player': 'messi',
          'venue': 'MetLife Stadium',
          'year': '2022',
          'group': 'B',
        },
      );
      expect(intent.team, 'ARG');
      expect(intent.team1, 'ARG');
      expect(intent.team2, 'BRA');
      expect(intent.player, 'messi');
      expect(intent.venue, 'MetLife Stadium');
      expect(intent.year, '2022');
      expect(intent.group, 'B');
    });

    test('entity getters return null when not present', () {
      const intent = ChatIntent(type: ChatIntentType.greeting);
      expect(intent.team, isNull);
      expect(intent.team1, isNull);
      expect(intent.player, isNull);
      expect(intent.venue, isNull);
      expect(intent.year, isNull);
      expect(intent.group, isNull);
    });

    test('toString includes type, confidence, and entities', () {
      const intent = ChatIntent(
        type: ChatIntentType.team,
        confidence: 0.9,
        entities: {'team': 'USA'},
      );
      final str = intent.toString();
      expect(str, contains('team'));
      expect(str, contains('0.9'));
      expect(str, contains('USA'));
    });
  });
}
