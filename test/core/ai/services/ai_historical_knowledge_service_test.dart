import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/core/ai/services/ai_historical_knowledge_service.dart';
import 'package:pregame_world_cup/core/services/cache_service.dart';

class MockCacheService extends Mock implements CacheService {}

/// Tests for AIHistoricalKnowledgeService.
///
/// The service uses CacheService.instance (a singleton). In the test
/// environment, the Hive-backed CacheService is not initialized, so cache
/// reads return null / throw and the service gracefully degrades.
/// We test the pure logic paths (matchup key, season list, status) and
/// verify that the service handles missing cache data gracefully.
void main() {
  late AIHistoricalKnowledgeService service;

  setUp(() {
    service = AIHistoricalKnowledgeService.instance;
  });

  // ===========================================================================
  // _createMatchupKey (tested indirectly via getHeadToHeadHistory)
  // ===========================================================================
  group('matchup key generation', () {
    // We test this by observing that getHeadToHeadHistory for (A, B) and (B, A)
    // behaves the same way. Since the cache is not initialized, both return null.
    test('getHeadToHeadHistory returns null for both orderings when cache unavailable', () async {
      final result1 = await service.getHeadToHeadHistory('Brazil', 'Germany');
      final result2 = await service.getHeadToHeadHistory('Germany', 'Brazil');
      expect(result1, isNull);
      expect(result2, isNull);
    });
  });

  // ===========================================================================
  // getHistoricalGames
  // ===========================================================================
  group('getHistoricalGames', () {
    test('returns empty list when cache not initialized', () async {
      final result = await service.getHistoricalGames(2024);
      expect(result, isEmpty);
    });

    test('returns empty list for various seasons', () async {
      for (final season in [2022, 2023, 2024, 2025, 2026]) {
        final result = await service.getHistoricalGames(season);
        expect(result, isEmpty);
      }
    });

    test('returns empty list for invalid season', () async {
      final result = await service.getHistoricalGames(1900);
      expect(result, isEmpty);
    });
  });

  // ===========================================================================
  // getSeasonStatistics
  // ===========================================================================
  group('getSeasonStatistics', () {
    test('returns null when cache not initialized', () async {
      final result = await service.getSeasonStatistics(2024);
      expect(result, isNull);
    });

    test('returns null for each historical season', () async {
      for (final season in [2022, 2023, 2024, 2025, 2026]) {
        final result = await service.getSeasonStatistics(season);
        expect(result, isNull);
      }
    });
  });

  // ===========================================================================
  // getHeadToHeadHistory
  // ===========================================================================
  group('getHeadToHeadHistory', () {
    test('returns null when cache not available', () async {
      final result = await service.getHeadToHeadHistory('France', 'Spain');
      expect(result, isNull);
    });

    test('handles same team passed twice', () async {
      final result = await service.getHeadToHeadHistory('Brazil', 'Brazil');
      expect(result, isNull);
    });

    test('handles empty team names gracefully', () async {
      final result = await service.getHeadToHeadHistory('', '');
      expect(result, isNull);
    });
  });

  // ===========================================================================
  // getTeamTrends
  // ===========================================================================
  group('getTeamTrends', () {
    test('returns null when cache not available', () async {
      final result = await service.getTeamTrends('Brazil');
      expect(result, isNull);
    });

    test('returns null for unknown team', () async {
      final result = await service.getTeamTrends('NonExistentTeam');
      expect(result, isNull);
    });

    test('handles empty team name', () async {
      final result = await service.getTeamTrends('');
      expect(result, isNull);
    });
  });

  // ===========================================================================
  // isKnowledgeBaseReady
  // ===========================================================================
  group('isKnowledgeBaseReady', () {
    test('returns false when cache not initialized', () async {
      final result = await service.isKnowledgeBaseReady();
      expect(result, isFalse);
    });
  });

  // ===========================================================================
  // getKnowledgeBaseStatus
  // ===========================================================================
  group('getKnowledgeBaseStatus', () {
    test('returns status map with expected keys', () async {
      final status = await service.getKnowledgeBaseStatus();

      expect(status, contains('totalSeasons'));
      expect(status, contains('cachedSeasons'));
      expect(status, contains('missingSeasons'));
      expect(status, contains('isReady'));
      expect(status, contains('historicalSeasons'));
    });

    test('totalSeasons is 5 (2022-2026)', () async {
      final status = await service.getKnowledgeBaseStatus();
      expect(status['totalSeasons'], 5);
    });

    test('historicalSeasons contains expected years', () async {
      final status = await service.getKnowledgeBaseStatus();
      final seasons = status['historicalSeasons'] as List<int>;
      expect(seasons, containsAll([2022, 2023, 2024, 2025, 2026]));
    });

    test('isReady is false when cache not initialized', () async {
      final status = await service.getKnowledgeBaseStatus();
      expect(status['isReady'], isFalse);
    });

    test('cachedSeasons is 0 when cache not initialized', () async {
      final status = await service.getKnowledgeBaseStatus();
      expect(status['cachedSeasons'], 0);
    });

    test('missingSeasons contains all seasons when cache empty', () async {
      final status = await service.getKnowledgeBaseStatus();
      final missing = status['missingSeasons'] as List;
      expect(missing.length, 5);
    });
  });

  // ===========================================================================
  // initializeKnowledgeBase
  // ===========================================================================
  group('initializeKnowledgeBase', () {
    test('does not throw when cache not available', () async {
      // Should gracefully handle missing cache
      await expectLater(service.initializeKnowledgeBase(), completes);
    });
  });

  // ===========================================================================
  // Singleton
  // ===========================================================================
  group('singleton pattern', () {
    test('instance returns the same object', () {
      final a = AIHistoricalKnowledgeService.instance;
      final b = AIHistoricalKnowledgeService.instance;
      expect(identical(a, b), isTrue);
    });
  });
}
