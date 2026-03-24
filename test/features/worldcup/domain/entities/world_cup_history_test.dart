import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/world_cup_history.dart';

void main() {
  group('WorldCupTournament', () {
    WorldCupTournament createTestTournament({
      int year = 2022,
      List<String> hostCountries = const ['Qatar'],
      List<String> hostCodes = const ['QAT'],
      String winner = 'Argentina',
      String winnerCode = 'ARG',
      String runnerUp = 'France',
      String runnerUpCode = 'FRA',
      String thirdPlace = 'Croatia',
      String thirdPlaceCode = 'CRO',
      String fourthPlace = 'Morocco',
      String fourthPlaceCode = 'MAR',
      int totalTeams = 32,
      int totalMatches = 64,
      int totalGoals = 172,
      String topScorer = 'Kylian Mbappe',
      String topScorerCountry = 'France',
      int topScorerGoals = 8,
      String? goldenBall,
      String? goldenBallCountry,
      String? bestYoungPlayer,
      String? bestYoungPlayerCountry,
      String? goldenGlove,
      String? goldenGloveCountry,
      String finalScore = '3-3 (4-2 pen)',
      String finalVenue = 'Lusail Stadium',
      String finalCity = 'Lusail',
      int finalAttendance = 88966,
      List<String> highlights = const ['Messi wins World Cup'],
    }) {
      return WorldCupTournament(
        year: year,
        hostCountries: hostCountries,
        hostCodes: hostCodes,
        winner: winner,
        winnerCode: winnerCode,
        runnerUp: runnerUp,
        runnerUpCode: runnerUpCode,
        thirdPlace: thirdPlace,
        thirdPlaceCode: thirdPlaceCode,
        fourthPlace: fourthPlace,
        fourthPlaceCode: fourthPlaceCode,
        totalTeams: totalTeams,
        totalMatches: totalMatches,
        totalGoals: totalGoals,
        topScorer: topScorer,
        topScorerCountry: topScorerCountry,
        topScorerGoals: topScorerGoals,
        goldenBall: goldenBall,
        goldenBallCountry: goldenBallCountry,
        bestYoungPlayer: bestYoungPlayer,
        bestYoungPlayerCountry: bestYoungPlayerCountry,
        goldenGlove: goldenGlove,
        goldenGloveCountry: goldenGloveCountry,
        finalScore: finalScore,
        finalVenue: finalVenue,
        finalCity: finalCity,
        finalAttendance: finalAttendance,
        highlights: highlights,
      );
    }

    group('Constructor', () {
      test('creates tournament with required fields', () {
        final tournament = createTestTournament();

        expect(tournament.year, equals(2022));
        expect(tournament.hostCountries, equals(['Qatar']));
        expect(tournament.hostCodes, equals(['QAT']));
        expect(tournament.winner, equals('Argentina'));
        expect(tournament.winnerCode, equals('ARG'));
        expect(tournament.runnerUp, equals('France'));
        expect(tournament.totalTeams, equals(32));
        expect(tournament.totalMatches, equals(64));
        expect(tournament.totalGoals, equals(172));
      });

      test('creates tournament with optional fields', () {
        final tournament = createTestTournament(
          goldenBall: 'Lionel Messi',
          goldenBallCountry: 'Argentina',
          bestYoungPlayer: 'Enzo Fernandez',
          bestYoungPlayerCountry: 'Argentina',
          goldenGlove: 'Emiliano Martinez',
          goldenGloveCountry: 'Argentina',
        );

        expect(tournament.goldenBall, equals('Lionel Messi'));
        expect(tournament.goldenBallCountry, equals('Argentina'));
        expect(tournament.bestYoungPlayer, equals('Enzo Fernandez'));
        expect(tournament.bestYoungPlayerCountry, equals('Argentina'));
        expect(tournament.goldenGlove, equals('Emiliano Martinez'));
        expect(tournament.goldenGloveCountry, equals('Argentina'));
      });

      test('creates tournament with multiple host countries', () {
        final tournament = createTestTournament(
          year: 2026,
          hostCountries: ['United States', 'Mexico', 'Canada'],
          hostCodes: ['USA', 'MEX', 'CAN'],
        );

        expect(tournament.hostCountries, hasLength(3));
        expect(tournament.hostCodes, hasLength(3));
      });
    });

    group('Computed getters', () {
      test('id returns correct format', () {
        final tournament = createTestTournament(year: 2022);
        expect(tournament.id, equals('wc_2022'));

        final tournament2026 = createTestTournament(year: 2026);
        expect(tournament2026.id, equals('wc_2026'));
      });

      test('goalsPerGame calculates correctly', () {
        final tournament = createTestTournament(
          totalMatches: 64,
          totalGoals: 172,
        );
        expect(tournament.goalsPerGame, closeTo(2.6875, 0.001));
      });

      test('goalsPerGame returns 0 when no matches', () {
        final tournament = createTestTournament(
          totalMatches: 0,
          totalGoals: 0,
        );
        expect(tournament.goalsPerGame, equals(0));
      });

      test('hostDisplay joins countries correctly', () {
        final singleHost = createTestTournament(
          hostCountries: ['Qatar'],
        );
        expect(singleHost.hostDisplay, equals('Qatar'));

        final multiHost = createTestTournament(
          hostCountries: ['United States', 'Mexico', 'Canada'],
        );
        expect(multiHost.hostDisplay, equals('United States, Mexico, Canada'));
      });
    });

    group('Firestore serialization', () {
      test('toFirestore serializes all fields', () {
        final tournament = createTestTournament(
          goldenBall: 'Lionel Messi',
          goldenBallCountry: 'Argentina',
        );
        final data = tournament.toFirestore();

        expect(data['year'], equals(2022));
        expect(data['hostCountries'], equals(['Qatar']));
        expect(data['winner'], equals('Argentina'));
        expect(data['winnerCode'], equals('ARG'));
        expect(data['totalTeams'], equals(32));
        expect(data['totalMatches'], equals(64));
        expect(data['totalGoals'], equals(172));
        expect(data['topScorer'], equals('Kylian Mbappe'));
        expect(data['topScorerGoals'], equals(8));
        expect(data['goldenBall'], equals('Lionel Messi'));
        expect(data['finalScore'], equals('3-3 (4-2 pen)'));
        expect(data['highlights'], equals(['Messi wins World Cup']));
      });

      test('fromFirestore deserializes correctly', () {
        final data = {
          'year': 2018,
          'hostCountries': ['Russia'],
          'hostCodes': ['RUS'],
          'winner': 'France',
          'winnerCode': 'FRA',
          'runnerUp': 'Croatia',
          'runnerUpCode': 'CRO',
          'thirdPlace': 'Belgium',
          'thirdPlaceCode': 'BEL',
          'fourthPlace': 'England',
          'fourthPlaceCode': 'ENG',
          'totalTeams': 32,
          'totalMatches': 64,
          'totalGoals': 169,
          'topScorer': 'Harry Kane',
          'topScorerCountry': 'England',
          'topScorerGoals': 6,
          'goldenBall': 'Luka Modric',
          'goldenBallCountry': 'Croatia',
          'bestYoungPlayer': 'Kylian Mbappe',
          'bestYoungPlayerCountry': 'France',
          'goldenGlove': 'Thibaut Courtois',
          'goldenGloveCountry': 'Belgium',
          'finalScore': '4-2',
          'finalVenue': 'Luzhniki Stadium',
          'finalCity': 'Moscow',
          'finalAttendance': 78011,
          'highlights': ['France wins second title', 'VAR debut'],
        };

        final tournament = WorldCupTournament.fromFirestore(data);

        expect(tournament.year, equals(2018));
        expect(tournament.winner, equals('France'));
        expect(tournament.totalGoals, equals(169));
        expect(tournament.goldenBall, equals('Luka Modric'));
        expect(tournament.bestYoungPlayer, equals('Kylian Mbappe'));
        expect(tournament.highlights, hasLength(2));
      });

      test('fromFirestore handles missing optional fields', () {
        final data = {
          'year': 2014,
          'hostCountries': ['Brazil'],
          'hostCodes': ['BRA'],
          'winner': 'Germany',
          'winnerCode': 'GER',
          'runnerUp': 'Argentina',
          'runnerUpCode': 'ARG',
          'thirdPlace': 'Netherlands',
          'thirdPlaceCode': 'NED',
          'fourthPlace': 'Brazil',
          'fourthPlaceCode': 'BRA',
          'totalTeams': 32,
          'totalMatches': 64,
          'totalGoals': 171,
          'topScorer': 'James Rodriguez',
          'topScorerCountry': 'Colombia',
          'topScorerGoals': 6,
          'finalScore': '1-0 (aet)',
          'finalVenue': 'Maracana',
          'finalCity': 'Rio de Janeiro',
          'finalAttendance': 74738,
          'highlights': [],
        };

        final tournament = WorldCupTournament.fromFirestore(data);

        expect(tournament.goldenBall, isNull);
        expect(tournament.goldenBallCountry, isNull);
        expect(tournament.bestYoungPlayer, isNull);
        expect(tournament.bestYoungPlayerCountry, isNull);
        expect(tournament.goldenGlove, isNull);
        expect(tournament.goldenGloveCountry, isNull);
        expect(tournament.highlights, isEmpty);
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestTournament(
          goldenBall: 'Lionel Messi',
          bestYoungPlayer: 'Enzo Fernandez',
          goldenGlove: 'Emiliano Martinez',
        );
        final data = original.toFirestore();
        final restored = WorldCupTournament.fromFirestore(data);

        expect(restored.year, equals(original.year));
        expect(restored.winner, equals(original.winner));
        expect(restored.winnerCode, equals(original.winnerCode));
        expect(restored.totalGoals, equals(original.totalGoals));
        expect(restored.goldenBall, equals(original.goldenBall));
        expect(restored.bestYoungPlayer, equals(original.bestYoungPlayer));
        expect(restored.goldenGlove, equals(original.goldenGlove));
      });
    });

    group('Equatable', () {
      test('two tournaments with same props are equal', () {
        final tournament1 = createTestTournament();
        final tournament2 = createTestTournament();

        expect(tournament1, equals(tournament2));
      });

      test('two tournaments with different years are not equal', () {
        final tournament1 = createTestTournament(year: 2022);
        final tournament2 = createTestTournament(year: 2018);

        expect(tournament1, isNot(equals(tournament2)));
      });

      test('two tournaments with different winners are not equal', () {
        final tournament1 = createTestTournament(winner: 'Argentina', winnerCode: 'ARG');
        final tournament2 = createTestTournament(winner: 'France', winnerCode: 'FRA');

        expect(tournament1, isNot(equals(tournament2)));
      });

      test('props contains expected fields', () {
        final tournament = createTestTournament();
        expect(tournament.props, hasLength(3));
        expect(tournament.props, contains(tournament.year));
        expect(tournament.props, contains(tournament.winner));
        expect(tournament.props, contains(tournament.winnerCode));
      });
    });
  });

  group('WorldCupRecord', () {
    WorldCupRecord createTestRecord({
      String id = 'record_1',
      String category = 'Most Goals',
      String record = 'Most goals in a single tournament',
      String holder = 'Just Fontaine',
      String holderType = 'player',
      dynamic value = 13,
      String? details,
    }) {
      return WorldCupRecord(
        id: id,
        category: category,
        record: record,
        holder: holder,
        holderType: holderType,
        value: value,
        details: details,
      );
    }

    group('Constructor', () {
      test('creates record with required fields', () {
        final record = createTestRecord();

        expect(record.id, equals('record_1'));
        expect(record.category, equals('Most Goals'));
        expect(record.record, equals('Most goals in a single tournament'));
        expect(record.holder, equals('Just Fontaine'));
        expect(record.holderType, equals('player'));
        expect(record.value, equals(13));
      });

      test('creates record with optional details', () {
        final record = createTestRecord(
          details: '1958 World Cup in Sweden',
        );

        expect(record.details, equals('1958 World Cup in Sweden'));
      });

      test('creates record with different holder types', () {
        final playerRecord = createTestRecord(holderType: 'player');
        final teamRecord = createTestRecord(holderType: 'team', holder: 'Brazil');
        final matchRecord = createTestRecord(holderType: 'match');

        expect(playerRecord.holderType, equals('player'));
        expect(teamRecord.holderType, equals('team'));
        expect(matchRecord.holderType, equals('match'));
      });

      test('creates record with different value types', () {
        final intRecord = createTestRecord(value: 13);
        final doubleRecord = createTestRecord(value: 2.68);
        final stringRecord = createTestRecord(value: '3-3 (4-2 pen)');

        expect(intRecord.value, isA<int>());
        expect(doubleRecord.value, isA<double>());
        expect(stringRecord.value, isA<String>());
      });
    });

    group('formattedValue getter', () {
      test('formats int values correctly', () {
        final record = createTestRecord(value: 16);
        expect(record.formattedValue, equals('16'));
      });

      test('formats double values correctly', () {
        final record = createTestRecord(value: 2.68);
        expect(record.formattedValue, equals('2.68'));
      });

      test('formats string values correctly', () {
        final record = createTestRecord(value: 'test value');
        expect(record.formattedValue, equals('test value'));
      });

      test('formats very precise double values', () {
        final record = createTestRecord(value: 3.14159);
        expect(record.formattedValue, equals('3.14'));
      });
    });

    group('Firestore serialization', () {
      test('toFirestore serializes all fields', () {
        final record = createTestRecord(
          details: '1958 World Cup in Sweden',
        );
        final data = record.toFirestore();

        expect(data['category'], equals('Most Goals'));
        expect(data['record'], equals('Most goals in a single tournament'));
        expect(data['holder'], equals('Just Fontaine'));
        expect(data['holderType'], equals('player'));
        expect(data['value'], equals(13));
        expect(data['details'], equals('1958 World Cup in Sweden'));
      });

      test('fromFirestore deserializes correctly', () {
        final data = {
          'category': 'Most Appearances',
          'record': 'Most World Cup appearances',
          'holder': 'Lionel Messi',
          'holderType': 'player',
          'value': 26,
          'details': 'Across 5 tournaments (2006-2022)',
        };

        final record = WorldCupRecord.fromFirestore(data, 'messi_appearances');

        expect(record.id, equals('messi_appearances'));
        expect(record.category, equals('Most Appearances'));
        expect(record.holder, equals('Lionel Messi'));
        expect(record.value, equals(26));
        expect(record.details, equals('Across 5 tournaments (2006-2022)'));
      });

      test('fromFirestore handles missing details', () {
        final data = {
          'category': 'Most Goals',
          'record': 'Most goals overall',
          'holder': 'Miroslav Klose',
          'holderType': 'player',
          'value': 16,
        };

        final record = WorldCupRecord.fromFirestore(data, 'klose_goals');

        expect(record.details, isNull);
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestRecord(
          id: 'brazil_titles',
          category: 'Most Titles',
          record: 'Most World Cup titles',
          holder: 'Brazil',
          holderType: 'team',
          value: 5,
          details: 'Won in 1958, 1962, 1970, 1994, 2002',
        );
        final data = original.toFirestore();
        final restored = WorldCupRecord.fromFirestore(data, original.id);

        expect(restored.id, equals(original.id));
        expect(restored.category, equals(original.category));
        expect(restored.record, equals(original.record));
        expect(restored.holder, equals(original.holder));
        expect(restored.holderType, equals(original.holderType));
        expect(restored.value, equals(original.value));
        expect(restored.details, equals(original.details));
      });
    });

    group('Equatable', () {
      test('two records with same props are equal', () {
        final record1 = createTestRecord();
        final record2 = createTestRecord();

        expect(record1, equals(record2));
      });

      test('two records with different ids are not equal', () {
        final record1 = createTestRecord(id: 'record_1');
        final record2 = createTestRecord(id: 'record_2');

        expect(record1, isNot(equals(record2)));
      });

      test('two records with different categories are not equal', () {
        final record1 = createTestRecord(category: 'Most Goals');
        final record2 = createTestRecord(category: 'Most Appearances');

        expect(record1, isNot(equals(record2)));
      });

      test('props contains expected fields', () {
        final record = createTestRecord();
        expect(record.props, hasLength(3));
        expect(record.props, contains(record.id));
        expect(record.props, contains(record.category));
        expect(record.props, contains(record.holder));
      });
    });
  });

  group('TeamWorldCupHistory', () {
    TeamWorldCupHistory createTestHistory({
      String teamCode = 'BRA',
      String teamName = 'Brazil',
      int totalAppearances = 22,
      int titlesWon = 5,
      List<int> titleYears = const [1958, 1962, 1970, 1994, 2002],
      String bestFinish = 'Winner',
      int? bestFinishYear = 2002,
      int totalMatches = 114,
      int totalWins = 76,
      int totalDraws = 18,
      int totalLosses = 20,
      int totalGoalsFor = 237,
      int totalGoalsAgainst = 106,
      List<int> appearanceYears = const [1930, 1934, 1938],
    }) {
      return TeamWorldCupHistory(
        teamCode: teamCode,
        teamName: teamName,
        totalAppearances: totalAppearances,
        titlesWon: titlesWon,
        titleYears: titleYears,
        bestFinish: bestFinish,
        bestFinishYear: bestFinishYear,
        totalMatches: totalMatches,
        totalWins: totalWins,
        totalDraws: totalDraws,
        totalLosses: totalLosses,
        totalGoalsFor: totalGoalsFor,
        totalGoalsAgainst: totalGoalsAgainst,
        appearanceYears: appearanceYears,
      );
    }

    group('Constructor', () {
      test('creates history with all fields', () {
        final history = createTestHistory();

        expect(history.teamCode, equals('BRA'));
        expect(history.teamName, equals('Brazil'));
        expect(history.totalAppearances, equals(22));
        expect(history.titlesWon, equals(5));
        expect(history.titleYears, hasLength(5));
        expect(history.bestFinish, equals('Winner'));
        expect(history.totalMatches, equals(114));
        expect(history.totalWins, equals(76));
      });

      test('creates history with no titles', () {
        final history = createTestHistory(
          teamCode: 'NED',
          teamName: 'Netherlands',
          titlesWon: 0,
          titleYears: [],
          bestFinish: 'Runner-up',
        );

        expect(history.titlesWon, equals(0));
        expect(history.titleYears, isEmpty);
        expect(history.bestFinish, equals('Runner-up'));
      });

      test('creates history with optional bestFinishYear null', () {
        final history = createTestHistory(
          bestFinishYear: null,
        );

        expect(history.bestFinishYear, isNull);
      });
    });

    group('Computed getters', () {
      test('winPercentage calculates correctly', () {
        final history = createTestHistory(
          totalMatches: 100,
          totalWins: 75,
        );
        expect(history.winPercentage, closeTo(75.0, 0.01));
      });

      test('winPercentage returns 0 when no matches', () {
        final history = createTestHistory(
          totalMatches: 0,
          totalWins: 0,
        );
        expect(history.winPercentage, equals(0));
      });

      test('goalDifference calculates correctly', () {
        final positiveGD = createTestHistory(
          totalGoalsFor: 237,
          totalGoalsAgainst: 106,
        );
        expect(positiveGD.goalDifference, equals(131));

        final negativeGD = createTestHistory(
          totalGoalsFor: 50,
          totalGoalsAgainst: 75,
        );
        expect(negativeGD.goalDifference, equals(-25));

        final evenGD = createTestHistory(
          totalGoalsFor: 100,
          totalGoalsAgainst: 100,
        );
        expect(evenGD.goalDifference, equals(0));
      });

      test('totalPoints calculates correctly', () {
        final history = createTestHistory(
          totalWins: 76,
          totalDraws: 18,
        );
        expect(history.totalPoints, equals((76 * 3) + 18));
        expect(history.totalPoints, equals(246));
      });

      test('totalPoints with no wins or draws', () {
        final history = createTestHistory(
          totalWins: 0,
          totalDraws: 0,
        );
        expect(history.totalPoints, equals(0));
      });
    });

    group('Firestore serialization', () {
      test('toFirestore serializes all fields', () {
        final history = createTestHistory();
        final data = history.toFirestore();

        expect(data['teamName'], equals('Brazil'));
        expect(data['totalAppearances'], equals(22));
        expect(data['titlesWon'], equals(5));
        expect(data['titleYears'], equals([1958, 1962, 1970, 1994, 2002]));
        expect(data['bestFinish'], equals('Winner'));
        expect(data['bestFinishYear'], equals(2002));
        expect(data['totalMatches'], equals(114));
        expect(data['totalWins'], equals(76));
        expect(data['totalDraws'], equals(18));
        expect(data['totalLosses'], equals(20));
        expect(data['totalGoalsFor'], equals(237));
        expect(data['totalGoalsAgainst'], equals(106));
      });

      test('fromFirestore deserializes correctly', () {
        final data = {
          'teamName': 'Germany',
          'totalAppearances': 20,
          'titlesWon': 4,
          'titleYears': [1954, 1974, 1990, 2014],
          'bestFinish': 'Winner',
          'bestFinishYear': 2014,
          'totalMatches': 109,
          'totalWins': 67,
          'totalDraws': 21,
          'totalLosses': 21,
          'totalGoalsFor': 229,
          'totalGoalsAgainst': 126,
          'appearanceYears': [1934, 1938, 1954],
        };

        final history = TeamWorldCupHistory.fromFirestore(data, 'GER');

        expect(history.teamCode, equals('GER'));
        expect(history.teamName, equals('Germany'));
        expect(history.titlesWon, equals(4));
        expect(history.titleYears, hasLength(4));
        expect(history.totalMatches, equals(109));
      });

      test('fromFirestore handles missing optional fields', () {
        final data = {
          'teamName': 'Iceland',
          'totalAppearances': 1,
          'titlesWon': 0,
          'titleYears': [],
          'bestFinish': 'Group Stage',
          'totalMatches': 3,
          'totalWins': 0,
          'totalDraws': 1,
          'totalLosses': 2,
          'totalGoalsFor': 2,
          'totalGoalsAgainst': 5,
          'appearanceYears': [2018],
        };

        final history = TeamWorldCupHistory.fromFirestore(data, 'ISL');

        expect(history.bestFinishYear, isNull);
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestHistory(
          teamCode: 'ARG',
          teamName: 'Argentina',
          titlesWon: 3,
          titleYears: [1978, 1986, 2022],
        );
        final data = original.toFirestore();
        final restored = TeamWorldCupHistory.fromFirestore(data, 'ARG');

        expect(restored.teamCode, equals(original.teamCode));
        expect(restored.teamName, equals(original.teamName));
        expect(restored.totalAppearances, equals(original.totalAppearances));
        expect(restored.titlesWon, equals(original.titlesWon));
        expect(restored.titleYears, equals(original.titleYears));
        expect(restored.totalMatches, equals(original.totalMatches));
        expect(restored.goalDifference, equals(original.goalDifference));
      });
    });

    group('Equatable', () {
      test('two histories with same props are equal', () {
        final history1 = createTestHistory();
        final history2 = createTestHistory();

        expect(history1, equals(history2));
      });

      test('two histories with different teamCodes are not equal', () {
        final history1 = createTestHistory(teamCode: 'BRA');
        final history2 = createTestHistory(teamCode: 'ARG');

        expect(history1, isNot(equals(history2)));
      });

      test('two histories with different appearances are not equal', () {
        final history1 = createTestHistory(totalAppearances: 22);
        final history2 = createTestHistory(totalAppearances: 18);

        expect(history1, isNot(equals(history2)));
      });

      test('props contains expected fields', () {
        final history = createTestHistory();
        expect(history.props, hasLength(3));
        expect(history.props, contains(history.teamCode));
        expect(history.props, contains(history.totalAppearances));
        expect(history.props, contains(history.titlesWon));
      });
    });
  });
}
