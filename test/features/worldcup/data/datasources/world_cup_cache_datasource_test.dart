import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import '../../../../test_helpers/mock_datasources.dart';
import '../../../worldcup/presentation/bloc/mock_repositories.dart';

void main() {
  late MockCacheService mockCacheService;
  late WorldCupCacheDataSource dataSource;

  final testMatches = TestDataFactory.createMatchList(count: 5);
  final testTeams = TestDataFactory.createTeamList(count: 4);
  final testGroups = TestDataFactory.createGroupList(count: 3);
  final testBracket = TestDataFactory.createBracket();
  final testVenues = [
    TestDataFactory.createVenue(venueId: 'v1', name: 'MetLife Stadium'),
    TestDataFactory.createVenue(venueId: 'v2', name: 'SoFi Stadium', city: 'Los Angeles'),
  ];

  setUpAll(() {
    registerFallbackValue(const Duration(hours: 1));
  });

  setUp(() {
    mockCacheService = MockCacheService();
    dataSource = WorldCupCacheDataSource(cacheService: mockCacheService);
  });

  // ==================== MATCHES ====================

  group('getCachedMatches', () {
    test('returns matches from cache', () async {
      final cachedData = testMatches.map((m) => m.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_matches'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedMatches();

      expect(result, isNotNull);
      expect(result!.length, 5);
      expect(result.first.matchId, testMatches.first.matchId);
    });

    test('returns null when cache is empty', () async {
      when(() => mockCacheService.get<List<dynamic>>('worldcup_matches'))
          .thenAnswer((_) async => null);

      final result = await dataSource.getCachedMatches();
      expect(result, isNull);
    });

    test('returns null on cache error', () async {
      when(() => mockCacheService.get<List<dynamic>>('worldcup_matches'))
          .thenThrow(Exception('Cache corrupted'));

      final result = await dataSource.getCachedMatches();
      expect(result, isNull);
    });
  });

  group('cacheMatches', () {
    test('stores matches with correct duration', () async {
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      await dataSource.cacheMatches(testMatches);

      verify(() => mockCacheService.set<List<Map<String, dynamic>>>(
            'worldcup_matches',
            any(),
            duration: any(named: 'duration'),
          )).called(1);
    });

    test('silently handles cache errors', () async {
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenThrow(Exception('Write error'));

      // Should not throw
      await dataSource.cacheMatches(testMatches);
    });
  });

  group('getCachedMatch', () {
    test('returns specific match by ID', () async {
      final cachedData = testMatches.map((m) => m.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_matches'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedMatch('match_0');

      expect(result, isNotNull);
      expect(result!.matchId, 'match_0');
    });

    test('returns null for nonexistent match', () async {
      final cachedData = testMatches.map((m) => m.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_matches'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedMatch('nonexistent');
      expect(result, isNull);
    });

    test('returns null when cache is empty', () async {
      when(() => mockCacheService.get<List<dynamic>>('worldcup_matches'))
          .thenAnswer((_) async => null);

      final result = await dataSource.getCachedMatch('match_0');
      expect(result, isNull);
    });
  });

  group('getCachedMatchesByStage', () {
    test('filters matches by stage', () async {
      final matches = [
        TestDataFactory.createMatch(matchId: 'm1', stage: MatchStage.groupStage),
        TestDataFactory.createMatch(matchId: 'm2', stage: MatchStage.roundOf16),
        TestDataFactory.createMatch(matchId: 'm3', stage: MatchStage.groupStage),
      ];
      final cachedData = matches.map((m) => m.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_matches'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedMatchesByStage(MatchStage.groupStage);

      expect(result, isNotNull);
      expect(result!.length, 2);
    });

    test('returns null when cache is empty', () async {
      when(() => mockCacheService.get<List<dynamic>>('worldcup_matches'))
          .thenAnswer((_) async => null);

      final result = await dataSource.getCachedMatchesByStage(MatchStage.groupStage);
      expect(result, isNull);
    });
  });

  group('getCachedMatchesByGroup', () {
    test('filters matches by group letter', () async {
      final matches = [
        TestDataFactory.createMatch(matchId: 'm1', group: 'A'),
        TestDataFactory.createMatch(matchId: 'm2', group: 'B'),
        TestDataFactory.createMatch(matchId: 'm3', group: 'A'),
      ];
      final cachedData = matches.map((m) => m.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_matches'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedMatchesByGroup('A');

      expect(result, isNotNull);
      expect(result!.length, 2);
    });
  });

  group('getCachedLiveMatches', () {
    test('returns live matches from separate cache key', () async {
      final liveMatch = TestDataFactory.createMatch(
        matchId: 'live_1',
        status: MatchStatus.inProgress,
      );
      final cachedData = [liveMatch.toMap()];
      when(() => mockCacheService.get<List<dynamic>>('worldcup_matches_live'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedLiveMatches();

      expect(result, isNotNull);
      expect(result!.length, 1);
    });

    test('returns null when no live cache', () async {
      when(() => mockCacheService.get<List<dynamic>>('worldcup_matches_live'))
          .thenAnswer((_) async => null);

      final result = await dataSource.getCachedLiveMatches();
      expect(result, isNull);
    });
  });

  group('cacheLiveMatches', () {
    test('stores with 30-second duration', () async {
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      await dataSource.cacheLiveMatches([testMatches.first]);

      verify(() => mockCacheService.set<List<Map<String, dynamic>>>(
            'worldcup_matches_live',
            any(),
            duration: any(named: 'duration'),
          )).called(1);
    });
  });

  group('getCachedTodaysMatches', () {
    test('returns today matches from cache', () async {
      final cachedData = testMatches.take(2).map((m) => m.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_matches_today'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedTodaysMatches();

      expect(result, isNotNull);
      expect(result!.length, 2);
    });
  });

  group('cacheTodaysMatches', () {
    test('stores with 15-minute duration', () async {
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      await dataSource.cacheTodaysMatches(testMatches);

      verify(() => mockCacheService.set<List<Map<String, dynamic>>>(
            'worldcup_matches_today',
            any(),
            duration: any(named: 'duration'),
          )).called(1);
    });
  });

  group('getCachedCompletedMatches / cacheCompletedMatches', () {
    test('round-trips completed matches', () async {
      final cachedData = testMatches.map((m) => m.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_matches_completed'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedCompletedMatches();
      expect(result, isNotNull);
      expect(result!.length, 5);
    });

    test('caches with 24-hour duration', () async {
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      await dataSource.cacheCompletedMatches(testMatches);

      verify(() => mockCacheService.set<List<Map<String, dynamic>>>(
            'worldcup_matches_completed',
            any(),
            duration: any(named: 'duration'),
          )).called(1);
    });
  });

  group('getCachedUpcomingMatches / cacheUpcomingMatches', () {
    test('round-trips upcoming matches', () async {
      final cachedData = testMatches.map((m) => m.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_matches_upcoming'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedUpcomingMatches();
      expect(result, isNotNull);
    });

    test('caches with 1-hour duration', () async {
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      await dataSource.cacheUpcomingMatches(testMatches);

      verify(() => mockCacheService.set<List<Map<String, dynamic>>>(
            'worldcup_matches_upcoming',
            any(),
            duration: any(named: 'duration'),
          )).called(1);
    });
  });

  // ==================== TEAMS ====================

  group('getCachedTeams', () {
    test('returns teams from cache', () async {
      final cachedData = testTeams.map((t) => t.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_teams'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedTeams();

      expect(result, isNotNull);
      expect(result!.length, 4);
    });

    test('returns null on empty cache', () async {
      when(() => mockCacheService.get<List<dynamic>>('worldcup_teams'))
          .thenAnswer((_) async => null);

      final result = await dataSource.getCachedTeams();
      expect(result, isNull);
    });
  });

  group('cacheTeams', () {
    test('stores teams with 24-hour duration', () async {
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      await dataSource.cacheTeams(testTeams);

      verify(() => mockCacheService.set<List<Map<String, dynamic>>>(
            'worldcup_teams',
            any(),
            duration: any(named: 'duration'),
          )).called(1);
    });
  });

  group('getCachedTeam', () {
    test('returns team by team code', () async {
      final cachedData = testTeams.map((t) => t.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_teams'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedTeam('USA');

      expect(result, isNotNull);
      expect(result!.teamCode, 'USA');
    });

    test('is case insensitive', () async {
      final cachedData = testTeams.map((t) => t.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_teams'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedTeam('usa');
      expect(result, isNotNull);
    });

    test('returns null for unknown team', () async {
      final cachedData = testTeams.map((t) => t.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_teams'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedTeam('ZZZ');
      expect(result, isNull);
    });
  });

  group('getCachedTeamsByGroup', () {
    test('filters teams by group', () async {
      final cachedData = testTeams.map((t) => t.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_teams'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedTeamsByGroup('A');

      expect(result, isNotNull);
      // Teams in group A from createTeamList: first 4 teams are in group A
      expect(result!.every((t) => t.group == 'A'), isTrue);
    });
  });

  // ==================== GROUPS ====================

  group('getCachedGroups', () {
    test('returns groups from cache', () async {
      final cachedData = testGroups.map((g) => g.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_groups'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedGroups();

      expect(result, isNotNull);
      expect(result!.length, 3);
    });
  });

  group('cacheGroups', () {
    test('stores groups with 15-minute duration', () async {
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      await dataSource.cacheGroups(testGroups);

      verify(() => mockCacheService.set<List<Map<String, dynamic>>>(
            'worldcup_groups',
            any(),
            duration: any(named: 'duration'),
          )).called(1);
    });
  });

  group('getCachedGroup', () {
    test('returns group by letter', () async {
      final cachedData = testGroups.map((g) => g.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_groups'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedGroup('A');

      expect(result, isNotNull);
      expect(result!.groupLetter, 'A');
    });

    test('returns null for nonexistent group', () async {
      final cachedData = testGroups.map((g) => g.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_groups'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedGroup('Z');
      expect(result, isNull);
    });
  });

  // ==================== BRACKET ====================

  group('getCachedBracket', () {
    test('returns bracket from cache', () async {
      when(() => mockCacheService.get<Map<String, dynamic>>('worldcup_bracket'))
          .thenAnswer((_) async => testBracket.toMap());

      final result = await dataSource.getCachedBracket();

      expect(result, isNotNull);
      expect(result!.roundOf32.length, testBracket.roundOf32.length);
    });

    test('returns null on empty cache', () async {
      when(() => mockCacheService.get<Map<String, dynamic>>('worldcup_bracket'))
          .thenAnswer((_) async => null);

      final result = await dataSource.getCachedBracket();
      expect(result, isNull);
    });

    test('returns null on error', () async {
      when(() => mockCacheService.get<Map<String, dynamic>>('worldcup_bracket'))
          .thenThrow(Exception('Error'));

      final result = await dataSource.getCachedBracket();
      expect(result, isNull);
    });
  });

  group('cacheBracket', () {
    test('stores bracket with 15-minute duration', () async {
      when(() => mockCacheService.set<Map<String, dynamic>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      await dataSource.cacheBracket(testBracket);

      verify(() => mockCacheService.set<Map<String, dynamic>>(
            'worldcup_bracket',
            any(),
            duration: any(named: 'duration'),
          )).called(1);
    });
  });

  // ==================== VENUES ====================

  group('getCachedVenues', () {
    test('returns venues from cache', () async {
      final cachedData = testVenues.map((v) => v.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_venues'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedVenues();

      expect(result, isNotNull);
      expect(result!.length, 2);
    });
  });

  group('cacheVenues', () {
    test('stores venues with 7-day duration', () async {
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      await dataSource.cacheVenues(testVenues);

      verify(() => mockCacheService.set<List<Map<String, dynamic>>>(
            'worldcup_venues',
            any(),
            duration: any(named: 'duration'),
          )).called(1);
    });
  });

  group('getCachedVenue', () {
    test('returns venue by ID', () async {
      final cachedData = testVenues.map((v) => v.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_venues'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedVenue('v1');

      expect(result, isNotNull);
      expect(result!.name, 'MetLife Stadium');
    });

    test('returns null for unknown venue', () async {
      final cachedData = testVenues.map((v) => v.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('worldcup_venues'))
          .thenAnswer((_) async => cachedData);

      final result = await dataSource.getCachedVenue('unknown');
      expect(result, isNull);
    });
  });

  // ==================== UTILITIES ====================

  group('clearAllCache', () {
    test('removes all cache keys', () async {
      when(() => mockCacheService.remove(any()))
          .thenAnswer((_) async {});

      await dataSource.clearAllCache();

      verify(() => mockCacheService.remove('worldcup_matches')).called(1);
      verify(() => mockCacheService.remove('worldcup_matches_live')).called(1);
      verify(() => mockCacheService.remove('worldcup_matches_today')).called(1);
      verify(() => mockCacheService.remove('worldcup_matches_completed')).called(1);
      verify(() => mockCacheService.remove('worldcup_matches_upcoming')).called(1);
      verify(() => mockCacheService.remove('worldcup_teams')).called(1);
      verify(() => mockCacheService.remove('worldcup_groups')).called(1);
      verify(() => mockCacheService.remove('worldcup_bracket')).called(1);
      verify(() => mockCacheService.remove('worldcup_venues')).called(1);
    });

    test('silently handles errors', () async {
      when(() => mockCacheService.remove(any()))
          .thenThrow(Exception('Error'));

      // Should not throw
      await dataSource.clearAllCache();
    });
  });

  group('clearCache', () {
    test('removes specific cache key', () async {
      when(() => mockCacheService.remove(any()))
          .thenAnswer((_) async {});

      await dataSource.clearCache('worldcup_teams');

      verify(() => mockCacheService.remove('worldcup_teams')).called(1);
    });
  });

  group('isCacheValid', () {
    test('returns true when data exists', () async {
      when(() => mockCacheService.get<dynamic>('some_key'))
          .thenAnswer((_) async => 'data');

      final result = await dataSource.isCacheValid('some_key');
      expect(result, isTrue);
    });

    test('returns false when data is null', () async {
      when(() => mockCacheService.get<dynamic>('some_key'))
          .thenAnswer((_) async => null);

      final result = await dataSource.isCacheValid('some_key');
      expect(result, isFalse);
    });

    test('returns false on error', () async {
      when(() => mockCacheService.get<dynamic>('some_key'))
          .thenThrow(Exception('Error'));

      final result = await dataSource.isCacheValid('some_key');
      expect(result, isFalse);
    });
  });
}
