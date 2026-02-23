import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/chatbot/data/services/chatbot_knowledge_base.dart';
import 'package:pregame_world_cup/features/chatbot/domain/entities/chat_intent.dart';
import 'package:pregame_world_cup/features/chatbot/domain/services/response_generator.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/enhanced_match_data_service.dart';

import '../../helpers/mock_knowledge_data.dart';

void main() {
  late ChatbotKnowledgeBase kb;
  late ResponseGenerator generator;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockAssetBundle();

    kb = ChatbotKnowledgeBase(enhancedData: EnhancedMatchDataService.instance);
    await kb.initialize();
    generator = ResponseGenerator(knowledgeBase: kb);
  });

  tearDownAll(() {
    tearDownMockAssetBundle();
  });

  group('Greeting response', () {
    test('returns friendly greeting with suggestion chips', () async {
      const intent = ChatIntent(type: ChatIntentType.greeting);
      final response = await generator.generate(intent);
      expect(response.text, contains('World Cup'));
      expect(response.suggestionChips, isNotEmpty);
    });
  });

  group('Thanks response', () {
    test('returns polite acknowledgment', () async {
      const intent = ChatIntent(type: ChatIntentType.thanks);
      final response = await generator.generate(intent);
      expect(response.text, contains('welcome'));
      expect(response.suggestionChips, isNotEmpty);
    });
  });

  group('App help response', () {
    test('lists capabilities', () async {
      const intent = ChatIntent(type: ChatIntentType.appHelp);
      final response = await generator.generate(intent);
      expect(response.text, contains('schedule'));
      expect(response.text, contains('squad'));
      expect(response.text, contains('history'));
      expect(response.suggestionChips, isNotEmpty);
    });
  });

  group('Schedule response', () {
    test('asks for team when none provided', () async {
      const intent = ChatIntent(type: ChatIntentType.schedule);
      final response = await generator.generate(intent);
      expect(response.text, contains('Which team'));
      expect(response.suggestionChips, isNotEmpty);
    });

    test('returns schedule for USA', () async {
      const intent = ChatIntent(
        type: ChatIntentType.schedule,
        entities: {'team': 'USA'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('United States'));
      expect(response.text, contains('Jun 12'));
      expect(response.text, contains('SoFi Stadium'));
      expect(response.suggestionChips, isNotEmpty);
    });

    test('includes group info', () async {
      const intent = ChatIntent(
        type: ChatIntentType.schedule,
        entities: {'team': 'USA'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('Group B'));
    });

    test('returns schedule for Argentina', () async {
      const intent = ChatIntent(
        type: ChatIntentType.schedule,
        entities: {'team': 'ARG'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('Argentina'));
    });
  });

  group('Head-to-head response', () {
    test('asks for two teams when none provided', () async {
      const intent = ChatIntent(type: ChatIntentType.headToHead);
      final response = await generator.generate(intent);
      expect(response.text, contains('two teams'));
    });

    test('returns h2h for Argentina vs Brazil', () async {
      const intent = ChatIntent(
        type: ChatIntentType.headToHead,
        entities: {'team1': 'ARG', 'team2': 'BRA'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('Argentina'));
      expect(response.text, contains('Brazil'));
      expect(response.text, contains('111'));
      expect(response.text, contains('40'));
      expect(response.text, contains('Notable'));
    });

    test('handles missing h2h data gracefully', () async {
      const intent = ChatIntent(
        type: ChatIntentType.headToHead,
        entities: {'team1': 'USA', 'team2': 'MEX'},
      );
      final response = await generator.generate(intent);
      // No H2H data for USA vs MEX in mock — should still return a response
      expect(response.text, isNotEmpty);
      expect(response.suggestionChips, isNotEmpty);
    });
  });

  group('Match preview response', () {
    test('returns preview for Argentina vs Brazil', () async {
      const intent = ChatIntent(
        type: ChatIntentType.matchPreview,
        entities: {'team1': 'ARG', 'team2': 'BRA'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('Preview'));
      expect(response.text, contains('greatest rivalry'));
      expect(response.text, contains('Prediction'));
      expect(response.text, contains('DRAW'));
    });

    test('includes players to watch', () async {
      const intent = ChatIntent(
        type: ChatIntentType.matchPreview,
        entities: {'team1': 'ARG', 'team2': 'BRA'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('Messi'));
    });
  });

  group('Prediction response', () {
    test('returns tournament favorites when no team specified', () async {
      const intent = ChatIntent(type: ChatIntentType.prediction);
      final response = await generator.generate(intent);
      expect(response.text, contains('Favorites'));
      expect(response.text, contains('France'));
      expect(response.text, contains('England'));
      expect(response.suggestionChips, isNotEmpty);
    });

    test('returns team-specific prediction with odds and value', () async {
      const intent = ChatIntent(
        type: ChatIntentType.prediction,
        entities: {'team': 'ARG'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('Argentina'));
      expect(response.text, contains('Outlook'));
      expect(response.text, contains('+700'));
      expect(response.text, contains('\$700M'));
    });

    test('shows recent form in prediction', () async {
      const intent = ChatIntent(
        type: ChatIntentType.prediction,
        entities: {'team': 'ARG'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('form'));
    });
  });

  group('Player response', () {
    test('asks for player when none provided', () async {
      const intent = ChatIntent(type: ChatIntentType.player);
      final response = await generator.generate(intent);
      expect(response.text, contains('Which player'));
    });

    test('returns Messi stats from player_stats file', () async {
      const intent = ChatIntent(
        type: ChatIntentType.player,
        entities: {'player': 'lionel messi'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('Lionel Messi'));
      expect(response.text, contains('Argentina'));
      expect(response.text, contains('26 appearances'));
      expect(response.text, contains('13 goals'));
      expect(response.text, contains('8 assists'));
      expect(response.text, contains('10/10'));
    });

    test('includes tournament breakdown', () async {
      const intent = ChatIntent(
        type: ChatIntentType.player,
        entities: {'player': 'lionel messi'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('2022'));
      expect(response.text, contains('Winner'));
    });
  });

  group('Injury response', () {
    test('asks for team when none provided', () async {
      const intent = ChatIntent(type: ChatIntentType.injury);
      final response = await generator.generate(intent);
      expect(response.text, contains('specific team'));
    });

    test('returns injury report for USA', () async {
      const intent = ChatIntent(
        type: ChatIntentType.injury,
        entities: {'team': 'USA'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('Pulisic'));
      expect(response.text, contains('Hamstring'));
    });

    test('reports no injuries when team is clean', () async {
      const intent = ChatIntent(
        type: ChatIntentType.injury,
        entities: {'team': 'MEX'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('No injury concerns'));
    });
  });

  group('Manager response', () {
    test('asks for team when none provided', () async {
      const intent = ChatIntent(type: ChatIntentType.manager);
      final response = await generator.generate(intent);
      expect(response.text, contains('Which team'));
    });

    test('returns manager info for USA', () async {
      const intent = ChatIntent(
        type: ChatIntentType.manager,
        entities: {'team': 'USA'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('Pochettino'));
      expect(response.text, contains('4-3-3'));
      expect(response.text, contains('High Press'));
      expect(response.text, contains('53%'));
    });

    test('returns manager info for Argentina', () async {
      const intent = ChatIntent(
        type: ChatIntentType.manager,
        entities: {'team': 'ARG'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('Scaloni'));
      expect(response.text, contains('World Cup 2022'));
    });
  });

  group('Team response', () {
    test('asks for team when none provided', () async {
      const intent = ChatIntent(type: ChatIntentType.team);
      final response = await generator.generate(intent);
      expect(response.text, contains('Which team'));
    });

    test('returns team info for USA', () async {
      const intent = ChatIntent(
        type: ChatIntentType.team,
        entities: {'team': 'USA'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('United States'));
      expect(response.text, contains('Group B'));
      expect(response.text, contains('\$500M'));
      expect(response.suggestionChips, isNotEmpty);
    });

    test('shows key players', () async {
      const intent = ChatIntent(
        type: ChatIntentType.team,
        entities: {'team': 'USA'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('Pulisic'));
    });
  });

  group('Venue response', () {
    test('lists all venues when no specific venue', () async {
      const intent = ChatIntent(type: ChatIntentType.venue);
      final response = await generator.generate(intent);
      expect(response.text, contains('Host Venues'));
      expect(response.text, contains('SoFi Stadium'));
      expect(response.text, contains('Estadio Azteca'));
    });

    test('returns specific venue info', () async {
      const intent = ChatIntent(
        type: ChatIntentType.venue,
        entities: {'venue': 'MetLife Stadium'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('MetLife Stadium'));
      expect(response.text, contains('Matches scheduled'));
    });
  });

  group('History response', () {
    test('returns records when no year specified', () async {
      const intent = ChatIntent(type: ChatIntentType.history);
      final response = await generator.generate(intent);
      expect(response.text, contains('Records'));
      expect(response.text, contains('Miroslav Klose'));
      expect(response.text, contains('Brazil'));
    });

    test('returns tournament data for specific year', () async {
      const intent = ChatIntent(
        type: ChatIntentType.history,
        entities: {'year': '2022'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('2022'));
      expect(response.text, contains('Argentina'));
      expect(response.text, contains('Mbappe'));
      expect(response.text, contains('3-3'));
    });

    test('returns tournament data for 2018', () async {
      const intent = ChatIntent(
        type: ChatIntentType.history,
        entities: {'year': '2018'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('France'));
      expect(response.text, contains('Croatia'));
    });

    test('shows recent winners', () async {
      const intent = ChatIntent(type: ChatIntentType.history);
      final response = await generator.generate(intent);
      expect(response.text, contains('Recent winners'));
    });
  });

  group('Odds response', () {
    test('returns ordered list of favorites', () async {
      const intent = ChatIntent(type: ChatIntentType.odds);
      final response = await generator.generate(intent);
      expect(response.text, contains('Betting Odds'));
      expect(response.text, contains('France'));
      expect(response.text, contains('+450'));
      expect(response.text, contains('18.2%'));
    });
  });

  group('Standings response', () {
    test('shows all groups overview when no group specified', () async {
      const intent = ChatIntent(type: ChatIntentType.standings);
      final response = await generator.generate(intent);
      expect(response.text, contains('Group'));
    });

    test('returns specific group info', () async {
      const intent = ChatIntent(
        type: ChatIntentType.standings,
        entities: {'group': 'B'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('Group B'));
      expect(response.text, contains('United States'));
      expect(response.text, contains('Brazil'));
      expect(response.text, contains('Argentina'));
    });
  });

  group('Unknown response', () {
    test('returns helpful fallback', () async {
      const intent = ChatIntent(type: ChatIntentType.unknown);
      final response = await generator.generate(intent);
      expect(response.text, contains('not sure'));
      expect(response.suggestionChips, isNotEmpty);
    });
  });

  group('Suggestion chips', () {
    test('every response has suggestion chips', () async {
      final intents = [
        const ChatIntent(type: ChatIntentType.greeting),
        const ChatIntent(type: ChatIntentType.thanks),
        const ChatIntent(type: ChatIntentType.appHelp),
        const ChatIntent(type: ChatIntentType.schedule, entities: {'team': 'USA'}),
        const ChatIntent(type: ChatIntentType.prediction),
        const ChatIntent(type: ChatIntentType.history),
        const ChatIntent(type: ChatIntentType.odds),
        const ChatIntent(type: ChatIntentType.unknown),
      ];

      for (final intent in intents) {
        final response = await generator.generate(intent);
        expect(
          response.suggestionChips,
          isNotEmpty,
          reason: '${intent.type} should have suggestion chips',
        );
      }
    });
  });

  group('Date formatting', () {
    test('formats dates correctly in schedule responses', () async {
      const intent = ChatIntent(
        type: ChatIntentType.schedule,
        entities: {'team': 'MEX'},
      );
      final response = await generator.generate(intent);
      expect(response.text, contains('Jun 11'));
    });
  });
}
