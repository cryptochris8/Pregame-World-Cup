import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/core/services/cache_service.dart';
import 'package:pregame_world_cup/features/schedule/data/datasources/espn_schedule_datasource.dart';
import 'package:pregame_world_cup/features/schedule/data/datasources/live_scores_datasource.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import 'package:pregame_world_cup/services/espn_service.dart';

// ==================== MOCKS ====================

class MockDio extends Mock implements Dio {
  @override
  BaseOptions get options => BaseOptions();
}

class MockESPNService extends Mock implements ESPNService {}

class MockCacheService extends Mock implements CacheService {}

// ==================== TEST DATA ====================

const _testApiKey = 'test_api_key';

final _testGames = [
  GameSchedule(
    gameId: 'game_1',
    homeTeamName: 'USA',
    awayTeamName: 'Mexico',
    week: 1,
    status: 'Scheduled',
    dateTime: DateTime(2026, 6, 15, 20, 0),
    dateTimeUTC: DateTime.utc(2026, 6, 16, 0, 0),
  ),
  GameSchedule(
    gameId: 'game_2',
    homeTeamName: 'Brazil',
    awayTeamName: 'Argentina',
    week: 1,
    status: 'Scheduled',
    dateTime: DateTime(2026, 6, 16, 15, 0),
    dateTimeUTC: DateTime.utc(2026, 6, 16, 19, 0),
  ),
  GameSchedule(
    gameId: 'game_3',
    homeTeamName: 'Germany',
    awayTeamName: 'France',
    week: 2,
    status: 'Scheduled',
    dateTime: DateTime(2026, 6, 20, 20, 0),
    dateTimeUTC: DateTime.utc(2026, 6, 21, 0, 0),
  ),
];

Map<String, dynamic> _createLiveGameData({
  String gameId = '12345',
  String homeTeam = 'USA',
  String awayTeam = 'Mexico',
  int? homeScore,
  int? awayScore,
  String? status,
  String? period,
  String? clock,
  String? dateTime,
}) {
  return {
    'GameID': int.tryParse(gameId) ?? 12345,
    'GlobalGameID': 100001,
    'Season': '2026',
    'SeasonType': 1,
    'Week': 1,
    'Status': status ?? 'Scheduled',
    'DateTime': dateTime ?? '2026-06-15T20:00:00Z',
    'HomeTeamName': homeTeam,
    'AwayTeamName': awayTeam,
    'HomeTeamID': 1,
    'AwayTeamID': 2,
    'GlobalHomeTeamID': 101,
    'GlobalAwayTeamID': 102,
    'StadiumID': 50,
    'Channel': 'FOX',
    'NeutralVenue': true,
    'HomeTeamScore': homeScore,
    'AwayTeamScore': awayScore,
    'Period': period,
    'Clock': clock,
  };
}

// ==================== TESTS ====================

