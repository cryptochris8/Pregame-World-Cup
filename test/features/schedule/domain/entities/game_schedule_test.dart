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
          'awayTeamName': 'Argentina',
          'homeTeamName': 'Brazil',
          'channel': 'FOX',
        };

        final game = GameSchedule.fromMap(data);

        expect(game.gameId, equals('game_001'));
        expect(game.globalGameId, equals(12345));
        expect(game.season, equals('2025'));
        expect(game.seasonType, equals(1));
        expect(game.week, equals(5));
        expect(game.status, equals('Scheduled'));
        expect(game.awayTeamName, equals('Argentina'));
        expect(game.homeTeamName, equals('Brazil'));
        expect(game.channel, equals('FOX'));
      });

      test('parses date strings', () {
        final data = {
          'gameId': 'game_002',
          'awayTeamName': 'Germany',
          'homeTeamName': 'France',
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
          'awayTeamName': 'Mexico',
          'homeTeamName': 'USA',
          'stadium': {
            'StadiumID': 1,
            'Name': 'MetLife Stadium',
            'City': 'East Rutherford',
            'State': 'NJ',
            'Capacity': 82500,
          },
        };

        final game = GameSchedule.fromMap(data);

        expect(game.stadium, isNotNull);
        expect(game.stadium!.name, equals('MetLife Stadium'));
        expect(game.stadium!.city, equals('East Rutherford'));
        expect(game.stadium!.state, equals('NJ'));
      });

      test('parses live score fields', () {
        final data = {
          'gameId': 'game_004',
          'awayTeamName': 'Spain',
          'homeTeamName': 'Portugal',
          'awayScore': 2,
          'homeScore': 3,
          'period': '2H',
          'timeRemaining': "72'",
          'isLive': true,
        };

        final game = GameSchedule.fromMap(data);

        expect(game.awayScore, equals(2));
        expect(game.homeScore, equals(3));
        expect(game.period, equals('2H'));
        expect(game.timeRemaining, equals("72'"));
        expect(game.isLive, isTrue);
      });

      test('parses social features fields', () {
        final data = {
          'gameId': 'game_005',
          'awayTeamName': 'Japan',
          'homeTeamName': 'South Korea',
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
          'awayTeamName': 'Costa Rica',
          'homeTeamName': 'Canada',
        };

        final game = GameSchedule.fromMap(data);

        expect(game.gameId, equals('unknown-id'));
        expect(game.awayTeamName, equals('Costa Rica'));
        expect(game.homeTeamName, equals('Canada'));
        expect(game.globalGameId, isNull);
        expect(game.stadium, isNull);
        expect(game.awayScore, isNull);
      });

      test('uses id parameter when gameId not in data', () {
        final data = {
          'awayTeamName': 'Colombia',
          'homeTeamName': 'Ecuador',
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
          'AwayTeamName': 'Uruguay',
          'HomeTeamName': 'Paraguay',
          'Channel': 'FOX Sports',
          'NeutralVenue': false,
        };

        final game = GameSchedule.fromSportsDataIo(json);

        expect(game.gameId, equals('54321'));
        expect(game.globalGameId, equals(98765));
        expect(game.season, equals('2025'));
        expect(game.week, equals(8));
        expect(game.status, equals('Scheduled'));
        expect(game.awayTeamName, equals('Uruguay'));
        expect(game.homeTeamName, equals('Paraguay'));
        expect(game.channel, equals('FOX Sports'));
        expect(game.neutralVenue, isFalse);
      });

      test('parses nested Stadium in SportsData.io format', () {
        final json = {
          'GameID': 11111,
          'AwayTeamName': 'France',
          'HomeTeamName': 'Germany',
          'Stadium': {
            'StadiumID': 5,
            'Name': 'AT&T Stadium',
            'City': 'Arlington',
            'State': 'TX',
            'GeoLat': 32.7473,
            'GeoLong': -97.0945,
          },
        };

        final game = GameSchedule.fromSportsDataIo(json);

        expect(game.stadium, isNotNull);
        expect(game.stadium!.name, equals('AT&T Stadium'));
        expect(game.stadium!.geoLat, equals(32.7473));
        expect(game.stadium!.geoLong, equals(-97.0945));
      });

      test('parses score information', () {
        final json = {
          'GameID': 22222,
          'AwayTeamName': 'Brazil',
          'HomeTeamName': 'Argentina',
          'Status': 'InProgress',
          'AwayTeamScore': 2,
          'HomeTeamScore': 1,
          'Period': '3',
          'TimeRemainingMinutes': 8,
        };

        final game = GameSchedule.fromSportsDataIo(json);

        expect(game.awayScore, equals(2));
        expect(game.homeScore, equals(1));
        expect(game.isLive, isTrue);
        expect(game.period, equals('3'));
        expect(game.timeRemaining, equals('8'));
      });

      test('handles missing GameID', () {
        final json = {
          'AwayTeamName': 'South Korea',
          'HomeTeamName': 'Japan',
        };

        final game = GameSchedule.fromSportsDataIo(json);
        expect(game.gameId, equals(''));
      });

      test('handles string GameID', () {
        final json = {
          'GameID': '99999',
          'AwayTeamName': 'Mexico',
          'HomeTeamName': 'Colombia',
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
            'currentPeriod': '2H',
            'contestClock': "65'",
            'stadium': 'Hard Rock Stadium',
            'away': {
              'names': {'short': 'JPN'},
              'name': 'Japan',
              'score': 1,
            },
            'home': {
              'names': {'short': 'USA'},
              'name': 'United States',
              'score': 2,
            },
          },
        };

        final game = GameSchedule.fromJson(json);

        expect(game.gameId, equals('api_game_001'));
        expect(game.week, equals(10));
        expect(game.awayTeamName, equals('JPN'));
        expect(game.homeTeamName, equals('USA'));
        expect(game.awayScore, equals(1));
        expect(game.homeScore, equals(2));
        expect(game.isLive, isTrue);
        expect(game.period, equals('2H'));
        expect(game.timeRemaining, equals("65'"));
      });

      test('handles flat structure without nested game', () {
        final json = {
          'gameID': 'flat_game_001',
          'startDate': '2025-11-08',
          'away': {
            'name': 'Netherlands',
          },
          'home': {
            'name': 'Belgium',
          },
        };

        final game = GameSchedule.fromJson(json);

        expect(game.gameId, equals('flat_game_001'));
        expect(game.awayTeamName, equals('Netherlands'));
        expect(game.homeTeamName, equals('Belgium'));
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
          awayTeamName: 'Germany',
          homeTeamName: 'France',
          awayScore: 3,
          homeScore: 2,
          channel: 'FOX',
        );

        final map = game.toMap();

        expect(map['gameId'], equals('map_game_001'));
        expect(map['globalGameId'], equals(11111));
        expect(map['season'], equals('2025'));
        expect(map['week'], equals(12));
        expect(map['status'], equals('Final'));
        expect(map['awayTeamName'], equals('Germany'));
        expect(map['homeTeamName'], equals('France'));
        expect(map['awayScore'], equals(3));
        expect(map['homeScore'], equals(2));
      });

      test('serializes dates as ISO strings', () {
        final game = GameSchedule(
          gameId: 'date_game',
          awayTeamName: 'Spain',
          homeTeamName: 'Portugal',
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
          awayTeamName: 'Costa Rica',
          homeTeamName: 'Honduras',
          status: 'Scheduled',
          week: 6,
        );

        final map = game.toFirestore();

        expect(map['week'], equals(6));
        expect(map['status'], equals('Scheduled'));
        expect(map['awayTeamName'], equals('Costa Rica'));
        expect(map['homeTeamName'], equals('Honduras'));
      });
    });
  });

  group('Stadium', () {
    group('fromMap', () {
      test('parses PascalCase keys', () {
        final map = {
          'StadiumID': 100,
          'Name': 'Mercedes-Benz Stadium',
          'City': 'Atlanta',
          'State': 'GA',
          'Capacity': 71000,
          'YearOpened': 2017,
          'GeoLat': 33.7553,
          'GeoLong': -84.4006,
          'Team': 'World Cup Venue',
        };

        final stadium = Stadium.fromMap(map);

        expect(stadium.stadiumId, equals(100));
        expect(stadium.name, equals('Mercedes-Benz Stadium'));
        expect(stadium.city, equals('Atlanta'));
        expect(stadium.state, equals('GA'));
        expect(stadium.capacity, equals(71000));
        expect(stadium.yearOpened, equals(2017));
        expect(stadium.geoLat, equals(33.7553));
        expect(stadium.geoLong, equals(-84.4006));
        expect(stadium.team, equals('World Cup Venue'));
      });

      test('parses camelCase keys', () {
        final map = {
          'stadiumId': 200,
          'name': 'NRG Stadium',
          'city': 'Houston',
          'state': 'TX',
          'capacity': 72220,
          'yearOpened': 2002,
          'geoLat': 29.6847,
          'geoLong': -95.4107,
          'team': 'World Cup Venue',
        };

        final stadium = Stadium.fromMap(map);

        expect(stadium.stadiumId, equals(200));
        expect(stadium.name, equals('NRG Stadium'));
        expect(stadium.city, equals('Houston'));
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
          'Name': 'Lumen Field',
          'City': 'Seattle',
          'State': 'WA',
          'Capacity': 69000,
          'YearOpened': 2002,
          'GeoLat': 47.5952,
          'GeoLong': -122.3316,
          'Team': 'World Cup Venue',
        };

        final stadium = Stadium.fromDataSource(json);

        expect(stadium.stadiumId, equals(300));
        expect(stadium.name, equals('Lumen Field'));
        expect(stadium.city, equals('Seattle'));
        expect(stadium.state, equals('WA'));
        expect(stadium.geoLat, equals(47.5952));
        expect(stadium.geoLong, equals(-122.3316));
      });
    });

    group('toFirestore', () {
      test('serializes all fields', () {
        final stadium = Stadium(
          stadiumId: 400,
          name: 'Hard Rock Stadium',
          city: 'Miami Gardens',
          state: 'FL',
          capacity: 65326,
          yearOpened: 1987,
          geoLat: 25.9580,
          geoLong: -80.2389,
          team: 'World Cup Venue',
        );

        final map = stadium.toFirestore();

        expect(map['StadiumID'], equals(400));
        expect(map['Name'], equals('Hard Rock Stadium'));
        expect(map['City'], equals('Miami Gardens'));
        expect(map['State'], equals('FL'));
        expect(map['Capacity'], equals(65326));
        expect(map['YearOpened'], equals(1987));
        expect(map['GeoLat'], equals(25.9580));
        expect(map['GeoLong'], equals(-80.2389));
        expect(map['Team'], equals('World Cup Venue'));
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
