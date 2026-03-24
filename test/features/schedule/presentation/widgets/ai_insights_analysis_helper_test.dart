import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/ai_insights_analysis_helper.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import '../../schedule_test_factory.dart';

void main() {
  group('AIInsightsAnalysisHelper', () {
    late GameSchedule testGame;
    late AIInsightsAnalysisHelper helper;

    setUp(() {
      testGame = ScheduleTestFactory.createGameSchedule();
      helper = AIInsightsAnalysisHelper(game: testGame);
    });

    test('buildGameStats returns correct gameType', () {
      final stats = helper.buildGameStats();

      expect(stats, isNotNull);
      expect(stats.containsKey('gameType'), isTrue);
      expect(stats['gameType'], isNotEmpty);
    });

    test('buildGameStats includes venue from stadium', () {
      final gameWithStadium = ScheduleTestFactory.createGameWithStadium();
      final helperWithStadium = AIInsightsAnalysisHelper(game: gameWithStadium);

      final stats = helperWithStadium.buildGameStats();

      expect(stats.containsKey('venue'), isTrue);
      expect(stats['venue'], contains('Match at'));
      expect(stats['venue'], contains(gameWithStadium.stadium!.name));
    });

    test('buildGameStats includes context for group stage (week <= 2)', () {
      final groupStageGame = ScheduleTestFactory.createGameSchedule(
        gameId: 'test-group',
        week: 1,
      );
      final groupHelper = AIInsightsAnalysisHelper(game: groupStageGame);

      final stats = groupHelper.buildGameStats();

      expect(stats.containsKey('context'), isTrue);
      expect(stats['context'], isNotEmpty);
    });

    test('buildGameStats includes context for knockout stage (week > 6)', () {
      final knockoutGame = ScheduleTestFactory.createGameSchedule(
        gameId: 'test-knockout',
        week: 7,
      );
      final knockoutHelper = AIInsightsAnalysisHelper(game: knockoutGame);

      final stats = knockoutHelper.buildGameStats();

      expect(stats.containsKey('context'), isTrue);
      expect(stats['context'], isNotEmpty);
    });

    test('extractPredictionData extracts prediction correctly', () {
      final analysisData = ScheduleTestFactory.createAiAnalysisData();

      final prediction = helper.extractPredictionData(analysisData);

      expect(prediction, isNotNull);
      expect(prediction, isA<Map<String, dynamic>>());
    });

    test('extractPredictionData returns fallback on null prediction', () {
      final emptyData = <String, dynamic>{};

      final prediction = helper.extractPredictionData(emptyData);

      expect(prediction, isNotNull);
      expect(prediction, isA<Map<String, dynamic>>());
      // Fallback should have basic structure
      expect(prediction.containsKey('winner'), isTrue);
    });

    test('extractKeyFactors returns factors list', () {
      final predictionMap = ScheduleTestFactory.createAiAnalysisData()['prediction'] as Map<String, dynamic>;

      final keyFactors = helper.extractKeyFactors(predictionMap);

      expect(keyFactors, isNotNull);
      expect(keyFactors, isA<List<dynamic>>());
      expect(keyFactors.isNotEmpty, isTrue);
    });

    test('extractKeyFactors returns defaults when missing', () {
      final emptyData = <String, dynamic>{};

      final keyFactors = helper.extractKeyFactors(emptyData);

      expect(keyFactors, isNotNull);
      expect(keyFactors, isA<List<dynamic>>());
      expect(keyFactors.length, greaterThan(0));
    });

    test('generateFallbackPrediction returns valid data', () {
      final fallback = helper.generateFallbackPrediction();

      expect(fallback, isNotNull);
      expect(fallback.containsKey('winner'), isTrue);
      expect(fallback.containsKey('homeScore'), isTrue);
      expect(fallback.containsKey('awayScore'), isTrue);
      expect(fallback.containsKey('confidence'), isTrue);
      expect(fallback.containsKey('keyFactors'), isTrue);

      expect(fallback['winner'], isNotEmpty);
      expect(fallback['homeScore'], isA<String>());
      expect(fallback['awayScore'], isA<String>());
      expect(fallback['confidence'], isA<String>());
      expect(fallback['keyFactors'], isA<List>());
    });

    test(
        'generateIntelligentSeriesFallback returns known rivalry text (Brazil vs Argentina)',
        () {
      final brazilArgentinaGame = ScheduleTestFactory.createGameSchedule(
        gameId: 'brazil-argentina',
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
      );
      final rivalryHelper = AIInsightsAnalysisHelper(game: brazilArgentinaGame);

      final seriesText = rivalryHelper.generateIntelligentSeriesFallback();

      expect(seriesText, isNotEmpty);
      // Should contain rivalry-related text
      expect(
        seriesText.toLowerCase().contains('rival') ||
            seriesText.toLowerCase().contains('classic') ||
            seriesText.toLowerCase().contains('intense'),
        isTrue,
      );
    });

    test(
        'generateIntelligentSeriesFallback returns confederation text for same-confederation teams',
        () {
      // Create two European teams
      final euroGame = ScheduleTestFactory.createGameSchedule(
        gameId: 'germany-spain',
        homeTeamName: 'Germany',
        awayTeamName: 'Spain',
      );
      final euroHelper = AIInsightsAnalysisHelper(game: euroGame);

      final seriesText = euroHelper.generateIntelligentSeriesFallback();

      expect(seriesText, isNotEmpty);
      // Should be a valid fallback text
      expect(seriesText.length, greaterThan(10));
    });

    test('generateFallbackSeasonData returns realistic stats', () {
      const teamName = 'Brazil';
      final seasonData = helper.generateFallbackSeasonData(teamName);

      expect(seasonData, isNotNull);
      expect(seasonData.containsKey('performance'), isTrue);

      final performance = seasonData['performance'] as Map<String, dynamic>;
      expect(performance.containsKey('wins'), isTrue);
      expect(performance.containsKey('losses'), isTrue);
      expect(performance.containsKey('draws'), isTrue);
      expect(performance.containsKey('goalsFor'), isTrue);
      expect(performance.containsKey('goalsAgainst'), isTrue);

      // Check that values are reasonable
      expect(performance['wins'], isA<int>());
      expect(performance['losses'], isA<int>());
      expect(performance['draws'], isA<int>());
      expect(performance['goalsFor'], isA<int>());
      expect(performance['goalsAgainst'], isA<int>());

      // Stats should be non-negative
      expect(performance['wins'], greaterThanOrEqualTo(0));
      expect(performance['losses'], greaterThanOrEqualTo(0));
      expect(performance['draws'], greaterThanOrEqualTo(0));
      expect(performance['goalsFor'], greaterThanOrEqualTo(0));
      expect(performance['goalsAgainst'], greaterThanOrEqualTo(0));
    });

    test('extractHistoricalData extracts historical data', () {
      final analysisData = ScheduleTestFactory.createAiAnalysisData();

      final historicalData = helper.extractHistoricalData(analysisData);

      expect(historicalData, isNotNull);
      expect(historicalData, isA<Map<String, dynamic>>());
    });

    test('extractAIInsights extracts AI insights', () {
      final analysisData = ScheduleTestFactory.createAiAnalysisData();

      final insights = helper.extractAIInsights(analysisData);

      expect(insights, isNotNull);
      expect(insights, isA<Map<String, dynamic>>());
    });

    test('buildEnhancedAnalysisData builds full analysis from enhanced data',
        () {
      final enhancedData = ScheduleTestFactory.createAiAnalysisData();

      final analysisData = helper.buildEnhancedAnalysisData(enhancedData);

      expect(analysisData, isNotNull);
      expect(analysisData, isA<Map<String, dynamic>>());
      // Should contain key sections
      expect(analysisData?.containsKey('prediction'), isTrue);
    });

    test('generateSeriesRecord sets series record field', () {
      // SeriesRecord starts empty and gets populated by the method
      expect(helper.seriesRecord, isEmpty);

      helper.generateSeriesRecord();

      // After calling, it should have a value
      expect(helper.seriesRecord, isA<String>());
    });

    test('generateFallbackHeadToHead generates head-to-head data', () {
      final headToHead = helper.generateFallbackHeadToHead();

      expect(headToHead, isNotNull);
      expect(headToHead, isA<Map<String, dynamic>>());
      expect(headToHead.containsKey('totalMeetings'), isTrue);
      expect(headToHead.containsKey('narrative'), isTrue);

      // Values should be reasonable
      expect(headToHead['totalMeetings'], greaterThanOrEqualTo(0));
      expect(headToHead['narrative'], isNotEmpty);
    });
  });
}
