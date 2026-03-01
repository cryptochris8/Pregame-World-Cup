import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/ai/services/multi_provider_ai_service.dart';

/// Tests for MultiProviderAIService.
///
/// Because the service uses a private constructor singleton pattern and
/// depends on GetIt-resolved services (AIService, ClaudeService), we test
/// the service in its *uninitialized* state where neither provider is
/// available. This exercises all fallback paths, provider routing logic,
/// status reporting, and the embedding zero-vector fallback.
void main() {
  // We use the singleton instance directly. In the test environment neither
  // OpenAI nor Claude will be initialized, so all calls exercise the
  // fallback / no-provider code paths.
  late MultiProviderAIService service;

  setUp(() {
    service = MultiProviderAIService.instance;
  });

  // ===========================================================================
  // getBestProviderFor
  // ===========================================================================
  group('getBestProviderFor', () {
    test('returns None for prediction when no providers available', () {
      expect(service.getBestProviderFor('prediction'), 'None');
    });

    test('returns None for analysis when no providers available', () {
      expect(service.getBestProviderFor('analysis'), 'None');
    });

    test('returns None for strategic when no providers available', () {
      expect(service.getBestProviderFor('strategic'), 'None');
    });

    test('returns None for venue when no providers available', () {
      expect(service.getBestProviderFor('venue'), 'None');
    });

    test('returns None for recommendation when no providers available', () {
      expect(service.getBestProviderFor('recommendation'), 'None');
    });

    test('returns None for embedding when no providers available', () {
      expect(service.getBestProviderFor('embedding'), 'None');
    });

    test('returns None for quick when no providers available', () {
      expect(service.getBestProviderFor('quick'), 'None');
    });

    test('returns None for chat when no providers available', () {
      expect(service.getBestProviderFor('chat'), 'None');
    });

    test('returns None for unknown task type when no providers available', () {
      expect(service.getBestProviderFor('unknown_task'), 'None');
    });

    test('is case-insensitive', () {
      expect(service.getBestProviderFor('PREDICTION'), 'None');
      expect(service.getBestProviderFor('Analysis'), 'None');
      expect(service.getBestProviderFor('VENUE'), 'None');
    });
  });

  // ===========================================================================
  // isAnyServiceAvailable
  // ===========================================================================
  group('isAnyServiceAvailable', () {
    test('returns false when no providers initialized', () {
      expect(service.isAnyServiceAvailable, isFalse);
    });
  });

  // ===========================================================================
  // getProviderStatus
  // ===========================================================================
  group('getProviderStatus', () {
    test('returns status map with expected top-level keys', () {
      final status = service.getProviderStatus();
      expect(status, contains('openai'));
      expect(status, contains('claude'));
      expect(status, contains('optimal_routing'));
    });

    test('openai status shows unavailable when not initialized', () {
      final status = service.getProviderStatus();
      final openai = status['openai'] as Map<String, dynamic>;

      expect(openai['available'], isFalse);
      expect(openai['capabilities'], isA<List>());
      expect(openai['capabilities'], contains('embeddings'));
      expect(openai['model'], 'GPT-3.5-turbo');
    });

    test('claude status shows unavailable when not initialized', () {
      final status = service.getProviderStatus();
      final claude = status['claude'] as Map<String, dynamic>;

      expect(claude['available'], isFalse);
      expect(claude['capabilities'], isA<List>());
      expect(claude['capabilities'], contains('deep_analysis'));
    });

    test('optimal_routing shows fallback selections', () {
      final status = service.getProviderStatus();
      final routing = status['optimal_routing'] as Map<String, dynamic>;

      // When neither provider available: game_predictions tries Claude first (None -> 'OpenAI' pattern won't happen)
      // embeddings is OpenAI-only -> None when OpenAI unavailable
      expect(routing['embeddings'], 'None');
      expect(routing, contains('game_predictions'));
      expect(routing, contains('sports_analysis'));
      expect(routing, contains('venue_recommendations'));
      expect(routing, contains('quick_responses'));
    });
  });

  // ===========================================================================
  // Fallback behavior - generateEnhancedGamePrediction
  // ===========================================================================
  group('generateEnhancedGamePrediction fallback', () {
    test('returns fallback prediction when no providers available', () async {
      final result = await service.generateEnhancedGamePrediction(
        homeTeam: 'Brazil',
        awayTeam: 'Argentina',
        gameStats: {'record': '8-2'},
      );

      expect(result['provider'], 'Fallback');
      expect(result['confidence'], 50);
      expect(result['prediction'], isA<String>());
      expect(result['prediction'], contains('Argentina'));
      expect(result['prediction'], contains('Brazil'));
    });

    test('fallback prediction includes key factors', () async {
      final result = await service.generateEnhancedGamePrediction(
        homeTeam: 'Germany',
        awayTeam: 'France',
        gameStats: {},
      );

      final keyFactors = result['keyFactors'] as List;
      expect(keyFactors, isNotEmpty);
      expect(keyFactors.length, greaterThanOrEqualTo(2));
    });

    test('fallback prediction includes analysis text', () async {
      final result = await service.generateEnhancedGamePrediction(
        homeTeam: 'Spain',
        awayTeam: 'Portugal',
        gameStats: {},
      );

      expect(result['analysis'], isA<String>());
      expect((result['analysis'] as String).length, greaterThan(10));
    });
  });

  // ===========================================================================
  // Fallback behavior - generateSportsAnalysis
  // ===========================================================================
  group('generateSportsAnalysis fallback', () {
    test('returns fallback with team names when no providers', () async {
      final result = await service.generateSportsAnalysis(
        homeTeam: 'France',
        awayTeam: 'Germany',
        gameContext: {'stage': 'Quarter-Final'},
      );

      expect(result, isA<String>());
      expect(result, contains('Germany'));
      expect(result, contains('France'));
    });

    test('returns non-empty string', () async {
      final result = await service.generateSportsAnalysis(
        homeTeam: 'Japan',
        awayTeam: 'South Korea',
        gameContext: {},
      );

      expect(result.length, greaterThan(20));
    });
  });

  // ===========================================================================
  // Fallback behavior - generateVenueRecommendations
  // ===========================================================================
  group('generateVenueRecommendations fallback', () {
    test('returns fallback with venue names', () async {
      final result = await service.generateVenueRecommendations(
        userPreferences: 'sports bar',
        gameContext: 'World Cup Final',
        nearbyVenues: ['The Pub', 'Sports Grill', 'Stadium Bar'],
      );

      expect(result, contains('The Pub'));
      expect(result, contains('Sports Grill'));
    });

    test('handles single venue in fallback', () async {
      final result = await service.generateVenueRecommendations(
        userPreferences: 'any',
        gameContext: 'Group Stage',
        nearbyVenues: ['Only Bar'],
      );

      expect(result, isA<String>());
      expect(result, contains('Only Bar'));
    });

    test('handles empty venue list gracefully', () async {
      final result = await service.generateVenueRecommendations(
        userPreferences: 'any',
        gameContext: 'Group Stage',
        nearbyVenues: [],
      );

      expect(result, isA<String>());
    });
  });

  // ===========================================================================
  // Fallback behavior - generateHistoricalAnalysis
  // ===========================================================================
  group('generateHistoricalAnalysis fallback', () {
    test('returns fallback with both team names', () async {
      final result = await service.generateHistoricalAnalysis(
        team1: 'Spain',
        team2: 'Italy',
        historicalData: {'meetings': 50},
      );

      expect(result, isA<String>());
      expect(result, contains('Spain'));
      expect(result, contains('Italy'));
    });
  });

  // ===========================================================================
  // Fallback behavior - generateQuickResponse
  // ===========================================================================
  group('generateQuickResponse fallback', () {
    test('returns helpful fallback message', () async {
      final result = await service.generateQuickResponse(
        prompt: 'Hello!',
      );

      expect(result, isA<String>());
      expect(result.length, greaterThan(10));
    });

    test('returns fallback even with system message', () async {
      final result = await service.generateQuickResponse(
        prompt: 'What is the weather?',
        systemMessage: 'You are a weather bot.',
      );

      expect(result, isA<String>());
    });
  });

  // ===========================================================================
  // Fallback behavior - generateEmbedding
  // ===========================================================================
  group('generateEmbedding fallback', () {
    test('returns zero vector of length 1536', () async {
      final result = await service.generateEmbedding('test text');

      expect(result, hasLength(1536));
      expect(result.every((v) => v == 0.0), isTrue);
    });

    test('returns zero vector for empty input', () async {
      final result = await service.generateEmbedding('');

      expect(result, hasLength(1536));
    });
  });

  // ===========================================================================
  // Singleton
  // ===========================================================================
  group('singleton pattern', () {
    test('instance returns the same object', () {
      final a = MultiProviderAIService.instance;
      final b = MultiProviderAIService.instance;
      expect(identical(a, b), isTrue);
    });
  });
}
