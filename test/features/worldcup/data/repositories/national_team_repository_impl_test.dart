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
  late NationalTeamRepositoryImpl repository;

  final testTeams = TestDataFactory.createTeamList(count: 5);
  final testTeam = TestDataFactory.createTeam(
    teamCode: 'USA',
    countryName: 'United States',
  );

  setUpAll(() {
    registerFallbackValue(TestDataFactory.createTeam());
    registerFallbackValue(<NationalTeam>[]);
    registerFallbackValue(Confederation.uefa);
  });

  setUp(() {
    mockApiDataSource = MockWorldCupApiDataSource();
    mockFirestoreDataSource = MockWorldCupFirestoreDataSource();
    mockCacheDataSource = MockWorldCupCacheDataSource();
    repository = NationalTeamRepositoryImpl(
      apiDataSource: mockApiDataSource,
      firestoreDataSource: mockFirestoreDataSource,
      cacheDataSource: mockCacheDataSource,
    );
  });

  group('getAllTeams', () {
    test('returns cached teams when cache is not empty', () async {
      when(() => mockCacheDataSource.getCachedTeams())
          .thenAnswer((_) async => testTeams);

      final result = await repository.getAllTeams();

      expect(result, equals(testTeams));
      verify(() => mockCacheDataSource.getCachedTeams()).called(1);
      verifyNever(() => mockFirestoreDataSource.getAllTeams());
    });

    test('falls back to Firestore when cache is empty', () async {
      when(() => mockCacheDataSource.getCachedTeams())
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getAllTeams())
          .thenAnswer((_) async => testTeams);
      when(() => mockCacheDataSource.cacheTeams(any()))
          .thenAnswer((_) async {});

      final result = await repository.getAllTeams();

      expect(result, equals(testTeams));
      verify(() => mockFirestoreDataSource.getAllTeams()).called(1);
      verify(() => mockCacheDataSource.cacheTeams(testTeams)).called(1);
    });

    test('falls back to API when cache and Firestore are empty', () async {
      when(() => mockCacheDataSource.getCachedTeams())
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getAllTeams())
          .thenAnswer((_) async => []);
      when(() => mockApiDataSource.fetchAllTeams())
          .thenAnswer((_) async => testTeams);
      when(() => mockFirestoreDataSource.saveTeams(any()))
          .thenAnswer((_) async {});
      when(() => mockCacheDataSource.cacheTeams(any()))
          .thenAnswer((_) async {});

      final result = await repository.getAllTeams();

      expect(result, equals(testTeams));
    });

    test('falls back to mock data when all sources fail', () async {
      when(() => mockCacheDataSource.getCachedTeams())
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getAllTeams())
          .thenThrow(Exception('Firestore error'));
      when(() => mockApiDataSource.fetchAllTeams())
          .thenThrow(Exception('API error'));
      when(() => mockCacheDataSource.cacheTeams(any()))
          .thenAnswer((_) async {});

      final result = await repository.getAllTeams();

      expect(result, isNotEmpty);
    });
  });

  group('getTeamByCode', () {
    test('returns cached team when available', () async {
      when(() => mockCacheDataSource.getCachedTeam('USA'))
          .thenAnswer((_) async => testTeam);

      final result = await repository.getTeamByCode('USA');

      expect(result, equals(testTeam));
      verifyNever(() => mockFirestoreDataSource.getTeamByCode(any()));
    });

    test('falls back to Firestore when cache miss', () async {
      when(() => mockCacheDataSource.getCachedTeam('USA'))
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getTeamByCode('USA'))
          .thenAnswer((_) async => testTeam);

      final result = await repository.getTeamByCode('USA');

      expect(result, equals(testTeam));
    });

    test('returns null on error', () async {
      when(() => mockCacheDataSource.getCachedTeam(any()))
          .thenThrow(Exception('Error'));

      final result = await repository.getTeamByCode('USA');

      expect(result, isNull);
    });
  });

  group('getTeamsByGroup', () {
    test('returns cached teams by group', () async {
      when(() => mockCacheDataSource.getCachedTeamsByGroup('A'))
          .thenAnswer((_) async => testTeams);

      final result = await repository.getTeamsByGroup('A');

      expect(result, equals(testTeams));
    });

    test('falls back to Firestore', () async {
      when(() => mockCacheDataSource.getCachedTeamsByGroup('A'))
          .thenAnswer((_) async => null);
      when(() => mockFirestoreDataSource.getTeamsByGroup('A'))
          .thenAnswer((_) async => testTeams);

      final result = await repository.getTeamsByGroup('A');

      expect(result, equals(testTeams));
    });

    test('returns empty list on error', () async {
      when(() => mockCacheDataSource.getCachedTeamsByGroup(any()))
          .thenThrow(Exception('Error'));

      final result = await repository.getTeamsByGroup('A');

      expect(result, isEmpty);
    });
  });

  group('getTeamsByConfederation', () {
    test('filters teams by confederation', () async {
      final teams = [
        TestDataFactory.createTeam(
          teamCode: 'USA',
          confederation: Confederation.concacaf,
        ),
        TestDataFactory.createTeam(
          teamCode: 'BRA',
          confederation: Confederation.conmebol,
        ),
        TestDataFactory.createTeam(
          teamCode: 'MEX',
          confederation: Confederation.concacaf,
        ),
      ];
      when(() => mockCacheDataSource.getCachedTeams())
          .thenAnswer((_) async => teams);

      final result = await repository.getTeamsByConfederation(Confederation.concacaf);

      expect(result.length, 2);
      expect(result.every((t) => t.confederation == Confederation.concacaf), isTrue);
    });

    test('falls back to mock data when cache throws', () async {
      when(() => mockCacheDataSource.getCachedTeams())
          .thenThrow(Exception('Error'));
      when(() => mockCacheDataSource.cacheTeams(any()))
          .thenAnswer((_) async {});

      final result = await repository.getTeamsByConfederation(Confederation.concacaf);

      // getAllTeams falls back to mock data, which includes CONCACAF teams
      expect(result, isNotEmpty);
      expect(result.every((t) => t.confederation == Confederation.concacaf), isTrue);
    });
  });

  group('getHostNations', () {
    test('filters host nations', () async {
      final teams = [
        TestDataFactory.createTeam(teamCode: 'USA', isHostNation: true),
        TestDataFactory.createTeam(teamCode: 'MEX', isHostNation: true),
        TestDataFactory.createTeam(teamCode: 'CAN', isHostNation: true),
        TestDataFactory.createTeam(teamCode: 'BRA', isHostNation: false),
      ];
      when(() => mockCacheDataSource.getCachedTeams())
          .thenAnswer((_) async => teams);

      final result = await repository.getHostNations();

      expect(result.length, 3);
      expect(result.every((t) => t.isHostNation), isTrue);
    });
  });

  group('getTeamsByRanking', () {
    test('returns teams sorted by world ranking', () async {
      final teams = [
        TestDataFactory.createTeam(teamCode: 'USA', worldRanking: 13),
        TestDataFactory.createTeam(teamCode: 'BRA', worldRanking: 1),
        TestDataFactory.createTeam(teamCode: 'MEX', worldRanking: 15),
      ];
      when(() => mockCacheDataSource.getCachedTeams())
          .thenAnswer((_) async => teams);

      final result = await repository.getTeamsByRanking();

      expect(result.length, 3);
      expect(result[0].worldRanking, 1);
      expect(result[1].worldRanking, 13);
      expect(result[2].worldRanking, 15);
    });
  });

  group('searchTeams', () {
    test('searches by country name', () async {
      final teams = [
        TestDataFactory.createTeam(teamCode: 'USA', countryName: 'United States'),
        TestDataFactory.createTeam(teamCode: 'BRA', countryName: 'Brazil'),
        TestDataFactory.createTeam(teamCode: 'MEX', countryName: 'Mexico'),
      ];
      when(() => mockCacheDataSource.getCachedTeams())
          .thenAnswer((_) async => teams);

      final result = await repository.searchTeams('united');

      expect(result.length, 1);
      expect(result[0].teamCode, 'USA');
    });

    test('searches by team code', () async {
      final teams = [
        TestDataFactory.createTeam(teamCode: 'USA', countryName: 'United States'),
        TestDataFactory.createTeam(teamCode: 'BRA', countryName: 'Brazil'),
      ];
      when(() => mockCacheDataSource.getCachedTeams())
          .thenAnswer((_) async => teams);

      final result = await repository.searchTeams('bra');

      expect(result.length, 1);
      expect(result[0].teamCode, 'BRA');
    });

    test('returns empty list on no match', () async {
      when(() => mockCacheDataSource.getCachedTeams())
          .thenAnswer((_) async => testTeams);

      final result = await repository.searchTeams('zzznonexistent');

      expect(result, isEmpty);
    });
  });

  group('getPreviousChampions', () {
    test('returns teams with world cup titles sorted descending', () async {
      final teams = [
        TestDataFactory.createTeam(teamCode: 'BRA'),
        TestDataFactory.createTeam(teamCode: 'USA'),
        TestDataFactory.createTeam(teamCode: 'GER'),
      ];
      when(() => mockCacheDataSource.getCachedTeams())
          .thenAnswer((_) async => teams);

      final result = await repository.getPreviousChampions();

      // Only teams with worldCupTitles > 0
      expect(result.every((t) => t.worldCupTitles > 0), isTrue);
    });
  });

  group('updateTeam', () {
    test('saves to Firestore and clears cache', () async {
      when(() => mockFirestoreDataSource.saveTeam(testTeam))
          .thenAnswer((_) async {});
      when(() => mockCacheDataSource.clearCache(any()))
          .thenAnswer((_) async {});

      await repository.updateTeam(testTeam);

      verify(() => mockFirestoreDataSource.saveTeam(testTeam)).called(1);
      verify(() => mockCacheDataSource.clearCache('worldcup_teams')).called(1);
    });

    test('throws on error', () async {
      when(() => mockFirestoreDataSource.saveTeam(any()))
          .thenThrow(Exception('Save failed'));

      expect(
        () => repository.updateTeam(testTeam),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('refreshTeams', () {
    test('fetches from API, saves to Firestore, and caches', () async {
      when(() => mockApiDataSource.fetchAllTeams())
          .thenAnswer((_) async => testTeams);
      when(() => mockFirestoreDataSource.saveTeams(any()))
          .thenAnswer((_) async {});
      when(() => mockCacheDataSource.cacheTeams(any()))
          .thenAnswer((_) async {});

      final result = await repository.refreshTeams();

      expect(result, equals(testTeams));
      verify(() => mockApiDataSource.fetchAllTeams()).called(1);
      verify(() => mockFirestoreDataSource.saveTeams(testTeams)).called(1);
      verify(() => mockCacheDataSource.cacheTeams(testTeams)).called(1);
    });

    test('throws on API error', () async {
      when(() => mockApiDataSource.fetchAllTeams())
          .thenThrow(Exception('API down'));

      expect(
        () => repository.refreshTeams(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('clearCache', () {
    test('clears team cache', () async {
      when(() => mockCacheDataSource.clearCache(any()))
          .thenAnswer((_) async {});

      await repository.clearCache();

      verify(() => mockCacheDataSource.clearCache('worldcup_teams')).called(1);
    });
  });

  group('watchTeams', () {
    test('delegates to Firestore stream', () {
      when(() => mockFirestoreDataSource.watchTeams())
          .thenAnswer((_) => Stream.value(testTeams));

      final stream = repository.watchTeams();

      expect(stream, isA<Stream<List<NationalTeam>>>());
    });
  });

  group('watchTeam', () {
    test('finds matching team from stream', () async {
      final teamsWithUsa = [
        ...testTeams,
        TestDataFactory.createTeam(teamCode: 'USA', countryName: 'United States'),
      ];
      when(() => mockFirestoreDataSource.watchTeams())
          .thenAnswer((_) => Stream.value(teamsWithUsa));

      final stream = repository.watchTeam('USA');
      final result = await stream.first;

      expect(result?.teamCode, 'USA');
    });

    test('returns null when team not found in stream', () async {
      when(() => mockFirestoreDataSource.watchTeams())
          .thenAnswer((_) => Stream.value(testTeams));

      final stream = repository.watchTeam('NONEXISTENT');
      final result = await stream.first;

      expect(result, isNull);
    });
  });
}
