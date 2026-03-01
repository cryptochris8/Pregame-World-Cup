import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/core/ai/services/enhanced_ai_game_analysis_service.dart';
import 'package:pregame_world_cup/core/ai/services/multi_provider_ai_service.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';

class MockMultiProviderAIService extends Mock
    implements MultiProviderAIService {}

/// Tests for EnhancedAIGameAnalysisService.
///
/// The service constructor eagerly resolves `sl<MultiProviderAIService>()`.
/// We register a mock before accessing the singleton. In the test environment,
/// the HistoricalGameAnalysisService API calls fail, driving the service into
/// its fallback code paths. The AI insights generation also fails, producing
/// the `_generateIntelligentAIFallback` output.
void main() {
  final sl = GetIt.instance;
  late MockMultiProviderAIService mockMultiAI;

  setUpAll(() {
    mockMultiAI = MockMultiProviderAIService();

    if (!sl.isRegistered<MultiProviderAIService>()) {
      sl.registerSingleton<MultiProviderAIService>(mockMultiAI);
    }

    // Default stubs
    when(() => mockMultiAI.getBestProviderFor(any())).thenReturn('None');
    when(() => mockMultiAI.generateSportsAnalysis(
          homeTeam: any(named: 'homeTeam'),
          awayTeam: any(named: 'awayTeam'),
          gameContext: any(named: 'gameContext'),
        )).thenThrow(Exception('Not initialized in test'));
  });

  GameSchedule makeGame({
    String gameId = 'test-game-1',
    String homeTeamName = 'Brazil',
    String awayTeamName = 'Germany',
    DateTime? dateTime,
    String? stadiumName,
    int? homeScore,
    int? awayScore,
  }) {
    return GameSchedule(
      gameId: gameId,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
      dateTime: dateTime,
      stadium: stadiumName != null ? Stadium(name: stadiumName) : null,
      homeScore: homeScore,
      awayScore: awayScore,
    );
  }

  late EnhancedAIGameAnalysisService service;

  setUp(() {
    service = EnhancedAIGameAnalysisService.instance;
  });

  // ===========================================================================
  // generateGameAnalysis - structure and content
  // ===========================================================================
  group('generateGameAnalysis', () {
    test('returns non-null analysis', () async {
      final game = makeGame();
      final result = await service.generateGameAnalysis(game);
      expect(result, isNotNull);
      expect(result, isA<Map<String, dynamic>>());
    });

    test('contains gameId matching input', () async {
      final game = makeGame(gameId: 'match-42');
      final result = await service.generateGameAnalysis(game);
      expect(result!['gameId'], 'match-42');
    });

    test('contains home team name', () async {
      final game = makeGame(homeTeamName: 'France', awayTeamName: 'Spain');
      final result = await service.generateGameAnalysis(game);
      final teams = result!['teams'] as Map<String, dynamic>;
      expect(teams['home']['name'], 'France');
    });

    test('contains away team name', () async {
      final game = makeGame(homeTeamName: 'France', awayTeamName: 'Spain');
      final result = await service.generateGameAnalysis(game);
      final teams = result!['teams'] as Map<String, dynamic>;
      expect(teams['away']['name'], 'Spain');
    });

    test('maps team names to FIFA codes', () async {
      final game = makeGame(
        homeTeamName: 'Argentina',
        awayTeamName: 'Netherlands',
      );
      final result = await service.generateGameAnalysis(game);
      final teams = result!['teams'] as Map<String, dynamic>;
      expect(teams['home']['key'], 'ARG');
      expect(teams['away']['key'], 'NED');
    });

    test('includes aiInsights map', () async {
      final game = makeGame();
      final result = await service.generateGameAnalysis(game);
      expect(result!['aiInsights'], isA<Map<String, dynamic>>());
    });

    test('aiInsights has summary string', () async {
      final game = makeGame();
      final result = await service.generateGameAnalysis(game);
      final insights = result!['aiInsights'] as Map<String, dynamic>;
      expect(insights['summary'], isA<String>());
      expect((insights['summary'] as String).length, greaterThan(20));
    });

    test('aiInsights has keyInsights list', () async {
      final game = makeGame();
      final result = await service.generateGameAnalysis(game);
      final insights = result!['aiInsights'] as Map<String, dynamic>;
      expect(insights['keyInsights'], isA<List>());
      expect((insights['keyInsights'] as List).length, greaterThanOrEqualTo(3));
    });

    test('aiInsights has provider string', () async {
      final game = makeGame();
      final result = await service.generateGameAnalysis(game);
      final insights = result!['aiInsights'] as Map<String, dynamic>;
      expect(insights['provider'], isA<String>());
    });

    test('includes confidence score between 0 and 1', () async {
      final game = makeGame();
      final result = await service.generateGameAnalysis(game);
      expect(result!['confidence'], isA<double>());
      expect(result!['confidence'], greaterThanOrEqualTo(0.0));
      expect(result!['confidence'], lessThanOrEqualTo(1.0));
    });

    test('includes dataQuality string', () async {
      final game = makeGame();
      final result = await service.generateGameAnalysis(game);
      expect(result!['dataQuality'], isA<String>());
    });

    test('includes generatedAt as valid ISO 8601', () async {
      final game = makeGame();
      final result = await service.generateGameAnalysis(game);
      final ts = result!['generatedAt'] as String;
      expect(() => DateTime.parse(ts), returnsNormally);
    });

    test('includes prediction map', () async {
      final game = makeGame();
      final result = await service.generateGameAnalysis(game);
      expect(result!['prediction'], isA<Map<String, dynamic>>());
    });

    test('prediction has homeTeamWinProbability', () async {
      final game = makeGame();
      final result = await service.generateGameAnalysis(game);
      final prediction = result!['prediction'] as Map<String, dynamic>;
      expect(prediction['homeTeamWinProbability'], isA<num>());
    });
  });

  // ===========================================================================
  // AI fallback insights content
  // ===========================================================================
  group('AI fallback insights', () {
    test('summary mentions both team names', () async {
      final game = makeGame(
        homeTeamName: 'Morocco',
        awayTeamName: 'Canada',
      );
      final result = await service.generateGameAnalysis(game);
      final summary =
          (result!['aiInsights'] as Map)['summary'] as String;
      expect(summary, contains('Canada'));
      expect(summary, contains('Morocco'));
    });

    test('summary identifies favored team when prediction > 0.5', () async {
      // Default prediction gives homeTeamWinProbability = 0.52
      final game = makeGame(
        homeTeamName: 'Brazil',
        awayTeamName: 'Japan',
      );
      final result = await service.generateGameAnalysis(game);
      final summary =
          (result!['aiInsights'] as Map)['summary'] as String;
      // Home team (Brazil) favored with probability 0.52
      expect(summary, contains('Brazil'));
    });

    test('keyInsights contains at least 4 items', () async {
      final game = makeGame();
      final result = await service.generateGameAnalysis(game);
      final keyInsights =
          (result!['aiInsights'] as Map)['keyInsights'] as List;
      expect(keyInsights.length, greaterThanOrEqualTo(4));
    });

    test('keyInsights mentions favored team', () async {
      final game = makeGame(
        homeTeamName: 'France',
        awayTeamName: 'Germany',
      );
      final result = await service.generateGameAnalysis(game);
      final keyInsights =
          (result!['aiInsights'] as Map)['keyInsights'] as List;
      final allText = keyInsights.join(' ');
      // Favored team (home with 0.52) should appear
      expect(allText, contains('France'));
    });
  });

  // ===========================================================================
  // Team key mapping (via generateGameAnalysis)
  // ===========================================================================
  group('team key mapping', () {
    final mappingTests = {
      'United States': 'USA',
      'South Korea': 'KOR',
      'Brazil': 'BRA',
      'Japan': 'JPN',
      'Switzerland': 'SUI',
      'Croatia': 'CRO',
      'Nigeria': 'NGA',
      'Cameroon': 'CMR',
      'Mexico': 'MEX',
      'England': 'ENG',
    };

    for (final entry in mappingTests.entries) {
      test('${entry.key} maps to ${entry.value}', () async {
        final game = makeGame(
          homeTeamName: entry.key,
          awayTeamName: 'Brazil',
        );
        final result = await service.generateGameAnalysis(game);
        final homeKey =
            (result!['teams'] as Map)['home']['key'] as String;
        expect(homeKey, entry.value);
      });
    }
  });

  // ===========================================================================
  // generateQuickSummary
  // ===========================================================================
  group('generateQuickSummary', () {
    test('returns a non-empty string', () async {
      final game = makeGame();
      final result = await service.generateQuickSummary(game);
      expect(result, isA<String>());
      expect(result.length, greaterThan(5));
    });

    test('handles multiple team combinations', () async {
      final teams = [
        ['France', 'Germany'],
        ['Japan', 'South Korea'],
        ['USA', 'Mexico'],
        ['Morocco', 'Nigeria'],
      ];

      for (final pair in teams) {
        final game = makeGame(homeTeamName: pair[0], awayTeamName: pair[1]);
        final result = await service.generateQuickSummary(game);
        expect(result, isA<String>());
        expect(result.length, greaterThan(5));
      }
    });

    test('does not throw for unusual team names', () async {
      final game = makeGame(
        homeTeamName: 'Unknown Country',
        awayTeamName: 'Another Country',
      );
      final result = await service.generateQuickSummary(game);
      expect(result, isA<String>());
    });
  });

  // ===========================================================================
  // Singleton
  // ===========================================================================
  group('singleton', () {
    test('instance returns the same object', () {
      final a = EnhancedAIGameAnalysisService.instance;
      final b = EnhancedAIGameAnalysisService.instance;
      expect(identical(a, b), isTrue);
    });
  });
}
