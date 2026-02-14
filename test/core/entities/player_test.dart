import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/entities/player.dart';

void main() {
  group('GoalkeeperStats', () {
    test('creates stats with required fields', () {
      const stats = GoalkeeperStats(
        saves: 45,
        cleanSheets: 8,
        goalsConceded: 12,
        savePercentage: 78.5,
      );

      expect(stats.saves, equals(45));
      expect(stats.cleanSheets, equals(8));
      expect(stats.goalsConceded, equals(12));
      expect(stats.savePercentage, equals(78.5));
    });

    test('fromJson parses correctly', () {
      final json = {
        'saves': 50,
        'cleanSheets': 10,
        'goalsConceded': 15,
        'savePercentage': 80.2,
      };

      final stats = GoalkeeperStats.fromJson(json);

      expect(stats.saves, equals(50));
      expect(stats.cleanSheets, equals(10));
      expect(stats.goalsConceded, equals(15));
      expect(stats.savePercentage, equals(80.2));
    });

    test('fromJson handles null values', () {
      final stats = GoalkeeperStats.fromJson({});

      expect(stats.saves, equals(0));
      expect(stats.cleanSheets, equals(0));
      expect(stats.goalsConceded, equals(0));
      expect(stats.savePercentage, equals(0.0));
    });

    test('fromJson parses string values', () {
      final json = {
        'saves': '45',
        'cleanSheets': '8',
        'goalsConceded': '12',
        'savePercentage': '78.5',
      };

      final stats = GoalkeeperStats.fromJson(json);

      expect(stats.saves, equals(45));
      expect(stats.cleanSheets, equals(8));
      expect(stats.goalsConceded, equals(12));
      expect(stats.savePercentage, equals(78.5));
    });

    test('fromJson parses double values as int', () {
      final json = {
        'saves': 45.7,
        'cleanSheets': 8.3,
        'goalsConceded': 12.0,
      };

      final stats = GoalkeeperStats.fromJson(json);

      expect(stats.saves, equals(46));
      expect(stats.cleanSheets, equals(8));
      expect(stats.goalsConceded, equals(12));
    });

    test('savesToConcededRatio calculates correctly', () {
      const stats = GoalkeeperStats(
        saves: 40,
        cleanSheets: 5,
        goalsConceded: 10,
        savePercentage: 80.0,
      );

      expect(stats.savesToConcededRatio, equals(4.0));
    });

    test('savesToConcededRatio returns saves when no goals conceded', () {
      const stats = GoalkeeperStats(
        saves: 30,
        cleanSheets: 10,
        goalsConceded: 0,
        savePercentage: 100.0,
      );

      expect(stats.savesToConcededRatio, equals(30.0));
    });
  });

  group('AttackingStats', () {
    test('creates stats with required fields', () {
      const stats = AttackingStats(
        goals: 12,
        assists: 8,
        shots: 60,
        shotsOnTarget: 35,
        minutesPlayed: 2700,
      );

      expect(stats.goals, equals(12));
      expect(stats.assists, equals(8));
      expect(stats.shots, equals(60));
      expect(stats.shotsOnTarget, equals(35));
      expect(stats.minutesPlayed, equals(2700));
    });

    test('fromJson parses correctly', () {
      final json = {
        'goals': 15,
        'assists': 10,
        'shots': 80,
        'shotsOnTarget': 45,
        'minutesPlayed': 3000,
      };

      final stats = AttackingStats.fromJson(json);

      expect(stats.goals, equals(15));
      expect(stats.assists, equals(10));
      expect(stats.shots, equals(80));
      expect(stats.shotsOnTarget, equals(45));
      expect(stats.minutesPlayed, equals(3000));
    });

    test('fromJson handles null values', () {
      final stats = AttackingStats.fromJson({});

      expect(stats.goals, equals(0));
      expect(stats.assists, equals(0));
      expect(stats.shots, equals(0));
      expect(stats.shotsOnTarget, equals(0));
      expect(stats.minutesPlayed, equals(0));
    });

    test('shotAccuracy calculates correctly', () {
      const stats = AttackingStats(
        goals: 10,
        assists: 5,
        shots: 50,
        shotsOnTarget: 25,
        minutesPlayed: 2000,
      );

      expect(stats.shotAccuracy, equals(50.0));
    });

    test('shotAccuracy returns 0 when no shots', () {
      const stats = AttackingStats(
        goals: 0,
        assists: 0,
        shots: 0,
        shotsOnTarget: 0,
        minutesPlayed: 0,
      );

      expect(stats.shotAccuracy, equals(0.0));
    });

    test('goalContributions sums goals and assists', () {
      const stats = AttackingStats(
        goals: 12,
        assists: 8,
        shots: 60,
        shotsOnTarget: 35,
        minutesPlayed: 2700,
      );

      expect(stats.goalContributions, equals(20));
    });

    test('minutesPerGoal calculates correctly', () {
      const stats = AttackingStats(
        goals: 10,
        assists: 5,
        shots: 50,
        shotsOnTarget: 25,
        minutesPlayed: 2000,
      );

      expect(stats.minutesPerGoal, equals(200.0));
    });

    test('minutesPerGoal returns 0 when no goals', () {
      const stats = AttackingStats(
        goals: 0,
        assists: 5,
        shots: 50,
        shotsOnTarget: 25,
        minutesPlayed: 2000,
      );

      expect(stats.minutesPerGoal, equals(0.0));
    });
  });

  group('CreativeStats', () {
    test('creates stats with required fields', () {
      const stats = CreativeStats(
        keyPasses: 45,
        crosses: 30,
        throughBalls: 15,
        chancesCreated: 50,
      );

      expect(stats.keyPasses, equals(45));
      expect(stats.crosses, equals(30));
      expect(stats.throughBalls, equals(15));
      expect(stats.chancesCreated, equals(50));
    });

    test('fromJson parses correctly', () {
      final json = {
        'keyPasses': 50,
        'crosses': 40,
        'throughBalls': 20,
        'chancesCreated': 60,
      };

      final stats = CreativeStats.fromJson(json);

      expect(stats.keyPasses, equals(50));
      expect(stats.crosses, equals(40));
      expect(stats.throughBalls, equals(20));
      expect(stats.chancesCreated, equals(60));
    });

    test('fromJson handles null values', () {
      final stats = CreativeStats.fromJson({});

      expect(stats.keyPasses, equals(0));
      expect(stats.crosses, equals(0));
      expect(stats.throughBalls, equals(0));
      expect(stats.chancesCreated, equals(0));
    });

    test('totalCreativeOutput sums key passes, crosses, and through balls', () {
      const stats = CreativeStats(
        keyPasses: 45,
        crosses: 30,
        throughBalls: 15,
        chancesCreated: 50,
      );

      expect(stats.totalCreativeOutput, equals(90));
    });
  });

  group('DefensiveStats', () {
    test('creates stats with required fields', () {
      const stats = DefensiveStats(
        tackles: 75,
        interceptions: 30,
        clearances: 50,
        blocks: 15,
        aerialDuelsWon: 40,
      );

      expect(stats.tackles, equals(75));
      expect(stats.interceptions, equals(30));
      expect(stats.clearances, equals(50));
      expect(stats.blocks, equals(15));
      expect(stats.aerialDuelsWon, equals(40));
    });

    test('fromJson parses correctly', () {
      final json = {
        'tackles': 80,
        'interceptions': 35,
        'clearances': 55,
        'blocks': 20,
        'aerialDuelsWon': 45,
      };

      final stats = DefensiveStats.fromJson(json);

      expect(stats.tackles, equals(80));
      expect(stats.interceptions, equals(35));
      expect(stats.clearances, equals(55));
      expect(stats.blocks, equals(20));
      expect(stats.aerialDuelsWon, equals(45));
    });

    test('fromJson handles null values', () {
      final stats = DefensiveStats.fromJson({});

      expect(stats.tackles, equals(0));
      expect(stats.interceptions, equals(0));
      expect(stats.clearances, equals(0));
      expect(stats.blocks, equals(0));
      expect(stats.aerialDuelsWon, equals(0));
    });

    test('totalDefensiveActions sums all actions', () {
      const stats = DefensiveStats(
        tackles: 50,
        interceptions: 20,
        clearances: 30,
        blocks: 10,
        aerialDuelsWon: 25,
      );

      expect(stats.totalDefensiveActions, equals(135));
    });

    test('defensiveImpact calculates correctly', () {
      const stats = DefensiveStats(
        tackles: 50,       // 50
        interceptions: 20, // 20*2 = 40
        clearances: 30,    // 30
        blocks: 10,        // 10*2 = 20
        aerialDuelsWon: 25, // 25
      );
      // Total: 50 + 40 + 30 + 20 + 25 = 165

      expect(stats.defensiveImpact, equals(165));
    });
  });

  group('PlayerStatistics', () {
    test('creates with required fields', () {
      const stats = PlayerStatistics(
        goalkeeper: GoalkeeperStats(
          saves: 40, cleanSheets: 8, goalsConceded: 10, savePercentage: 80.0,
        ),
        attacking: AttackingStats(
          goals: 0, assists: 0, shots: 0, shotsOnTarget: 0, minutesPlayed: 2700,
        ),
        creative: CreativeStats(
          keyPasses: 5, crosses: 10, throughBalls: 0, chancesCreated: 5,
        ),
        defensive: DefensiveStats(
          tackles: 2, interceptions: 0, clearances: 5, blocks: 0, aerialDuelsWon: 3,
        ),
      );

      expect(stats.goalkeeper.saves, equals(40));
      expect(stats.attacking.minutesPlayed, equals(2700));
    });

    test('fromJson parses all stat categories', () {
      final json = {
        'goalkeeper': {
          'saves': 50,
          'cleanSheets': 10,
          'goalsConceded': 12,
          'savePercentage': 80.6,
        },
        'attacking': {
          'goals': 0,
          'assists': 1,
          'shots': 2,
          'shotsOnTarget': 1,
          'minutesPlayed': 3150,
        },
        'creative': {
          'keyPasses': 8,
          'crosses': 12,
          'throughBalls': 3,
          'chancesCreated': 10,
        },
        'defensive': {
          'tackles': 5,
          'interceptions': 3,
          'clearances': 10,
          'blocks': 2,
          'aerialDuelsWon': 8,
        },
      };

      final stats = PlayerStatistics.fromJson(json);

      expect(stats.goalkeeper.saves, equals(50));
      expect(stats.goalkeeper.savePercentage, equals(80.6));
      expect(stats.attacking.minutesPlayed, equals(3150));
    });

    test('fromJson handles missing categories', () {
      final stats = PlayerStatistics.fromJson({});

      expect(stats.goalkeeper.saves, equals(0));
      expect(stats.attacking.goals, equals(0));
      expect(stats.creative.keyPasses, equals(0));
      expect(stats.defensive.tackles, equals(0));
    });
  });

  group('Player', () {
    const testGoalkeeperStats = GoalkeeperStats(
      saves: 45, cleanSheets: 8, goalsConceded: 12, savePercentage: 78.9,
    );
    const testAttackingStats = AttackingStats(
      goals: 15, assists: 10, shots: 80, shotsOnTarget: 45, minutesPlayed: 3000,
    );
    const testCreativeStats = CreativeStats(
      keyPasses: 50, crosses: 40, throughBalls: 20, chancesCreated: 60,
    );
    const testDefensiveStats = DefensiveStats(
      tackles: 75, interceptions: 30, clearances: 50, blocks: 15, aerialDuelsWon: 40,
    );

    const testStats = PlayerStatistics(
      goalkeeper: testGoalkeeperStats,
      attacking: testAttackingStats,
      creative: testCreativeStats,
      defensive: testDefensiveStats,
    );

    test('creates player with required fields', () {
      const player = Player(
        id: 'p1',
        name: 'Lionel Messi',
        position: 'RW',
        nationality: 'Argentina',
        height: '170',
        weight: '72',
        number: '10',
        club: 'Inter Miami',
      );

      expect(player.id, equals('p1'));
      expect(player.name, equals('Lionel Messi'));
      expect(player.position, equals('RW'));
      expect(player.nationality, equals('Argentina'));
      expect(player.height, equals('170'));
      expect(player.weight, equals('72'));
      expect(player.number, equals('10'));
      expect(player.club, equals('Inter Miami'));
    });

    test('creates player with optional fields', () {
      const player = Player(
        id: 'p1',
        name: 'Lionel Messi',
        position: 'RW',
        nationality: 'Argentina',
        height: '170',
        weight: '72',
        number: '10',
        club: 'Inter Miami',
        statistics: testStats,
        teamKey: 'argentina',
      );

      expect(player.statistics, isNotNull);
      expect(player.teamKey, equals('argentina'));
    });

    test('displayNameWithPosition formats correctly', () {
      const player = Player(
        id: 'p1',
        name: 'Kylian Mbappe',
        position: 'ST',
        nationality: 'France',
        height: '178',
        weight: '73',
        number: '7',
        club: 'Real Madrid',
      );

      expect(player.displayNameWithPosition, equals('Kylian Mbappe (ST)'));
    });

    test('physicalStats formats correctly', () {
      const player = Player(
        id: 'p1',
        name: 'Erling Haaland',
        position: 'ST',
        nationality: 'Norway',
        height: '194',
        weight: '88',
        number: '9',
        club: 'Manchester City',
      );

      expect(player.physicalStats, equals('194, 88 kg'));
    });

    test('hasStatistics returns false when null', () {
      const player = Player(
        id: 'p1',
        name: 'Test Player',
        position: 'ST',
        nationality: 'Brazil',
        height: '180',
        weight: '75',
        number: '9',
        club: 'Test Club',
      );

      expect(player.hasStatistics, isFalse);
    });

    test('hasStatistics returns true when stats exist', () {
      const player = Player(
        id: 'p1',
        name: 'Test Player',
        position: 'ST',
        nationality: 'Brazil',
        height: '180',
        weight: '75',
        number: '9',
        club: 'Test Club',
        statistics: testStats,
      );

      expect(player.hasStatistics, isTrue);
    });

    group('primaryStat', () {
      test('returns no stats when statistics is null', () {
        const player = Player(
          id: 'p1',
          name: 'Test Player',
          position: 'ST',
          nationality: 'Brazil',
          height: '180',
          weight: '75',
          number: '9',
          club: 'Test Club',
        );

        expect(player.primaryStat, equals('No stats available'));
      });

      test('returns goalkeeper stats for GK', () {
        const player = Player(
          id: 'p1',
          name: 'Thibaut Courtois',
          position: 'GK',
          nationality: 'Belgium',
          height: '199',
          weight: '96',
          number: '1',
          club: 'Real Madrid',
          statistics: testStats,
        );

        expect(player.primaryStat, equals('45 saves, 8 clean sheets'));
      });

      test('returns defensive stats for CB', () {
        const player = Player(
          id: 'p2',
          name: 'Virgil van Dijk',
          position: 'CB',
          nationality: 'Netherlands',
          height: '193',
          weight: '92',
          number: '4',
          club: 'Liverpool',
          statistics: testStats,
        );

        expect(player.primaryStat, equals('75 tackles, 30 interceptions'));
      });

      test('returns defensive stats for LB', () {
        const player = Player(
          id: 'p3',
          name: 'Alphonso Davies',
          position: 'LB',
          nationality: 'Canada',
          height: '183',
          weight: '75',
          number: '19',
          club: 'Real Madrid',
          statistics: testStats,
        );

        expect(player.primaryStat, equals('75 tackles, 30 interceptions'));
      });

      test('returns creative stats for CM', () {
        const player = Player(
          id: 'p4',
          name: 'Kevin De Bruyne',
          position: 'CM',
          nationality: 'Belgium',
          height: '181',
          weight: '68',
          number: '17',
          club: 'Manchester City',
          statistics: testStats,
        );

        expect(player.primaryStat, equals('50 key passes, 60 chances created'));
      });

      test('returns creative stats for CAM', () {
        const player = Player(
          id: 'p5',
          name: 'Jude Bellingham',
          position: 'CAM',
          nationality: 'England',
          height: '186',
          weight: '75',
          number: '5',
          club: 'Real Madrid',
          statistics: testStats,
        );

        expect(player.primaryStat, equals('50 key passes, 60 chances created'));
      });

      test('returns attacking stats for ST', () {
        const player = Player(
          id: 'p6',
          name: 'Kylian Mbappe',
          position: 'ST',
          nationality: 'France',
          height: '178',
          weight: '73',
          number: '7',
          club: 'Real Madrid',
          statistics: testStats,
        );

        expect(player.primaryStat, equals('15 goals, 10 assists'));
      });

      test('returns attacking stats for LW', () {
        const player = Player(
          id: 'p7',
          name: 'Vinicius Jr',
          position: 'LW',
          nationality: 'Brazil',
          height: '176',
          weight: '73',
          number: '7',
          club: 'Real Madrid',
          statistics: testStats,
        );

        expect(player.primaryStat, equals('15 goals, 10 assists'));
      });

      test('returns attacking stats for RW', () {
        const player = Player(
          id: 'p8',
          name: 'Mohamed Salah',
          position: 'RW',
          nationality: 'Egypt',
          height: '175',
          weight: '71',
          number: '11',
          club: 'Liverpool',
          statistics: testStats,
        );

        expect(player.primaryStat, equals('15 goals, 10 assists'));
      });

      test('returns defensive stats for CDM', () {
        const player = Player(
          id: 'p9',
          name: 'Casemiro',
          position: 'CDM',
          nationality: 'Brazil',
          height: '185',
          weight: '84',
          number: '18',
          club: 'Manchester United',
          statistics: testStats,
        );

        expect(player.primaryStat, equals('75 tackles, 30 interceptions'));
      });
    });

    group('fromApi', () {
      test('parses basic fields', () {
        final json = {
          'id': '12345',
          'name': 'Kylian Mbappe',
          'position': 'ST',
          'nationality': 'France',
          'height': '178',
          'weight': '73',
          'number': '7',
          'club': 'Real Madrid',
          'teamKey': 'france',
        };

        final player = Player.fromApi(json);

        expect(player.id, equals('12345'));
        expect(player.name, equals('Kylian Mbappe'));
        expect(player.position, equals('ST'));
        expect(player.nationality, equals('France'));
        expect(player.height, equals('178'));
        expect(player.weight, equals('73'));
        expect(player.number, equals('7'));
        expect(player.club, equals('Real Madrid'));
        expect(player.teamKey, equals('france'));
      });

      test('handles null values with defaults', () {
        final player = Player.fromApi({});

        expect(player.id, equals(''));
        expect(player.name, equals('Unknown Player'));
        expect(player.position, equals('N/A'));
        expect(player.nationality, equals('N/A'));
        expect(player.height, equals('N/A'));
        expect(player.weight, equals('N/A'));
        expect(player.number, equals('N/A'));
        expect(player.club, equals('N/A'));
        expect(player.statistics, isNull);
        expect(player.teamKey, isNull);
      });

      test('parses statistics when present', () {
        final json = {
          'id': '12345',
          'name': 'Alisson Becker',
          'position': 'GK',
          'nationality': 'Brazil',
          'height': '191',
          'weight': '91',
          'number': '1',
          'club': 'Liverpool',
          'stats': {
            'goalkeeper': {
              'saves': 55,
              'cleanSheets': 12,
              'goalsConceded': 18,
              'savePercentage': 75.3,
            },
            'attacking': {
              'goals': 0,
              'assists': 1,
              'shots': 0,
              'shotsOnTarget': 0,
              'minutesPlayed': 3420,
            },
          },
        };

        final player = Player.fromApi(json);

        expect(player.statistics, isNotNull);
        expect(player.statistics!.goalkeeper.saves, equals(55));
        expect(player.statistics!.attacking.minutesPlayed, equals(3420));
      });
    });

    group('toJson', () {
      test('serializes player without statistics', () {
        const player = Player(
          id: 'p1',
          name: 'Kylian Mbappe',
          position: 'ST',
          nationality: 'France',
          height: '178',
          weight: '73',
          number: '7',
          club: 'Real Madrid',
          teamKey: 'france',
        );

        final json = player.toJson();

        expect(json['id'], equals('p1'));
        expect(json['name'], equals('Kylian Mbappe'));
        expect(json['position'], equals('ST'));
        expect(json['nationality'], equals('France'));
        expect(json['height'], equals('178'));
        expect(json['weight'], equals('73'));
        expect(json['number'], equals('7'));
        expect(json['club'], equals('Real Madrid'));
        expect(json['teamKey'], equals('france'));
        expect(json['statistics'], isNull);
      });

      test('serializes player with statistics', () {
        const player = Player(
          id: 'p1',
          name: 'Kylian Mbappe',
          position: 'ST',
          nationality: 'France',
          height: '178',
          weight: '73',
          number: '7',
          club: 'Real Madrid',
          statistics: testStats,
        );

        final json = player.toJson();

        expect(json['statistics'], isNotNull);
        expect(json['statistics']['goalkeeper']['saves'], equals(45));
        expect(json['statistics']['attacking']['goals'], equals(15));
        expect(json['statistics']['creative']['keyPasses'], equals(50));
        expect(json['statistics']['defensive']['tackles'], equals(75));
      });
    });
  });
}
