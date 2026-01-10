import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/entities/team_statistics.dart';

void main() {
  group('TeamStatistics', () {
    test('creates team statistics with required fields', () {
      final stats = TeamStatistics(
        teamId: 'team_1',
        teamName: 'Georgia Bulldogs',
        offense: const OffensiveStats(
          totalYards: 450.0,
          passingYards: 280.0,
          rushingYards: 170.0,
          pointsPerGame: 35.0,
          thirdDownConversion: 0.45,
          redZoneEfficiency: 0.85,
          yardsPerPlay: 6.5,
          turnoversPerGame: 1.0,
        ),
        defense: const DefensiveStats(
          totalYardsAllowed: 300.0,
          passingYardsAllowed: 180.0,
          rushingYardsAllowed: 120.0,
          pointsAllowedPerGame: 14.0,
          sacks: 3.0,
          interceptions: 1.5,
          forcedFumbles: 0.5,
          thirdDownDefense: 0.30,
          redZoneDefense: 0.50,
        ),
        special: const SpecialTeamsStats(
          fieldGoalPercentage: 0.85,
          puntAverage: 45.0,
          kickoffReturnAverage: 22.0,
          puntReturnAverage: 10.0,
          blockedKicks: 1.0,
        ),
        record: '10-2',
        ranking: 3,
      );

      expect(stats.teamId, equals('team_1'));
      expect(stats.teamName, equals('Georgia Bulldogs'));
      expect(stats.record, equals('10-2'));
      expect(stats.ranking, equals(3));
    });

    group('fromNCAAApi', () {
      test('parses complete JSON correctly', () {
        final json = {
          'teamId': 'team_1',
          'teamName': 'Alabama Crimson Tide',
          'offense': {
            'totalYards': 420.0,
            'passingYards': 250.0,
            'rushingYards': 170.0,
            'pointsPerGame': 38.0,
            'thirdDownConversion': 0.42,
            'redZoneEfficiency': 0.90,
            'yardsPerPlay': 6.2,
            'turnoversPerGame': 1.2,
          },
          'defense': {
            'totalYardsAllowed': 320.0,
            'passingYardsAllowed': 200.0,
            'rushingYardsAllowed': 120.0,
            'pointsAllowedPerGame': 18.0,
            'sacks': 2.5,
            'interceptions': 1.2,
            'forcedFumbles': 0.8,
            'thirdDownDefense': 0.35,
            'redZoneDefense': 0.55,
          },
          'special': {
            'fieldGoalPercentage': 0.80,
            'puntAverage': 42.0,
            'kickoffReturnAverage': 20.0,
            'puntReturnAverage': 8.0,
            'blockedKicks': 0.0,
          },
          'record': '11-1',
          'ranking': 2,
        };

        final stats = TeamStatistics.fromNCAAApi(json);

        expect(stats.teamId, equals('team_1'));
        expect(stats.teamName, equals('Alabama Crimson Tide'));
        expect(stats.offense.totalYards, equals(420.0));
        expect(stats.defense.pointsAllowedPerGame, equals(18.0));
        expect(stats.special.fieldGoalPercentage, equals(0.80));
        expect(stats.record, equals('11-1'));
        expect(stats.ranking, equals(2));
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{};

        final stats = TeamStatistics.fromNCAAApi(json);

        expect(stats.teamId, isEmpty);
        expect(stats.teamName, equals('Unknown Team'));
        expect(stats.record, equals('0-0'));
        expect(stats.ranking, equals(0));
      });
    });

    group('Computed properties', () {
      test('overallEfficiency calculates weighted average', () {
        final stats = TeamStatistics(
          teamId: 'team_1',
          teamName: 'Test Team',
          offense: const OffensiveStats(
            totalYards: 400.0,
            passingYards: 250.0,
            rushingYards: 150.0,
            pointsPerGame: 30.0,
            thirdDownConversion: 0.40,
            redZoneEfficiency: 0.80,
            yardsPerPlay: 6.0,
            turnoversPerGame: 1.0,
          ),
          defense: const DefensiveStats(
            totalYardsAllowed: 350.0,
            passingYardsAllowed: 210.0,
            rushingYardsAllowed: 140.0,
            pointsAllowedPerGame: 21.0,
            sacks: 2.0,
            interceptions: 1.0,
            forcedFumbles: 0.5,
            thirdDownDefense: 0.38,
            redZoneDefense: 0.60,
          ),
          special: const SpecialTeamsStats(
            fieldGoalPercentage: 0.80,
            puntAverage: 42.0,
            kickoffReturnAverage: 20.0,
            puntReturnAverage: 8.0,
            blockedKicks: 0.0,
          ),
          record: '8-4',
          ranking: 15,
        );

        final efficiency = stats.overallEfficiency;
        expect(efficiency, greaterThan(0));
        expect(efficiency, lessThanOrEqualTo(100));
      });

      test('winPercentage calculates correctly from record', () {
        final stats = TeamStatistics(
          teamId: 'team_1',
          teamName: 'Test Team',
          offense: const OffensiveStats(
            totalYards: 400.0,
            passingYards: 250.0,
            rushingYards: 150.0,
            pointsPerGame: 30.0,
            thirdDownConversion: 0.40,
            redZoneEfficiency: 0.80,
            yardsPerPlay: 6.0,
            turnoversPerGame: 1.0,
          ),
          defense: const DefensiveStats(
            totalYardsAllowed: 350.0,
            passingYardsAllowed: 210.0,
            rushingYardsAllowed: 140.0,
            pointsAllowedPerGame: 21.0,
            sacks: 2.0,
            interceptions: 1.0,
            forcedFumbles: 0.5,
            thirdDownDefense: 0.38,
            redZoneDefense: 0.60,
          ),
          special: const SpecialTeamsStats(
            fieldGoalPercentage: 0.80,
            puntAverage: 42.0,
            kickoffReturnAverage: 20.0,
            puntReturnAverage: 8.0,
            blockedKicks: 0.0,
          ),
          record: '8-4',
          ranking: 15,
        );

        expect(stats.winPercentage, closeTo(0.667, 0.001));
      });

      test('winPercentage returns 0 for invalid record', () {
        final stats = TeamStatistics(
          teamId: 'team_1',
          teamName: 'Test Team',
          offense: const OffensiveStats(
            totalYards: 400.0,
            passingYards: 250.0,
            rushingYards: 150.0,
            pointsPerGame: 30.0,
            thirdDownConversion: 0.40,
            redZoneEfficiency: 0.80,
            yardsPerPlay: 6.0,
            turnoversPerGame: 1.0,
          ),
          defense: const DefensiveStats(
            totalYardsAllowed: 350.0,
            passingYardsAllowed: 210.0,
            rushingYardsAllowed: 140.0,
            pointsAllowedPerGame: 21.0,
            sacks: 2.0,
            interceptions: 1.0,
            forcedFumbles: 0.5,
            thirdDownDefense: 0.38,
            redZoneDefense: 0.60,
          ),
          special: const SpecialTeamsStats(
            fieldGoalPercentage: 0.80,
            puntAverage: 42.0,
            kickoffReturnAverage: 20.0,
            puntReturnAverage: 8.0,
            blockedKicks: 0.0,
          ),
          record: 'invalid',
          ranking: 0,
        );

        expect(stats.winPercentage, equals(0.0));
      });

      test('isRanked returns true for top 25 teams', () {
        final rankedStats = TeamStatistics(
          teamId: 'team_1',
          teamName: 'Ranked Team',
          offense: const OffensiveStats(
            totalYards: 400.0, passingYards: 250.0, rushingYards: 150.0,
            pointsPerGame: 30.0, thirdDownConversion: 0.40,
            redZoneEfficiency: 0.80, yardsPerPlay: 6.0, turnoversPerGame: 1.0,
          ),
          defense: const DefensiveStats(
            totalYardsAllowed: 350.0, passingYardsAllowed: 210.0,
            rushingYardsAllowed: 140.0, pointsAllowedPerGame: 21.0,
            sacks: 2.0, interceptions: 1.0, forcedFumbles: 0.5,
            thirdDownDefense: 0.38, redZoneDefense: 0.60,
          ),
          special: const SpecialTeamsStats(
            fieldGoalPercentage: 0.80, puntAverage: 42.0,
            kickoffReturnAverage: 20.0, puntReturnAverage: 8.0, blockedKicks: 0.0,
          ),
          record: '10-2',
          ranking: 5,
        );

        expect(rankedStats.isRanked, isTrue);
        expect(rankedStats.rankingDisplay, equals('#5'));
      });

      test('isRanked returns false for unranked teams', () {
        final unrankedStats = TeamStatistics(
          teamId: 'team_1',
          teamName: 'Unranked Team',
          offense: const OffensiveStats(
            totalYards: 300.0, passingYards: 180.0, rushingYards: 120.0,
            pointsPerGame: 20.0, thirdDownConversion: 0.35,
            redZoneEfficiency: 0.70, yardsPerPlay: 5.0, turnoversPerGame: 2.0,
          ),
          defense: const DefensiveStats(
            totalYardsAllowed: 400.0, passingYardsAllowed: 250.0,
            rushingYardsAllowed: 150.0, pointsAllowedPerGame: 28.0,
            sacks: 1.5, interceptions: 0.5, forcedFumbles: 0.3,
            thirdDownDefense: 0.45, redZoneDefense: 0.70,
          ),
          special: const SpecialTeamsStats(
            fieldGoalPercentage: 0.70, puntAverage: 40.0,
            kickoffReturnAverage: 18.0, puntReturnAverage: 6.0, blockedKicks: 0.0,
          ),
          record: '5-7',
          ranking: 0,
        );

        expect(unrankedStats.isRanked, isFalse);
        expect(unrankedStats.rankingDisplay, equals('Unranked'));
      });
    });
  });

  group('OffensiveStats', () {
    test('creates offensive stats with required fields', () {
      const stats = OffensiveStats(
        totalYards: 450.0,
        passingYards: 280.0,
        rushingYards: 170.0,
        pointsPerGame: 35.0,
        thirdDownConversion: 0.45,
        redZoneEfficiency: 0.85,
        yardsPerPlay: 6.5,
        turnoversPerGame: 1.0,
      );

      expect(stats.totalYards, equals(450.0));
      expect(stats.passingYards, equals(280.0));
      expect(stats.rushingYards, equals(170.0));
      expect(stats.pointsPerGame, equals(35.0));
    });

    test('fromJson parses correctly', () {
      final json = {
        'totalYards': 400.0,
        'passingYards': 240.0,
        'rushingYards': 160.0,
        'pointsPerGame': 32.0,
        'thirdDownConversion': 0.42,
        'redZoneEfficiency': 0.82,
        'yardsPerPlay': 6.0,
        'turnoversPerGame': 1.5,
      };

      final stats = OffensiveStats.fromJson(json);

      expect(stats.totalYards, equals(400.0));
      expect(stats.turnoversPerGame, equals(1.5));
    });

    group('offensiveBalance', () {
      test('returns 0.5 for perfectly balanced offense', () {
        const stats = OffensiveStats(
          totalYards: 400.0,
          passingYards: 200.0,
          rushingYards: 200.0,
          pointsPerGame: 28.0,
          thirdDownConversion: 0.40,
          redZoneEfficiency: 0.80,
          yardsPerPlay: 5.5,
          turnoversPerGame: 1.0,
        );

        expect(stats.offensiveBalance, equals(0.5));
      });

      test('returns high value for pass-heavy offense', () {
        const stats = OffensiveStats(
          totalYards: 400.0,
          passingYards: 320.0,
          rushingYards: 80.0,
          pointsPerGame: 30.0,
          thirdDownConversion: 0.40,
          redZoneEfficiency: 0.80,
          yardsPerPlay: 6.0,
          turnoversPerGame: 1.0,
        );

        expect(stats.offensiveBalance, equals(0.8));
      });

      test('returns low value for run-heavy offense', () {
        const stats = OffensiveStats(
          totalYards: 400.0,
          passingYards: 100.0,
          rushingYards: 300.0,
          pointsPerGame: 28.0,
          thirdDownConversion: 0.38,
          redZoneEfficiency: 0.85,
          yardsPerPlay: 5.5,
          turnoversPerGame: 0.8,
        );

        expect(stats.offensiveBalance, equals(0.25));
      });
    });

    group('efficiency', () {
      test('calculates efficiency rating', () {
        const stats = OffensiveStats(
          totalYards: 450.0,
          passingYards: 280.0,
          rushingYards: 170.0,
          pointsPerGame: 35.0,
          thirdDownConversion: 0.45,
          redZoneEfficiency: 0.85,
          yardsPerPlay: 6.5,
          turnoversPerGame: 1.0,
        );

        final efficiency = stats.efficiency;
        expect(efficiency, greaterThan(0));
        expect(efficiency, lessThanOrEqualTo(100));
      });

      test('turnovers reduce efficiency', () {
        const lowTurnover = OffensiveStats(
          totalYards: 400.0, passingYards: 240.0, rushingYards: 160.0,
          pointsPerGame: 30.0, thirdDownConversion: 0.40,
          redZoneEfficiency: 0.80, yardsPerPlay: 6.0, turnoversPerGame: 0.5,
        );

        const highTurnover = OffensiveStats(
          totalYards: 400.0, passingYards: 240.0, rushingYards: 160.0,
          pointsPerGame: 30.0, thirdDownConversion: 0.40,
          redZoneEfficiency: 0.80, yardsPerPlay: 6.0, turnoversPerGame: 3.0,
        );

        expect(lowTurnover.efficiency, greaterThan(highTurnover.efficiency));
      });
    });

    group('offensiveStyle', () {
      test('returns Pass Heavy for pass-dominant teams', () {
        const stats = OffensiveStats(
          totalYards: 400.0, passingYards: 300.0, rushingYards: 100.0,
          pointsPerGame: 32.0, thirdDownConversion: 0.42,
          redZoneEfficiency: 0.82, yardsPerPlay: 6.2, turnoversPerGame: 1.2,
        );

        expect(stats.offensiveStyle, equals('Pass Heavy'));
      });

      test('returns Run Heavy for run-dominant teams', () {
        const stats = OffensiveStats(
          totalYards: 400.0, passingYards: 120.0, rushingYards: 280.0,
          pointsPerGame: 28.0, thirdDownConversion: 0.38,
          redZoneEfficiency: 0.85, yardsPerPlay: 5.5, turnoversPerGame: 0.8,
        );

        expect(stats.offensiveStyle, equals('Run Heavy'));
      });

      test('returns Balanced for balanced teams', () {
        const stats = OffensiveStats(
          totalYards: 400.0, passingYards: 220.0, rushingYards: 180.0,
          pointsPerGame: 30.0, thirdDownConversion: 0.40,
          redZoneEfficiency: 0.80, yardsPerPlay: 5.8, turnoversPerGame: 1.0,
        );

        expect(stats.offensiveStyle, equals('Balanced'));
      });
    });
  });

  group('DefensiveStats', () {
    test('creates defensive stats with required fields', () {
      const stats = DefensiveStats(
        totalYardsAllowed: 300.0,
        passingYardsAllowed: 180.0,
        rushingYardsAllowed: 120.0,
        pointsAllowedPerGame: 14.0,
        sacks: 3.0,
        interceptions: 1.5,
        forcedFumbles: 0.5,
        thirdDownDefense: 0.30,
        redZoneDefense: 0.50,
      );

      expect(stats.totalYardsAllowed, equals(300.0));
      expect(stats.pointsAllowedPerGame, equals(14.0));
      expect(stats.sacks, equals(3.0));
    });

    test('fromJson parses correctly', () {
      final json = {
        'totalYardsAllowed': 320.0,
        'passingYardsAllowed': 200.0,
        'rushingYardsAllowed': 120.0,
        'pointsAllowedPerGame': 18.0,
        'sacks': 2.5,
        'interceptions': 1.0,
        'forcedFumbles': 0.5,
        'thirdDownDefense': 0.35,
        'redZoneDefense': 0.55,
      };

      final stats = DefensiveStats.fromJson(json);

      expect(stats.totalYardsAllowed, equals(320.0));
      expect(stats.interceptions, equals(1.0));
    });

    test('turnoversForced sums interceptions and fumbles', () {
      const stats = DefensiveStats(
        totalYardsAllowed: 300.0, passingYardsAllowed: 180.0,
        rushingYardsAllowed: 120.0, pointsAllowedPerGame: 14.0,
        sacks: 3.0, interceptions: 1.5, forcedFumbles: 0.5,
        thirdDownDefense: 0.30, redZoneDefense: 0.50,
      );

      expect(stats.turnoversForced, equals(2.0));
    });

    test('efficiency calculates defensive rating', () {
      const stats = DefensiveStats(
        totalYardsAllowed: 280.0, passingYardsAllowed: 170.0,
        rushingYardsAllowed: 110.0, pointsAllowedPerGame: 14.0,
        sacks: 3.5, interceptions: 2.0, forcedFumbles: 1.0,
        thirdDownDefense: 0.28, redZoneDefense: 0.45,
      );

      final efficiency = stats.efficiency;
      expect(efficiency, greaterThan(0));
      expect(efficiency, lessThanOrEqualTo(100));
    });

    group('defensiveStrength', () {
      test('returns Strong Pass Defense for pass-stopping teams', () {
        const stats = DefensiveStats(
          totalYardsAllowed: 280.0, passingYardsAllowed: 140.0,
          rushingYardsAllowed: 140.0, pointsAllowedPerGame: 14.0,
          sacks: 3.0, interceptions: 2.0, forcedFumbles: 0.5,
          thirdDownDefense: 0.28, redZoneDefense: 0.45,
        );

        expect(stats.defensiveStrength, equals('Strong Pass Defense'));
      });

      test('returns Strong Run Defense for run-stopping teams', () {
        const stats = DefensiveStats(
          totalYardsAllowed: 280.0, passingYardsAllowed: 200.0,
          rushingYardsAllowed: 80.0, pointsAllowedPerGame: 16.0,
          sacks: 2.0, interceptions: 1.0, forcedFumbles: 1.0,
          thirdDownDefense: 0.32, redZoneDefense: 0.50,
        );

        expect(stats.defensiveStrength, equals('Strong Run Defense'));
      });

      test('returns Strong Pass Defense when passing yards allowed lower than threshold', () {
        // When passingYardsAllowed < rushingYardsAllowed * 1.5, returns Strong Pass Defense
        // This means the defense is better at stopping the pass relative to the run
        const stats = DefensiveStats(
          totalYardsAllowed: 300.0, passingYardsAllowed: 170.0,
          rushingYardsAllowed: 130.0, pointsAllowedPerGame: 18.0,
          sacks: 2.5, interceptions: 1.0, forcedFumbles: 0.5,
          thirdDownDefense: 0.35, redZoneDefense: 0.55,
        );

        // 170 < 130 * 1.5 = 195, so this returns Strong Pass Defense
        expect(stats.defensiveStrength, equals('Strong Pass Defense'));
      });
    });
  });

  group('SpecialTeamsStats', () {
    test('creates special teams stats with required fields', () {
      const stats = SpecialTeamsStats(
        fieldGoalPercentage: 0.85,
        puntAverage: 45.0,
        kickoffReturnAverage: 22.0,
        puntReturnAverage: 10.0,
        blockedKicks: 1.0,
      );

      expect(stats.fieldGoalPercentage, equals(0.85));
      expect(stats.puntAverage, equals(45.0));
      expect(stats.kickoffReturnAverage, equals(22.0));
    });

    test('fromJson parses correctly', () {
      final json = {
        'fieldGoalPercentage': 0.80,
        'puntAverage': 42.0,
        'kickoffReturnAverage': 20.0,
        'puntReturnAverage': 8.0,
        'blockedKicks': 0.0,
      };

      final stats = SpecialTeamsStats.fromJson(json);

      expect(stats.fieldGoalPercentage, equals(0.80));
      expect(stats.puntAverage, equals(42.0));
    });

    test('efficiency calculates special teams rating', () {
      const stats = SpecialTeamsStats(
        fieldGoalPercentage: 0.90,
        puntAverage: 48.0,
        kickoffReturnAverage: 24.0,
        puntReturnAverage: 12.0,
        blockedKicks: 2.0,
      );

      final efficiency = stats.efficiency;
      expect(efficiency, greaterThan(0));
      expect(efficiency, lessThanOrEqualTo(100));
    });

    group('specialTeamsStrength', () {
      test('returns Elite Kicking Game for high FG percentage', () {
        const stats = SpecialTeamsStats(
          fieldGoalPercentage: 0.90,
          puntAverage: 40.0,
          kickoffReturnAverage: 18.0,
          puntReturnAverage: 6.0,
          blockedKicks: 0.0,
        );

        expect(stats.specialTeamsStrength, equals('Elite Kicking Game'));
      });

      test('returns Dangerous Return Game for high return averages', () {
        const stats = SpecialTeamsStats(
          fieldGoalPercentage: 0.75,
          puntAverage: 40.0,
          kickoffReturnAverage: 28.0,
          puntReturnAverage: 8.0,
          blockedKicks: 0.0,
        );

        expect(stats.specialTeamsStrength, equals('Dangerous Return Game'));
      });

      test('returns Strong Punting Game for high punt average', () {
        const stats = SpecialTeamsStats(
          fieldGoalPercentage: 0.80,
          puntAverage: 48.0,
          kickoffReturnAverage: 20.0,
          puntReturnAverage: 8.0,
          blockedKicks: 0.0,
        );

        expect(stats.specialTeamsStrength, equals('Strong Punting Game'));
      });

      test('returns Solid Special Teams for average stats', () {
        const stats = SpecialTeamsStats(
          fieldGoalPercentage: 0.75,
          puntAverage: 40.0,
          kickoffReturnAverage: 18.0,
          puntReturnAverage: 6.0,
          blockedKicks: 0.0,
        );

        expect(stats.specialTeamsStrength, equals('Solid Special Teams'));
      });
    });
  });
}
