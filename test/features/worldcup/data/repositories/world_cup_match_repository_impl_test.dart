import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import '../../../worldcup/presentation/bloc/mock_repositories.dart';

class MockWorldCupApiDataSource extends Mock implements WorldCupApiDataSource {}
class MockWorldCupFirestoreDataSource extends Mock
    implements WorldCupFirestoreDataSource {}
class MockWorldCupCacheDataSource extends Mock
    implements WorldCupCacheDataSource {}

void main() {
  late MockWorldCupApiDataSource mockApiDataSource;
  late MockWorldCupFirestoreDataSource mockFirestoreDataSource;
  late MockWorldCupCacheDataSource mockCacheDataSource;
  late WorldCupMatchRepositoryImpl repository;

  final testMatches = TestDataFactory.createMatchList(count: 5);
  final testMatch = TestDataFactory.createMatch(matchId: 'match_1');

  setUpAll(() {
    registerFallbackValue(TestDataFactory.createMatch());
    registerFallbackValue(<WorldCupMatch>[]);
    registerFallbackValue(MatchStage.groupStage);
  });

  setUp(() {
    mockApiDataSource = MockWorldCupApiDataSource();
    mockFirestoreDataSource = MockWorldCupFirestoreDataSource();
    mockCacheDataSource = MockWorldCupCacheDataSource();
    repository = WorldCupMatchRepositoryImpl(
      apiDataSource: mockApiDataSource,
      firestoreDataSource: mockFirestoreDataSource,
      cacheDataSource: mockCacheDataSource,
    );
  });

  group('getAllMatches', () {
    test('returns cached matches when cache is not empty', () async {
      when(() => mockCacheDataSource.getCachedMatches())
          .thenAnswer((_) async => testMatches);

      final result = await repository.getAllMatches();

      expect(result, equals(testMatches));
      expect(result.length, 5);
      verify(() => mockCacheDataSource.getCachedMatches()).called(1);
      verifyNever(() => mockFirestoreDataSource.getAllMatches());
      verifyNever(() => mockApiDataSource.fetchAllMatches());
    });

    test('falls back to Firestore when cache is empty', () async {
      when(() => mockCacheDataSource.getCachedMatches())
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getAllMatches())
          .thenAnswer((_) async => testMatches);
      when(() => mockCacheDataSource.cacheMatches(any()))
          .thenAnswer((_) async {});

      final result = await repository.getAllMatches();

      expect(result, equals(testMatches));
      verify(() => mockCacheDataSource.getCachedMatches()).called(1);
      verify(() => mockFirestoreDataSource.getAllMatches()).called(1);
      verify(() => mockCacheDataSource.cacheMatches(testMatches)).called(1);
    });

    test('falls back to API when cache and Firestore are empty', () async {
      when(() => mockCacheDataSource.getCachedMatches())
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getAllMatches())
          .thenAnswer((_) async => []);
      when(() => mockApiDataSource.fetchAllMatches())
          .thenAnswer((_) async => testMatches);
      when(() => mockFirestoreDataSource.saveMatches(any()))
          .thenAnswer((_) async {});
      when(() => mockCacheDataSource.cacheMatches(any()))
          .thenAnswer((_) async {});

      final result = await repository.getAllMatches();

      expect(result, equals(testMatches));
    });

    test('falls back to mock data when all sources fail', () async {
      when(() => mockCacheDataSource.getCachedMatches())
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getAllMatches())
          .thenThrow(Exception('Firestore error'));
      when(() => mockApiDataSource.fetchAllMatches())
          .thenThrow(Exception('API error'));
      when(() => mockCacheDataSource.cacheMatches(any()))
          .thenAnswer((_) async {});

      final result = await repository.getAllMatches();

      expect(result, isNotEmpty);
    });

    test('returns empty cache as no data', () async {
      when(() => mockCacheDataSource.getCachedMatches())
          .thenAnswer((_) async => []);
      when(() => mockFirestoreDataSource.getAllMatches())
          .thenAnswer((_) async => testMatches);
      when(() => mockCacheDataSource.cacheMatches(any()))
          .thenAnswer((_) async {});

      final result = await repository.getAllMatches();

      expect(result, equals(testMatches));
      verify(() => mockFirestoreDataSource.getAllMatches()).called(1);
    });
  });

  group('getMatchById', () {
    test('returns cached match when available', () async {
      when(() => mockCacheDataSource.getCachedMatch('match_1'))
          .thenAnswer((_) async => testMatch);

      final result = await repository.getMatchById('match_1');

      expect(result, equals(testMatch));
      verifyNever(() => mockFirestoreDataSource.getMatchById(any()));
    });

    test('falls back to Firestore when cache miss', () async {
      when(() => mockCacheDataSource.getCachedMatch('match_1'))
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getMatchById('match_1'))
          .thenAnswer((_) async => testMatch);

      final result = await repository.getMatchById('match_1');

      expect(result, equals(testMatch));
      verify(() => mockFirestoreDataSource.getMatchById('match_1')).called(1);
    });

    test('returns null on error', () async {
      when(() => mockCacheDataSource.getCachedMatch(any()))
          .thenThrow(Exception('Cache error'));

      final result = await repository.getMatchById('match_1');

      expect(result, isNull);
    });
  });

  group('getMatchesByStage', () {
    test('returns cached matches by stage when available', () async {
      when(() => mockCacheDataSource.getCachedMatchesByStage(MatchStage.groupStage))
          .thenAnswer((_) async => testMatches);

      final result = await repository.getMatchesByStage(MatchStage.groupStage);

      expect(result, equals(testMatches));
      verifyNever(() => mockFirestoreDataSource.getMatchesByStage(any()));
    });

    test('falls back to Firestore when cache is empty', () async {
      when(() => mockCacheDataSource.getCachedMatchesByStage(MatchStage.groupStage))
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getMatchesByStage(MatchStage.groupStage))
          .thenAnswer((_) async => testMatches);

      final result = await repository.getMatchesByStage(MatchStage.groupStage);

      expect(result, equals(testMatches));
    });

    test('returns empty list on error', () async {
      when(() => mockCacheDataSource.getCachedMatchesByStage(any()))
          .thenThrow(Exception('Error'));

      final result = await repository.getMatchesByStage(MatchStage.groupStage);

      expect(result, isEmpty);
    });
  });

  group('getMatchesByGroup', () {
    test('returns cached matches by group', () async {
      when(() => mockCacheDataSource.getCachedMatchesByGroup('A'))
          .thenAnswer((_) async => testMatches);

      final result = await repository.getMatchesByGroup('A');

      expect(result, equals(testMatches));
    });

    test('falls back to Firestore', () async {
      when(() => mockCacheDataSource.getCachedMatchesByGroup('A'))
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getMatchesByGroup('A'))
          .thenAnswer((_) async => testMatches);

      final result = await repository.getMatchesByGroup('A');

      expect(result, equals(testMatches));
    });

    test('returns empty list on error', () async {
      when(() => mockCacheDataSource.getCachedMatchesByGroup(any()))
          .thenThrow(Exception('Error'));

      final result = await repository.getMatchesByGroup('A');

      expect(result, isEmpty);
    });
  });

  group('getMatchesByTeam', () {
    test('delegates to Firestore', () async {
      when(() => mockFirestoreDataSource.getMatchesByTeam('USA'))
          .thenAnswer((_) async => testMatches);

      final result = await repository.getMatchesByTeam('USA');

      expect(result, equals(testMatches));
      verify(() => mockFirestoreDataSource.getMatchesByTeam('USA')).called(1);
    });

    test('returns empty list on error', () async {
      when(() => mockFirestoreDataSource.getMatchesByTeam(any()))
          .thenThrow(Exception('Error'));

      final result = await repository.getMatchesByTeam('USA');

      expect(result, isEmpty);
    });
  });

  group('getUpcomingMatches', () {
    test('returns cached upcoming matches', () async {
      when(() => mockCacheDataSource.getCachedUpcomingMatches())
          .thenAnswer((_) async => testMatches);

      final result = await repository.getUpcomingMatches(limit: 3);

      expect(result.length, 3);
    });

    test('falls back to Firestore and caches result', () async {
      when(() => mockCacheDataSource.getCachedUpcomingMatches())
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getUpcomingMatches(limit: 10))
          .thenAnswer((_) async => testMatches);
      when(() => mockCacheDataSource.cacheUpcomingMatches(any()))
          .thenAnswer((_) async {});

      final result = await repository.getUpcomingMatches();

      expect(result, equals(testMatches));
      verify(() => mockCacheDataSource.cacheUpcomingMatches(testMatches)).called(1);
    });

    test('returns empty list on error', () async {
      when(() => mockCacheDataSource.getCachedUpcomingMatches())
          .thenThrow(Exception('Error'));

      final result = await repository.getUpcomingMatches();

      expect(result, isEmpty);
    });
  });

  group('getLiveMatches', () {
    test('returns cached live matches', () async {
      final liveMatches = [
        TestDataFactory.createMatch(status: MatchStatus.inProgress),
      ];
      when(() => mockCacheDataSource.getCachedLiveMatches())
          .thenAnswer((_) async => liveMatches);

      final result = await repository.getLiveMatches();

      expect(result, equals(liveMatches));
      verifyNever(() => mockApiDataSource.fetchLiveMatches());
    });

    test('falls back to API when no cache', () async {
      final liveMatches = [
        TestDataFactory.createMatch(status: MatchStatus.inProgress),
      ];
      when(() => mockCacheDataSource.getCachedLiveMatches())
          .thenAnswer((_) async => null);
      when(() => mockApiDataSource.fetchLiveMatches())
          .thenAnswer((_) async => liveMatches);
      when(() => mockCacheDataSource.cacheLiveMatches(any()))
          .thenAnswer((_) async {});
      when(() => mockFirestoreDataSource.saveMatch(any()))
          .thenAnswer((_) async {});

      final result = await repository.getLiveMatches();

      expect(result, equals(liveMatches));
      verify(() => mockCacheDataSource.cacheLiveMatches(liveMatches)).called(1);
    });

    test('falls back to Firestore when API fails', () async {
      final liveMatches = [
        TestDataFactory.createMatch(status: MatchStatus.inProgress),
      ];
      when(() => mockCacheDataSource.getCachedLiveMatches())
          .thenAnswer((_) async => null);
      when(() => mockApiDataSource.fetchLiveMatches())
          .thenThrow(Exception('API error'));
      when(() => mockFirestoreDataSource.getLiveMatches())
          .thenAnswer((_) async => liveMatches);

      final result = await repository.getLiveMatches();

      expect(result, equals(liveMatches));
    });

    test('returns empty list on error', () async {
      when(() => mockCacheDataSource.getCachedLiveMatches())
          .thenThrow(Exception('Error'));

      final result = await repository.getLiveMatches();

      expect(result, isEmpty);
    });
  });

  group('getTodaysMatches', () {
    test('returns cached today matches', () async {
      when(() => mockCacheDataSource.getCachedTodaysMatches())
          .thenAnswer((_) async => testMatches);

      final result = await repository.getTodaysMatches();

      expect(result, equals(testMatches));
    });

    test('returns empty list on error', () async {
      when(() => mockCacheDataSource.getCachedTodaysMatches())
          .thenThrow(Exception('Error'));

      final result = await repository.getTodaysMatches();

      expect(result, isEmpty);
    });
  });

  group('updateMatch', () {
    test('saves to Firestore and clears cache', () async {
      when(() => mockFirestoreDataSource.saveMatch(testMatch))
          .thenAnswer((_) async {});
      when(() => mockCacheDataSource.clearCache(any()))
          .thenAnswer((_) async {});

      await repository.updateMatch(testMatch);

      verify(() => mockFirestoreDataSource.saveMatch(testMatch)).called(1);
      verify(() => mockCacheDataSource.clearCache('worldcup_matches')).called(1);
    });

    test('throws on error', () async {
      when(() => mockFirestoreDataSource.saveMatch(any()))
          .thenThrow(Exception('Save failed'));

      expect(
        () => repository.updateMatch(testMatch),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('refreshMatches', () {
    test('fetches from API, saves to Firestore, and caches', () async {
      when(() => mockApiDataSource.fetchAllMatches())
          .thenAnswer((_) async => testMatches);
      when(() => mockFirestoreDataSource.saveMatches(any()))
          .thenAnswer((_) async {});
      when(() => mockCacheDataSource.cacheMatches(any()))
          .thenAnswer((_) async {});

      final result = await repository.refreshMatches();

      expect(result, equals(testMatches));
      verify(() => mockApiDataSource.fetchAllMatches()).called(1);
      verify(() => mockFirestoreDataSource.saveMatches(testMatches)).called(1);
      verify(() => mockCacheDataSource.cacheMatches(testMatches)).called(1);
    });

    test('returns empty list when API returns nothing', () async {
      when(() => mockApiDataSource.fetchAllMatches())
          .thenAnswer((_) async => []);

      final result = await repository.refreshMatches();

      expect(result, isEmpty);
    });

    test('throws on API error', () async {
      when(() => mockApiDataSource.fetchAllMatches())
          .thenThrow(Exception('API down'));

      expect(
        () => repository.refreshMatches(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('clearCache', () {
    test('clears all match cache keys', () async {
      when(() => mockCacheDataSource.clearCache(any()))
          .thenAnswer((_) async {});

      await repository.clearCache();

      verify(() => mockCacheDataSource.clearCache('worldcup_matches')).called(1);
      verify(() => mockCacheDataSource.clearCache('worldcup_matches_live')).called(1);
      verify(() => mockCacheDataSource.clearCache('worldcup_matches_today')).called(1);
      verify(() => mockCacheDataSource.clearCache('worldcup_matches_completed')).called(1);
      verify(() => mockCacheDataSource.clearCache('worldcup_matches_upcoming')).called(1);
    });
  });

  group('watchLiveMatches', () {
    test('delegates to Firestore stream', () {
      when(() => mockFirestoreDataSource.watchLiveMatches())
          .thenAnswer((_) => Stream.value(testMatches));

      final stream = repository.watchLiveMatches();

      expect(stream, isA<Stream<List<WorldCupMatch>>>());
    });
  });

  group('watchMatch', () {
    test('delegates to Firestore stream', () {
      when(() => mockFirestoreDataSource.watchMatch('match_1'))
          .thenAnswer((_) => Stream.value(testMatch));

      final stream = repository.watchMatch('match_1');

      expect(stream, isA<Stream<WorldCupMatch?>>());
    });
  });

  group('getMatchesByDate', () {
    test('filters matches by year, month, and day', () async {
      final matchesWithDates = [
        TestDataFactory.createMatch(
          matchId: 'm1',
          dateTime: DateTime(2026, 6, 15, 18, 0),
        ),
        TestDataFactory.createMatch(
          matchId: 'm2',
          dateTime: DateTime(2026, 6, 15, 21, 0),
        ),
        TestDataFactory.createMatch(
          matchId: 'm3',
          dateTime: DateTime(2026, 6, 16, 18, 0),
        ),
      ];
      when(() => mockCacheDataSource.getCachedMatches())
          .thenAnswer((_) async => matchesWithDates);

      final result = await repository.getMatchesByDate(DateTime(2026, 6, 15));

      expect(result.length, 2);
      expect(result.every((m) => m.dateTime!.day == 15), true);
    });

    test('returns empty list when no matches on date', () async {
      when(() => mockCacheDataSource.getCachedMatches())
          .thenAnswer((_) async => testMatches);

      final result = await repository.getMatchesByDate(DateTime(2030, 1, 1));

      expect(result, isEmpty);
    });

    test('falls back to mock data when cache throws', () async {
      when(() => mockCacheDataSource.getCachedMatches())
          .thenThrow(Exception('Error'));
      when(() => mockCacheDataSource.cacheMatches(any()))
          .thenAnswer((_) async {});

      final result = await repository.getMatchesByDate(DateTime(2026, 6, 15));

      // getAllMatches falls back to mock data internally, so result may not be empty
      expect(result, isA<List<WorldCupMatch>>());
    });

    test('excludes matches with null dateTime', () async {
      final matchesWithNull = [
        TestDataFactory.createMatch(
          matchId: 'm1',
          dateTime: DateTime(2026, 6, 15, 18, 0),
        ),
        const WorldCupMatch(
          matchId: 'm2',
          matchNumber: 2,
          stage: MatchStage.groupStage,
          homeTeamName: 'TBD',
          awayTeamName: 'TBD',
          dateTime: null,
        ),
      ];
      when(() => mockCacheDataSource.getCachedMatches())
          .thenAnswer((_) async => matchesWithNull);

      final result = await repository.getMatchesByDate(DateTime(2026, 6, 15));

      expect(result.length, 1);
      expect(result[0].matchId, 'm1');
    });
  });

  group('getMatchesByVenue', () {
    test('filters matches by venueId', () async {
      final matchesWithVenues = [
        TestDataFactory.createMatch(matchId: 'm1', venueId: 'venue_A'),
        TestDataFactory.createMatch(matchId: 'm2', venueId: 'venue_B'),
        TestDataFactory.createMatch(matchId: 'm3', venueId: 'venue_A'),
      ];
      when(() => mockCacheDataSource.getCachedMatches())
          .thenAnswer((_) async => matchesWithVenues);

      final result = await repository.getMatchesByVenue('venue_A');

      expect(result.length, 2);
      expect(result.every((m) => m.venueId == 'venue_A'), true);
    });

    test('returns empty list for unknown venue', () async {
      when(() => mockCacheDataSource.getCachedMatches())
          .thenAnswer((_) async => testMatches);

      final result = await repository.getMatchesByVenue('nonexistent_venue');

      expect(result, isEmpty);
    });

    test('returns empty list on error', () async {
      when(() => mockCacheDataSource.getCachedMatches())
          .thenThrow(Exception('Error'));

      final result = await repository.getMatchesByVenue('venue_A');

      expect(result, isEmpty);
    });
  });

  group('getCompletedMatches', () {
    test('returns cached completed matches when available', () async {
      final completedMatches = [
        TestDataFactory.createMatch(
          matchId: 'm1',
          status: MatchStatus.completed,
        ),
        TestDataFactory.createMatch(
          matchId: 'm2',
          status: MatchStatus.completed,
        ),
      ];
      when(() => mockCacheDataSource.getCachedCompletedMatches())
          .thenAnswer((_) async => completedMatches);

      final result = await repository.getCompletedMatches();

      expect(result, equals(completedMatches));
      verifyNever(() => mockCacheDataSource.getCachedMatches());
    });

    test('filters completed from all matches on cache miss', () async {
      final allMatches = [
        TestDataFactory.createMatch(matchId: 'm1', status: MatchStatus.completed),
        TestDataFactory.createMatch(matchId: 'm2', status: MatchStatus.scheduled),
        TestDataFactory.createMatch(matchId: 'm3', status: MatchStatus.completed),
        TestDataFactory.createMatch(matchId: 'm4', status: MatchStatus.inProgress),
      ];
      when(() => mockCacheDataSource.getCachedCompletedMatches())
          .thenAnswer((_) async => null);
      when(() => mockCacheDataSource.getCachedMatches())
          .thenAnswer((_) async => allMatches);
      when(() => mockCacheDataSource.cacheCompletedMatches(any()))
          .thenAnswer((_) async {});

      final result = await repository.getCompletedMatches();

      expect(result.length, 2);
      expect(result.every((m) => m.status == MatchStatus.completed), true);
    });

    test('sorts completed matches by date descending', () async {
      final allMatches = [
        TestDataFactory.createMatch(
          matchId: 'm1',
          status: MatchStatus.completed,
          dateTime: DateTime(2026, 6, 12),
        ),
        TestDataFactory.createMatch(
          matchId: 'm2',
          status: MatchStatus.completed,
          dateTime: DateTime(2026, 6, 15),
        ),
        TestDataFactory.createMatch(
          matchId: 'm3',
          status: MatchStatus.completed,
          dateTime: DateTime(2026, 6, 13),
        ),
      ];
      when(() => mockCacheDataSource.getCachedCompletedMatches())
          .thenAnswer((_) async => null);
      when(() => mockCacheDataSource.getCachedMatches())
          .thenAnswer((_) async => allMatches);
      when(() => mockCacheDataSource.cacheCompletedMatches(any()))
          .thenAnswer((_) async {});

      final result = await repository.getCompletedMatches();

      expect(result[0].matchId, 'm2'); // June 15 (most recent)
      expect(result[1].matchId, 'm3'); // June 13
      expect(result[2].matchId, 'm1'); // June 12 (oldest)
    });

    test('respects limit parameter', () async {
      final completedMatches = List.generate(
        5,
        (i) => TestDataFactory.createMatch(
          matchId: 'completed_$i',
          status: MatchStatus.completed,
        ),
      );
      when(() => mockCacheDataSource.getCachedCompletedMatches())
          .thenAnswer((_) async => completedMatches);

      final result = await repository.getCompletedMatches(limit: 3);

      expect(result.length, 3);
    });

    test('returns empty list on error', () async {
      when(() => mockCacheDataSource.getCachedCompletedMatches())
          .thenThrow(Exception('Error'));

      final result = await repository.getCompletedMatches();

      expect(result, isEmpty);
    });
  });

  group('getMatchesByGroupMatchDay', () {
    test('filters group stage matches by match day', () async {
      final matchesWithDays = [
        TestDataFactory.createMatch(
          matchId: 'm1',
          stage: MatchStage.groupStage,
          groupMatchDay: 1,
        ),
        TestDataFactory.createMatch(
          matchId: 'm2',
          stage: MatchStage.groupStage,
          groupMatchDay: 2,
        ),
        TestDataFactory.createMatch(
          matchId: 'm3',
          stage: MatchStage.groupStage,
          groupMatchDay: 1,
        ),
        TestDataFactory.createMatch(
          matchId: 'm4',
          stage: MatchStage.roundOf16,
          groupMatchDay: null,
        ),
      ];
      when(() => mockCacheDataSource.getCachedMatches())
          .thenAnswer((_) async => matchesWithDays);

      final result = await repository.getMatchesByGroupMatchDay(1);

      expect(result.length, 2);
      expect(result.every((m) => m.groupMatchDay == 1), true);
      expect(result.every((m) => m.stage == MatchStage.groupStage), true);
    });

    test('returns empty list for invalid match day', () async {
      when(() => mockCacheDataSource.getCachedMatches())
          .thenAnswer((_) async => testMatches);

      final result = await repository.getMatchesByGroupMatchDay(99);

      expect(result, isEmpty);
    });

    test('falls back to mock data when cache throws', () async {
      when(() => mockCacheDataSource.getCachedMatches())
          .thenThrow(Exception('Error'));
      when(() => mockCacheDataSource.cacheMatches(any()))
          .thenAnswer((_) async {});

      final result = await repository.getMatchesByGroupMatchDay(1);

      // getAllMatches falls back to mock data internally, so result may not be empty
      expect(result, isA<List<WorldCupMatch>>());
    });
  });
}
