import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/chatbot/data/services/chatbot_knowledge_base.dart';
import 'package:pregame_world_cup/features/chatbot/domain/entities/chat_intent.dart';
import 'package:pregame_world_cup/features/chatbot/domain/services/chatbot_service.dart';
import 'package:pregame_world_cup/features/chatbot/domain/services/intent_classifier.dart';
import 'package:pregame_world_cup/features/chatbot/domain/services/response_generator.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/enhanced_match_data_service.dart';

import '../../helpers/mock_knowledge_data.dart';

/// Integration tests for the full chatbot pipeline:
/// User message → IntentClassifier → ChatbotKnowledgeBase → ResponseGenerator → ChatResponse
void main() {
  late ChatbotService service;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockAssetBundle();

    final kb = ChatbotKnowledgeBase(enhancedData: EnhancedMatchDataService.instance);
    await kb.initialize();

    service = ChatbotService(
      knowledgeBase: kb,
      classifier: IntentClassifier(knowledgeBase: kb),
      responseGenerator: ResponseGenerator(knowledgeBase: kb),
    );
  });

  tearDownAll(() {
    tearDownMockAssetBundle();
  });

  setUp(() {
    service.clearHistory();
  });

  group('Welcome message', () {
    test('has a non-empty welcome message', () {
      expect(ChatbotService.welcomeMessage, isNotEmpty);
      expect(ChatbotService.welcomeMessage, contains('World Cup'));
    });

    test('has welcome suggestion chips', () {
      expect(ChatbotService.welcomeSuggestions, isNotEmpty);
      expect(ChatbotService.welcomeSuggestions.length, greaterThanOrEqualTo(3));
    });
  });

  group('End-to-end: greeting', () {
    test('"hello" returns a greeting with chips', () async {
      final response = await service.getResponse('hello');
      expect(response.text, contains('World Cup'));
      expect(response.suggestionChips, isNotEmpty);
      expect(response.resolvedIntent.type, ChatIntentType.greeting);
    });

    test('"hi" returns a greeting', () async {
      final response = await service.getResponse('hi');
      expect(response.resolvedIntent.type, ChatIntentType.greeting);
    });
  });

  group('End-to-end: schedule', () {
    test('"when does USA play" returns schedule', () async {
      final response = await service.getResponse('when does USA play');
      expect(response.text, contains('United States'));
      expect(response.text, contains('Jun'));
      expect(response.resolvedIntent.type, ChatIntentType.schedule);
    });

    test('"Mexico schedule" returns Mexico matches', () async {
      final response = await service.getResponse('Mexico schedule');
      expect(response.text, contains('Mexico'));
      expect(response.text, contains('Estadio Azteca'));
    });
  });

  group('End-to-end: team info', () {
    test('"tell me about Argentina" returns team info', () async {
      final response = await service.getResponse('tell me about Argentina');
      expect(response.text, contains('Argentina'));
      expect(response.text, contains('Group B'));
    });

    test('"USMNT" resolves alias and returns team info', () async {
      final response = await service.getResponse('USMNT');
      expect(response.text, contains('United States'));
    });
  });

  group('End-to-end: player', () {
    test('"Messi stats" returns featured player data', () async {
      final response = await service.getResponse('Messi stats');
      expect(response.text, contains('Lionel Messi'));
      expect(response.text, contains('13 goals'));
      expect(response.resolvedIntent.type, ChatIntentType.player);
    });

    test('"tell me about McKennie" returns enriched profile', () async {
      final response = await service.getResponse('tell me about McKennie');
      expect(response.text, contains('McKennie'));
      expect(response.resolvedIntent.type, ChatIntentType.player);
      // Should have enriched content from profile (not just bare squad)
      expect(response.text, contains('box-to-box'));
    });

    test('"Pulisic" returns enriched profile with bio', () async {
      final response = await service.getResponse('who is Pulisic');
      expect(response.text, contains('Pulisic'));
      expect(response.text, contains('Hershey'));
      expect(response.text, contains('Captain America'));
    });

    test('"Julian Alvarez" returns enriched profile from ARG', () async {
      final response = await service.getResponse('Julian Alvarez stats');
      expect(response.text, contains('Alvarez'));
      expect(response.text, contains('Calchin'));
    });
  });

  group('End-to-end: head-to-head', () {
    test('"Argentina vs Brazil" returns h2h', () async {
      final response = await service.getResponse('Argentina vs Brazil');
      expect(response.text, contains('111'));
      expect(response.resolvedIntent.type, ChatIntentType.headToHead);
    });
  });

  group('End-to-end: prediction', () {
    test('"who will win the world cup" returns favorites', () async {
      final response = await service.getResponse('who will win the world cup');
      expect(response.text, contains('France'));
      expect(response.resolvedIntent.type, ChatIntentType.prediction);
    });

    test('"Argentina chances" returns team prediction', () async {
      final response = await service.getResponse('Argentina chances');
      expect(response.text, contains('Argentina'));
      expect(response.text, contains('+700'));
    });
  });

  group('End-to-end: history', () {
    test('"World Cup 2022" returns tournament data', () async {
      final response = await service.getResponse('World Cup 2022');
      expect(response.text, contains('Argentina'));
      expect(response.text, contains('Mbappe'));
    });

    test('"World Cup records" returns records', () async {
      final response = await service.getResponse('World Cup history');
      expect(response.text, contains('Miroslav Klose'));
    });
  });

  group('End-to-end: venue', () {
    test('"stadiums" returns venue list', () async {
      final response = await service.getResponse('what stadiums are there');
      expect(response.text, contains('Venue'));
    });

    test('"MetLife Stadium" returns venue details', () async {
      final response = await service.getResponse('tell me about MetLife Stadium');
      expect(response.text, contains('MetLife'));
    });
  });

  group('End-to-end: manager', () {
    test('"USA coach" returns manager', () async {
      final response = await service.getResponse('USA coach');
      expect(response.text, contains('Pochettino'));
    });
  });

  group('End-to-end: injury', () {
    test('"USA injuries" returns injury report', () async {
      final response = await service.getResponse('USA injuries');
      expect(response.text, contains('Pulisic'));
    });
  });

  group('End-to-end: odds', () {
    test('"betting odds" returns odds table', () async {
      final response = await service.getResponse('betting odds');
      expect(response.text, contains('Betting Odds'));
      expect(response.text, contains('+450'));
    });
  });

  group('End-to-end: standings', () {
    test('"Group B" returns group info', () async {
      final response = await service.getResponse('Group B');
      expect(response.text, contains('Group B'));
      expect(response.text, contains('United States'));
    });
  });

  group('End-to-end: app help', () {
    test('"help" returns capabilities', () async {
      final response = await service.getResponse('help');
      expect(response.text, contains('schedule'));
      expect(response.text, contains('history'));
    });
  });

  group('End-to-end: unknown', () {
    test('gibberish returns helpful fallback', () async {
      final response = await service.getResponse('asdfghjkl');
      expect(response.text, contains('not sure'));
      expect(response.suggestionChips, isNotEmpty);
    });
  });

  group('Error handling', () {
    test('all responses have text', () async {
      final queries = [
        'hello', 'thanks', 'help', 'USA schedule', 'Messi stats',
        'Argentina vs Brazil', 'who will win', 'World Cup 2022',
        'Group B', 'USA injuries', 'USA coach', 'betting odds',
        'stadiums', 'xyzzy',
      ];

      for (final q in queries) {
        final response = await service.getResponse(q);
        expect(response.text, isNotEmpty, reason: '"$q" should produce a response');
        expect(response.resolvedIntent, isNotNull);
      }
    });
  });

  group('Conversation context', () {
    test('pronoun resolution works across turns', () async {
      // First ask about USA
      await service.getResponse('USA schedule');
      // Then use pronoun
      final response = await service.getResponse('what are their chances');
      expect(response.text, contains('United States'));
    });

    test('clearHistory resets context', () async {
      await service.getResponse('Argentina schedule');
      service.clearHistory();
      final response = await service.getResponse('their schedule');
      // After clear, should NOT resolve to Argentina
      expect(response.resolvedIntent.team, isNull);
    });
  });
}
