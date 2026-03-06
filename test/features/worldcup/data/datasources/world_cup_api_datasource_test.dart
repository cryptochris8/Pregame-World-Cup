import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

// ==================== MOCKS ====================

class MockDio extends Mock implements Dio {
  @override
  BaseOptions get options => BaseOptions();
}

// ==================== TEST DATA ====================

const _testApiKey = 'test_api_key';

Map<String, dynamic> _createMatchJson({
  String gameId = '12345',
  int gameNumber = 1,
  String? round,
  String? stage,
  String? group,
  int? groupMatchDay,
  String? homeTeamKey = 'USA',
  String homeTeamName = 'United States',
  String? awayTeamKey = 'MEX',
  String awayTeamName = 'Mexico',
  int? homeScore,
  int? awayScore,
  String? status,
  String? dateTime,
  String? dateTimeUtc,
  String? venueId,
  List<String>? channels,
  int? clock,
  int? homeHalfTimeScore,
  int? awayHalfTimeScore,
  int? homeExtraTimeScore,
  int? awayExtraTimeScore,
  int? homePenaltyScore,
  int? awayPenaltyScore,
  String? winnerTeamKey,
  String? updated,
}) {
  return {
    'GameId': gameId,
    'GameNumber': gameNumber,
    'Round': round,
    'Stage': stage,
    'Group': group,
    'GroupMatchDay': groupMatchDay,
    'HomeTeamKey': homeTeamKey,
    'HomeTeamName': homeTeamName,
    'HomeTeamLogo': null,
    'AwayTeamKey': awayTeamKey,
    'AwayTeamName': awayTeamName,
    'AwayTeamLogo': null,
    'DateTime': dateTime ?? '2026-06-11T18:00:00',
    'DateTimeUTC': dateTimeUtc,
    'VenueId': venueId ?? '1',
    'Channels': channels,
    'Status': status ?? 'Scheduled',
    'Clock': clock,
    'HomeTeamScore': homeScore,
    'AwayTeamScore': awayScore,
    'HomeTeamScoreHalftime': homeHalfTimeScore,
    'AwayTeamScoreHalftime': awayHalfTimeScore,
    'HomeTeamScoreExtraTime': homeExtraTimeScore,
    'AwayTeamScoreExtraTime': awayExtraTimeScore,
    'HomeTeamScorePenalties': homePenaltyScore,
    'AwayTeamScorePenalties': awayPenaltyScore,
    'WinnerTeamKey': winnerTeamKey,
    'Updated': updated,
  };
}

Map<String, dynamic> _createTeamJson({
  String key = 'USA',
  String fullName = 'United States',
  String? shortName,
  String? logoUrl,
  String? areaName,
  int? ranking,
  String? group,
  Map<String, dynamic>? coach,
}) {
  return {
    'Key': key,
    'TeamId': 1,
    'FullName': fullName,
    'Name': fullName,
    'ShortName': shortName ?? key,
    'WikipediaLogoUrl': logoUrl,
    'FlagUrl': null,
    'AreaName': areaName ?? 'North America',
    'GlobalTeamRanking': ranking,
    'Coach': coach,
    'Group': group,
  };
}

Map<String, dynamic> _createStandingJson({
  String group = 'A',
  String teamKey = 'USA',
  String teamName = 'United States',
  int rank = 1,
  int games = 3,
  int wins = 2,
  int draws = 1,
  int losses = 0,
  int goalsScored = 5,
  int goalsAgainst = 2,
  int points = 7,
}) {
  return {
    'Group': group,
    'TeamKey': teamKey,
    'TeamName': teamName,
    'TeamLogo': null,
    'Rank': rank,
    'Games': games,
    'Wins': wins,
    'Draws': draws,
    'Losses': losses,
    'GoalsScored': goalsScored,
    'GoalsAgainst': goalsAgainst,
    'Points': points,
  };
}

Map<String, dynamic> _createVenueJson({
  String venueId = '1',
  String name = 'MetLife Stadium',
  String city = 'East Rutherford',
  String? state = 'New Jersey',
  String country = 'United States',
  int capacity = 82500,
  double? geoLat,
  double? geoLong,
  String? address,
  String? photoUrl,
}) {
  return {
    'VenueId': int.tryParse(venueId) ?? 1,
    'Name': name,
    'City': city,
    'State': state,
    'Country': country,
    'Capacity': capacity,
    'GeoLat': geoLat,
    'GeoLong': geoLong,
    'Address': address,
    'PhotoUrl': photoUrl,
  };
}

