import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/ai/services/team_season_stats_generator.dart';

void main() {
  group('TeamSeasonStatsGenerator', () {
    group('getBowlName', () {
      test('returns World Cup Final / Semi-Final for 11+ wins', () {
        expect(
          TeamSeasonStatsGenerator.getBowlName(11, 2),
          equals('World Cup Final / Semi-Final'),
        );
        expect(
          TeamSeasonStatsGenerator.getBowlName(13, 0),
          equals('World Cup Final / Semi-Final'),
        );
      });

      test('returns World Cup Quarter-Final for 9-10 wins', () {
        expect(
          TeamSeasonStatsGenerator.getBowlName(9, 3),
          equals('World Cup Quarter-Final'),
        );
        expect(
          TeamSeasonStatsGenerator.getBowlName(10, 2),
          equals('World Cup Quarter-Final'),
        );
      });

      test('returns World Cup Round of 16 for 7-8 wins', () {
        expect(
          TeamSeasonStatsGenerator.getBowlName(7, 5),
          equals('World Cup Round of 16'),
        );
        expect(
          TeamSeasonStatsGenerator.getBowlName(8, 4),
          equals('World Cup Round of 16'),
        );
      });

      test('returns World Cup Group Stage for fewer than 7 wins', () {
        expect(
          TeamSeasonStatsGenerator.getBowlName(6, 6),
          equals('World Cup Group Stage'),
        );
        expect(
          TeamSeasonStatsGenerator.getBowlName(0, 3),
          equals('World Cup Group Stage'),
        );
        expect(
          TeamSeasonStatsGenerator.getBowlName(3, 3),
          equals('World Cup Group Stage'),
        );
      });

      test('boundary at 11 wins', () {
        expect(
          TeamSeasonStatsGenerator.getBowlName(10, 2),
          isNot(equals('World Cup Final / Semi-Final')),
        );
        expect(
          TeamSeasonStatsGenerator.getBowlName(11, 2),
          equals('World Cup Final / Semi-Final'),
        );
      });

      test('losses parameter does not affect result', () {
        // The method only uses wins for its logic
        expect(
          TeamSeasonStatsGenerator.getBowlName(11, 0),
          equals(TeamSeasonStatsGenerator.getBowlName(11, 10)),
        );
      });
    });

    group('getSeasonOutcome', () {
      test('returns Tournament Champions for 12+ wins', () {
        expect(
          TeamSeasonStatsGenerator.getSeasonOutcome(12, 1, ''),
          equals('Tournament Champions'),
        );
        expect(
          TeamSeasonStatsGenerator.getSeasonOutcome(14, 0, ''),
          equals('Tournament Champions'),
        );
      });

      test('returns Deep Tournament Run for 10-11 wins', () {
        expect(
          TeamSeasonStatsGenerator.getSeasonOutcome(10, 2, ''),
          equals('Deep Tournament Run'),
        );
        expect(
          TeamSeasonStatsGenerator.getSeasonOutcome(11, 2, ''),
          equals('Deep Tournament Run'),
        );
      });

      test('returns Successful Campaign for 8-9 wins', () {
        expect(
          TeamSeasonStatsGenerator.getSeasonOutcome(8, 4, ''),
          equals('Successful Campaign'),
        );
        expect(
          TeamSeasonStatsGenerator.getSeasonOutcome(9, 3, ''),
          equals('Successful Campaign'),
        );
      });

      test('returns Knockout Stage Qualification for 6-7 wins', () {
        expect(
          TeamSeasonStatsGenerator.getSeasonOutcome(6, 6, ''),
          equals('Knockout Stage Qualification'),
        );
        expect(
          TeamSeasonStatsGenerator.getSeasonOutcome(7, 5, ''),
          equals('Knockout Stage Qualification'),
        );
      });

      test('returns Group Stage Campaign for fewer than 6 wins', () {
        expect(
          TeamSeasonStatsGenerator.getSeasonOutcome(5, 7, ''),
          equals('Group Stage Campaign'),
        );
        expect(
          TeamSeasonStatsGenerator.getSeasonOutcome(0, 3, ''),
          equals('Group Stage Campaign'),
        );
      });
    });

    group('generateRivalryAnalysis', () {
      test('returns expected keys', () {
        final analysis = TeamSeasonStatsGenerator.generateRivalryAnalysis(
          'Brazil',
          {'overall': {'wins': 7, 'losses': 3}},
        );
        expect(analysis, contains('rivalryGames'));
        expect(analysis, contains('rivalryRecord'));
        expect(analysis, contains('biggestRivalryWin'));
      });

      test('returns placeholder values', () {
        final analysis = TeamSeasonStatsGenerator.generateRivalryAnalysis(
          'Brazil',
          {'overall': {'wins': 7, 'losses': 3}},
        );
        expect(analysis['rivalryGames'], equals(2));
        expect(analysis['rivalryRecord'], equals('1-1'));
        expect(analysis['biggestRivalryWin'], isA<String>());
        expect(
          (analysis['biggestRivalryWin'] as String).isNotEmpty,
          isTrue,
        );
      });
    });

    group('generateKeyAchievements', () {
      test('includes wins achievement for 8+ wins', () {
        final achievements =
            TeamSeasonStatsGenerator.generateKeyAchievements(
          {
            'overall': {'wins': 9, 'losses': 3},
            'bigWins': ['Win1'],
          },
          {'bowlEligibility': 'Eligible', 'seasonOutcome': 'Successful'},
        );
        expect(
          achievements.any((a) => a.contains('9 wins')),
          isTrue,
        );
      });

      test('does not include wins achievement for fewer than 8 wins', () {
        final achievements =
            TeamSeasonStatsGenerator.generateKeyAchievements(
          {
            'overall': {'wins': 5, 'losses': 7},
            'bigWins': [],
          },
          {'bowlEligibility': 'Not Eligible', 'seasonOutcome': 'Group Stage'},
        );
        expect(
          achievements.any((a) => a.contains('5 wins')),
          isFalse,
        );
      });

      test('includes group stage advancement when eligible', () {
        final achievements =
            TeamSeasonStatsGenerator.generateKeyAchievements(
          {
            'overall': {'wins': 5, 'losses': 7},
            'bigWins': [],
          },
          {'bowlEligibility': 'Eligible - Advanced', 'seasonOutcome': 'Good'},
        );
        expect(
          achievements.any((a) => a.contains('group stage')),
          isTrue,
        );
      });

      test('includes signature victories when big wins exist', () {
        final achievements =
            TeamSeasonStatsGenerator.generateKeyAchievements(
          {
            'overall': {'wins': 5, 'losses': 7},
            'bigWins': ['Win vs France'],
          },
          {'bowlEligibility': 'Not Eligible', 'seasonOutcome': 'Group Stage'},
        );
        expect(
          achievements.any((a) => a.contains('signature victories')),
          isTrue,
        );
      });

      test('returns empty list for minimal stats', () {
        final achievements =
            TeamSeasonStatsGenerator.generateKeyAchievements(
          {
            'overall': {'wins': 2, 'losses': 5},
            'bigWins': [],
          },
          // Note: 'Not Eligible' contains 'Eligible', so use a value
          // that does not contain 'Eligible' at all
          {'bowlEligibility': 'Eliminated', 'seasonOutcome': 'Group Stage'},
        );
        expect(achievements, isEmpty);
      });
    });

    group('generateImprovementAreas', () {
      test('includes consistency area when more losses than wins', () {
        final areas = TeamSeasonStatsGenerator.generateImprovementAreas({
          'overall': {'wins': 3, 'losses': 5},
          'scoring': {'averageAllowed': 1.5, 'averageScored': 1.2},
        });
        expect(
          areas.any((a) => a.contains('Consistency')),
          isTrue,
        );
      });

      test('does not include consistency when more wins than losses', () {
        final areas = TeamSeasonStatsGenerator.generateImprovementAreas({
          'overall': {'wins': 7, 'losses': 3},
          'scoring': {'averageAllowed': 1.0, 'averageScored': 2.0},
        });
        expect(
          areas.any((a) => a.contains('Consistency')),
          isFalse,
        );
      });

      test('includes defensive area when conceding more than scoring', () {
        final areas = TeamSeasonStatsGenerator.generateImprovementAreas({
          'overall': {'wins': 5, 'losses': 5},
          'scoring': {'averageAllowed': 2.0, 'averageScored': 1.0},
        });
        expect(
          areas.any((a) => a.contains('Defensive')),
          isTrue,
        );
      });

      test('does not include defensive area when scoring more', () {
        final areas = TeamSeasonStatsGenerator.generateImprovementAreas({
          'overall': {'wins': 5, 'losses': 5},
          'scoring': {'averageAllowed': 0.5, 'averageScored': 2.0},
        });
        expect(
          areas.any((a) => a.contains('Defensive')),
          isFalse,
        );
      });

      test('always includes player development area', () {
        final areas = TeamSeasonStatsGenerator.generateImprovementAreas({
          'overall': {'wins': 10, 'losses': 1},
          'scoring': {'averageAllowed': 0.3, 'averageScored': 3.0},
        });
        expect(
          areas.any((a) => a.contains('Player development')),
          isTrue,
        );
      });
    });

    group('generate2025Outlook', () {
      test('returns positive outlook when more wins than losses', () {
        final outlook = TeamSeasonStatsGenerator.generate2025Outlook(
          'Brazil',
          {'overall': {'wins': 7, 'losses': 3}},
        );
        expect(outlook, contains('Strong foundation'));
      });

      test('returns building outlook when more losses than wins', () {
        final outlook = TeamSeasonStatsGenerator.generate2025Outlook(
          'Brazil',
          {'overall': {'wins': 3, 'losses': 7}},
        );
        expect(outlook, contains('Valuable experience'));
      });

      test('returns building outlook when wins equal losses', () {
        // wins > losses is false when equal, so building path
        final outlook = TeamSeasonStatsGenerator.generate2025Outlook(
          'Brazil',
          {'overall': {'wins': 5, 'losses': 5}},
        );
        expect(outlook, contains('Valuable experience'));
      });
    });

    group('generateQuickSummary', () {
      test('formats record correctly', () {
        final summary = TeamSeasonStatsGenerator.generateQuickSummary(
          {'overall': {'wins': 7, 'losses': 3}},
          {
            'bowlEligibility': 'Eligible',
            'seasonOutcome': 'Successful Campaign',
          },
        );
        expect(summary, contains('7-3'));
        expect(summary, contains('Eligible'));
        expect(summary, contains('Successful Campaign'));
      });

      test('includes bullet separator', () {
        final summary = TeamSeasonStatsGenerator.generateQuickSummary(
          {'overall': {'wins': 5, 'losses': 5}},
          {
            'bowlEligibility': 'Not Eligible',
            'seasonOutcome': 'Group Stage',
          },
        );
        // Unicode bullet \u2022
        expect(summary, contains('\u2022'));
      });
    });

    group('generateHighlightStats', () {
      test('returns 4 highlight stats', () {
        final stats = TeamSeasonStatsGenerator.generateHighlightStats(
          {'scoring': {'averageScored': 2.1, 'averageAllowed': 0.8}},
          {
            'bigWins': ['Win1', 'Win2'],
            'closeGames': ['Close1'],
          },
        );
        expect(stats, hasLength(4));
      });

      test('includes goals scored average', () {
        final stats = TeamSeasonStatsGenerator.generateHighlightStats(
          {'scoring': {'averageScored': 2.5, 'averageAllowed': 1.0}},
          {'bigWins': [], 'closeGames': []},
        );
        expect(stats[0], contains('2.5'));
        expect(stats[0], contains('Goals Scored'));
      });

      test('includes goals conceded average', () {
        final stats = TeamSeasonStatsGenerator.generateHighlightStats(
          {'scoring': {'averageScored': 2.5, 'averageAllowed': 1.2}},
          {'bigWins': [], 'closeGames': []},
        );
        expect(stats[1], contains('1.2'));
        expect(stats[1], contains('Goals Conceded'));
      });

      test('includes signature wins count', () {
        final stats = TeamSeasonStatsGenerator.generateHighlightStats(
          {'scoring': {'averageScored': 2.0, 'averageAllowed': 1.0}},
          {
            'bigWins': ['Win1', 'Win2', 'Win3'],
            'closeGames': [],
          },
        );
        expect(stats[2], contains('3'));
        expect(stats[2], contains('Signature Wins'));
      });

      test('includes close matches count', () {
        final stats = TeamSeasonStatsGenerator.generateHighlightStats(
          {'scoring': {'averageScored': 2.0, 'averageAllowed': 1.0}},
          {
            'bigWins': [],
            'closeGames': ['Close1', 'Close2'],
          },
        );
        expect(stats[3], contains('2'));
        expect(stats[3], contains('1 Goal or Less'));
      });
    });

    group('generateStarPlayersAnalysis', () {
      late Map<String, dynamic> seasonRecord;

      setUp(() {
        seasonRecord = {
          'overall': {'wins': 7, 'losses': 3},
        };
      });

      test('returns expected top-level keys', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          seasonRecord,
        );
        expect(analysis, contains('starPlayers'));
        expect(analysis, contains('teamCaptains'));
        expect(analysis, contains('allConferenceCandidates'));
      });

      test('generates exactly 4 star players', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          seasonRecord,
        );
        final players = analysis['starPlayers'] as List;
        expect(players, hasLength(4));
      });

      test('generates one player per position', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          seasonRecord,
        );
        final players = analysis['starPlayers'] as List<Map<String, dynamic>>;
        final positions = players.map((p) => p['position']).toSet();
        expect(positions, containsAll(['Goalkeeper', 'Defender', 'Midfielder', 'Forward']));
      });

      test('each player has required fields', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          seasonRecord,
        );
        final players = analysis['starPlayers'] as List<Map<String, dynamic>>;
        for (final player in players) {
          expect(player, contains('name'));
          expect(player, contains('position'));
          expect(player, contains('age'));
          expect(player, contains('stats'));
          expect(player, contains('highlights'));
          expect(player['name'], isA<String>());
          expect((player['name'] as String).isNotEmpty, isTrue);
          expect(player['age'], isA<int>());
          expect(player['highlights'], isA<List>());
          expect((player['highlights'] as List), hasLength(2));
        }
      });

      test('player ages are between 22 and 35', () {
        // Run multiple times due to randomness
        for (var i = 0; i < 10; i++) {
          final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
            'Team$i',
            seasonRecord,
          );
          final players =
              analysis['starPlayers'] as List<Map<String, dynamic>>;
          for (final player in players) {
            final age = player['age'] as int;
            expect(age, greaterThanOrEqualTo(22));
            expect(age, lessThanOrEqualTo(35));
          }
        }
      });

      test('goalkeeper stats have expected fields', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          seasonRecord,
        );
        final players = analysis['starPlayers'] as List<Map<String, dynamic>>;
        final gk = players.firstWhere((p) => p['position'] == 'Goalkeeper');
        final stats = gk['stats'] as Map<String, dynamic>;
        expect(stats, contains('appearances'));
        expect(stats, contains('saves'));
        expect(stats, contains('cleanSheets'));
        expect(stats, contains('goalsConceded'));
        expect(stats, contains('savePercentage'));
      });

      test('goalkeeper stats are reasonable', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          seasonRecord,
        );
        final players = analysis['starPlayers'] as List<Map<String, dynamic>>;
        final gk = players.firstWhere((p) => p['position'] == 'Goalkeeper');
        final stats = gk['stats'] as Map<String, dynamic>;

        expect(stats['appearances'] as int, greaterThan(0));
        expect(stats['saves'] as int, greaterThan(0));
        expect(stats['cleanSheets'] as int, greaterThanOrEqualTo(0));
        expect(stats['goalsConceded'] as int, greaterThanOrEqualTo(0));
        expect(stats['savePercentage'] as double, greaterThan(0));
        expect(stats['savePercentage'] as double, lessThanOrEqualTo(100));
      });

      test('defender stats have expected fields', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          seasonRecord,
        );
        final players = analysis['starPlayers'] as List<Map<String, dynamic>>;
        final def = players.firstWhere((p) => p['position'] == 'Defender');
        final stats = def['stats'] as Map<String, dynamic>;
        expect(stats, contains('appearances'));
        expect(stats, contains('tackles'));
        expect(stats, contains('interceptions'));
        expect(stats, contains('clearances'));
        expect(stats, contains('aerialDuelsWon'));
      });

      test('defender stats are within expected ranges', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          seasonRecord,
        );
        final players = analysis['starPlayers'] as List<Map<String, dynamic>>;
        final def = players.firstWhere((p) => p['position'] == 'Defender');
        final stats = def['stats'] as Map<String, dynamic>;

        expect(stats['tackles'] as int, greaterThanOrEqualTo(25));
        expect(stats['tackles'] as int, lessThan(56));
        expect(stats['interceptions'] as int, greaterThanOrEqualTo(15));
        expect(stats['interceptions'] as int, lessThan(36));
        expect(stats['clearances'] as int, greaterThanOrEqualTo(30));
        expect(stats['clearances'] as int, lessThan(66));
        expect(stats['aerialDuelsWon'] as int, greaterThanOrEqualTo(20));
        expect(stats['aerialDuelsWon'] as int, lessThan(46));
      });

      test('midfielder stats have expected fields', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          seasonRecord,
        );
        final players = analysis['starPlayers'] as List<Map<String, dynamic>>;
        final mid = players.firstWhere((p) => p['position'] == 'Midfielder');
        final stats = mid['stats'] as Map<String, dynamic>;
        expect(stats, contains('appearances'));
        expect(stats, contains('passesCompleted'));
        expect(stats, contains('keyPasses'));
        expect(stats, contains('assists'));
        expect(stats, contains('distanceCoveredKm'));
      });

      test('midfielder passes are within expected range', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          seasonRecord,
        );
        final players = analysis['starPlayers'] as List<Map<String, dynamic>>;
        final mid = players.firstWhere((p) => p['position'] == 'Midfielder');
        final stats = mid['stats'] as Map<String, dynamic>;

        expect(stats['passesCompleted'] as int, greaterThanOrEqualTo(250));
        expect(stats['passesCompleted'] as int, lessThan(551));
        expect(stats['keyPasses'] as int, greaterThanOrEqualTo(8));
        expect(stats['keyPasses'] as int, lessThan(24));
      });

      test('forward stats have expected fields', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          seasonRecord,
        );
        final players = analysis['starPlayers'] as List<Map<String, dynamic>>;
        final fw = players.firstWhere((p) => p['position'] == 'Forward');
        final stats = fw['stats'] as Map<String, dynamic>;
        expect(stats, contains('appearances'));
        expect(stats, contains('goals'));
        expect(stats, contains('shotsOnTarget'));
        expect(stats, contains('conversionRate'));
        expect(stats, contains('assists'));
      });

      test('forward goals are reasonable for a tournament', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          seasonRecord,
        );
        final players = analysis['starPlayers'] as List<Map<String, dynamic>>;
        final fw = players.firstWhere((p) => p['position'] == 'Forward');
        final stats = fw['stats'] as Map<String, dynamic>;

        // With 7 wins: goals = (4) + random(5), range 4-9
        expect(stats['goals'] as int, greaterThanOrEqualTo(1));
        expect(stats['goals'] as int, lessThanOrEqualTo(9));
        expect(stats['shotsOnTarget'] as int, greaterThan(stats['goals'] as int));
      });

      test('team captains are first 2 players', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          seasonRecord,
        );
        final players = analysis['starPlayers'] as List;
        final captains = analysis['teamCaptains'] as List;
        expect(captains, hasLength(2));
        expect(captains[0], equals(players[0]));
        expect(captains[1], equals(players[1]));
      });

      test('all conference candidates include all players when wins > losses', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          {'overall': {'wins': 7, 'losses': 3}},
        );
        final candidates = analysis['allConferenceCandidates'] as List;
        // When wins > losses, all players pass the where filter
        expect(candidates, hasLength(4));
      });

      test('all conference candidates is empty when losses > wins', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          {'overall': {'wins': 2, 'losses': 5}},
        );
        final candidates = analysis['allConferenceCandidates'] as List;
        expect(candidates, isEmpty);
      });

      test('player name has first and last name', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'Brazil',
          seasonRecord,
        );
        final players = analysis['starPlayers'] as List<Map<String, dynamic>>;
        for (final player in players) {
          final name = player['name'] as String;
          final parts = name.split(' ');
          expect(parts.length, greaterThanOrEqualTo(2),
              reason: 'Player name "$name" should have first and last name');
        }
      });

      test('handles zero wins and losses', () {
        final analysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
          'NewTeam',
          {'overall': {'wins': 0, 'losses': 0}},
        );
        final players = analysis['starPlayers'] as List<Map<String, dynamic>>;
        expect(players, hasLength(4));

        // GK appearances should default to 7 when totalGames is 0
        final gk = players.firstWhere((p) => p['position'] == 'Goalkeeper');
        final gkStats = gk['stats'] as Map<String, dynamic>;
        expect(gkStats['appearances'], equals(7));
      });
    });
  });
}
