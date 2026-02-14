import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/entities/team_statistics.dart';

void main() {
  group('TeamStatistics', () {
    test('creates team statistics with required fields', () {
      final stats = TeamStatistics(
        teamId: 'team_1',
        teamName: 'Brazil',
        attack: const AttackStats(
          goalsScored: 2.5,
          shotsPerGame: 16.0,
          possession: 58.0,
          passAccuracy: 87.0,
          chancesCreated: 12.0,
        ),
        defense: const DefenseStats(
          goalsConceded: 0.8,
          cleanSheets: 6.0,
          tacklesPerGame: 18.0,
          interceptions: 12.0,
          savesPerGame: 3.5,
        ),
        setPieces: const SetPieceStats(
          cornerKicks: 6.5,
          freeKicks: 14.0,
          penalties: 3.0,
          penaltyConversionRate: 80.0,
        ),
        record: '8-2-1',
        fifaRanking: 3,
      );

      expect(stats.teamId, equals('team_1'));
      expect(stats.teamName, equals('Brazil'));
      expect(stats.record, equals('8-2-1'));
      expect(stats.fifaRanking, equals(3));
    });

    group('fromApi', () {
      test('parses complete JSON correctly', () {
        final json = {
          'teamId': 'team_1',
          'teamName': 'France',
          'attack': {
            'goalsScored': 2.8,
            'shotsPerGame': 17.0,
            'possession': 60.0,
            'passAccuracy': 89.0,
            'chancesCreated': 13.0,
          },
          'defense': {
            'goalsConceded': 0.6,
            'cleanSheets': 7.0,
            'tacklesPerGame': 20.0,
            'interceptions': 14.0,
            'savesPerGame': 4.0,
          },
          'setPieces': {
            'cornerKicks': 7.0,
            'freeKicks': 13.0,
            'penalties': 4.0,
            'penaltyConversionRate': 85.0,
          },
          'record': '9-1-1',
          'fifaRanking': 2,
        };

        final stats = TeamStatistics.fromApi(json);

        expect(stats.teamId, equals('team_1'));
        expect(stats.teamName, equals('France'));
        expect(stats.attack.goalsScored, equals(2.8));
        expect(stats.defense.goalsConceded, equals(0.6));
        expect(stats.setPieces.cornerKicks, equals(7.0));
        expect(stats.record, equals('9-1-1'));
        expect(stats.fifaRanking, equals(2));
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{};

        final stats = TeamStatistics.fromApi(json);

        expect(stats.teamId, isEmpty);
        expect(stats.teamName, equals('Unknown Team'));
        expect(stats.record, equals('0-0-0'));
        expect(stats.fifaRanking, equals(0));
      });
    });

    group('Computed properties', () {
      test('overallEfficiency calculates weighted average', () {
        final stats = TeamStatistics(
          teamId: 'team_1',
          teamName: 'Test Team',
          attack: const AttackStats(
            goalsScored: 2.0,
            shotsPerGame: 14.0,
            possession: 55.0,
            passAccuracy: 85.0,
            chancesCreated: 10.0,
          ),
          defense: const DefenseStats(
            goalsConceded: 1.0,
            cleanSheets: 5.0,
            tacklesPerGame: 18.0,
            interceptions: 10.0,
            savesPerGame: 3.0,
          ),
          setPieces: const SetPieceStats(
            cornerKicks: 5.0,
            freeKicks: 12.0,
            penalties: 2.0,
            penaltyConversionRate: 75.0,
          ),
          record: '6-3-2',
          fifaRanking: 15,
        );

        final efficiency = stats.overallEfficiency;
        expect(efficiency, greaterThan(0));
        expect(efficiency, lessThanOrEqualTo(100));
      });

      test('winPercentage calculates correctly from W-D-L record', () {
        final stats = TeamStatistics(
          teamId: 'team_1',
          teamName: 'Test Team',
          attack: const AttackStats(
            goalsScored: 2.0,
            shotsPerGame: 14.0,
            possession: 55.0,
            passAccuracy: 85.0,
            chancesCreated: 10.0,
          ),
          defense: const DefenseStats(
            goalsConceded: 1.0,
            cleanSheets: 5.0,
            tacklesPerGame: 18.0,
            interceptions: 10.0,
            savesPerGame: 3.0,
          ),
          setPieces: const SetPieceStats(
            cornerKicks: 5.0,
            freeKicks: 12.0,
            penalties: 2.0,
            penaltyConversionRate: 75.0,
          ),
          record: '6-3-1',
          fifaRanking: 15,
        );

        // 6 wins out of 10 total games = 0.6
        expect(stats.winPercentage, equals(0.6));
      });

      test('winPercentage returns 0 for invalid record', () {
        final stats = TeamStatistics(
          teamId: 'team_1',
          teamName: 'Test Team',
          attack: const AttackStats(
            goalsScored: 2.0,
            shotsPerGame: 14.0,
            possession: 55.0,
            passAccuracy: 85.0,
            chancesCreated: 10.0,
          ),
          defense: const DefenseStats(
            goalsConceded: 1.0,
            cleanSheets: 5.0,
            tacklesPerGame: 18.0,
            interceptions: 10.0,
            savesPerGame: 3.0,
          ),
          setPieces: const SetPieceStats(
            cornerKicks: 5.0,
            freeKicks: 12.0,
            penalties: 2.0,
            penaltyConversionRate: 75.0,
          ),
          record: 'invalid',
          fifaRanking: 0,
        );

        expect(stats.winPercentage, equals(0.0));
      });

      test('pointsPerGame calculates correctly', () {
        final stats = TeamStatistics(
          teamId: 'team_1',
          teamName: 'Test Team',
          attack: const AttackStats(
            goalsScored: 2.0,
            shotsPerGame: 14.0,
            possession: 55.0,
            passAccuracy: 85.0,
            chancesCreated: 10.0,
          ),
          defense: const DefenseStats(
            goalsConceded: 1.0,
            cleanSheets: 5.0,
            tacklesPerGame: 18.0,
            interceptions: 10.0,
            savesPerGame: 3.0,
          ),
          setPieces: const SetPieceStats(
            cornerKicks: 5.0,
            freeKicks: 12.0,
            penalties: 2.0,
            penaltyConversionRate: 75.0,
          ),
          record: '6-3-1',
          fifaRanking: 15,
        );

        // (6*3 + 3) / 10 = 21/10 = 2.1
        expect(stats.pointsPerGame, equals(2.1));
      });

      test('isTopRanked returns true for top 20 teams', () {
        final rankedStats = TeamStatistics(
          teamId: 'team_1',
          teamName: 'Argentina',
          attack: const AttackStats(
            goalsScored: 2.5, shotsPerGame: 16.0, possession: 58.0,
            passAccuracy: 87.0, chancesCreated: 12.0,
          ),
          defense: const DefenseStats(
            goalsConceded: 0.7, cleanSheets: 7.0, tacklesPerGame: 19.0,
            interceptions: 13.0, savesPerGame: 3.5,
          ),
          setPieces: const SetPieceStats(
            cornerKicks: 6.0, freeKicks: 13.0, penalties: 3.0,
            penaltyConversionRate: 90.0,
          ),
          record: '9-2-0',
          fifaRanking: 1,
        );

        expect(rankedStats.isTopRanked, isTrue);
        expect(rankedStats.rankingDisplay, equals('FIFA #1'));
      });

      test('isTopRanked returns false for unranked teams', () {
        final unrankedStats = TeamStatistics(
          teamId: 'team_1',
          teamName: 'New Zealand',
          attack: const AttackStats(
            goalsScored: 1.0, shotsPerGame: 8.0, possession: 42.0,
            passAccuracy: 75.0, chancesCreated: 5.0,
          ),
          defense: const DefenseStats(
            goalsConceded: 2.0, cleanSheets: 2.0, tacklesPerGame: 15.0,
            interceptions: 8.0, savesPerGame: 5.0,
          ),
          setPieces: const SetPieceStats(
            cornerKicks: 3.0, freeKicks: 10.0, penalties: 1.0,
            penaltyConversionRate: 50.0,
          ),
          record: '3-2-6',
          fifaRanking: 0,
        );

        expect(unrankedStats.isTopRanked, isFalse);
        expect(unrankedStats.rankingDisplay, equals('Unranked'));
      });
    });
  });

  group('AttackStats', () {
    test('creates attack stats with required fields', () {
      const stats = AttackStats(
        goalsScored: 2.5,
        shotsPerGame: 16.0,
        possession: 58.0,
        passAccuracy: 87.0,
        chancesCreated: 12.0,
      );

      expect(stats.goalsScored, equals(2.5));
      expect(stats.shotsPerGame, equals(16.0));
      expect(stats.possession, equals(58.0));
      expect(stats.passAccuracy, equals(87.0));
      expect(stats.chancesCreated, equals(12.0));
    });

    test('fromJson parses correctly', () {
      final json = {
        'goalsScored': 2.2,
        'shotsPerGame': 14.0,
        'possession': 55.0,
        'passAccuracy': 85.0,
        'chancesCreated': 10.0,
      };

      final stats = AttackStats.fromJson(json);

      expect(stats.goalsScored, equals(2.2));
      expect(stats.possession, equals(55.0));
    });

    group('attackingStyle', () {
      test('returns Possession-Based for high possession teams', () {
        const stats = AttackStats(
          goalsScored: 2.0, shotsPerGame: 14.0, possession: 65.0,
          passAccuracy: 90.0, chancesCreated: 12.0,
        );

        expect(stats.attackingStyle, equals('Possession-Based'));
      });

      test('returns Counter-Attacking for low possession high shots', () {
        const stats = AttackStats(
          goalsScored: 2.0, shotsPerGame: 16.0, possession: 40.0,
          passAccuracy: 78.0, chancesCreated: 8.0,
        );

        expect(stats.attackingStyle, equals('Counter-Attacking'));
      });

      test('returns Defensive / Counter for very low possession', () {
        const stats = AttackStats(
          goalsScored: 0.8, shotsPerGame: 8.0, possession: 35.0,
          passAccuracy: 72.0, chancesCreated: 4.0,
        );

        expect(stats.attackingStyle, equals('Defensive / Counter'));
      });

      test('returns Balanced for moderate possession', () {
        const stats = AttackStats(
          goalsScored: 1.5, shotsPerGame: 12.0, possession: 50.0,
          passAccuracy: 82.0, chancesCreated: 8.0,
        );

        expect(stats.attackingStyle, equals('Balanced'));
      });
    });

    group('efficiency', () {
      test('calculates efficiency rating', () {
        const stats = AttackStats(
          goalsScored: 2.5,
          shotsPerGame: 16.0,
          possession: 58.0,
          passAccuracy: 87.0,
          chancesCreated: 12.0,
        );

        final efficiency = stats.efficiency;
        expect(efficiency, greaterThan(0));
        expect(efficiency, lessThanOrEqualTo(100));
      });
    });

    test('conversionRate calculates correctly', () {
      const stats = AttackStats(
        goalsScored: 2.0, shotsPerGame: 10.0, possession: 50.0,
        passAccuracy: 80.0, chancesCreated: 8.0,
      );

      expect(stats.conversionRate, equals(20.0));
    });

    test('conversionRate returns 0 when no shots', () {
      const stats = AttackStats(
        goalsScored: 0.0, shotsPerGame: 0.0, possession: 50.0,
        passAccuracy: 80.0, chancesCreated: 0.0,
      );

      expect(stats.conversionRate, equals(0.0));
    });
  });

  group('DefenseStats', () {
    test('creates defense stats with required fields', () {
      const stats = DefenseStats(
        goalsConceded: 0.8,
        cleanSheets: 6.0,
        tacklesPerGame: 18.0,
        interceptions: 12.0,
        savesPerGame: 3.5,
      );

      expect(stats.goalsConceded, equals(0.8));
      expect(stats.cleanSheets, equals(6.0));
      expect(stats.tacklesPerGame, equals(18.0));
    });

    test('fromJson parses correctly', () {
      final json = {
        'goalsConceded': 1.2,
        'cleanSheets': 4.0,
        'tacklesPerGame': 16.0,
        'interceptions': 10.0,
        'savesPerGame': 4.0,
      };

      final stats = DefenseStats.fromJson(json);

      expect(stats.goalsConceded, equals(1.2));
      expect(stats.interceptions, equals(10.0));
    });

    test('defensiveActionsPerGame sums tackles and interceptions', () {
      const stats = DefenseStats(
        goalsConceded: 1.0, cleanSheets: 4.0,
        tacklesPerGame: 18.0, interceptions: 12.0, savesPerGame: 3.0,
      );

      expect(stats.defensiveActionsPerGame, equals(30.0));
    });

    test('efficiency calculates defensive rating', () {
      const stats = DefenseStats(
        goalsConceded: 0.5, cleanSheets: 8.0,
        tacklesPerGame: 22.0, interceptions: 14.0, savesPerGame: 4.0,
      );

      final efficiency = stats.efficiency;
      expect(efficiency, greaterThan(0));
      expect(efficiency, lessThanOrEqualTo(100));
    });

    group('defensiveStrength', () {
      test('returns Elite Defense for very low goals and high clean sheets', () {
        const stats = DefenseStats(
          goalsConceded: 0.3, cleanSheets: 8.0,
          tacklesPerGame: 20.0, interceptions: 14.0, savesPerGame: 2.0,
        );

        expect(stats.defensiveStrength, equals('Elite Defense'));
      });

      test('returns Strong Defense for low goals conceded', () {
        const stats = DefenseStats(
          goalsConceded: 0.8, cleanSheets: 4.0,
          tacklesPerGame: 16.0, interceptions: 10.0, savesPerGame: 3.0,
        );

        expect(stats.defensiveStrength, equals('Strong Defense'));
      });

      test('returns Aggressive Defense for high tackles and interceptions', () {
        const stats = DefenseStats(
          goalsConceded: 1.5, cleanSheets: 3.0,
          tacklesPerGame: 25.0, interceptions: 15.0, savesPerGame: 4.0,
        );

        expect(stats.defensiveStrength, equals('Aggressive Defense'));
      });

      test('returns Balanced Defense for average stats', () {
        const stats = DefenseStats(
          goalsConceded: 1.5, cleanSheets: 3.0,
          tacklesPerGame: 15.0, interceptions: 8.0, savesPerGame: 4.0,
        );

        expect(stats.defensiveStrength, equals('Balanced Defense'));
      });
    });
  });

  group('SetPieceStats', () {
    test('creates set piece stats with required fields', () {
      const stats = SetPieceStats(
        cornerKicks: 6.5,
        freeKicks: 14.0,
        penalties: 3.0,
        penaltyConversionRate: 80.0,
      );

      expect(stats.cornerKicks, equals(6.5));
      expect(stats.freeKicks, equals(14.0));
      expect(stats.penalties, equals(3.0));
      expect(stats.penaltyConversionRate, equals(80.0));
    });

    test('fromJson parses correctly', () {
      final json = {
        'cornerKicks': 5.0,
        'freeKicks': 12.0,
        'penalties': 2.0,
        'penaltyConversionRate': 75.0,
      };

      final stats = SetPieceStats.fromJson(json);

      expect(stats.cornerKicks, equals(5.0));
      expect(stats.freeKicks, equals(12.0));
    });

    test('efficiency calculates set piece rating', () {
      const stats = SetPieceStats(
        cornerKicks: 7.0,
        freeKicks: 14.0,
        penalties: 4.0,
        penaltyConversionRate: 90.0,
      );

      final efficiency = stats.efficiency;
      expect(efficiency, greaterThan(0));
      expect(efficiency, lessThanOrEqualTo(100));
    });

    group('setPieceStrength', () {
      test('returns Clinical from the Spot for high penalty conversion', () {
        const stats = SetPieceStats(
          cornerKicks: 5.0,
          freeKicks: 12.0,
          penalties: 5.0,
          penaltyConversionRate: 90.0,
        );

        expect(stats.setPieceStrength, equals('Clinical from the Spot'));
      });

      test('returns Dangerous from Corners for high corner count', () {
        const stats = SetPieceStats(
          cornerKicks: 8.0,
          freeKicks: 12.0,
          penalties: 2.0,
          penaltyConversionRate: 70.0,
        );

        expect(stats.setPieceStrength, equals('Dangerous from Corners'));
      });

      test('returns Active Set Piece Team for high free kick count', () {
        const stats = SetPieceStats(
          cornerKicks: 5.0,
          freeKicks: 15.0,
          penalties: 2.0,
          penaltyConversionRate: 70.0,
        );

        expect(stats.setPieceStrength, equals('Active Set Piece Team'));
      });

      test('returns Standard Set Pieces for average stats', () {
        const stats = SetPieceStats(
          cornerKicks: 4.0,
          freeKicks: 10.0,
          penalties: 1.0,
          penaltyConversionRate: 60.0,
        );

        expect(stats.setPieceStrength, equals('Standard Set Pieces'));
      });
    });
  });
}