Response<dynamic> _successResponse(dynamic data) {
  return Response(
    data: data,
    statusCode: 200,
    requestOptions: RequestOptions(path: ''),
  );
}

// ==================== TESTS ====================

void main() {
  late MockDio mockDio;
  late WorldCupApiDataSource dataSource;

  setUp(() {
    mockDio = MockDio();
    dataSource = WorldCupApiDataSource(
      dio: mockDio,
      apiKey: _testApiKey,
    );
  });

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------
  group('WorldCupApiDataSource - constructor', () {
    test('creates instance with required apiKey and custom Dio', () {
      expect(dataSource, isNotNull);
      expect(dataSource, isA<WorldCupApiDataSource>());
    });

    test('creates instance with default Dio when none provided', () {
      final ds = WorldCupApiDataSource(apiKey: _testApiKey);
      expect(ds, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // fetchAllMatches
  // ---------------------------------------------------------------------------
  group('WorldCupApiDataSource - fetchAllMatches', () {
    test('returns parsed matches on 200 with data', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            _createMatchJson(
              gameId: '1',
              homeTeamKey: 'USA',
              awayTeamKey: 'MEX',
              round: 'Group Stage',
            ),
            _createMatchJson(
              gameId: '2',
              homeTeamKey: 'BRA',
              awayTeamKey: 'ARG',
              round: 'Group Stage',
            ),
          ]));

      final result = await dataSource.fetchAllMatches();

      expect(result.length, 2);
      expect(result[0].matchId, '1');
      expect(result[0].homeTeamCode, 'USA');
      expect(result[1].matchId, '2');
      expect(result[1].homeTeamCode, 'BRA');
    });

    test('returns empty list on 200 with empty data', () async {
      when(() => mockDio.get(any()))
          .thenAnswer((_) async => _successResponse(<dynamic>[]));

      final result = await dataSource.fetchAllMatches();

      expect(result, isEmpty);
    });

    test('returns empty list on DioException', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await dataSource.fetchAllMatches();

      expect(result, isEmpty);
    });

    test('returns empty list on null data', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.fetchAllMatches();

      expect(result, isEmpty);
    });

    test('parses multiple matches with different stages', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            _createMatchJson(gameId: '1', round: 'Group Stage'),
            _createMatchJson(gameId: '2', round: 'Round of 16'),
            _createMatchJson(gameId: '3', round: 'Quarter-final'),
          ]));

      final result = await dataSource.fetchAllMatches();

      expect(result.length, 3);
      expect(result[0].stage, MatchStage.groupStage);
      expect(result[1].stage, MatchStage.roundOf16);
      expect(result[2].stage, MatchStage.quarterFinal);
    });
  });

  // ---------------------------------------------------------------------------
  // fetchMatchesByDate
  // ---------------------------------------------------------------------------
  group('WorldCupApiDataSource - fetchMatchesByDate', () {
    test('formats date correctly in request path', () async {
      when(() => mockDio.get(any()))
          .thenAnswer((_) async => _successResponse(<dynamic>[]));

      await dataSource.fetchMatchesByDate(DateTime(2026, 6, 15));

      verify(() => mockDio.get('/scores/json/GamesByDate/2026-06-15')).called(1);
    });

    test('filters by competition ID', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            {
              ..._createMatchJson(gameId: '1'),
              'Competition': {'CompetitionId': 'FIFA_WORLDCUP_2026'},
            },
            {
              ..._createMatchJson(gameId: '2'),
              'Competition': {'CompetitionId': 'OTHER_COMP'},
            },
          ]));

      final result = await dataSource.fetchMatchesByDate(DateTime(2026, 6, 15));

      expect(result.length, 1);
      expect(result[0].matchId, '1');
    });

    test('returns empty list when no matches for date', () async {
      when(() => mockDio.get(any()))
          .thenAnswer((_) async => _successResponse(<dynamic>[]));

      final result = await dataSource.fetchMatchesByDate(DateTime(2026, 5, 1));

      expect(result, isEmpty);
    });

    test('returns empty list on DioException', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      ));

      final result = await dataSource.fetchMatchesByDate(DateTime(2026, 6, 15));

      expect(result, isEmpty);
    });

    test('pads single-digit month and day with leading zeros', () async {
      when(() => mockDio.get(any()))
          .thenAnswer((_) async => _successResponse(<dynamic>[]));

      await dataSource.fetchMatchesByDate(DateTime(2026, 7, 5));

      verify(() => mockDio.get('/scores/json/GamesByDate/2026-07-05')).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // fetchLiveMatches
  // ---------------------------------------------------------------------------
  group('WorldCupApiDataSource - fetchLiveMatches', () {
    test('returns parsed live matches on 200', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            _createMatchJson(
              gameId: '1',
              status: 'InProgress',
              homeScore: 1,
              awayScore: 0,
            ),
          ]));

      final result = await dataSource.fetchLiveMatches();

      expect(result.length, 1);
      expect(result[0].homeScore, 1);
    });

    test('returns empty list when no live matches', () async {
      when(() => mockDio.get(any()))
          .thenAnswer((_) async => _successResponse(<dynamic>[]));

      final result = await dataSource.fetchLiveMatches();

      expect(result, isEmpty);
    });

    test('returns empty list on DioException', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await dataSource.fetchLiveMatches();

      expect(result, isEmpty);
    });

    test('returns empty list on null data', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.fetchLiveMatches();

      expect(result, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // fetchAllTeams
  // ---------------------------------------------------------------------------
  group('WorldCupApiDataSource - fetchAllTeams', () {
    test('returns parsed teams on 200', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            _createTeamJson(key: 'USA', fullName: 'United States'),
            _createTeamJson(key: 'BRA', fullName: 'Brazil', areaName: 'South America'),
          ]));

      final result = await dataSource.fetchAllTeams();

      expect(result.length, 2);
      expect(result[0].fifaCode, 'USA');
      expect(result[1].fifaCode, 'BRA');
      expect(result[1].confederation, Confederation.conmebol);
    });

    test('returns empty list on empty response', () async {
      when(() => mockDio.get(any()))
          .thenAnswer((_) async => _successResponse(<dynamic>[]));

      final result = await dataSource.fetchAllTeams();

      expect(result, isEmpty);
    });

    test('returns empty list on DioException', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await dataSource.fetchAllTeams();

      expect(result, isEmpty);
    });

    test('returns empty list on null data', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.fetchAllTeams();

      expect(result, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // fetchGroupStandings
  // ---------------------------------------------------------------------------
  group('WorldCupApiDataSource - fetchGroupStandings', () {
    test('parses groups and sorts standings by rank', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            _createStandingJson(group: 'A', teamKey: 'MEX', rank: 2),
            _createStandingJson(group: 'A', teamKey: 'USA', rank: 1),
            _createStandingJson(group: 'B', teamKey: 'BRA', rank: 1),
          ]));

      final result = await dataSource.fetchGroupStandings();

      expect(result.length, 2);

      final groupA = result.firstWhere((g) => g.groupLetter == 'A');
      expect(groupA.standings.length, 2);
      expect(groupA.standings[0].teamCode, 'USA'); // rank 1 first
      expect(groupA.standings[1].teamCode, 'MEX'); // rank 2 second

      final groupB = result.firstWhere((g) => g.groupLetter == 'B');
      expect(groupB.standings.length, 1);
    });

    test('returns empty list on empty response', () async {
      when(() => mockDio.get(any()))
          .thenAnswer((_) async => _successResponse(<dynamic>[]));

      final result = await dataSource.fetchGroupStandings();

      expect(result, isEmpty);
    });

    test('returns empty list on DioException', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await dataSource.fetchGroupStandings();

      expect(result, isEmpty);
    });

    test('skips entries with null group letter', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            _createStandingJson(group: 'A', teamKey: 'USA', rank: 1),
            {'Group': null, 'TeamKey': 'XXX', 'Rank': 1},
          ]));

      final result = await dataSource.fetchGroupStandings();

      expect(result.length, 1);
      expect(result[0].groupLetter, 'A');
    });
  });

  // ---------------------------------------------------------------------------
  // fetchMatchById
  // ---------------------------------------------------------------------------
  group('WorldCupApiDataSource - fetchMatchById', () {
    test('returns parsed match when found', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse(
            _createMatchJson(gameId: '42', homeTeamKey: 'FRA'),
          ));

      final result = await dataSource.fetchMatchById('42');

      expect(result, isNotNull);
      expect(result!.matchId, '42');
      expect(result.homeTeamCode, 'FRA');
    });

    test('returns null when not found (null data)', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.fetchMatchById('999');

      expect(result, isNull);
    });

    test('returns null on DioException', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await dataSource.fetchMatchById('42');

      expect(result, isNull);
    });

    test('calls correct endpoint path', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      await dataSource.fetchMatchById('abc123');

      verify(() => mockDio.get('/scores/json/Game/abc123')).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // fetchVenues
  // ---------------------------------------------------------------------------
  group('WorldCupApiDataSource - fetchVenues', () {
    test('parses venues from API response', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            _createVenueJson(
              venueId: '1',
              name: 'MetLife Stadium',
              country: 'United States',
            ),
            _createVenueJson(
              venueId: '2',
              name: 'Estadio Azteca',
              city: 'Mexico City',
              state: null,
              country: 'Mexico',
            ),
          ]));

      final result = await dataSource.fetchVenues();

      expect(result.length, 2);
      expect(result[0].name, 'MetLife Stadium');
      expect(result[0].country, HostCountry.usa);
      expect(result[1].name, 'Estadio Azteca');
      expect(result[1].country, HostCountry.mexico);
    });

    test('filters out non-World Cup venues', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            _createVenueJson(
              venueId: '1',
              name: 'MetLife Stadium',
              country: 'United States',
            ),
            _createVenueJson(
              venueId: '2',
              name: 'Wembley',
              city: 'London',
              state: null,
              country: 'England',
            ),
            _createVenueJson(
              venueId: '3',
              name: 'BC Place',
              city: 'Vancouver',
              state: 'British Columbia',
              country: 'Canada',
            ),
          ]));

      final result = await dataSource.fetchVenues();

      expect(result.length, 2);
      expect(result.any((v) => v.name == 'Wembley'), false);
    });

    test('returns WorldCupVenues.all on DioException (static fallback)', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await dataSource.fetchVenues();

      expect(result, equals(WorldCupVenues.all));
      expect(result.isNotEmpty, true);
    });

    test('returns WorldCupVenues.all when response data is null', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.fetchVenues();

      expect(result, equals(WorldCupVenues.all));
    });
  });

  // ---------------------------------------------------------------------------
  // _parseStage (tested indirectly through fetchAllMatches)
  // ---------------------------------------------------------------------------
  group('WorldCupApiDataSource - stage parsing', () {
    Future<MatchStage> parseStageViaFetch(String? roundValue) async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            _createMatchJson(round: roundValue, stage: null),
          ]));
      final result = await dataSource.fetchAllMatches();
      return result.first.stage;
    }

    test('parses "Group Stage" as groupStage', () async {
      expect(await parseStageViaFetch('Group Stage'), MatchStage.groupStage);
    });

    test('parses "Round of 32" as roundOf32', () async {
      expect(await parseStageViaFetch('Round of 32'), MatchStage.roundOf32);
    });

    test('parses "Round of 16" as roundOf16', () async {
      expect(await parseStageViaFetch('Round of 16'), MatchStage.roundOf16);
    });

    test('parses "Quarter-final" as quarterFinal', () async {
      expect(await parseStageViaFetch('Quarter-final'), MatchStage.quarterFinal);
    });

    test('parses "Semi-final" as semiFinal', () async {
      expect(await parseStageViaFetch('Semi-final'), MatchStage.semiFinal);
    });

    test('parses "Third Place" as thirdPlace', () async {
      expect(await parseStageViaFetch('Third Place'), MatchStage.thirdPlace);
    });

    test('parses "3rd Place" as thirdPlace', () async {
      expect(await parseStageViaFetch('3rd Place'), MatchStage.thirdPlace);
    });

    test('parses "Final" as final_', () async {
      expect(await parseStageViaFetch('Final'), MatchStage.final_);
    });

    test('parses null as groupStage (default)', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            {
              ..._createMatchJson(),
              'Round': null,
              'Stage': null,
            },
          ]));
      final result = await dataSource.fetchAllMatches();
      expect(result.first.stage, MatchStage.groupStage);
    });
  });

  // ---------------------------------------------------------------------------
  // _parseStatus (tested indirectly through fetchAllMatches)
  // ---------------------------------------------------------------------------
  group('WorldCupApiDataSource - status parsing', () {
    Future<MatchStatus> parseStatusViaFetch(String? statusValue) async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            _createMatchJson(status: statusValue),
          ]));
      final result = await dataSource.fetchAllMatches();
      return result.first.status;
    }

    test('parses "Scheduled" as scheduled', () async {
      expect(await parseStatusViaFetch('Scheduled'), MatchStatus.scheduled);
    });

    test('parses "In Progress" as inProgress', () async {
      expect(await parseStatusViaFetch('In Progress'), MatchStatus.inProgress);
    });

    test('parses "Half Time" as halfTime', () async {
      expect(await parseStatusViaFetch('Half Time'), MatchStatus.halfTime);
    });

    test('parses "Extra Time" as extraTime', () async {
      expect(await parseStatusViaFetch('Extra Time'), MatchStatus.extraTime);
    });

    test('parses "Penalties" as penalties', () async {
      expect(await parseStatusViaFetch('Penalties'), MatchStatus.penalties);
    });

    test('parses "Completed" as completed', () async {
      expect(await parseStatusViaFetch('Completed'), MatchStatus.completed);
    });

    test('parses "Postponed" as postponed', () async {
      expect(await parseStatusViaFetch('Postponed'), MatchStatus.postponed);
    });

    test('parses "Cancelled" as cancelled', () async {
      expect(await parseStatusViaFetch('Cancelled'), MatchStatus.cancelled);
    });

    test('parses null as scheduled (default)', () async {
      expect(await parseStatusViaFetch(null), MatchStatus.scheduled);
    });
  });

  // ---------------------------------------------------------------------------
  // _parseConfederation (tested indirectly through fetchAllTeams)
  // ---------------------------------------------------------------------------
  group('WorldCupApiDataSource - confederation parsing', () {
    Future<Confederation> parseConfederationViaFetch(String? areaName) async {
      final teamJson = _createTeamJson();
      teamJson['AreaName'] = areaName;
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            teamJson,
          ]));
      final result = await dataSource.fetchAllTeams();
      return result.first.confederation;
    }

    test('parses "Europe" as UEFA', () async {
      expect(
          await parseConfederationViaFetch('Europe'), Confederation.uefa);
    });

    test('parses "South America" as CONMEBOL', () async {
      expect(await parseConfederationViaFetch('South America'),
          Confederation.conmebol);
    });

    test('parses "North America" as CONCACAF', () async {
      expect(await parseConfederationViaFetch('North America'),
          Confederation.concacaf);
    });

    test('parses "Central America" as CONCACAF', () async {
      expect(await parseConfederationViaFetch('Central America'),
          Confederation.concacaf);
    });

    test('parses "Asia" as AFC', () async {
      expect(await parseConfederationViaFetch('Asia'), Confederation.afc);
    });

    test('parses "Africa" as CAF', () async {
      expect(await parseConfederationViaFetch('Africa'), Confederation.caf);
    });

    test('parses null as UEFA (default)', () async {
      expect(await parseConfederationViaFetch(null), Confederation.uefa);
    });
  });

  // ---------------------------------------------------------------------------
  // _parseHostCountry (tested indirectly through fetchVenues)
  // ---------------------------------------------------------------------------
  group('WorldCupApiDataSource - host country parsing', () {
    Future<HostCountry> parseHostCountryViaFetch(String country) async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            _createVenueJson(country: country),
          ]));
      final result = await dataSource.fetchVenues();
      return result.first.country;
    }

    test('parses "United States" as USA', () async {
      expect(await parseHostCountryViaFetch('United States'), HostCountry.usa);
    });

    test('parses "Mexico" as mexico', () async {
      expect(await parseHostCountryViaFetch('Mexico'), HostCountry.mexico);
    });

    test('parses "Canada" as canada', () async {
      expect(await parseHostCountryViaFetch('Canada'), HostCountry.canada);
    });

    test('parses "USA" variant as USA (default)', () async {
      expect(await parseHostCountryViaFetch('USA'), HostCountry.usa);
    });
  });

  // ---------------------------------------------------------------------------
  // _parseMatch field mapping
  // ---------------------------------------------------------------------------
  group('WorldCupApiDataSource - match field parsing', () {
    test('maps all match fields correctly', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            _createMatchJson(
              gameId: '99',
              gameNumber: 42,
              round: 'Semi-final',
              group: null,
              groupMatchDay: null,
              homeTeamKey: 'FRA',
              homeTeamName: 'France',
              awayTeamKey: 'BRA',
              awayTeamName: 'Brazil',
              homeScore: 2,
              awayScore: 1,
              status: 'Completed',
              dateTime: '2026-07-14T20:00:00',
              venueId: '5',
              channels: ['FOX', 'Telemundo'],
              clock: 90,
              winnerTeamKey: 'FRA',
              updated: '2026-07-14T22:00:00',
            ),
          ]));

      final result = await dataSource.fetchAllMatches();
      final match = result.first;

      expect(match.matchId, '99');
      expect(match.matchNumber, 42);
      expect(match.stage, MatchStage.semiFinal);
      expect(match.homeTeamCode, 'FRA');
      expect(match.homeTeamName, 'France');
      expect(match.awayTeamCode, 'BRA');
      expect(match.awayTeamName, 'Brazil');
      expect(match.homeScore, 2);
      expect(match.awayScore, 1);
      expect(match.status, MatchStatus.completed);
      expect(match.venueId, '5');
      expect(match.broadcastChannels, ['FOX', 'Telemundo']);
      expect(match.minute, 90);
      expect(match.winnerTeamCode, 'FRA');
    });

    test('handles missing optional fields gracefully', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            {
              'GameId': null,
              'GameNumber': null,
              'Round': null,
              'Stage': null,
              'Group': null,
              'GroupMatchDay': null,
              'HomeTeamKey': null,
              'HomeTeamName': null,
              'AwayTeamKey': null,
              'AwayTeamName': null,
              'DateTime': null,
              'DateTimeUTC': null,
              'VenueId': null,
              'Channels': null,
              'Status': null,
              'Clock': null,
              'HomeTeamScore': null,
              'AwayTeamScore': null,
              'HomeTeamLogo': null,
              'AwayTeamLogo': null,
              'HomeTeamScoreHalftime': null,
              'AwayTeamScoreHalftime': null,
              'HomeTeamScoreExtraTime': null,
              'AwayTeamScoreExtraTime': null,
              'HomeTeamScorePenalties': null,
              'AwayTeamScorePenalties': null,
              'WinnerTeamKey': null,
              'Updated': null,
            },
          ]));

      final result = await dataSource.fetchAllMatches();
      final match = result.first;

      expect(match.matchId, '');
      expect(match.matchNumber, 0);
      expect(match.stage, MatchStage.groupStage);
      expect(match.homeTeamName, 'TBD');
      expect(match.awayTeamName, 'TBD');
      expect(match.status, MatchStatus.scheduled);
      expect(match.broadcastChannels, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // _parseTeam field mapping
  // ---------------------------------------------------------------------------
  group('WorldCupApiDataSource - team field parsing', () {
    test('maps all team fields correctly', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => _successResponse([
            _createTeamJson(
              key: 'BRA',
              fullName: 'Brazil',
              shortName: 'BRA',
              areaName: 'South America',
              ranking: 3,
              group: 'C',
              coach: {'Name': 'Dorival Junior'},
            ),
          ]));

      final result = await dataSource.fetchAllTeams();
      final team = result.first;

      expect(team.fifaCode, 'BRA');
      expect(team.countryName, 'Brazil');
      expect(team.shortName, 'BRA');
      expect(team.confederation, Confederation.conmebol);
      expect(team.fifaRanking, 3);
      expect(team.group, 'C');
      expect(team.coachName, 'Dorival Junior');
      expect(team.isQualified, true);
    });
  });
}
