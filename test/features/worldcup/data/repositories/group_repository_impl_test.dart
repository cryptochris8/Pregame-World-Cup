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
  late GroupRepositoryImpl repository;

  final testGroups = TestDataFactory.createGroupList(count: 4);
  final testGroup = TestDataFactory.createGroup(groupLetter: 'A');

  setUp(() {
    mockApiDataSource = MockWorldCupApiDataSource();
    mockFirestoreDataSource = MockWorldCupFirestoreDataSource();
    mockCacheDataSource = MockWorldCupCacheDataSource();
    repository = GroupRepositoryImpl(
      apiDataSource: mockApiDataSource,
      firestoreDataSource: mockFirestoreDataSource,
      cacheDataSource: mockCacheDataSource,
    );
  });

  setUpAll(() {
    registerFallbackValue(TestDataFactory.createGroup());
  });

  group('getAllGroups', () {
    test('returns cached groups when cache is not empty', () async {
      when(() => mockCacheDataSource.getCachedGroups())
          .thenAnswer((_) async => testGroups);

      final result = await repository.getAllGroups();

      expect(result, equals(testGroups));
      verify(() => mockCacheDataSource.getCachedGroups()).called(1);
      verifyNever(() => mockFirestoreDataSource.getAllGroups());
    });

    test('falls back to Firestore when cache is empty', () async {
      when(() => mockCacheDataSource.getCachedGroups())
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getAllGroups())
          .thenAnswer((_) async => testGroups);
      when(() => mockCacheDataSource.cacheGroups(any()))
          .thenAnswer((_) async {});

      final result = await repository.getAllGroups();

      expect(result, equals(testGroups));
      verify(() => mockFirestoreDataSource.getAllGroups()).called(1);
      verify(() => mockCacheDataSource.cacheGroups(testGroups)).called(1);
    });

    test('falls back to API when cache and Firestore are empty', () async {
      when(() => mockCacheDataSource.getCachedGroups())
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getAllGroups())
          .thenAnswer((_) async => []);
      when(() => mockApiDataSource.fetchGroupStandings())
          .thenAnswer((_) async => testGroups);
      when(() => mockFirestoreDataSource.saveGroup(any()))
          .thenAnswer((_) async {});
      when(() => mockCacheDataSource.cacheGroups(any()))
          .thenAnswer((_) async {});

      final result = await repository.getAllGroups();

      expect(result, equals(testGroups));
    });

    test('falls back to mock data when all sources fail', () async {
      when(() => mockCacheDataSource.getCachedGroups())
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getAllGroups())
          .thenThrow(Exception('Firestore error'));
      when(() => mockApiDataSource.fetchGroupStandings())
          .thenThrow(Exception('API error'));
      when(() => mockCacheDataSource.cacheGroups(any()))
          .thenAnswer((_) async {});

      final result = await repository.getAllGroups();

      expect(result, isNotEmpty);
    });
  });

  group('getGroupByLetter', () {
    test('returns cached group when available', () async {
      when(() => mockCacheDataSource.getCachedGroup('A'))
          .thenAnswer((_) async => testGroup);

      final result = await repository.getGroupByLetter('A');

      expect(result, equals(testGroup));
      verifyNever(() => mockFirestoreDataSource.getGroupByLetter(any()));
    });

    test('falls back to Firestore when cache miss', () async {
      when(() => mockCacheDataSource.getCachedGroup('A'))
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getGroupByLetter('A'))
          .thenAnswer((_) async => testGroup);

      final result = await repository.getGroupByLetter('A');

      expect(result, equals(testGroup));
    });

    test('returns null on error', () async {
      when(() => mockCacheDataSource.getCachedGroup(any()))
          .thenThrow(Exception('Error'));

      final result = await repository.getGroupByLetter('A');

      expect(result, isNull);
    });
  });

  group('getActiveGroups', () {
    test('filters groups that are active (not complete, matchDay > 0)', () async {
      final groups = [
        WorldCupGroup(
          groupLetter: 'A',
          standings: TestDataFactory.createGroup().standings,
          currentMatchDay: 2,
          isComplete: false,
        ),
        WorldCupGroup(
          groupLetter: 'B',
          standings: TestDataFactory.createGroup().standings,
          currentMatchDay: 3,
          isComplete: true,
        ),
        WorldCupGroup(
          groupLetter: 'C',
          standings: TestDataFactory.createGroup().standings,
          currentMatchDay: 0,
          isComplete: false,
        ),
      ];
      when(() => mockCacheDataSource.getCachedGroups())
          .thenAnswer((_) async => groups);

      final result = await repository.getActiveGroups();

      expect(result.length, 1);
      expect(result[0].groupLetter, 'A');
    });
  });

  group('getCompletedGroups', () {
    test('filters completed groups', () async {
      final groups = [
        WorldCupGroup(
          groupLetter: 'A',
          standings: TestDataFactory.createGroup().standings,
          isComplete: true,
        ),
        WorldCupGroup(
          groupLetter: 'B',
          standings: TestDataFactory.createGroup().standings,
          isComplete: false,
        ),
      ];
      when(() => mockCacheDataSource.getCachedGroups())
          .thenAnswer((_) async => groups);

      final result = await repository.getCompletedGroups();

      expect(result.length, 1);
      expect(result[0].groupLetter, 'A');
    });
  });

  group('getGroupStandings', () {
    test('returns sorted standings for a group', () async {
      when(() => mockCacheDataSource.getCachedGroup('A'))
          .thenAnswer((_) async => testGroup);

      final result = await repository.getGroupStandings('A');

      expect(result, isNotEmpty);
    });

    test('returns empty when group not found', () async {
      when(() => mockCacheDataSource.getCachedGroup('Z'))
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getGroupByLetter('Z'))
          .thenAnswer((_) async => null);

      final result = await repository.getGroupStandings('Z');

      expect(result, isEmpty);
    });
  });

  group('updateGroup', () {
    test('saves to Firestore and clears cache', () async {
      when(() => mockFirestoreDataSource.saveGroup(any()))
          .thenAnswer((_) async {});
      when(() => mockCacheDataSource.clearCache(any()))
          .thenAnswer((_) async {});

      await repository.updateGroup(testGroup);

      verify(() => mockFirestoreDataSource.saveGroup(testGroup)).called(1);
      verify(() => mockCacheDataSource.clearCache('worldcup_groups')).called(1);
    });

    test('throws on error', () async {
      when(() => mockFirestoreDataSource.saveGroup(any()))
          .thenThrow(Exception('Save failed'));

      expect(
        () => repository.updateGroup(testGroup),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('refreshGroups', () {
    test('fetches from API, saves each to Firestore, and caches', () async {
      when(() => mockApiDataSource.fetchGroupStandings())
          .thenAnswer((_) async => testGroups);
      when(() => mockFirestoreDataSource.saveGroup(any()))
          .thenAnswer((_) async {});
      when(() => mockCacheDataSource.cacheGroups(any()))
          .thenAnswer((_) async {});

      final result = await repository.refreshGroups();

      expect(result, equals(testGroups));
      verify(() => mockApiDataSource.fetchGroupStandings()).called(1);
      verify(() => mockFirestoreDataSource.saveGroup(any()))
          .called(testGroups.length);
      verify(() => mockCacheDataSource.cacheGroups(testGroups)).called(1);
    });

    test('throws on API error', () async {
      when(() => mockApiDataSource.fetchGroupStandings())
          .thenThrow(Exception('API down'));

      expect(
        () => repository.refreshGroups(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('clearCache', () {
    test('clears group cache', () async {
      when(() => mockCacheDataSource.clearCache(any()))
          .thenAnswer((_) async {});

      await repository.clearCache();

      verify(() => mockCacheDataSource.clearCache('worldcup_groups')).called(1);
    });
  });

  group('watchGroups', () {
    test('delegates to Firestore stream', () {
      when(() => mockFirestoreDataSource.watchGroups())
          .thenAnswer((_) => Stream.value(testGroups));

      final stream = repository.watchGroups();

      expect(stream, isA<Stream<List<WorldCupGroup>>>());
    });
  });

  group('watchGroup', () {
    test('delegates to Firestore stream', () {
      when(() => mockFirestoreDataSource.watchGroup('A'))
          .thenAnswer((_) => Stream.value(testGroup));

      final stream = repository.watchGroup('A');

      expect(stream, isA<Stream<WorldCupGroup?>>());
    });
  });
}
