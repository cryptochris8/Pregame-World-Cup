import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/head_to_head.dart';

void main() {
  group('HistoricalMatch', () {
    HistoricalMatch createTestMatch({
      int year = 2022,
      String tournament = 'World Cup',
      String? stage,
      int team1Score = 2,
      int team2Score = 1,
      String? winnerCode,
      String? location,
      String? description,
    }) {
      return HistoricalMatch(
        year: year,
        tournament: tournament,
        stage: stage,
        team1Score: team1Score,
        team2Score: team2Score,
        winnerCode: winnerCode,
        location: location,
        description: description,
      );
    }

    group('Constructor', () {
      test('creates match with required fields', () {
        final match = createTestMatch();

        expect(match.year, equals(2022));
        expect(match.tournament, equals('World Cup'));
        expect(match.team1Score, equals(2));
        expect(match.team2Score, equals(1));
      });

      test('creates match with all fields', () {
        final match = createTestMatch(
          stage: 'Final',
          winnerCode: 'ARG',
          location: 'Lusail Stadium',
          description: 'Messi wins his first World Cup',
        );

        expect(match.stage, equals('Final'));
        expect(match.winnerCode, equals('ARG'));
        expect(match.location, equals('Lusail Stadium'));
        expect(match.description, contains('Messi'));
      });
    });

    group('Computed getters', () {
      test('scoreDisplay returns correct format', () {
        final match = createTestMatch(team1Score: 3, team2Score: 2);
        expect(match.scoreDisplay, equals('3-2'));
      });

      test('isDraw returns true for draw', () {
        final draw = createTestMatch(team1Score: 1, team2Score: 1);
        final notDraw = createTestMatch(team1Score: 2, team2Score: 1);

        expect(draw.isDraw, isTrue);
        expect(notDraw.isDraw, isFalse);
      });
    });

    group('Map serialization', () {
      test('toMap serializes all fields', () {
        final match = createTestMatch(
          stage: 'Semi-Final',
          winnerCode: 'BRA',
          location: 'Doha',
          description: 'Classic match',
        );
        final map = match.toMap();

        expect(map['year'], equals(2022));
        expect(map['tournament'], equals('World Cup'));
        expect(map['stage'], equals('Semi-Final'));
        expect(map['team1Score'], equals(2));
        expect(map['team2Score'], equals(1));
        expect(map['winnerCode'], equals('BRA'));
        expect(map['location'], equals('Doha'));
        expect(map['description'], equals('Classic match'));
      });

      test('fromMap deserializes correctly', () {
        final map = {
          'year': 2018,
          'tournament': 'World Cup',
          'stage': 'Final',
          'team1Score': 4,
          'team2Score': 2,
          'winnerCode': 'FRA',
          'location': 'Moscow',
        };

        final match = HistoricalMatch.fromMap(map);

        expect(match.year, equals(2018));
        expect(match.tournament, equals('World Cup'));
        expect(match.stage, equals('Final'));
        expect(match.team1Score, equals(4));
        expect(match.team2Score, equals(2));
        expect(match.winnerCode, equals('FRA'));
        expect(match.location, equals('Moscow'));
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestMatch(
          year: 2014,
          tournament: 'World Cup',
          stage: 'Semi-Final',
          team1Score: 7,
          team2Score: 1,
          winnerCode: 'GER',
        );
        final map = original.toMap();
        final restored = HistoricalMatch.fromMap(map);

        expect(restored.year, equals(original.year));
        expect(restored.team1Score, equals(original.team1Score));
        expect(restored.team2Score, equals(original.team2Score));
        expect(restored.winnerCode, equals(original.winnerCode));
      });
    });

    group('Equatable', () {
      test('two matches with same props are equal', () {
        final match1 = createTestMatch();
        final match2 = createTestMatch();

        expect(match1, equals(match2));
      });

      test('two matches with different year are not equal', () {
        final match1 = createTestMatch(year: 2022);
        final match2 = createTestMatch(year: 2018);

        expect(match1, isNot(equals(match2)));
      });
    });
  });

  group('HeadToHead', () {
    HeadToHead createTestH2H({
      String team1Code = 'ARG',
      String team2Code = 'BRA',
      int totalMatches = 100,
      int team1Wins = 40,
      int team2Wins = 35,
      int draws = 25,
      int team1Goals = 150,
      int team2Goals = 140,
      int worldCupMatches = 10,
      int team1WorldCupWins = 4,
      int team2WorldCupWins = 3,
      int worldCupDraws = 3,
      List<HistoricalMatch>? notableMatches,
      DateTime? lastMatch,
      DateTime? firstMeeting,
    }) {
      return HeadToHead(
        team1Code: team1Code,
        team2Code: team2Code,
        totalMatches: totalMatches,
        team1Wins: team1Wins,
        team2Wins: team2Wins,
        draws: draws,
        team1Goals: team1Goals,
        team2Goals: team2Goals,
        worldCupMatches: worldCupMatches,
        team1WorldCupWins: team1WorldCupWins,
        team2WorldCupWins: team2WorldCupWins,
        worldCupDraws: worldCupDraws,
        notableMatches: notableMatches ?? const [],
        lastMatch: lastMatch,
        firstMeeting: firstMeeting,
      );
    }

    group('Constructor', () {
      test('creates h2h with required fields', () {
        final h2h = createTestH2H();

        expect(h2h.team1Code, equals('ARG'));
        expect(h2h.team2Code, equals('BRA'));
        expect(h2h.totalMatches, equals(100));
        expect(h2h.team1Wins, equals(40));
        expect(h2h.team2Wins, equals(35));
        expect(h2h.draws, equals(25));
      });

      test('creates h2h with defaults', () {
        const h2h = HeadToHead(
          team1Code: 'USA',
          team2Code: 'MEX',
          totalMatches: 50,
          team1Wins: 20,
          team2Wins: 25,
          draws: 5,
        );

        expect(h2h.team1Goals, equals(0));
        expect(h2h.team2Goals, equals(0));
        expect(h2h.worldCupMatches, equals(0));
        expect(h2h.notableMatches, isEmpty);
      });

      test('creates h2h with notable matches', () {
        final matches = [
          HistoricalMatch(year: 2022, tournament: 'World Cup', team1Score: 3, team2Score: 3),
          HistoricalMatch(year: 1986, tournament: 'World Cup', team1Score: 2, team2Score: 1),
        ];
        final h2h = createTestH2H(notableMatches: matches);

        expect(h2h.notableMatches, hasLength(2));
      });
    });

    group('Computed getters', () {
      test('id returns sorted pair', () {
        final h2h1 = createTestH2H(team1Code: 'ARG', team2Code: 'BRA');
        final h2h2 = createTestH2H(team1Code: 'BRA', team2Code: 'ARG');

        expect(h2h1.id, equals('ARG_BRA'));
        expect(h2h2.id, equals('ARG_BRA'));
      });

      test('dominantTeam returns team with more wins', () {
        final team1Dominant = createTestH2H(team1Wins: 50, team2Wins: 30);
        final team2Dominant = createTestH2H(team1Wins: 30, team2Wins: 50);
        final tied = createTestH2H(team1Wins: 40, team2Wins: 40);

        expect(team1Dominant.dominantTeam, equals('ARG'));
        expect(team2Dominant.dominantTeam, equals('BRA'));
        expect(tied.dominantTeam, isNull);
      });

      test('win percentages calculate correctly', () {
        final h2h = createTestH2H(
          totalMatches: 100,
          team1Wins: 40,
          team2Wins: 35,
          draws: 25,
        );

        expect(h2h.team1WinPercentage, equals(40.0));
        expect(h2h.team2WinPercentage, equals(35.0));
        expect(h2h.drawPercentage, equals(25.0));
      });

      test('win percentages return 0 for no matches', () {
        final h2h = createTestH2H(
          totalMatches: 0,
          team1Wins: 0,
          team2Wins: 0,
          draws: 0,
        );

        expect(h2h.team1WinPercentage, equals(0.0));
        expect(h2h.team2WinPercentage, equals(0.0));
        expect(h2h.drawPercentage, equals(0.0));
      });
    });

    group('getSummary', () {
      test('returns team1 leads when team1 has more wins', () {
        final h2h = createTestH2H(team1Wins: 50, team2Wins: 30, draws: 20);
        final summary = h2h.getSummary('Argentina', 'Brazil');

        expect(summary, equals('Argentina leads 50-30-20'));
      });

      test('returns team2 leads when team2 has more wins', () {
        final h2h = createTestH2H(team1Wins: 30, team2Wins: 50, draws: 20);
        final summary = h2h.getSummary('Argentina', 'Brazil');

        expect(summary, equals('Brazil leads 50-30-20'));
      });

      test('returns series tied when equal wins', () {
        final h2h = createTestH2H(team1Wins: 40, team2Wins: 40, draws: 20);
        final summary = h2h.getSummary('Argentina', 'Brazil');

        expect(summary, equals('Series tied 40-40-20'));
      });
    });

    group('getWorldCupSummary', () {
      test('returns no meetings when 0 World Cup matches', () {
        final h2h = createTestH2H(worldCupMatches: 0);
        expect(h2h.getWorldCupSummary('Argentina', 'Brazil'),
            equals('No World Cup meetings'));
      });

      test('returns team1 leads in World Cups', () {
        final h2h = createTestH2H(
          worldCupMatches: 10,
          team1WorldCupWins: 5,
          team2WorldCupWins: 3,
          worldCupDraws: 2,
        );
        expect(h2h.getWorldCupSummary('Argentina', 'Brazil'),
            equals('Argentina leads 5-3-2 in World Cups'));
      });

      test('returns team2 leads in World Cups', () {
        final h2h = createTestH2H(
          worldCupMatches: 10,
          team1WorldCupWins: 2,
          team2WorldCupWins: 6,
          worldCupDraws: 2,
        );
        expect(h2h.getWorldCupSummary('Argentina', 'Brazil'),
            equals('Brazil leads 6-2-2 in World Cups'));
      });

      test('returns tied in World Cups', () {
        final h2h = createTestH2H(
          worldCupMatches: 10,
          team1WorldCupWins: 4,
          team2WorldCupWins: 4,
          worldCupDraws: 2,
        );
        expect(h2h.getWorldCupSummary('Argentina', 'Brazil'),
            equals('Tied 4-4-2 in World Cups'));
      });
    });

    group('Map serialization', () {
      test('toMap serializes all fields', () {
        final h2h = createTestH2H(
          notableMatches: [
            HistoricalMatch(year: 2022, tournament: 'World Cup', team1Score: 3, team2Score: 3),
          ],
          lastMatch: DateTime(2022, 12, 9),
          firstMeeting: DateTime(1914, 7, 20),
        );
        final map = h2h.toMap();

        expect(map['team1Code'], equals('ARG'));
        expect(map['team2Code'], equals('BRA'));
        expect(map['totalMatches'], equals(100));
        expect(map['team1Wins'], equals(40));
        expect(map['team2Wins'], equals(35));
        expect(map['draws'], equals(25));
        expect(map['team1Goals'], equals(150));
        expect(map['team2Goals'], equals(140));
        expect(map['worldCupMatches'], equals(10));
        expect(map['notableMatches'], hasLength(1));
        expect(map['lastMatch'], isNotNull);
        expect(map['firstMeeting'], isNotNull);
      });

      test('fromMap deserializes correctly', () {
        final map = {
          'team1Code': 'GER',
          'team2Code': 'FRA',
          'totalMatches': 50,
          'team1Wins': 20,
          'team2Wins': 18,
          'draws': 12,
          'team1Goals': 80,
          'team2Goals': 75,
          'worldCupMatches': 5,
          'team1WorldCupWins': 2,
          'team2WorldCupWins': 2,
          'worldCupDraws': 1,
          'notableMatches': [
            {'year': 2014, 'tournament': 'World Cup', 'stage': 'Quarter-Final', 'team1Score': 1, 'team2Score': 0},
          ],
          'lastMatch': '2022-09-12T00:00:00.000',
        };

        final h2h = HeadToHead.fromMap(map);

        expect(h2h.team1Code, equals('GER'));
        expect(h2h.team2Code, equals('FRA'));
        expect(h2h.totalMatches, equals(50));
        expect(h2h.team1Wins, equals(20));
        expect(h2h.worldCupMatches, equals(5));
        expect(h2h.notableMatches, hasLength(1));
        expect(h2h.notableMatches.first.year, equals(2014));
        expect(h2h.lastMatch, isNotNull);
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestH2H(
          notableMatches: [
            HistoricalMatch(year: 1990, tournament: 'World Cup', team1Score: 1, team2Score: 0),
          ],
          lastMatch: DateTime(2022, 1, 1),
          firstMeeting: DateTime(1950, 6, 25),
        );
        final map = original.toMap();
        final restored = HeadToHead.fromMap(map);

        expect(restored.team1Code, equals(original.team1Code));
        expect(restored.team2Code, equals(original.team2Code));
        expect(restored.totalMatches, equals(original.totalMatches));
        expect(restored.notableMatches.length, equals(original.notableMatches.length));
        expect(restored.lastMatch, equals(original.lastMatch));
        expect(restored.firstMeeting, equals(original.firstMeeting));
      });

      test('fromMap handles missing optional fields', () {
        final map = {
          'team1Code': 'USA',
          'team2Code': 'MEX',
          'totalMatches': 70,
          'team1Wins': 20,
          'team2Wins': 35,
          'draws': 15,
        };

        final h2h = HeadToHead.fromMap(map);

        expect(h2h.team1Goals, equals(0));
        expect(h2h.worldCupMatches, equals(0));
        expect(h2h.notableMatches, isEmpty);
        expect(h2h.lastMatch, isNull);
        expect(h2h.firstMeeting, isNull);
      });
    });

    group('Equatable', () {
      test('two h2h with same props are equal', () {
        final h2h1 = createTestH2H();
        final h2h2 = createTestH2H();

        expect(h2h1, equals(h2h2));
      });

      test('two h2h with different team codes are not equal', () {
        final h2h1 = createTestH2H(team1Code: 'ARG', team2Code: 'BRA');
        final h2h2 = createTestH2H(team1Code: 'GER', team2Code: 'FRA');

        expect(h2h1, isNot(equals(h2h2)));
      });
    });
  });
}
