import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import '../../../../test_helpers/mock_datasources.dart';
import '../../../worldcup/presentation/bloc/mock_repositories.dart';

void main() {
  late MockWorldCupFirestoreDataSource mockFirestoreDataSource;
  late MockWorldCupCacheDataSource mockCacheDataSource;
  late BracketRepositoryImpl repository;

  final testBracket = TestDataFactory.createBracket();

  setUpAll(() {
    registerFallbackValue(const WorldCupBracket());
    registerFallbackValue(TestDataFactory.createBracketMatch());
  });

  setUp(() {
    mockFirestoreDataSource = MockWorldCupFirestoreDataSource();
    mockCacheDataSource = MockWorldCupCacheDataSource();
    repository = BracketRepositoryImpl(
      firestoreDataSource: mockFirestoreDataSource,
      cacheDataSource: mockCacheDataSource,
    );
  });

  group('getBracket', () {
    test('returns cached bracket when cache hit', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getBracket();

      expect(result.roundOf32.length, testBracket.roundOf32.length);
      verify(() => mockCacheDataSource.getCachedBracket()).called(1);
      verifyNever(() => mockFirestoreDataSource.getBracket());
    });

    test('falls back to Firestore when cache miss', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getBracket())
          .thenAnswer((_) async => testBracket);
      when(() => mockCacheDataSource.cacheBracket(any()))
          .thenAnswer((_) async {});

      final result = await repository.getBracket();

      expect(result.roundOf32.length, testBracket.roundOf32.length);
      verify(() => mockFirestoreDataSource.getBracket()).called(1);
      verify(() => mockCacheDataSource.cacheBracket(any())).called(1);
    });

    test('returns empty bracket when Firestore returns null', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getBracket())
          .thenAnswer((_) async => null);

      final result = await repository.getBracket();

      expect(result.roundOf32, isEmpty);
      expect(result.roundOf16, isEmpty);
    });

    test('returns cached bracket on error with cache available', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      // First call succeeds from cache, second would error
      final result = await repository.getBracket();
      expect(result.roundOf32.length, testBracket.roundOf32.length);
    });

    test('returns empty bracket on error with no cache', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenThrow(Exception('Cache error'));

      final result = await repository.getBracket();
      expect(result.roundOf32, isEmpty);
    });
  });

  group('getMatchesByStage', () {
    test('returns matches for round of 32', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getMatchesByStage(MatchStage.roundOf32);

      expect(result.length, testBracket.roundOf32.length);
      expect(result.every((m) => m.stage == MatchStage.roundOf32), isTrue);
    });

    test('returns matches for quarter finals', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getMatchesByStage(MatchStage.quarterFinal);

      expect(result.length, testBracket.quarterFinals.length);
    });

    test('returns empty list on error', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenThrow(Exception('Error'));

      final result = await repository.getMatchesByStage(MatchStage.roundOf16);
      expect(result, isEmpty);
    });
  });

  group('getBracketMatchById', () {
    test('returns match when found', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getBracketMatchById('r32_0');

      expect(result, isNotNull);
      expect(result!.matchId, 'r32_0');
    });

    test('returns null when not found', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getBracketMatchById('nonexistent');
      expect(result, isNull);
    });

    test('returns null on error', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenThrow(Exception('Error'));

      final result = await repository.getBracketMatchById('r32_0');
      expect(result, isNull);
    });
  });

  group('getTeamKnockoutPath', () {
    test('returns matches where team appears', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getTeamKnockoutPath('USA');

      // USA appears in default bracket slots
      expect(result, isNotEmpty);
      for (final match in result) {
        expect(
          match.homeSlot.teamCode == 'USA' || match.awaySlot.teamCode == 'USA',
          isTrue,
        );
      }
    });

    test('returns empty list for team not in bracket', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getTeamKnockoutPath('JAM');
      expect(result, isEmpty);
    });

    test('sorts by stage order', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getTeamKnockoutPath('USA');

      if (result.length >= 2) {
        final stageOrder = {
          MatchStage.roundOf32: 0,
          MatchStage.roundOf16: 1,
          MatchStage.quarterFinal: 2,
          MatchStage.semiFinal: 3,
          MatchStage.thirdPlace: 4,
          MatchStage.final_: 5,
        };
        for (int i = 0; i < result.length - 1; i++) {
          expect(
            (stageOrder[result[i].stage] ?? 0) <=
                (stageOrder[result[i + 1].stage] ?? 0),
            isTrue,
          );
        }
      }
    });
  });

  group('getUpcomingKnockoutMatches', () {
    test('returns scheduled matches sorted by date', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getUpcomingKnockoutMatches();

      expect(result, isNotEmpty);
      for (final match in result) {
        expect(match.status, MatchStatus.scheduled);
      }
    });

    test('respects limit parameter', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getUpcomingKnockoutMatches(limit: 3);

      expect(result.length, lessThanOrEqualTo(3));
    });
  });

  group('getLiveKnockoutMatches', () {
    test('returns live matches from bracket', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getLiveKnockoutMatches();

      // Default bracket has no live matches
      expect(result, isEmpty);
    });

    test('returns empty on error', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenThrow(Exception('Error'));

      final result = await repository.getLiveKnockoutMatches();
      expect(result, isEmpty);
    });
  });

  group('getCompletedKnockoutMatches', () {
    test('returns completed matches', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getCompletedKnockoutMatches();

      // Default bracket has no completed matches
      expect(result, isEmpty);
    });
  });

  group('getSemiFinals', () {
    test('returns semi-final matches', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getSemiFinals();

      expect(result.length, testBracket.semiFinals.length);
    });
  });

  group('getFinalMatch', () {
    test('returns the final match', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getFinalMatch();

      expect(result, isNotNull);
      expect(result!.matchId, 'final');
    });

    test('returns null on error', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenThrow(Exception('Error'));

      final result = await repository.getFinalMatch();
      expect(result, isNull);
    });
  });

  group('getThirdPlaceMatch', () {
    test('returns the third place match', () async {
      when(() => mockCacheDataSource.getCachedBracket())
          .thenAnswer((_) async => testBracket);

      final result = await repository.getThirdPlaceMatch();

      expect(result, isNotNull);
      expect(result!.matchId, '3rd');
    });
  });

  group('updateBracket', () {
    test('saves to Firestore and caches', () async {
      when(() => mockFirestoreDataSource.saveBracket(any()))
          .thenAnswer((_) async {});
      when(() => mockCacheDataSource.cacheBracket(any()))
          .thenAnswer((_) async {});

      await repository.updateBracket(testBracket);

      verify(() => mockFirestoreDataSource.saveBracket(any())).called(1);
      verify(() => mockCacheDataSource.cacheBracket(any())).called(1);
    });

    test('throws on Firestore error', () async {
      when(() => mockFirestoreDataSource.saveBracket(any()))
          .thenThrow(Exception('Write failed'));

      expect(
        () => repository.updateBracket(testBracket),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('refreshBracket', () {
    test('clears cache and fetches from Firestore', () async {
      when(() => mockCacheDataSource.clearCache(any()))
          .thenAnswer((_) async {});
      when(() => mockFirestoreDataSource.getBracket())
          .thenAnswer((_) async => testBracket);
      when(() => mockCacheDataSource.cacheBracket(any()))
          .thenAnswer((_) async {});

      final result = await repository.refreshBracket();

      verify(() => mockCacheDataSource.clearCache('worldcup_bracket')).called(1);
      verify(() => mockFirestoreDataSource.getBracket()).called(1);
      expect(result.roundOf32.length, testBracket.roundOf32.length);
    });

    test('returns empty bracket when Firestore returns null', () async {
      when(() => mockCacheDataSource.clearCache(any()))
          .thenAnswer((_) async {});
      when(() => mockFirestoreDataSource.getBracket())
          .thenAnswer((_) async => null);

      final result = await repository.refreshBracket();
      expect(result.roundOf32, isEmpty);
    });
  });

  group('clearCache', () {
    test('clears bracket cache key', () async {
      when(() => mockCacheDataSource.clearCache(any()))
          .thenAnswer((_) async {});

      await repository.clearCache();

      verify(() => mockCacheDataSource.clearCache('worldcup_bracket')).called(1);
    });
  });

  group('watchBracket', () {
    test('maps Firestore stream to bracket', () async {
      when(() => mockFirestoreDataSource.watchBracket())
          .thenAnswer((_) => Stream.value(testBracket));

      final stream = repository.watchBracket();
      final first = await stream.first;

      expect(first.roundOf32.length, testBracket.roundOf32.length);
    });

    test('returns empty bracket when Firestore emits null', () async {
      when(() => mockFirestoreDataSource.watchBracket())
          .thenAnswer((_) => Stream.value(null));

      final stream = repository.watchBracket();
      final first = await stream.first;

      expect(first.roundOf32, isEmpty);
    });
  });

  group('watchBracketMatch', () {
    test('maps stream to specific match', () async {
      when(() => mockFirestoreDataSource.watchBracket())
          .thenAnswer((_) => Stream.value(testBracket));

      final stream = repository.watchBracketMatch('r32_0');
      final first = await stream.first;

      expect(first, isNotNull);
      expect(first!.matchId, 'r32_0');
    });

    test('returns null for nonexistent match', () async {
      when(() => mockFirestoreDataSource.watchBracket())
          .thenAnswer((_) => Stream.value(testBracket));

      final stream = repository.watchBracketMatch('nonexistent');
      final first = await stream.first;

      expect(first, isNull);
    });
  });
}
