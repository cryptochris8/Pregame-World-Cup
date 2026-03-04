import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/schedule/data/datasources/live_scores_datasource.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';

// ==================== MOCKS ====================

class MockDio extends Mock implements Dio {
  @override
  BaseOptions get options => BaseOptions();
}

// ==================== TEST DATA ====================

const _testApiKey = 'test_sportsdata_api_key';
const _testBaseUrl = 'https://api.sportsdata.io/v4/soccer/scores/json';

Map<String, dynamic> _createSportsDataGame({
  String gameId = '12345',
  String homeTeam = 'USA',
  String awayTeam = 'Mexico',
  int? homeScore,
  int? awayScore,
  String? status,
  String? period,
  String? clock,
  int? minute,
  String? dateTime,
  int? homeTeamId,
  int? awayTeamId,
  int? globalGameId,
  String? season,
  int? week,
  String? channel,
  bool? neutralVenue,
}) {
  return {
    'GameID': int.tryParse(gameId) ?? 12345,
    'GlobalGameID': globalGameId ?? 100001,
    'Season': season ?? '2026',
    'SeasonType': 1,
    'Week': week ?? 1,
    'Status': status ?? 'Scheduled',
    'DateTime': dateTime ?? '2026-06-15T20:00:00Z',
    'HomeTeamName': homeTeam,
    'AwayTeamName': awayTeam,
    'HomeTeamID': homeTeamId ?? 1,
    'AwayTeamID': awayTeamId ?? 2,
    'GlobalHomeTeamID': 101,
    'GlobalAwayTeamID': 102,
    'StadiumID': 50,
    'Channel': channel ?? 'FOX',
    'NeutralVenue': neutralVenue ?? true,
    'HomeTeamScore': homeScore,
    'AwayTeamScore': awayScore,
    'Period': period,
    'Clock': clock,
    if (minute != null) 'Minute': minute,
  };
}

// ==================== TESTS ====================