void main() {
  // ===========================================================================
  // LiveScoresDataSourceImpl tests
  // ===========================================================================
  group('LiveScoresDataSourceImpl', () {
    late MockDio mockDio;
    late LiveScoresDataSourceImpl dataSource;

    setUp(() {
      mockDio = MockDio();
      dataSource = LiveScoresDataSourceImpl(
        dio: mockDio,
        apiKey: _testApiKey,
      );
    });

    group('constructor', () {
      test('creates instance with required parameters', () {
        expect(dataSource, isNotNull);
        expect(dataSource, isA<LiveScoresDataSource>());
      });

      test('uses default base URL', () {
        final ds = LiveScoresDataSourceImpl(
          dio: mockDio,
          apiKey: 'key',
        );
        expect(ds, isNotNull);
      });

      test('accepts custom base URL', () {
        final ds = LiveScoresDataSourceImpl(
          dio: mockDio,
          apiKey: 'key',
          baseUrl: 'https://custom.api.com',
        );
        expect(ds, isNotNull);
      });
    });

    group('getLiveScores', () {
      test('returns list of GameSchedule on success', () async {
        final today = DateTime.now();
        final formattedDate =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: [
                _createLiveGameData(
                  homeScore: 2,
                  awayScore: 1,
                  status: 'InProgress',
                  period: '2H',
                  clock: "67'",
                ),
              ],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getLiveScores();

        expect(result.length, 1);
        expect(result.first.homeTeamName, 'USA');
        expect(result.first.awayTeamName, 'Mexico');
        expect(result.first.homeScore, 2);
        expect(result.first.awayScore, 1);
        expect(result.first.isLive, true);
        expect(result.first.period, '2H');
        expect(result.first.timeRemaining, "67'");
      });

      test('throws exception on non-200 status', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 500,
              requestOptions: RequestOptions(path: ''),
            ));

        expect(
          () => dataSource.getLiveScores(),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.connectionTimeout,
            ));

        expect(
          () => dataSource.getLiveScores(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getGameLiveScore', () {
      test('returns GameSchedule for existing game', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: _createLiveGameData(
                gameId: '99',
                homeScore: 1,
                awayScore: 0,
                status: 'FirstHalf',
                period: '1H',
                clock: "32'",
              ),
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getGameLiveScore('99');

        expect(result, isNotNull);
        expect(result!.homeScore, 1);
        expect(result.awayScore, 0);
        expect(result.isLive, true);
      });

      test('returns null for non-200 status', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: null,
              statusCode: 404,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getGameLiveScore('999');

        expect(result, isNull);
      });

      test('returns null on DioException', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getGameLiveScore('999');

        expect(result, isNull);
      });
    });

    group('getLiveGames', () {
      test('filters for only live games', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: [
                _createLiveGameData(status: 'InProgress', homeScore: 1, awayScore: 0),
                _createLiveGameData(
                  gameId: '2',
                  status: 'Scheduled',
                  homeTeam: 'Brazil',
                  awayTeam: 'Argentina',
                ),
                _createLiveGameData(
                  gameId: '3',
                  status: 'SecondHalf',
                  homeTeam: 'Germany',
                  awayTeam: 'France',
                  homeScore: 2,
                  awayScore: 2,
                ),
              ],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getLiveGames();

        // InProgress and SecondHalf are live, Scheduled is not
        expect(result.length, 2);
        expect(result.any((g) => g.homeTeamName == 'USA'), true);
        expect(result.any((g) => g.homeTeamName == 'Germany'), true);
      });

      test('returns empty list when no live games', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: [
                _createLiveGameData(status: 'Scheduled'),
                _createLiveGameData(gameId: '2', status: 'Final'),
              ],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getLiveGames();

        expect(result, isEmpty);
      });

      test('returns empty list on error', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getLiveGames();

        expect(result, isEmpty);
      });
    });

    group('_parseGameWithLiveScore', () {
      test('parses date and time correctly', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: [
                _createLiveGameData(
                  dateTime: '2026-06-15T20:00:00Z',
                  status: 'Scheduled',
                ),
              ],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getLiveScores();

        expect(result.first.dateTimeUTC, isNotNull);
        expect(result.first.dateTimeUTC!.year, 2026);
        expect(result.first.dateTimeUTC!.month, 6);
        expect(result.first.dateTimeUTC!.day, 15);
      });

      test('handles null DateTime gracefully', () async {
        final gameData = Map<String, dynamic>.from(
          _createLiveGameData(status: 'Scheduled'),
        );
        gameData['DateTime'] = null;

        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: [gameData],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getLiveScores();
        expect(result.first.dateTimeUTC, isNull);
      });

      test('handles invalid DateTime string', () async {
        final gameData = Map<String, dynamic>.from(
          _createLiveGameData(status: 'Scheduled'),
        );
        gameData['DateTime'] = 'not-a-date';

        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: [gameData],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Should not throw - warning is logged
        final result = await dataSource.getLiveScores();
        expect(result.length, 1);
      });

      test('uses Minute field when Clock is null', () async {
        final gameData = Map<String, dynamic>.from(
          _createLiveGameData(status: 'InProgress'),
        );
        gameData['Clock'] = null;
        gameData['Minute'] = 42;

        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: [gameData],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getLiveScores();
        expect(result.first.timeRemaining, "42'");
      });

      test('parses social fields as defaults', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: [_createLiveGameData(status: 'Scheduled')],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getLiveScores();
        expect(result.first.userPredictions, 0);
        expect(result.first.userComments, 0);
        expect(result.first.userPhotos, 0);
        expect(result.first.userRating, 0.0);
      });

      test('uses HomeTeam fallback when HomeTeamName is null', () async {
        final gameData = Map<String, dynamic>.from(
          _createLiveGameData(status: 'Scheduled'),
        );
        gameData['HomeTeamName'] = null;
        gameData['HomeTeam'] = 'FallbackHome';
        gameData['AwayTeamName'] = null;
        gameData['AwayTeam'] = 'FallbackAway';

        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: [gameData],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getLiveScores();
        expect(result.first.homeTeamName, 'FallbackHome');
        expect(result.first.awayTeamName, 'FallbackAway');
      });

      test('falls back to N/A when no team name available', () async {
        final gameData = Map<String, dynamic>.from(
          _createLiveGameData(status: 'Scheduled'),
        );
        gameData['HomeTeamName'] = null;
        gameData['HomeTeam'] = null;
        gameData['AwayTeamName'] = null;
        gameData['AwayTeam'] = null;

        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: [gameData],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getLiveScores();
        expect(result.first.homeTeamName, 'N/A');
        expect(result.first.awayTeamName, 'N/A');
      });
    });

    group('_isGameLive', () {
      final liveStatuses = [
        'InProgress',
        'Live',
        'FirstHalf',
        '1st Half',
        'SecondHalf',
        '2nd Half',
        'Halftime',
        'HalfTime',
        'ExtraTime',
        'Extra Time',
        'ExtraTimeHalfTime',
        'PenaltyShootout',
        'Penalty Shootout',
      ];

      for (final status in liveStatuses) {
        test('recognizes "$status" as live', () async {
          when(() => mockDio.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => Response(
                data: [_createLiveGameData(status: status, homeScore: 0, awayScore: 0)],
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

          final result = await dataSource.getLiveScores();
          expect(result.first.isLive, true,
              reason: 'Status "$status" should be live');
        });
      }

      final nonLiveStatuses = ['Scheduled', 'Final', 'Postponed', 'Cancelled'];
      for (final status in nonLiveStatuses) {
        test('does NOT recognize "$status" as live', () async {
          when(() => mockDio.get(
                any(),
                queryParameters: any(named: 'queryParameters'),
              )).thenAnswer((_) async => Response(
                data: [_createLiveGameData(status: status)],
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

          final result = await dataSource.getLiveScores();
          expect(result.first.isLive, false,
              reason: 'Status "$status" should NOT be live');
        });
      }

      test('null status is not live', () async {
        final gameData = Map<String, dynamic>.from(
          _createLiveGameData(),
        );
        gameData['Status'] = null;

        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: [gameData],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getLiveScores();
        expect(result.first.isLive, false);
      });
    });
  });

  // ===========================================================================
  // ESPNScheduleDataSource tests
  // ===========================================================================
  group('ESPNScheduleDataSource', () {
    late MockESPNService mockEspnService;
    late MockCacheService mockCacheService;
    late ESPNScheduleDataSource dataSource;

    setUp(() {
      mockEspnService = MockESPNService();
      mockCacheService = MockCacheService();
      dataSource = ESPNScheduleDataSource(
        espnService: mockEspnService,
        cacheService: mockCacheService,
      );
    });

    group('constructor', () {
      test('creates instance with default dependencies', () {
        // Calling without args should not throw
        final ds = ESPNScheduleDataSource();
        expect(ds, isNotNull);
      });

      test('creates instance with injected dependencies', () {
        expect(dataSource, isNotNull);
      });
    });

    group('fetchUpcomingGames', () {
      test('returns cached games on cache hit', () async {
        final cachedData = _testGames.take(2).map((g) => g.toMap()).toList();
        when(() => mockCacheService.get<List<dynamic>>('espn_upcoming_games_10'))
            .thenAnswer((_) async => cachedData);

        final result = await dataSource.fetchUpcomingGames();

        expect(result.length, 2);
        expect(result.first.gameId, 'game_1');
        verifyNever(
            () => mockEspnService.getUpcomingGames(limit: any(named: 'limit')));
      });

      test('fetches from ESPN and caches on cache miss', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.getUpcomingGames(limit: any(named: 'limit')))
            .thenAnswer((_) async => _testGames.take(2).toList());
        when(() => mockCacheService.set<List<Map<String, dynamic>>>(
              any(),
              any(),
              duration: any(named: 'duration'),
            )).thenAnswer((_) async {});

        final result = await dataSource.fetchUpcomingGames();

        expect(result.length, 2);
        verify(() => mockEspnService.getUpcomingGames(limit: 10)).called(1);
      });

      test('returns empty list when ESPN returns empty', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.getUpcomingGames(limit: any(named: 'limit')))
            .thenAnswer((_) async => []);

        final result = await dataSource.fetchUpcomingGames(limit: 5);

        expect(result, isEmpty);
      });

      test('returns empty list on exception', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.getUpcomingGames(limit: any(named: 'limit')))
            .thenThrow(Exception('API error'));

        final result = await dataSource.fetchUpcomingGames();

        expect(result, isEmpty);
      });

      test('uses custom limit for cache key', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.getUpcomingGames(limit: any(named: 'limit')))
            .thenAnswer((_) async => _testGames);
        when(() => mockCacheService.set<List<Map<String, dynamic>>>(
              any(),
              any(),
              duration: any(named: 'duration'),
            )).thenAnswer((_) async {});

        await dataSource.fetchUpcomingGames(limit: 20);

        verify(() =>
            mockCacheService.get<List<dynamic>>('espn_upcoming_games_20'))
            .called(1);
      });
    });

    group('fetch2025SeasonSchedule', () {
      test('returns cached schedule on cache hit', () async {
        final cachedData = _testGames.map((g) => g.toMap()).toList();
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => cachedData);

        final result = await dataSource.fetch2025SeasonSchedule();

        expect(result.length, 3);
        verifyNever(
            () => mockEspnService.get2025Schedule(limit: any(named: 'limit')));
      });

      test('fetches from ESPN and caches on cache miss', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.get2025Schedule(limit: any(named: 'limit')))
            .thenAnswer((_) async => _testGames);
        when(() => mockCacheService.set<List<Map<String, dynamic>>>(
              any(),
              any(),
              duration: any(named: 'duration'),
            )).thenAnswer((_) async {});

        final result = await dataSource.fetch2025SeasonSchedule();

        expect(result.length, 3);
        verify(() => mockEspnService.get2025Schedule(limit: 100)).called(1);
      });

      test('returns empty list on exception', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.get2025Schedule(limit: any(named: 'limit')))
            .thenThrow(Exception('ESPN error'));

        final result = await dataSource.fetch2025SeasonSchedule();

        expect(result, isEmpty);
      });
    });

    group('fetchHistoricalSeasonSchedule', () {
      test('returns cached historical data on cache hit', () async {
        final cachedData = _testGames.map((g) => g.toMap()).toList();
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => cachedData);

        final result = await dataSource.fetchHistoricalSeasonSchedule(2022);

        expect(result.length, 3);
      });

      test('fetches from ESPN for historical data', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.getScheduleForYear(any(), limit: any(named: 'limit')))
            .thenAnswer((_) async => _testGames);
        when(() => mockCacheService.set<List<Map<String, dynamic>>>(
              any(),
              any(),
              duration: any(named: 'duration'),
            )).thenAnswer((_) async {});

        final result = await dataSource.fetchHistoricalSeasonSchedule(2018);

        expect(result.length, 3);
        verify(() => mockEspnService.getScheduleForYear(2018, limit: 500))
            .called(1);
      });

      test('returns empty list on exception', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.getScheduleForYear(any(), limit: any(named: 'limit')))
            .thenThrow(Exception('Historical error'));

        final result = await dataSource.fetchHistoricalSeasonSchedule(2014);

        expect(result, isEmpty);
      });
    });

    group('getGamesByTeams', () {
      test('filters games by team name (case insensitive)', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.get2025Schedule(limit: any(named: 'limit')))
            .thenAnswer((_) async => _testGames);
        when(() => mockCacheService.set<List<Map<String, dynamic>>>(
              any(),
              any(),
              duration: any(named: 'duration'),
            )).thenAnswer((_) async {});

        final result = await dataSource.getGamesByTeams(['usa']);

        expect(result.length, 1);
        expect(result.first.homeTeamName, 'USA');
      });

      test('returns multiple matches for team', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.get2025Schedule(limit: any(named: 'limit')))
            .thenAnswer((_) async => _testGames);
        when(() => mockCacheService.set<List<Map<String, dynamic>>>(
              any(),
              any(),
              duration: any(named: 'duration'),
            )).thenAnswer((_) async {});

        final result = await dataSource.getGamesByTeams(['usa', 'brazil']);

        expect(result.length, 2);
      });

      test('returns empty list when no teams match', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.get2025Schedule(limit: any(named: 'limit')))
            .thenAnswer((_) async => _testGames);
        when(() => mockCacheService.set<List<Map<String, dynamic>>>(
              any(),
              any(),
              duration: any(named: 'duration'),
            )).thenAnswer((_) async {});

        final result = await dataSource.getGamesByTeams(['Japan']);

        expect(result, isEmpty);
      });

      test('returns empty list on error', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.get2025Schedule(limit: any(named: 'limit')))
            .thenThrow(Exception('Error'));

        final result = await dataSource.getGamesByTeams(['usa']);

        expect(result, isEmpty);
      });
    });

    group('getGamesInDateRange', () {
      test('filters games within date range', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.get2025Schedule(limit: any(named: 'limit')))
            .thenAnswer((_) async => _testGames);
        when(() => mockCacheService.set<List<Map<String, dynamic>>>(
              any(),
              any(),
              duration: any(named: 'duration'),
            )).thenAnswer((_) async {});

        final result = await dataSource.getGamesInDateRange(
          DateTime(2026, 6, 14),
          DateTime(2026, 6, 17),
        );

        // game_1 (June 15) and game_2 (June 16) are within range
        expect(result.length, 2);
      });

      test('returns empty list for range with no games', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.get2025Schedule(limit: any(named: 'limit')))
            .thenAnswer((_) async => _testGames);
        when(() => mockCacheService.set<List<Map<String, dynamic>>>(
              any(),
              any(),
              duration: any(named: 'duration'),
            )).thenAnswer((_) async {});

        final result = await dataSource.getGamesInDateRange(
          DateTime(2026, 7, 1),
          DateTime(2026, 7, 5),
        );

        expect(result, isEmpty);
      });

      test('returns empty list on error', () async {
        when(() => mockCacheService.get<List<dynamic>>(any()))
            .thenAnswer((_) async => null);
        when(() => mockEspnService.get2025Schedule(limit: any(named: 'limit')))
            .thenThrow(Exception('Error'));

        final result = await dataSource.getGamesInDateRange(
          DateTime(2026, 6, 14),
          DateTime(2026, 6, 17),
        );

        expect(result, isEmpty);
      });
    });

    group('clearCache', () {
      test('removes known cache keys', () async {
        when(() => mockCacheService.remove(any()))
            .thenAnswer((_) async {});

        await dataSource.clearCache();

        // Verify at least some keys were removed
        verify(() => mockCacheService.remove('espn_upcoming_games_10'))
            .called(1);
        verify(() => mockCacheService.remove('espn_2025_season_schedule_100'))
            .called(1);
      });

      test('handles cache clear error gracefully', () async {
        when(() => mockCacheService.remove(any()))
            .thenThrow(Exception('Cache error'));

        // Should not throw
        await dataSource.clearCache();
      });
    });

    group('testConnection', () {
      test('returns true when ESPN returns games', () async {
        // getCurrentGames returns List<Map<String, dynamic>>
        when(() => mockEspnService.getCurrentGames())
            .thenAnswer((_) async => [
              {'gameId': 'g1', 'homeTeamName': 'USA', 'awayTeamName': 'Mexico'},
            ]);

        final result = await dataSource.testConnection();

        expect(result, true);
      });

      test('returns false when ESPN returns empty list', () async {
        when(() => mockEspnService.getCurrentGames())
            .thenAnswer((_) async => <Map<String, dynamic>>[]);

        final result = await dataSource.testConnection();

        expect(result, false);
      });

      test('returns false on exception', () async {
        when(() => mockEspnService.getCurrentGames())
            .thenThrow(Exception('Connection error'));

        final result = await dataSource.testConnection();

        expect(result, false);
      });
    });
  });
}
