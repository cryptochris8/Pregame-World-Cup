import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';

/// Tests for GameSchedule entity and Stadium class
void main() {
  group('GameSchedule', () {
    group('fromMap', () {
      test('parses basic game data', () {
        final data = {
          'gameId': 'game_001',
          'globalGameId': 12345,
          'season': '2025',
          'seasonType': 1,
          'week': 5,
          'status': 'Scheduled',
          'awayTeamName': 'Alabama',
          'homeTeamName': 'Georgia',
          'channel': 'ESPN',
        };

        final game = GameSchedule.fromMap(data);

        expect(game.gameId, equals('game_001'));
        expect(game.globalGameId, equals(12345));
        expect(game.season, equals('2025'));
        expect(game.seasonType, equals(1));
        expect(game.week, equals(5));
        expect(game.status, equals('Scheduled'));
        expect(game.awayTeamName, equals('Alabama'));
        expect(game.homeTeamName, equals('Georgia'));
        expect(game.channel, equals('ESPN'));
      });

      test('parses date strings', () {
        final data = {
          'gameId': 'game_002',
          'awayTeamName': 'LSU',
          'homeTeamName': 'Florida',
          'day': '2025-10-15',
          'dateTime': '2025-10-15T19:00:00',
          'dateTimeUTC': '2025-10-15T23:00:00Z',
        };

        final game = GameSchedule.fromMap(data);

        expect(game.day, isNotNull);
        expect(game.day!.year, equals(2025));
        expect(game.day!.month, equals(10));
        expect(game.day!.day, equals(15));
        expect(game.dateTime, isNotNull);
        expect(game.dateTimeUTC, isNotNull);
      });

      test('parses nested stadium data', () {
        final data = {
          'gameId': 'game_003',
          'awayTeamName': 'Auburn',
          'homeTeamName': 'Tennessee',
          'stadium': {
            'StadiumID': 1,
            'Name': 'Neyland Stadium',
            'City': 'Knoxville',
            'State': 'TN',
            'Capacity': 102455,
          },
        };

        final game = GameSchedule.fromMap(data);

        expect(game.stadium, isNotNull);
        expect(game.stadium!.name, equals('Neyland Stadium'));
        expect(game.stadium!.city, equals('Knoxville'));
        expect(game.stadium!.state, equals('TN'));
      });

      test('parses live score fields', () {
        final data = {
          'gameId': 'game_004',
          'awayTeamName': 'Texas',
          'homeTeamName': 'Oklahoma',
          'awayScore': 21,
          'homeScore': 28,
          'period': 'Q3',
          'timeRemaining': '5:32',
          'isLive': true,
        };

        final game = GameSchedule.fromMap(data);

        expect(game.awayScore, equals(21));
        expect(game.homeScore, equals(28));
        expect(game.period, equals('Q3'));
        expect(game.timeRemaining, equals('5:32'));
        expect(game.isLive, isTrue);
      });

      test('parses social features fields', () {
        final data = {
          'gameId': 'game_005',
          'awayTeamName': 'Missouri',
          'homeTeamName': 'Kentucky',
          'userPredictions': 150,
          'userComments': 45,
          'userPhotos': 20,
          'userRating': 4.5,
        };

        final game = GameSchedule.fromMap(data);

        expect(game.userPredictions, equals(150));
        expect(game.userComments, equals(45));
        expect(game.userPhotos, equals(20));
        expect(game.userRating, equals(4.5));
      });

      test('handles missing optional fields', () {
        final data = {
          'awayTeamName': 'Vanderbilt',
          'homeTeamName': 'South Carolina',
        };

        final game = GameSchedule.fromMap(data);

        expect(game.gameId, equals('unknown-id'));
        expect(game.awayTeamName, equals('Vanderbilt'));
        expect(game.homeTeamName, equals('South Carolina'));
        expect(game.globalGameId, isNull);
        expect(game.stadium, isNull);
        expect(game.awayScore, isNull);
      });

      test('uses id parameter when gameId not in data', () {
        final data = {
          'awayTeamName': 'Arkansas',
          'homeTeamName': 'Ole Miss',
        };

        final game = GameSchedule.fromMap(data, id: 'custom_id_123');

        expect(game.gameId, equals('custom_id_123'));
      });

      test('handles N/A for missing team names', () {
        final data = <String, dynamic>{};
        final game = GameSchedule.fromMap(data);

        expect(game.awayTeamName, equals('N/A'));
        expect(game.homeTeamName, equals('N/A'));
      });
    });

    group('fromSportsDataIo', () {
      test('parses SportsData.io API format', () {
        final json = {
          'GameID': 54321,
          'GlobalGameID': 98765,
          'Season': 2025,
          'SeasonType': 1,
          'Week': 8,
          'Status': 'Scheduled',
          'Day': '2025-10-20',
          'DateTime': '2025-10-20T15:30:00',
          'AwayTeamID': 10,
          'HomeTeamID': 20,
          'AwayTeamName': 'Texas A&M',
          'HomeTeamName': 'Mississippi State',
          'Channel': 'SEC Network',
          'NeutralVenue': false,
        };

        final game = GameSchedule.fromSportsDataIo(json);

        expect(game.gameId, equals('54321'));
        expect(game.globalGameId, equals(98765));
        expect(game.season, equals('2025'));
        expect(game.week, equals(8));
        expect(game.status, equals('Scheduled'));
        expect(game.awayTeamName, equals('Texas A&M'));
        expect(game.homeTeamName, equals('Mississippi State'));
        expect(game.channel, equals('SEC Network'));
        expect(game.neutralVenue, isFalse);
      });

      test('parses nested Stadium in SportsData.io format', () {
        final json = {
          'GameID': 11111,
          'AwayTeamName': 'Florida',
          'HomeTeamName': 'LSU',
          'Stadium': {
            'StadiumID': 5,
            'Name': 'Tiger Stadium',
            'City': 'Baton Rouge',
            'State': 'LA',
            'GeoLat': 30.4120,
            'GeoLong': -91.1847,
          },
        };

        final game = GameSchedule.fromSportsDataIo(json);

        expect(game.stadium, isNotNull);
        expect(game.stadium!.name, equals('Tiger Stadium'));
        expect(game.stadium!.geoLat, equals(30.4120));
        expect(game.stadium!.geoLong, equals(-91.1847));
      });

      test('parses score information', () {
        final json = {
          'GameID': 22222,
          'AwayTeamName': 'Georgia',
          'HomeTeamName': 'Alabama',
          'Status': 'InProgress',
          'AwayTeamScore': 14,
          'HomeTeamScore': 21,
          'Period': '3',
          'TimeRemainingMinutes': 8,
        };

        final game = GameSchedule.fromSportsDataIo(json);

        expect(game.awayScore, equals(14));
        expect(game.homeScore, equals(21));
        expect(game.isLive, isTrue);
        expect(game.period, equals('3'));
        expect(game.timeRemaining, equals('8'));
      });

      test('handles missing GameID', () {
        final json = {
          'AwayTeamName': 'Kentucky',
          'HomeTeamName': 'Tennessee',
        };

        final game = GameSchedule.fromSportsDataIo(json);
        expect(game.gameId, equals(''));
      });

      test('handles string GameID', () {
        final json = {
          'GameID': '99999',
          'AwayTeamName': 'Auburn',
          'HomeTeamName': 'Arkansas',
        };

        final game = GameSchedule.fromSportsDataIo(json);
        expect(game.gameId, equals('99999'));
      });
    });

    group('fromJson', () {
      test('parses nested game structure', () {
        final json = {
          'week': 10,
          'game': {
            'gameID': 'api_game_001',
            'startDate': '2025-11-01',
            'startTimeEpoch': '1730487600',
            'gameState': 'live',
            'currentPeriod': 'Q2',
            'contestClock': '3:45',
            'stadium': 'Bryant-Denny Stadium',
            'away': {
              'names': {'short': 'TENN'},
              'name': 'Tennessee',
              'score': 17,
            },
            'home': {
              'names': {'short': 'BAMA'},
              'name': 'Alabama',
              'score': 24,
            },
          },
        };

        final game = GameSchedule.fromJson(json);

        expect(game.gameId, equals('api_game_001'));
        expect(game.week, equals(10));
        expect(game.awayTeamName, equals('TENN'));
        expect(game.homeTeamName, equals('BAMA'));
        expect(game.awayScore, equals(17));
        expect(game.homeScore, equals(24));
        expect(game.isLive, isTrue);
        expect(game.period, equals('Q2'));
        expect(game.timeRemaining, equals('3:45'));
      });

      test('handles flat structure without nested game', () {
        final json = {
          'gameID': 'flat_game_001',
          'startDate': '2025-11-08',
          'away': {
            'name': 'Missouri',
          },
          'home': {
            'name': 'South Carolina',
          },
        };

        final game = GameSchedule.fromJson(json);

        expect(game.gameId, equals('flat_game_001'));
        expect(game.awayTeamName, equals('Missouri'));
        expect(game.homeTeamName, equals('South Carolina'));
      });

      test('handles missing team data', () {
        final json = {
          'gameID': 'minimal_game',
        };

        final game = GameSchedule.fromJson(json);

        expect(game.awayTeamName, equals('Unknown'));
        expect(game.homeTeamName, equals('Unknown'));
      });
    });

    group('toMap', () {
      test('serializes all fields', () {
        final game = GameSchedule(
          gameId: 'map_game_001',
          globalGameId: 11111,
          season: '2025',
          seasonType: 1,
          week: 12,
          status: 'Final',
          awayTeamName: 'LSU',
          homeTeamName: 'Florida',
          awayScore: 35,
          homeScore: 28,
          channel: 'CBS',
        );

        final map = game.toMap();

        expect(map['gameId'], equals('map_game_001'));
        expect(map['globalGameId'], equals(11111));
        expect(map['season'], equals('2025'));
        expect(map['week'], equals(12));
        expect(map['status'], equals('Final'));
        expect(map['awayTeamName'], equals('LSU'));
        expect(map['homeTeamName'], equals('Florida'));
        expect(map['awayScore'], equals(35));
        expect(map['homeScore'], equals(28));
      });

      test('serializes dates as ISO strings', () {
        final game = GameSchedule(
          gameId: 'date_game',
          awayTeamName: 'Texas',
          homeTeamName: 'Oklahoma',
          day: DateTime(2025, 10, 11),
          dateTime: DateTime(2025, 10, 11, 12, 0),
        );

        final map = game.toMap();

        expect(map['day'], contains('2025-10-11'));
        expect(map['dateTime'], contains('2025-10-11'));
      });
    });

    group('toFirestore', () {
      test('serializes for Firestore', () {
        final game = GameSchedule(
          gameId: 'fs_game_001',
          awayTeamName: 'Vanderbilt',
          homeTeamName: 'Kentucky',
          status: 'Scheduled',
          week: 6,
        );

        final map = game.toFirestore();

        expect(map['week'], equals(6));
        expect(map['status'], equals('Scheduled'));
        expect(map['awayTeamName'], equals('Vanderbilt'));
        expect(map['homeTeamName'], equals('Kentucky'));
      });
    });
  });

  group('Stadium', () {
    group('fromMap', () {
      test('parses PascalCase keys', () {
        final map = {
          'StadiumID': 100,
          'Name': 'Sanford Stadium',
          'City': 'Athens',
          'State': 'GA',
          'Capacity': 92746,
          'YearOpened': 1929,
          'GeoLat': 33.9498,
          'GeoLong': -83.3734,
          'Team': 'Georgia Bulldogs',
        };

        final stadium = Stadium.fromMap(map);

        expect(stadium.stadiumId, equals(100));
        expect(stadium.name, equals('Sanford Stadium'));
        expect(stadium.city, equals('Athens'));
        expect(stadium.state, equals('GA'));
        expect(stadium.capacity, equals(92746));
        expect(stadium.yearOpened, equals(1929));
        expect(stadium.geoLat, equals(33.9498));
        expect(stadium.geoLong, equals(-83.3734));
        expect(stadium.team, equals('Georgia Bulldogs'));
      });

      test('parses camelCase keys', () {
        final map = {
          'stadiumId': 200,
          'name': 'Kyle Field',
          'city': 'College Station',
          'state': 'TX',
          'capacity': 102733,
          'yearOpened': 1927,
          'geoLat': 30.6101,
          'geoLong': -96.3416,
          'team': 'Texas A&M Aggies',
        };

        final stadium = Stadium.fromMap(map);

        expect(stadium.stadiumId, equals(200));
        expect(stadium.name, equals('Kyle Field'));
        expect(stadium.city, equals('College Station'));
        expect(stadium.state, equals('TX'));
      });

      test('handles missing optional fields', () {
        final map = <String, dynamic>{};
        final stadium = Stadium.fromMap(map);

        expect(stadium.stadiumId, isNull);
        expect(stadium.name, isNull);
        expect(stadium.city, isNull);
        expect(stadium.geoLat, isNull);
      });

      test('handles numeric types for coordinates', () {
        final map = {
          'GeoLat': 30, // int instead of double
          'GeoLong': -90,
        };

        final stadium = Stadium.fromMap(map);

        expect(stadium.geoLat, equals(30.0));
        expect(stadium.geoLong, equals(-90.0));
        expect(stadium.geoLat, isA<double>());
      });
    });

    group('fromDataSource', () {
      test('parses SportsData.io format', () {
        final json = {
          'StadiumID': 300,
          'Name': 'Jordan-Hare Stadium',
          'City': 'Auburn',
          'State': 'AL',
          'Capacity': 87451,
          'YearOpened': 1939,
          'GeoLat': 32.6025,
          'GeoLong': -85.4897,
          'Team': 'Auburn Tigers',
        };

        final stadium = Stadium.fromDataSource(json);

        expect(stadium.stadiumId, equals(300));
        expect(stadium.name, equals('Jordan-Hare Stadium'));
        expect(stadium.city, equals('Auburn'));
        expect(stadium.state, equals('AL'));
        expect(stadium.geoLat, equals(32.6025));
        expect(stadium.geoLong, equals(-85.4897));
      });
    });

    group('toFirestore', () {
      test('serializes all fields', () {
        final stadium = Stadium(
          stadiumId: 400,
          name: 'Ben Hill Griffin Stadium',
          city: 'Gainesville',
          state: 'FL',
          capacity: 88548,
          yearOpened: 1930,
          geoLat: 29.6500,
          geoLong: -82.3486,
          team: 'Florida Gators',
        );

        final map = stadium.toFirestore();

        expect(map['StadiumID'], equals(400));
        expect(map['Name'], equals('Ben Hill Griffin Stadium'));
        expect(map['City'], equals('Gainesville'));
        expect(map['State'], equals('FL'));
        expect(map['Capacity'], equals(88548));
        expect(map['YearOpened'], equals(1930));
        expect(map['GeoLat'], equals(29.6500));
        expect(map['GeoLong'], equals(-82.3486));
        expect(map['Team'], equals('Florida Gators'));
      });

      test('handles null values', () {
        final stadium = Stadium(
          name: 'Test Stadium',
        );

        final map = stadium.toFirestore();

        expect(map['StadiumID'], isNull);
        expect(map['Name'], equals('Test Stadium'));
        expect(map['City'], isNull);
      });
    });
  });

  group('TimeFilter enum', () {
    test('has today value', () {
      expect(TimeFilter.today, isNotNull);
      expect(TimeFilter.values, contains(TimeFilter.today));
    });

    test('has thisWeek value', () {
      expect(TimeFilter.thisWeek, isNotNull);
      expect(TimeFilter.values, contains(TimeFilter.thisWeek));
    });

    test('has all value', () {
      expect(TimeFilter.all, isNotNull);
      expect(TimeFilter.values, contains(TimeFilter.all));
    });

    test('has exactly 3 values', () {
      expect(TimeFilter.values.length, equals(3));
    });
  });
}
