import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/core/ai/services/ai_service.dart';
import 'package:pregame_world_cup/core/services/venue_ai_analysis_service.dart';
import 'package:pregame_world_cup/core/services/venue_models.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';

// Mock the AIService
class MockAIService extends Mock implements AIService {}

void main() {
  late VenueAIAnalysisService service;
  late MockAIService mockAIService;

  setUp(() {
    mockAIService = MockAIService();
    service = VenueAIAnalysisService(aiService: mockAIService);
  });

  // ============================================================================
  // Helper factories
  // ============================================================================

  Place makePlace({
    String placeId = 'test_place',
    String name = 'Test Venue',
    double? rating,
    int? priceLevel,
    List<String>? types,
  }) {
    return Place(
      placeId: placeId,
      name: name,
      rating: rating,
      priceLevel: priceLevel,
      types: types,
    );
  }

  GameSchedule makeGame({
    String gameId = 'g1',
    String homeTeamName = 'USA',
    String awayTeamName = 'Mexico',
  }) {
    return GameSchedule(
      gameId: gameId,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
    );
  }

  // ============================================================================
  // generateAnalysis - sentiment parsing
  // ============================================================================
  group('generateAnalysis', () {
    test('returns analysis with excellent score when AI says "excellent"', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'This is an excellent venue for watching');

      final venue = makePlace(rating: 4.2, types: ['bar', 'sports_bar']);
      final analysis = await service.generateAnalysis(
        venue, makeGame(), 'watch_party', null,
      );

      expect(analysis.overallScore, closeTo(1.0, 0.001)); // 0.9 + 0.1 (rating>=4) = 1.0 clamped
      expect(analysis.confidence, 0.75);
    });

    test('returns analysis with "great" sentiment score', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'This is a great place');

      final venue = makePlace(rating: 3.0, types: ['restaurant']);
      final analysis = await service.generateAnalysis(
        venue, makeGame(), 'general', null,
      );

      // 0.8 (great sentiment), no rating bonus (3.0 < 4.0)
      expect(analysis.overallScore, closeTo(0.8, 0.001));
    });

    test('returns analysis with "decent" sentiment score', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'Its decent enough for the event');

      final venue = makePlace(types: ['cafe']);
      final analysis = await service.generateAnalysis(
        venue, null, 'general', null,
      );

      expect(analysis.overallScore, closeTo(0.6, 0.001));
    });

    test('returns analysis with "poor" sentiment score', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'This is a poor choice for game day');

      final venue = makePlace();
      final analysis = await service.generateAnalysis(
        venue, null, 'general', null,
      );

      expect(analysis.overallScore, closeTo(0.3, 0.001));
    });

    test('returns default score 0.5 for neutral sentiment', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'It is an average venue');

      final venue = makePlace();
      final analysis = await service.generateAnalysis(
        venue, null, 'general', null,
      );

      expect(analysis.overallScore, closeTo(0.5, 0.001));
    });

    test('adds rating bonus when rating >= 4.0', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'Neutral response');

      final venue = makePlace(rating: 4.5);
      final analysis = await service.generateAnalysis(
        venue, null, 'general', null,
      );

      // 0.5 (neutral) + 0.1 (rating bonus) = 0.6
      expect(analysis.overallScore, closeTo(0.6, 0.001));
    });

    test('generates insight for highly rated venue', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'Neutral response');

      final venue = makePlace(rating: 4.3);
      final analysis = await service.generateAnalysis(
        venue, null, 'general', null,
      );

      expect(analysis.insights, contains('Highly rated venue (4.3/5)'));
    });

    test('generates game watching insight for sports-type venues', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'Neutral response');

      final venue = makePlace(types: ['sports_bar', 'bar']);
      final analysis = await service.generateAnalysis(
        venue, null, 'general', null,
      );

      expect(analysis.insights, contains('Great for watching games'));
      expect(analysis.gameWatchingScore, 0.8);
    });

    test('generates pre_game insight in pre_game context', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'Neutral response');

      final venue = makePlace();
      final analysis = await service.generateAnalysis(
        venue, null, 'pre_game', null,
      );

      expect(analysis.insights, contains('Perfect pre-game atmosphere'));
    });

    test('crowd prediction is Heavy for bar venues in watch_party context', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'Neutral response');

      final venue = makePlace(types: ['bar']);
      final analysis = await service.generateAnalysis(
        venue, null, 'watch_party', null,
      );

      expect(analysis.crowdPrediction, 'Heavy');
      expect(analysis.socialScore, 0.8);
    });

    test('crowd prediction is Moderate for non-bar venues', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'Neutral response');

      final venue = makePlace(types: ['cafe']);
      final analysis = await service.generateAnalysis(
        venue, null, 'general', null,
      );

      expect(analysis.crowdPrediction, 'Moderate');
    });

    test('returns fallback analysis on AI service error', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenThrow(Exception('AI service unavailable'));

      final venue = makePlace();
      final analysis = await service.generateAnalysis(
        venue, null, 'general', null,
      );

      // Should return AIVenueAnalysis.fallback() values
      expect(analysis.overallScore, 0.5);
      expect(analysis.confidence, 0.6);
      expect(analysis.crowdPrediction, 'Moderate');
      expect(analysis.atmosphereRating, 0.5);
      expect(analysis.gameWatchingScore, 0.5);
      expect(analysis.socialScore, 0.5);
    });

    test('passes correct prompt with venue and game details', () async {
      String? capturedPrompt;
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((invocation) async {
        capturedPrompt = invocation.namedArguments[#prompt] as String;
        return 'Neutral response';
      });

      final venue = makePlace(
        name: 'The Sports Pub',
        rating: 4.0,
        priceLevel: 2,
        types: ['bar', 'restaurant'],
      );
      final game = makeGame(homeTeamName: 'Brazil', awayTeamName: 'Germany');

      await service.generateAnalysis(venue, game, 'watch_party', null);

      expect(capturedPrompt, isNotNull);
      expect(capturedPrompt!, contains('The Sports Pub'));
      expect(capturedPrompt!, contains('4.0'));
      expect(capturedPrompt!, contains('Brazil'));
      expect(capturedPrompt!, contains('Germany'));
      expect(capturedPrompt!, contains('watch_party'));
    });

    test('handles null game gracefully in prompt', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'Neutral response');

      final venue = makePlace();
      final analysis = await service.generateAnalysis(
        venue, null, 'general', null,
      );

      expect(analysis, isA<AIVenueAnalysis>());
    });

    test('fallback insights when no specific matches', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'Neutral response');

      final venue = makePlace(rating: 2.0, types: ['store']);
      final analysis = await service.generateAnalysis(
        venue, null, 'general', null,
      );

      // No rating insight, no sports insight, no pre_game insight
      // Should get default 'AI-analyzed venue'
      expect(analysis.insights, contains('AI-analyzed venue'));
    });

    test('gameWatchingScore is 0.5 for non-sports venues', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'Neutral response');

      final venue = makePlace(types: ['cafe', 'coffee']);
      final analysis = await service.generateAnalysis(
        venue, null, 'general', null,
      );

      expect(analysis.gameWatchingScore, 0.5);
    });

    test('recommendations always contain game day message', () async {
      when(() => mockAIService.generateCompletion(
        prompt: any(named: 'prompt'),
        maxTokens: any(named: 'maxTokens'),
        temperature: any(named: 'temperature'),
      )).thenAnswer((_) async => 'Neutral response');

      final venue = makePlace();
      final analysis = await service.generateAnalysis(
        venue, null, 'general', null,
      );

      expect(analysis.recommendations,
          contains('Recommended for game day experience'));
    });
  });
}