void main() {
  late MockDio mockDio;
  late LiveScoresDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    dataSource = LiveScoresDataSourceImpl(
      dio: mockDio,
      apiKey: _testApiKey,
    );
  });

  // ---------------------------------------------------------------------------
  // Constructor tests
  // ---------------------------------------------------------------------------
  group('LiveScoresDataSourceImpl - constructor', () {
    test('creates instance with required parameters', () {
      expect(dataSource, isNotNull);
      expect(dataSource, isA<LiveScoresDataSource>());
    });

    test('uses default SportsData.io base URL', () {
      expect(dataSource.baseUrl, _testBaseUrl);
    });

    test('accepts custom base URL', () {
      final ds = LiveScoresDataSourceImpl(
        dio: mockDio,
        apiKey: _testApiKey,
        baseUrl: 'https://custom.api.com/v4',
      );
      expect(ds.baseUrl, 'https://custom.api.com/v4');
    });

    test('stores provided API key', () {
      expect(dataSource.apiKey, _testApiKey);
    });
  });

  // ---------------------------------------------------------------------------
  // getLiveScores tests
  // ---------------------------------------------------------------------------
  group('LiveScoresDataSourceImpl - getLiveScores', () {
    test('sends API key as query parameter', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: <dynamic>[],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      await dataSource.getLiveScores();

      final captured = verify(() => mockDio.get(
            any(),
            queryParameters: captureAny(named: 'queryParameters'),
          )).captured;

      final queryParams = captured.first as Map<String, dynamic>;
      expect(queryParams['key'], _testApiKey);
    });

    test('requests GamesByDate endpoint with today formatted date', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: <dynamic>[],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      await dataSource.getLiveScores();

      final today = DateTime.now();
      final expectedDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      verify(() => mockDio.get(
            '$_testBaseUrl/GamesByDate/$expectedDate',
            queryParameters: any(named: 'queryParameters'),
          )).called(1);
    });

    test('returns list of GameSchedule on 200 response', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(
                homeTeam: 'Brazil',
                awayTeam: 'Argentina',
                homeScore: 2,
                awayScore: 1,
                status: 'InProgress',
                period: '2H',
                clock: "67'",
              ),
              _createSportsDataGame(
                gameId: '99999',
                homeTeam: 'Germany',
                awayTeam: 'France',
                status: 'Scheduled',
              ),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result, isA<List<GameSchedule>>());
      expect(result.length, 2);
      expect(result[0].homeTeamName, 'Brazil');
      expect(result[0].awayTeamName, 'Argentina');
      expect(result[0].homeScore, 2);
      expect(result[0].awayScore, 1);
      expect(result[0].isLive, true);
      expect(result[1].homeTeamName, 'Germany');
      expect(result[1].isLive, false);
    });

    test('returns empty list when API returns no games', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: <dynamic>[],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result, isEmpty);
    });

    test('throws exception on non-200 status code', () async {
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

    test('throws exception on 404 status code', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: 'Not Found',
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ));

      expect(
        () => dataSource.getLiveScores(),
        throwsA(isA<Exception>()),
      );
    });

    test('throws exception on network error (DioException)', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timed out',
          ));

      expect(
        () => dataSource.getLiveScores(),
        throwsA(isA<Exception>()),
      );
    });

    test('throws exception on connection error', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          ));

      expect(
        () => dataSource.getLiveScores(),
        throwsA(isA<Exception>()),
      );
    });

    test('throws exception on receive timeout', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.receiveTimeout,
          ));

      expect(
        () => dataSource.getLiveScores(),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getGameLiveScore tests
  // ---------------------------------------------------------------------------
  group('LiveScoresDataSourceImpl - getGameLiveScore', () {
    test('requests Game endpoint with game ID', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: _createSportsDataGame(gameId: '42'),
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      await dataSource.getGameLiveScore('42');

      verify(() => mockDio.get(
            '$_testBaseUrl/Game/42',
            queryParameters: {'key': _testApiKey},
          )).called(1);
    });

    test('returns GameSchedule for existing game', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: _createSportsDataGame(
              gameId: '99',
              homeTeam: 'England',
              awayTeam: 'Spain',
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
      expect(result!.homeTeamName, 'England');
      expect(result.awayTeamName, 'Spain');
      expect(result.homeScore, 1);
      expect(result.awayScore, 0);
      expect(result.isLive, true);
      expect(result.period, '1H');
      expect(result.timeRemaining, "32'");
    });

    test('returns null for non-200 status (404)', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: null,
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getGameLiveScore('nonexistent');

      expect(result, isNull);
    });

    test('returns null on DioException', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
          ));

      final result = await dataSource.getGameLiveScore('999');

      expect(result, isNull);
    });

    test('returns null on generic exception', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(Exception('Unexpected error'));

      final result = await dataSource.getGameLiveScore('999');

      expect(result, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // getLiveGames tests
  // ---------------------------------------------------------------------------
  group('LiveScoresDataSourceImpl - getLiveGames', () {
    test('filters for only live games from all scores', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(
                gameId: '1',
                status: 'InProgress',
                homeTeam: 'USA',
                awayTeam: 'Mexico',
                homeScore: 1,
                awayScore: 0,
              ),
              _createSportsDataGame(
                gameId: '2',
                status: 'Scheduled',
                homeTeam: 'Brazil',
                awayTeam: 'Argentina',
              ),
              _createSportsDataGame(
                gameId: '3',
                status: 'SecondHalf',
                homeTeam: 'Germany',
                awayTeam: 'France',
                homeScore: 2,
                awayScore: 2,
              ),
              _createSportsDataGame(
                gameId: '4',
                status: 'Final',
                homeTeam: 'Japan',
                awayTeam: 'South Korea',
                homeScore: 3,
                awayScore: 1,
              ),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveGames();

      // InProgress and SecondHalf are live; Scheduled and Final are not
      expect(result.length, 2);
      expect(result.any((g) => g.homeTeamName == 'USA'), true);
      expect(result.any((g) => g.homeTeamName == 'Germany'), true);
    });

    test('returns empty list when no games are live', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(status: 'Scheduled'),
              _createSportsDataGame(gameId: '2', status: 'Final'),
              _createSportsDataGame(gameId: '3', status: 'Postponed'),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveGames();

      expect(result, isEmpty);
    });

    test('returns empty list on network error', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          ));

      final result = await dataSource.getLiveGames();

      expect(result, isEmpty);
    });

    test('returns all games when all are live', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(
                gameId: '1',
                status: 'FirstHalf',
                homeScore: 0,
                awayScore: 0,
              ),
              _createSportsDataGame(
                gameId: '2',
                status: 'Halftime',
                homeScore: 1,
                awayScore: 1,
              ),
              _createSportsDataGame(
                gameId: '3',
                status: 'PenaltyShootout',
                homeScore: 2,
                awayScore: 2,
              ),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveGames();

      expect(result.length, 3);
    });
  });

  // ---------------------------------------------------------------------------
  // Match status mapping (_isGameLive)
  // ---------------------------------------------------------------------------
  group('LiveScoresDataSourceImpl - match status mapping', () {
    // All statuses that should be recognized as live
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
              data: [_createSportsDataGame(status: status, homeScore: 0, awayScore: 0)],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getLiveScores();
        expect(result.first.isLive, true,
            reason: 'Status "$status" should be recognized as live');
      });
    }

    // All statuses that should NOT be recognized as live
    final nonLiveStatuses = [
      'Scheduled',
      'Final',
      'Postponed',
      'Cancelled',
      'Suspended',
      'Delayed',
      'Abandoned',
    ];

    for (final status in nonLiveStatuses) {
      test('does NOT recognize "$status" as live', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: [_createSportsDataGame(status: status)],
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await dataSource.getLiveScores();
        expect(result.first.isLive, false,
            reason: 'Status "$status" should NOT be recognized as live');
      });
    }

    test('null status is not live', () async {
      final gameData = Map<String, dynamic>.from(_createSportsDataGame());
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

  // ---------------------------------------------------------------------------
  // Score extraction and parsing
  // ---------------------------------------------------------------------------
  group('LiveScoresDataSourceImpl - score extraction', () {
    test('extracts home and away scores from response', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(
                homeScore: 3,
                awayScore: 2,
                status: 'InProgress',
              ),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result.first.homeScore, 3);
      expect(result.first.awayScore, 2);
    });

    test('handles null scores for scheduled games', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [_createSportsDataGame(status: 'Scheduled')],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result.first.homeScore, isNull);
      expect(result.first.awayScore, isNull);
    });

    test('extracts zero-zero scores correctly', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(
                homeScore: 0,
                awayScore: 0,
                status: 'FirstHalf',
              ),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result.first.homeScore, 0);
      expect(result.first.awayScore, 0);
    });

    test('extracts Clock field as timeRemaining', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(
                status: 'InProgress',
                clock: "45'+2",
                homeScore: 1,
                awayScore: 0,
              ),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result.first.timeRemaining, "45'+2");
    });

    test('uses Minute field when Clock is null', () async {
      final gameData = Map<String, dynamic>.from(
        _createSportsDataGame(status: 'InProgress', homeScore: 0, awayScore: 0),
      );
      gameData['Clock'] = null;
      gameData['Minute'] = 72;

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [gameData],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result.first.timeRemaining, "72'");
    });

    test('timeRemaining is null when both Clock and Minute are null', () async {
      final gameData = Map<String, dynamic>.from(
        _createSportsDataGame(status: 'Scheduled'),
      );
      gameData['Clock'] = null;
      // Minute not set in the helper when not passed

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [gameData],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result.first.timeRemaining, isNull);
    });

    test('extracts period field', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(
                status: 'ExtraTime',
                period: 'ET1',
                homeScore: 2,
                awayScore: 2,
              ),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result.first.period, 'ET1');
    });
  });

  // ---------------------------------------------------------------------------
  // Response data parsing (_parseGameWithLiveScore)
  // ---------------------------------------------------------------------------
  group('LiveScoresDataSourceImpl - response parsing', () {
    test('parses date and time correctly', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(
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

    test('handles null DateTime field gracefully', () async {
      final gameData = Map<String, dynamic>.from(
        _createSportsDataGame(status: 'Scheduled'),
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
      expect(result.first.dateTime, isNull);
      expect(result.first.day, isNull);
    });

    test('handles invalid DateTime string without crashing', () async {
      final gameData = Map<String, dynamic>.from(
        _createSportsDataGame(status: 'Scheduled'),
      );
      gameData['DateTime'] = 'not-a-valid-date';

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [gameData],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Should not throw - the warning is just logged
      final result = await dataSource.getLiveScores();
      expect(result.length, 1);
    });

    test('parses team IDs correctly', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(
                homeTeamId: 42,
                awayTeamId: 99,
                status: 'Scheduled',
              ),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result.first.homeTeamId, 42);
      expect(result.first.awayTeamId, 99);
    });

    test('parses global game ID', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(
                globalGameId: 555555,
                status: 'Scheduled',
              ),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result.first.globalGameId, 555555);
    });

    test('parses channel and neutral venue', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(
                channel: 'ESPN',
                neutralVenue: false,
                status: 'Scheduled',
              ),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result.first.channel, 'ESPN');
      expect(result.first.neutralVenue, false);
    });

    test('uses HomeTeam/AwayTeam fallback when Name fields are null', () async {
      final gameData = Map<String, dynamic>.from(
        _createSportsDataGame(status: 'Scheduled'),
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

    test('falls back to N/A when no team name is available', () async {
      final gameData = Map<String, dynamic>.from(
        _createSportsDataGame(status: 'Scheduled'),
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

    test('initializes social fields to zero defaults', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [_createSportsDataGame(status: 'Scheduled')],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result.first.userPredictions, 0);
      expect(result.first.userComments, 0);
      expect(result.first.userPhotos, 0);
      expect(result.first.userRating, 0.0);
    });

    test('sets updatedApi to current time', () async {
      final beforeTest = DateTime.now();

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [_createSportsDataGame(status: 'Scheduled')],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result.first.updatedApi, isNotNull);
      expect(
        result.first.updatedApi!.isAfter(beforeTest) ||
            result.first.updatedApi!.isAtSameMomentAs(beforeTest),
        true,
      );
    });

    test('sets lastScoreUpdate only for live games', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(
                gameId: '1',
                status: 'InProgress',
                homeScore: 1,
                awayScore: 0,
              ),
              _createSportsDataGame(
                gameId: '2',
                status: 'Scheduled',
              ),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      // Live game should have lastScoreUpdate
      expect(result[0].lastScoreUpdate, isNotNull);
      // Non-live game should not
      expect(result[1].lastScoreUpdate, isNull);
    });

    test('parses season and week fields', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(
                season: '2026',
                week: 3,
                status: 'Scheduled',
              ),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result.first.season, '2026');
      expect(result.first.week, 3);
    });

    test('parses multiple games in a single response', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [
              _createSportsDataGame(
                gameId: '1',
                homeTeam: 'USA',
                awayTeam: 'Mexico',
              ),
              _createSportsDataGame(
                gameId: '2',
                homeTeam: 'Brazil',
                awayTeam: 'Argentina',
              ),
              _createSportsDataGame(
                gameId: '3',
                homeTeam: 'France',
                awayTeam: 'Germany',
              ),
              _createSportsDataGame(
                gameId: '4',
                homeTeam: 'England',
                awayTeam: 'Spain',
              ),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getLiveScores();

      expect(result.length, 4);
      expect(result[0].homeTeamName, 'USA');
      expect(result[1].homeTeamName, 'Brazil');
      expect(result[2].homeTeamName, 'France');
      expect(result[3].homeTeamName, 'England');
    });
  });

  // ---------------------------------------------------------------------------
  // API key usage
  // ---------------------------------------------------------------------------
  group('LiveScoresDataSourceImpl - API key usage', () {
    test('sends API key in getLiveScores request', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: <dynamic>[],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      await dataSource.getLiveScores();

      verify(() => mockDio.get(
            any(),
            queryParameters: {'key': _testApiKey},
          )).called(1);
    });

    test('sends API key in getGameLiveScore request', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: _createSportsDataGame(),
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      await dataSource.getGameLiveScore('123');

      verify(() => mockDio.get(
            any(),
            queryParameters: {'key': _testApiKey},
          )).called(1);
    });
  });
}
