import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/core/services/cache_service.dart';
import 'package:pregame_world_cup/features/schedule/data/datasources/espn_schedule_datasource.dart';
import 'package:pregame_world_cup/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';

class MockESPNScheduleDataSource extends Mock implements ESPNScheduleDataSource {}
class MockCacheService extends Mock implements CacheService {}

void main() {
  late MockESPNScheduleDataSource mockRemoteDataSource;
  late MockCacheService mockCacheService;
  late ScheduleRepositoryImpl repository;

  final testGames = [
    GameSchedule(
      gameId: 'game_1',
      homeTeamName: 'Team A',
      awayTeamName: 'Team B',
      week: 1,
    ),
    GameSchedule(
      gameId: 'game_2',
      homeTeamName: 'Team C',
      awayTeamName: 'Team D',
      week: 1,
    ),
    GameSchedule(
      gameId: 'game_3',
      homeTeamName: 'Team E',
      awayTeamName: 'Team F',
      week: 2,
    ),
  ];

  setUp(() {
    mockRemoteDataSource = MockESPNScheduleDataSource();
    mockCacheService = MockCacheService();
    repository = ScheduleRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      cacheService: mockCacheService,
    );
  });

  group('getUpcomingGames', () {
    test('returns cached games when cache hit', () async {
      final cachedData = testGames.take(2).map((g) => g.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('schedule_upcoming_10'))
          .thenAnswer((_) async => cachedData);

      final result = await repository.getUpcomingGames();

      expect(result.length, 2);
      expect(result.first.gameId, 'game_1');
      verifyNever(() => mockRemoteDataSource.fetchUpcomingGames(limit: any(named: 'limit')));
    });

    test('fetches from remote and caches on cache miss', () async {
      when(() => mockCacheService.get<List<dynamic>>('schedule_upcoming_10'))
          .thenAnswer((_) async => null);
      when(() => mockRemoteDataSource.fetchUpcomingGames(limit: 10))
          .thenAnswer((_) async => testGames.take(2).toList());
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      final result = await repository.getUpcomingGames();

      expect(result.length, 2);
      verify(() => mockRemoteDataSource.fetchUpcomingGames(limit: 10)).called(1);
      verify(() => mockCacheService.set<List<Map<String, dynamic>>>(
            'schedule_upcoming_10',
            any(),
            duration: any(named: 'duration'),
          )).called(1);
    });

    test('uses custom limit for cache key', () async {
      when(() => mockCacheService.get<List<dynamic>>('schedule_upcoming_5'))
          .thenAnswer((_) async => null);
      when(() => mockRemoteDataSource.fetchUpcomingGames(limit: 5))
          .thenAnswer((_) async => [testGames.first]);
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      final result = await repository.getUpcomingGames(limit: 5);

      expect(result.length, 1);
      verify(() => mockCacheService.get<List<dynamic>>('schedule_upcoming_5')).called(1);
    });

    test('ignores cache errors and fetches from remote', () async {
      when(() => mockCacheService.get<List<dynamic>>('schedule_upcoming_10'))
          .thenThrow(Exception('Cache error'));
      when(() => mockRemoteDataSource.fetchUpcomingGames(limit: 10))
          .thenAnswer((_) async => testGames);
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      final result = await repository.getUpcomingGames();
      expect(result.length, 3);
    });
  });

  group('getScheduleForWeek', () {
    test('returns cached week games when cache hit', () async {
      final weekGames = testGames.where((g) => g.week == 1).toList();
      final cachedData = weekGames.map((g) => g.toMap()).toList();
      when(() => mockCacheService.get<List<dynamic>>('schedule_week_2025_1'))
          .thenAnswer((_) async => cachedData);

      final result = await repository.getScheduleForWeek(2025, 1);

      expect(result.length, 2);
      verifyNever(() => mockRemoteDataSource.fetch2025SeasonSchedule(limit: any(named: 'limit')));
    });

    test('fetches all games and filters by week on cache miss', () async {
      when(() => mockCacheService.get<List<dynamic>>('schedule_week_2025_1'))
          .thenAnswer((_) async => null);
      when(() => mockRemoteDataSource.fetch2025SeasonSchedule(limit: 500))
          .thenAnswer((_) async => testGames);
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      final result = await repository.getScheduleForWeek(2025, 1);

      expect(result.length, 2); // Only week 1 games
      expect(result.every((g) => g.week == 1), isTrue);
    });

    test('caches filtered results with 2-hour duration', () async {
      when(() => mockCacheService.get<List<dynamic>>('schedule_week_2025_2'))
          .thenAnswer((_) async => null);
      when(() => mockRemoteDataSource.fetch2025SeasonSchedule(limit: 500))
          .thenAnswer((_) async => testGames);
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      await repository.getScheduleForWeek(2025, 2);

      verify(() => mockCacheService.set<List<Map<String, dynamic>>>(
            'schedule_week_2025_2',
            any(),
            duration: any(named: 'duration'),
          )).called(1);
    });

    test('returns empty list for week with no games', () async {
      when(() => mockCacheService.get<List<dynamic>>('schedule_week_2025_99'))
          .thenAnswer((_) async => null);
      when(() => mockRemoteDataSource.fetch2025SeasonSchedule(limit: 500))
          .thenAnswer((_) async => testGames);
      when(() => mockCacheService.set<List<Map<String, dynamic>>>(
            any(),
            any(),
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});

      final result = await repository.getScheduleForWeek(2025, 99);

      expect(result, isEmpty);
    });
  });
}
