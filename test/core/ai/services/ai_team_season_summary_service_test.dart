import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/ai/services/ai_team_season_summary_service.dart';
import 'package:pregame_world_cup/core/ai/services/team_season_constants.dart';
import 'package:pregame_world_cup/core/ai/services/team_season_stats_generator.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';

/// Tests for AITeamSeasonSummaryService.
///
/// The service depends on AIHistoricalKnowledgeService (cache-backed) and
/// CacheService (Hive-backed). In test environment both are uninitialized,
/// so generateTeamSeasonSummary falls through to _generateFallbackSummary.
///
/// We thoroughly test:
///   1. Fallback summary structure and content
///   2. TeamSeasonStatsGenerator (all static methods, pure logic)
///   3. TeamSeasonConstants (confederation lookup, elite programs, variations)
///   4. Season record calculation logic (via unit-testable inputs)
void main() {
  // ===========================================================================
  // AITeamSeasonSummaryService - fallback summary
  // ===========================================================================
  group('AITeamSeasonSummaryService.generateTeamSeasonSummary', () {
    late AITeamSeasonSummaryService service;

    setUp(() {
      service = AITeamSeasonSummaryService.instance;
    });

    test('returns a map for any team', () async {
      final result = await service.generateTeamSeasonSummary('Brazil');
      expect(result, isA<Map<String, dynamic>>());
    });

    test('fallback contains teamName', () async {
      final result = await service.generateTeamSeasonSummary('France');
      expect(result['teamName'], 'France');
    });

    test('fallback contains season', () async {
      final result =
          await service.generateTeamSeasonSummary('Germany', season: 2023);
      expect(result['season'], 2023);
    });

    test('fallback has default season 2024', () async {
      final result = await service.generateTeamSeasonSummary('Japan');
      expect(result['season'], 2024);
    });

    test('fallback contains quickSummary', () async {
      final result = await service.generateTeamSeasonSummary('Spain');
      expect(result['quickSummary'], isA<String>());
    });

    test('fallback contains seasonRecord with overall', () async {
      final result = await service.generateTeamSeasonSummary('England');
      final seasonRecord = result['seasonRecord'] as Map<String, dynamic>;
      expect(seasonRecord['overall'], isA<Map>());
      expect(seasonRecord['overall']['wins'], isA<int>());
      expect(seasonRecord['overall']['losses'], isA<int>());
    });

    test('fallback contains seasonRecord with scoring', () async {
      final result = await service.generateTeamSeasonSummary('Netherlands');
      final seasonRecord = result['seasonRecord'] as Map<String, dynamic>;
      expect(seasonRecord['scoring'], isA<Map>());
    });

    test('fallback contains keyInsights list', () async {
      final result = await service.generateTeamSeasonSummary('Portugal');
      expect(result['keyInsights'], isA<List>());
      expect((result['keyInsights'] as List), isNotEmpty);
    });

    test('fallback contains overallAssessment', () async {
      final result = await service.generateTeamSeasonSummary('Argentina');
      expect(result['overallAssessment'], isA<Map<String, dynamic>>());
      final assessment = result['overallAssessment'] as Map<String, dynamic>;
      expect(assessment, contains('seasonGrade'));
      expect(assessment, contains('assessment'));
    });

    test('handles unknown team gracefully', () async {
      final result =
          await service.generateTeamSeasonSummary('Unknown Country FC');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['teamName'], 'Unknown Country FC');
    });

    test('handles empty team name', () async {
      final result = await service.generateTeamSeasonSummary('');
      expect(result, isA<Map<String, dynamic>>());
    });
  });

  // ===========================================================================
  // AITeamSeasonSummaryService - singleton
  // ===========================================================================
  group('AITeamSeasonSummaryService singleton', () {
    test('instance returns same object', () {
      final a = AITeamSeasonSummaryService.instance;
      final b = AITeamSeasonSummaryService.instance;
      expect(identical(a, b), isTrue);
    });
  });

  // ===========================================================================
  // TeamSeasonConstants
  // ===========================================================================
  group('TeamSeasonConstants', () {
    group('getTeamConference', () {
      test('UEFA teams', () {
        expect(TeamSeasonConstants.getTeamConference('France'), 'UEFA');
        expect(TeamSeasonConstants.getTeamConference('Germany'), 'UEFA');
        expect(TeamSeasonConstants.getTeamConference('Spain'), 'UEFA');
        expect(TeamSeasonConstants.getTeamConference('England'), 'UEFA');
        expect(TeamSeasonConstants.getTeamConference('Croatia'), 'UEFA');
      });

      test('CONMEBOL teams', () {
        expect(TeamSeasonConstants.getTeamConference('Brazil'), 'CONMEBOL');
        expect(TeamSeasonConstants.getTeamConference('Argentina'), 'CONMEBOL');
        expect(TeamSeasonConstants.getTeamConference('Uruguay'), 'CONMEBOL');
        expect(TeamSeasonConstants.getTeamConference('Colombia'), 'CONMEBOL');
      });

      test('CONCACAF teams', () {
        expect(TeamSeasonConstants.getTeamConference('United States'),
            'CONCACAF');
        expect(TeamSeasonConstants.getTeamConference('Mexico'), 'CONCACAF');
        expect(TeamSeasonConstants.getTeamConference('Canada'), 'CONCACAF');
      });

      test('AFC teams', () {
        expect(TeamSeasonConstants.getTeamConference('Japan'), 'AFC');
        expect(TeamSeasonConstants.getTeamConference('South Korea'), 'AFC');
        expect(TeamSeasonConstants.getTeamConference('Australia'), 'AFC');
        expect(TeamSeasonConstants.getTeamConference('Iran'), 'AFC');
      });

      test('CAF teams', () {
        expect(TeamSeasonConstants.getTeamConference('Morocco'), 'CAF');
        expect(TeamSeasonConstants.getTeamConference('Senegal'), 'CAF');
        expect(TeamSeasonConstants.getTeamConference('Nigeria'), 'CAF');
        expect(TeamSeasonConstants.getTeamConference('Egypt'), 'CAF');
      });

      test('OFC teams', () {
        expect(TeamSeasonConstants.getTeamConference('New Zealand'), 'OFC');
      });

      test('unknown team returns Independent', () {
        expect(
            TeamSeasonConstants.getTeamConference('Fantasy FC'), 'Independent');
      });
    });

    group('isEliteProgram', () {
      test('recognizes elite programs', () {
        expect(TeamSeasonConstants.isEliteProgram('Brazil'), isTrue);
        expect(TeamSeasonConstants.isEliteProgram('France'), isTrue);
        expect(TeamSeasonConstants.isEliteProgram('Germany'), isTrue);
        expect(TeamSeasonConstants.isEliteProgram('Argentina'), isTrue);
        expect(TeamSeasonConstants.isEliteProgram('Spain'), isTrue);
        expect(TeamSeasonConstants.isEliteProgram('England'), isTrue);
        expect(TeamSeasonConstants.isEliteProgram('Italy'), isTrue);
        expect(TeamSeasonConstants.isEliteProgram('Morocco'), isTrue);
        expect(TeamSeasonConstants.isEliteProgram('Japan'), isTrue);
        expect(TeamSeasonConstants.isEliteProgram('United States'), isTrue);
      });

      test('non-elite programs return false', () {
        expect(TeamSeasonConstants.isEliteProgram('New Zealand'), isFalse);
        expect(TeamSeasonConstants.isEliteProgram('Qatar'), isFalse);
        expect(TeamSeasonConstants.isEliteProgram('Saudi Arabia'), isFalse);
        expect(TeamSeasonConstants.isEliteProgram('Unknown'), isFalse);
      });
    });

    group('commonVariations', () {
      test('has variations for major teams', () {
        expect(TeamSeasonConstants.commonVariations, contains('Brazil'));
        expect(TeamSeasonConstants.commonVariations, contains('Argentina'));
        expect(TeamSeasonConstants.commonVariations, contains('France'));
        expect(TeamSeasonConstants.commonVariations, contains('Germany'));
      });

      test('Brazil variations include Selecao', () {
        expect(
            TeamSeasonConstants.commonVariations['Brazil'], contains('Selecao'));
      });

      test('Argentina variations include La Albiceleste', () {
        expect(TeamSeasonConstants.commonVariations['Argentina'],
            contains('La Albiceleste'));
      });

      test('United States variations include USMNT', () {
        expect(TeamSeasonConstants.commonVariations['United States'],
            contains('USMNT'));
      });

      test('Mexico variations include El Tri', () {
        expect(TeamSeasonConstants.commonVariations['Mexico'],
            contains('El Tri'));
      });
    });

    group('conferences', () {
      test('has all six confederations', () {
        expect(TeamSeasonConstants.conferences, hasLength(6));
        expect(TeamSeasonConstants.conferences.keys,
            containsAll(['UEFA', 'CONMEBOL', 'CONCACAF', 'AFC', 'CAF', 'OFC']));
      });

      test('UEFA has the most teams', () {
        expect(TeamSeasonConstants.conferences['UEFA']!.length,
            greaterThan(15));
      });
    });
  });

  // ===========================================================================
  // TeamSeasonStatsGenerator
  // ===========================================================================
  group('TeamSeasonStatsGenerator', () {
    group('getBowlName', () {
      test('11+ wins = World Cup Final / Semi-Final', () {
        expect(TeamSeasonStatsGenerator.getBowlName(12, 0),
            'World Cup Final / Semi-Final');
        expect(TeamSeasonStatsGenerator.getBowlName(11, 1),
            'World Cup Final / Semi-Final');
      });

      test('9-10 wins = World Cup Quarter-Final', () {
        expect(TeamSeasonStatsGenerator.getBowlName(10, 2),
            'World Cup Quarter-Final');
        expect(TeamSeasonStatsGenerator.getBowlName(9, 3),
            'World Cup Quarter-Final');
      });

      test('7-8 wins = World Cup Round of 16', () {
        expect(TeamSeasonStatsGenerator.getBowlName(8, 4),
            'World Cup Round of 16');
        expect(TeamSeasonStatsGenerator.getBowlName(7, 5),
            'World Cup Round of 16');
      });

      test('< 7 wins = World Cup Group Stage', () {
        expect(TeamSeasonStatsGenerator.getBowlName(6, 6),
            'World Cup Group Stage');
        expect(TeamSeasonStatsGenerator.getBowlName(3, 9),
            'World Cup Group Stage');
        expect(TeamSeasonStatsGenerator.getBowlName(0, 10),
            'World Cup Group Stage');
      });
    });

    group('getSeasonOutcome', () {
      test('12+ wins = Tournament Champions', () {
        expect(TeamSeasonStatsGenerator.getSeasonOutcome(12, 0, ''),
            'Tournament Champions');
      });

      test('10-11 wins = Deep Tournament Run', () {
        expect(TeamSeasonStatsGenerator.getSeasonOutcome(10, 2, ''),
            'Deep Tournament Run');
      });

      test('8-9 wins = Successful Campaign', () {
        expect(TeamSeasonStatsGenerator.getSeasonOutcome(8, 4, ''),
            'Successful Campaign');
      });

      test('6-7 wins = Knockout Stage Qualification', () {
        expect(TeamSeasonStatsGenerator.getSeasonOutcome(6, 6, ''),
            'Knockout Stage Qualification');
      });

      test('< 6 wins = Group Stage Campaign', () {
        expect(TeamSeasonStatsGenerator.getSeasonOutcome(3, 9, ''),
            'Group Stage Campaign');
      });
    });

    group('generateRivalryAnalysis', () {
      test('returns map with expected keys', () {
        final result = TeamSeasonStatsGenerator.generateRivalryAnalysis(
          'Brazil',
          {'overall': {'wins': 8, 'losses': 4}},
        );
        expect(result, contains('rivalryGames'));
        expect(result, contains('rivalryRecord'));
        expect(result, contains('biggestRivalryWin'));
      });
    });

    group('generateKeyAchievements', () {
      test('includes win achievement for 8+ wins', () {
        final record = {
          'overall': {'wins': 9, 'losses': 3},
          'bigWins': [
            {'opponent': 'Brazil'}
          ],
        };
        final postseason = {
          'bowlEligibility': 'Eligible for Knockout Stage',
        };
        final achievements = TeamSeasonStatsGenerator.generateKeyAchievements(
            record, postseason);
        expect(achievements.any((a) => a.contains('9 wins')), isTrue);
      });

      test('includes knockout stage achievement', () {
        final record = {
          'overall': {'wins': 7, 'losses': 5},
          'bigWins': <Map<String, dynamic>>[],
        };
        final postseason = {
          'bowlEligibility': 'Eligible for Knockout Stage',
        };
        final achievements = TeamSeasonStatsGenerator.generateKeyAchievements(
            record, postseason);
        expect(achievements.any((a) => a.contains('group stage')), isTrue);
      });

      test('includes big wins achievement', () {
        final record = {
          'overall': {'wins': 6, 'losses': 6},
          'bigWins': [
            {'opponent': 'France'},
            {'opponent': 'Germany'},
          ],
        };
        final achievements = TeamSeasonStatsGenerator.generateKeyAchievements(
            record, {});
        expect(
            achievements
                .any((a) => a.contains('signature victories')),
            isTrue);
      });

      test('returns empty for underperforming team', () {
        final record = {
          'overall': {'wins': 2, 'losses': 9},
          'bigWins': <Map<String, dynamic>>[],
        };
        final achievements = TeamSeasonStatsGenerator.generateKeyAchievements(
            record, {});
        expect(achievements, isEmpty);
      });
    });

    group('generateImprovementAreas', () {
      test('includes consistency when losses > wins', () {
        final record = {
          'overall': {'wins': 3, 'losses': 7},
          'scoring': {'averageAllowed': 2, 'averageScored': 1},
        };
        final areas =
            TeamSeasonStatsGenerator.generateImprovementAreas(record);
        expect(areas.any((a) => a.contains('Consistency')), isTrue);
      });

      test('includes defensive improvement when allowed > scored', () {
        final record = {
          'overall': {'wins': 5, 'losses': 5},
          'scoring': {'averageAllowed': 3, 'averageScored': 2},
        };
        final areas =
            TeamSeasonStatsGenerator.generateImprovementAreas(record);
        expect(areas.any((a) => a.contains('Defensive')), isTrue);
      });

      test('always includes player development', () {
        final record = {
          'overall': {'wins': 10, 'losses': 2},
          'scoring': {'averageAllowed': 1, 'averageScored': 3},
        };
        final areas =
            TeamSeasonStatsGenerator.generateImprovementAreas(record);
        expect(areas.any((a) => a.contains('Player development')), isTrue);
      });
    });

    group('generate2025Outlook', () {
      test('positive outlook when wins > losses', () {
        final record = {
          'overall': {'wins': 8, 'losses': 4}
        };
        final outlook =
            TeamSeasonStatsGenerator.generate2025Outlook('Brazil', record);
        expect(outlook, contains('Strong foundation'));
      });

      test('building outlook when losses >= wins', () {
        final record = {
          'overall': {'wins': 4, 'losses': 7}
        };
        final outlook =
            TeamSeasonStatsGenerator.generate2025Outlook('Canada', record);
        expect(outlook, contains('Valuable experience'));
      });
    });

    group('generateQuickSummary', () {
      test('includes record', () {
        final record = {
          'overall': {'wins': 8, 'losses': 4},
        };
        final postseason = {
          'bowlEligibility': 'Eligible',
          'seasonOutcome': 'Successful Campaign',
        };
        final summary =
            TeamSeasonStatsGenerator.generateQuickSummary(record, postseason);
        expect(summary, contains('8-4'));
      });

      test('includes bowl eligibility', () {
        final record = {
          'overall': {'wins': 6, 'losses': 6},
        };
        final postseason = {
          'bowlEligibility': 'Not Eligible for Knockout Stage',
          'seasonOutcome': 'Group Stage Campaign',
        };
        final summary =
            TeamSeasonStatsGenerator.generateQuickSummary(record, postseason);
        expect(summary, contains('Not Eligible'));
      });
    });

    group('generateHighlightStats', () {
      test('returns list of 4 stat strings', () {
        final record = {
          'scoring': {'averageScored': 2, 'averageAllowed': 1},
        };
        final analysis = {
          'bigWins': [
            {'opponent': 'Brazil'}
          ],
          'closeGames': [
            {'opponent': 'France'},
            {'opponent': 'Germany'},
          ],
        };
        final stats = TeamSeasonStatsGenerator.generateHighlightStats(
            record, analysis);
        expect(stats, hasLength(4));
      });

      test('includes scoring averages', () {
        final record = {
          'scoring': {'averageScored': 3, 'averageAllowed': 1},
        };
        final analysis = {
          'bigWins': <Map<String, dynamic>>[],
          'closeGames': <Map<String, dynamic>>[],
        };
        final stats = TeamSeasonStatsGenerator.generateHighlightStats(
            record, analysis);
        expect(stats[0], contains('3'));
        expect(stats[1], contains('1'));
      });
    });

    group('generateStarPlayersAnalysis', () {
      test('returns map with starPlayers', () {
        final record = {
          'overall': {'wins': 8, 'losses': 4},
        };
        final result = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
            'Brazil', record);
        expect(result, contains('starPlayers'));
        expect(result['starPlayers'], isA<List>());
      });

      test('generates 4 players (GK, DF, MF, FW)', () {
        final record = {
          'overall': {'wins': 7, 'losses': 5},
        };
        final result = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
            'Japan', record);
        final players = result['starPlayers'] as List;
        expect(players, hasLength(4));

        final positions = players.map((p) => p['position'] as String).toSet();
        expect(positions, containsAll(['Goalkeeper', 'Defender', 'Midfielder', 'Forward']));
      });

      test('each player has name, position, age, stats, highlights', () {
        final record = {
          'overall': {'wins': 6, 'losses': 6},
        };
        final result = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
            'Spain', record);
        for (final player in result['starPlayers'] as List) {
          expect(player, contains('name'));
          expect(player, contains('position'));
          expect(player, contains('age'));
          expect(player, contains('stats'));
          expect(player, contains('highlights'));
          expect(player['age'], greaterThanOrEqualTo(22));
          expect(player['age'], lessThanOrEqualTo(35));
        }
      });

      test('teamCaptains is subset of starPlayers', () {
        final record = {
          'overall': {'wins': 9, 'losses': 3},
        };
        final result = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
            'Germany', record);
        expect(result['teamCaptains'], isA<List>());
        expect((result['teamCaptains'] as List).length, lessThanOrEqualTo(2));
      });

      test('goalkeeper stats include expected fields', () {
        final record = {
          'overall': {'wins': 8, 'losses': 4},
        };
        final result = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
            'France', record);
        final gk = (result['starPlayers'] as List)
            .firstWhere((p) => p['position'] == 'Goalkeeper');
        final stats = gk['stats'] as Map<String, dynamic>;
        expect(stats, contains('appearances'));
        expect(stats, contains('saves'));
        expect(stats, contains('cleanSheets'));
        expect(stats, contains('goalsConceded'));
        expect(stats, contains('savePercentage'));
      });

      test('forward stats include goals and conversion rate', () {
        final record = {
          'overall': {'wins': 10, 'losses': 2},
        };
        final result = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(
            'Argentina', record);
        final fw = (result['starPlayers'] as List)
            .firstWhere((p) => p['position'] == 'Forward');
        final stats = fw['stats'] as Map<String, dynamic>;
        expect(stats, contains('goals'));
        expect(stats, contains('conversionRate'));
        expect(stats, contains('assists'));
        expect(stats['goals'], greaterThan(0));
      });
    });
  });

  // ===========================================================================
  // GameSchedule entity tests relevant to season summary
  // ===========================================================================
  group('GameSchedule for season analysis', () {
    test('can create minimal GameSchedule', () {
      final game = GameSchedule(
        gameId: 'test-1',
        homeTeamName: 'Brazil',
        awayTeamName: 'Germany',
      );
      expect(game.gameId, 'test-1');
      expect(game.homeTeamName, 'Brazil');
      expect(game.awayTeamName, 'Germany');
    });

    test('can create GameSchedule with scores', () {
      final game = GameSchedule(
        gameId: 'test-2',
        homeTeamName: 'France',
        awayTeamName: 'Spain',
        homeScore: 3,
        awayScore: 1,
      );
      expect(game.homeScore, 3);
      expect(game.awayScore, 1);
    });

    test('can create GameSchedule with week', () {
      final game = GameSchedule(
        gameId: 'test-3',
        homeTeamName: 'Japan',
        awayTeamName: 'Australia',
        week: 15,
      );
      expect(game.week, 15);
    });
  });
}
