import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/entities/player.dart';

void main() {
  group('PassingStats', () {
    test('creates stats with required fields', () {
      const stats = PassingStats(
        attempts: 250,
        completions: 175,
        yards: 2500,
        touchdowns: 20,
        interceptions: 5,
        rating: 145.5,
      );

      expect(stats.attempts, equals(250));
      expect(stats.completions, equals(175));
      expect(stats.yards, equals(2500));
      expect(stats.touchdowns, equals(20));
      expect(stats.interceptions, equals(5));
      expect(stats.rating, equals(145.5));
    });

    test('fromJson parses correctly', () {
      final json = {
        'attempts': 300,
        'completions': 200,
        'yards': 3000,
        'touchdowns': 25,
        'interceptions': 8,
        'rating': 150.2,
      };

      final stats = PassingStats.fromJson(json);

      expect(stats.attempts, equals(300));
      expect(stats.completions, equals(200));
      expect(stats.yards, equals(3000));
      expect(stats.touchdowns, equals(25));
      expect(stats.interceptions, equals(8));
      expect(stats.rating, equals(150.2));
    });

    test('fromJson handles null values', () {
      final stats = PassingStats.fromJson({});

      expect(stats.attempts, equals(0));
      expect(stats.completions, equals(0));
      expect(stats.yards, equals(0));
      expect(stats.touchdowns, equals(0));
      expect(stats.interceptions, equals(0));
      expect(stats.rating, equals(0.0));
    });

    test('fromJson parses string values', () {
      final json = {
        'attempts': '100',
        'completions': '65',
        'yards': '850',
        'touchdowns': '7',
        'interceptions': '2',
        'rating': '128.5',
      };

      final stats = PassingStats.fromJson(json);

      expect(stats.attempts, equals(100));
      expect(stats.completions, equals(65));
      expect(stats.yards, equals(850));
      expect(stats.touchdowns, equals(7));
      expect(stats.interceptions, equals(2));
      expect(stats.rating, equals(128.5));
    });

    test('fromJson parses double values as int', () {
      final json = {
        'attempts': 100.7,
        'completions': 65.3,
        'yards': 850.0,
      };

      final stats = PassingStats.fromJson(json);

      expect(stats.attempts, equals(101));
      expect(stats.completions, equals(65));
      expect(stats.yards, equals(850));
    });

    test('completionPercentage calculates correctly', () {
      const stats = PassingStats(
        attempts: 200,
        completions: 150,
        yards: 2000,
        touchdowns: 15,
        interceptions: 5,
        rating: 140.0,
      );

      expect(stats.completionPercentage, equals(75.0));
    });

    test('completionPercentage returns 0 when no attempts', () {
      const stats = PassingStats(
        attempts: 0,
        completions: 0,
        yards: 0,
        touchdowns: 0,
        interceptions: 0,
        rating: 0.0,
      );

      expect(stats.completionPercentage, equals(0.0));
    });

    test('yardsPerAttempt calculates correctly', () {
      const stats = PassingStats(
        attempts: 100,
        completions: 60,
        yards: 800,
        touchdowns: 5,
        interceptions: 2,
        rating: 130.0,
      );

      expect(stats.yardsPerAttempt, equals(8.0));
    });

    test('tdIntRatio calculates correctly', () {
      const stats = PassingStats(
        attempts: 100,
        completions: 60,
        yards: 800,
        touchdowns: 10,
        interceptions: 2,
        rating: 130.0,
      );

      expect(stats.tdIntRatio, equals(5.0));
    });

    test('tdIntRatio returns touchdowns when no interceptions', () {
      const stats = PassingStats(
        attempts: 100,
        completions: 60,
        yards: 800,
        touchdowns: 10,
        interceptions: 0,
        rating: 130.0,
      );

      expect(stats.tdIntRatio, equals(10.0));
    });
  });

  group('RushingStats', () {
    test('creates stats with required fields', () {
      const stats = RushingStats(
        attempts: 150,
        yards: 900,
        touchdowns: 8,
        average: 6.0,
        longRush: 55,
      );

      expect(stats.attempts, equals(150));
      expect(stats.yards, equals(900));
      expect(stats.touchdowns, equals(8));
      expect(stats.average, equals(6.0));
      expect(stats.longRush, equals(55));
    });

    test('fromJson parses correctly', () {
      final json = {
        'attempts': 200,
        'yards': 1200,
        'touchdowns': 12,
        'average': 6.0,
        'longRush': 75,
      };

      final stats = RushingStats.fromJson(json);

      expect(stats.attempts, equals(200));
      expect(stats.yards, equals(1200));
      expect(stats.touchdowns, equals(12));
      expect(stats.average, equals(6.0));
      expect(stats.longRush, equals(75));
    });

    test('fromJson handles null values', () {
      final stats = RushingStats.fromJson({});

      expect(stats.attempts, equals(0));
      expect(stats.yards, equals(0));
      expect(stats.touchdowns, equals(0));
      expect(stats.average, equals(0.0));
      expect(stats.longRush, equals(0));
    });

    test('yardsPerCarry calculates correctly', () {
      const stats = RushingStats(
        attempts: 100,
        yards: 500,
        touchdowns: 5,
        average: 5.0,
        longRush: 40,
      );

      expect(stats.yardsPerCarry, equals(5.0));
    });

    test('yardsPerCarry returns 0 when no attempts', () {
      const stats = RushingStats(
        attempts: 0,
        yards: 0,
        touchdowns: 0,
        average: 0.0,
        longRush: 0,
      );

      expect(stats.yardsPerCarry, equals(0.0));
    });
  });

  group('ReceivingStats', () {
    test('creates stats with required fields', () {
      const stats = ReceivingStats(
        receptions: 80,
        yards: 1100,
        touchdowns: 10,
        average: 13.75,
        longReception: 65,
      );

      expect(stats.receptions, equals(80));
      expect(stats.yards, equals(1100));
      expect(stats.touchdowns, equals(10));
      expect(stats.average, equals(13.75));
      expect(stats.longReception, equals(65));
    });

    test('fromJson parses correctly', () {
      final json = {
        'receptions': 100,
        'yards': 1500,
        'touchdowns': 15,
        'average': 15.0,
        'longReception': 80,
      };

      final stats = ReceivingStats.fromJson(json);

      expect(stats.receptions, equals(100));
      expect(stats.yards, equals(1500));
      expect(stats.touchdowns, equals(15));
      expect(stats.average, equals(15.0));
      expect(stats.longReception, equals(80));
    });

    test('fromJson handles null values', () {
      final stats = ReceivingStats.fromJson({});

      expect(stats.receptions, equals(0));
      expect(stats.yards, equals(0));
      expect(stats.touchdowns, equals(0));
      expect(stats.average, equals(0.0));
      expect(stats.longReception, equals(0));
    });

    test('yardsPerReception calculates correctly', () {
      const stats = ReceivingStats(
        receptions: 50,
        yards: 750,
        touchdowns: 5,
        average: 15.0,
        longReception: 55,
      );

      expect(stats.yardsPerReception, equals(15.0));
    });

    test('yardsPerReception returns 0 when no receptions', () {
      const stats = ReceivingStats(
        receptions: 0,
        yards: 0,
        touchdowns: 0,
        average: 0.0,
        longReception: 0,
      );

      expect(stats.yardsPerReception, equals(0.0));
    });
  });

  group('DefenseStats', () {
    test('creates stats with required fields', () {
      const stats = DefenseStats(
        tackles: 75,
        sacks: 8,
        interceptions: 3,
        passBreakups: 12,
        forcedFumbles: 2,
      );

      expect(stats.tackles, equals(75));
      expect(stats.sacks, equals(8));
      expect(stats.interceptions, equals(3));
      expect(stats.passBreakups, equals(12));
      expect(stats.forcedFumbles, equals(2));
    });

    test('fromJson parses correctly', () {
      final json = {
        'tackles': 100,
        'sacks': 10,
        'interceptions': 5,
        'passBreakups': 15,
        'forcedFumbles': 3,
      };

      final stats = DefenseStats.fromJson(json);

      expect(stats.tackles, equals(100));
      expect(stats.sacks, equals(10));
      expect(stats.interceptions, equals(5));
      expect(stats.passBreakups, equals(15));
      expect(stats.forcedFumbles, equals(3));
    });

    test('fromJson handles null values', () {
      final stats = DefenseStats.fromJson({});

      expect(stats.tackles, equals(0));
      expect(stats.sacks, equals(0));
      expect(stats.interceptions, equals(0));
      expect(stats.passBreakups, equals(0));
      expect(stats.forcedFumbles, equals(0));
    });

    test('defensiveImpact calculates correctly', () {
      const stats = DefenseStats(
        tackles: 50,       // 50
        sacks: 5,          // 5*2 = 10
        interceptions: 2,  // 2*3 = 6
        passBreakups: 8,   // 8
        forcedFumbles: 1,  // 1*2 = 2
      );
      // Total: 50 + 10 + 6 + 8 + 2 = 76

      expect(stats.defensiveImpact, equals(76));
    });
  });

  group('PlayerStatistics', () {
    test('creates with required fields', () {
      const stats = PlayerStatistics(
        passing: PassingStats(
          attempts: 100, completions: 60, yards: 800,
          touchdowns: 5, interceptions: 2, rating: 130.0,
        ),
        rushing: RushingStats(
          attempts: 50, yards: 250, touchdowns: 2,
          average: 5.0, longRush: 30,
        ),
        receiving: ReceivingStats(
          receptions: 0, yards: 0, touchdowns: 0,
          average: 0.0, longReception: 0,
        ),
        defense: DefenseStats(
          tackles: 0, sacks: 0, interceptions: 0,
          passBreakups: 0, forcedFumbles: 0,
        ),
      );

      expect(stats.passing.attempts, equals(100));
      expect(stats.rushing.yards, equals(250));
    });

    test('fromJson parses all stat categories', () {
      final json = {
        'passing': {
          'attempts': 200,
          'completions': 140,
          'yards': 2000,
          'touchdowns': 15,
          'interceptions': 5,
          'rating': 145.0,
        },
        'rushing': {
          'attempts': 30,
          'yards': 150,
          'touchdowns': 1,
          'average': 5.0,
          'longRush': 25,
        },
        'receiving': {
          'receptions': 0,
          'yards': 0,
          'touchdowns': 0,
          'average': 0.0,
          'longReception': 0,
        },
        'defense': {
          'tackles': 0,
          'sacks': 0,
          'interceptions': 0,
          'passBreakups': 0,
          'forcedFumbles': 0,
        },
      };

      final stats = PlayerStatistics.fromJson(json);

      expect(stats.passing.attempts, equals(200));
      expect(stats.passing.yards, equals(2000));
      expect(stats.rushing.yards, equals(150));
    });

    test('fromJson handles missing categories', () {
      final stats = PlayerStatistics.fromJson({});

      expect(stats.passing.attempts, equals(0));
      expect(stats.rushing.attempts, equals(0));
      expect(stats.receiving.receptions, equals(0));
      expect(stats.defense.tackles, equals(0));
    });
  });

  group('Player', () {
    const testPassingStats = PassingStats(
      attempts: 200, completions: 140, yards: 2000,
      touchdowns: 15, interceptions: 5, rating: 145.0,
    );
    const testRushingStats = RushingStats(
      attempts: 30, yards: 150, touchdowns: 1,
      average: 5.0, longRush: 25,
    );
    const testReceivingStats = ReceivingStats(
      receptions: 50, yards: 700, touchdowns: 5,
      average: 14.0, longReception: 55,
    );
    const testDefenseStats = DefenseStats(
      tackles: 75, sacks: 8, interceptions: 3,
      passBreakups: 10, forcedFumbles: 2,
    );

    const testStats = PlayerStatistics(
      passing: testPassingStats,
      rushing: testRushingStats,
      receiving: testReceivingStats,
      defense: testDefenseStats,
    );

    test('creates player with required fields', () {
      const player = Player(
        id: 'p1',
        name: 'John Smith',
        position: 'QB',
        playerClass: 'Junior',
        height: '6-2',
        weight: '215',
        number: '12',
        hometown: 'Austin, TX',
      );

      expect(player.id, equals('p1'));
      expect(player.name, equals('John Smith'));
      expect(player.position, equals('QB'));
      expect(player.playerClass, equals('Junior'));
      expect(player.height, equals('6-2'));
      expect(player.weight, equals('215'));
      expect(player.number, equals('12'));
      expect(player.hometown, equals('Austin, TX'));
    });

    test('creates player with optional fields', () {
      const player = Player(
        id: 'p1',
        name: 'John Smith',
        position: 'QB',
        playerClass: 'Junior',
        height: '6-2',
        weight: '215',
        number: '12',
        hometown: 'Austin, TX',
        statistics: testStats,
        teamKey: 'texas',
      );

      expect(player.statistics, isNotNull);
      expect(player.teamKey, equals('texas'));
    });

    test('displayNameWithPosition formats correctly', () {
      const player = Player(
        id: 'p1',
        name: 'John Smith',
        position: 'QB',
        playerClass: 'Junior',
        height: '6-2',
        weight: '215',
        number: '12',
        hometown: 'Austin, TX',
      );

      expect(player.displayNameWithPosition, equals('John Smith (QB)'));
    });

    test('physicalStats formats correctly', () {
      const player = Player(
        id: 'p1',
        name: 'John Smith',
        position: 'QB',
        playerClass: 'Junior',
        height: '6-2',
        weight: '215',
        number: '12',
        hometown: 'Austin, TX',
      );

      expect(player.physicalStats, equals('6-2, 215 lbs'));
    });

    test('hasStatistics returns false when null', () {
      const player = Player(
        id: 'p1',
        name: 'John Smith',
        position: 'QB',
        playerClass: 'Junior',
        height: '6-2',
        weight: '215',
        number: '12',
        hometown: 'Austin, TX',
      );

      expect(player.hasStatistics, isFalse);
    });

    test('hasStatistics returns true when stats exist', () {
      const player = Player(
        id: 'p1',
        name: 'John Smith',
        position: 'QB',
        playerClass: 'Junior',
        height: '6-2',
        weight: '215',
        number: '12',
        hometown: 'Austin, TX',
        statistics: testStats,
      );

      expect(player.hasStatistics, isTrue);
    });

    group('primaryStat', () {
      test('returns no stats when statistics is null', () {
        const player = Player(
          id: 'p1',
          name: 'John Smith',
          position: 'QB',
          playerClass: 'Junior',
          height: '6-2',
          weight: '215',
          number: '12',
          hometown: 'Austin, TX',
        );

        expect(player.primaryStat, equals('No stats available'));
      });

      test('returns passing stats for QB', () {
        const player = Player(
          id: 'p1',
          name: 'John Smith',
          position: 'QB',
          playerClass: 'Junior',
          height: '6-2',
          weight: '215',
          number: '12',
          hometown: 'Austin, TX',
          statistics: testStats,
        );

        expect(player.primaryStat, equals('2000 pass yds, 15 TDs'));
      });

      test('returns rushing stats for RB', () {
        const player = Player(
          id: 'p2',
          name: 'Mike Johnson',
          position: 'RB',
          playerClass: 'Senior',
          height: '5-10',
          weight: '200',
          number: '22',
          hometown: 'Dallas, TX',
          statistics: testStats,
        );

        expect(player.primaryStat, equals('150 rush yds, 1 TDs'));
      });

      test('returns receiving stats for WR', () {
        const player = Player(
          id: 'p3',
          name: 'Chris Brown',
          position: 'WR',
          playerClass: 'Sophomore',
          height: '6-0',
          weight: '185',
          number: '5',
          hometown: 'Houston, TX',
          statistics: testStats,
        );

        expect(player.primaryStat, equals('700 rec yds, 5 TDs'));
      });

      test('returns receiving stats for TE', () {
        const player = Player(
          id: 'p4',
          name: 'David Wilson',
          position: 'TE',
          playerClass: 'Freshman',
          height: '6-4',
          weight: '245',
          number: '88',
          hometown: 'San Antonio, TX',
          statistics: testStats,
        );

        expect(player.primaryStat, equals('700 rec yds, 5 TDs'));
      });

      test('returns defense stats for defensive players', () {
        const player = Player(
          id: 'p5',
          name: 'James Lee',
          position: 'LB',
          playerClass: 'Junior',
          height: '6-2',
          weight: '230',
          number: '55',
          hometown: 'Fort Worth, TX',
          statistics: testStats,
        );

        expect(player.primaryStat, equals('75 tackles, 8 sacks'));
      });
    });

    group('fromApi', () {
      test('parses basic fields', () {
        final json = {
          'id': '12345',
          'name': 'John Smith',
          'position': 'QB',
          'class': 'Junior',
          'height': '6-2',
          'weight': '215',
          'number': '12',
          'hometown': 'Austin, TX',
          'teamKey': 'texas',
        };

        final player = Player.fromApi(json);

        expect(player.id, equals('12345'));
        expect(player.name, equals('John Smith'));
        expect(player.position, equals('QB'));
        expect(player.playerClass, equals('Junior'));
        expect(player.height, equals('6-2'));
        expect(player.weight, equals('215'));
        expect(player.number, equals('12'));
        expect(player.hometown, equals('Austin, TX'));
        expect(player.teamKey, equals('texas'));
      });

      test('handles null values with defaults', () {
        final player = Player.fromApi({});

        expect(player.id, equals(''));
        expect(player.name, equals('Unknown Player'));
        expect(player.position, equals('N/A'));
        expect(player.playerClass, equals('N/A'));
        expect(player.height, equals('N/A'));
        expect(player.weight, equals('N/A'));
        expect(player.number, equals('N/A'));
        expect(player.hometown, equals('N/A'));
        expect(player.statistics, isNull);
        expect(player.teamKey, isNull);
      });

      test('parses statistics when present', () {
        final json = {
          'id': '12345',
          'name': 'John Smith',
          'position': 'QB',
          'class': 'Junior',
          'height': '6-2',
          'weight': '215',
          'number': '12',
          'hometown': 'Austin, TX',
          'stats': {
            'passing': {
              'attempts': 300,
              'completions': 200,
              'yards': 2500,
              'touchdowns': 20,
              'interceptions': 5,
              'rating': 150.0,
            },
            'rushing': {
              'attempts': 40,
              'yards': 200,
              'touchdowns': 2,
            },
          },
        };

        final player = Player.fromApi(json);

        expect(player.statistics, isNotNull);
        expect(player.statistics!.passing.yards, equals(2500));
        expect(player.statistics!.rushing.yards, equals(200));
      });
    });

    group('toJson', () {
      test('serializes player without statistics', () {
        const player = Player(
          id: 'p1',
          name: 'John Smith',
          position: 'QB',
          playerClass: 'Junior',
          height: '6-2',
          weight: '215',
          number: '12',
          hometown: 'Austin, TX',
          teamKey: 'texas',
        );

        final json = player.toJson();

        expect(json['id'], equals('p1'));
        expect(json['name'], equals('John Smith'));
        expect(json['position'], equals('QB'));
        expect(json['playerClass'], equals('Junior'));
        expect(json['height'], equals('6-2'));
        expect(json['weight'], equals('215'));
        expect(json['number'], equals('12'));
        expect(json['hometown'], equals('Austin, TX'));
        expect(json['teamKey'], equals('texas'));
        expect(json['statistics'], isNull);
      });

      test('serializes player with statistics', () {
        const player = Player(
          id: 'p1',
          name: 'John Smith',
          position: 'QB',
          playerClass: 'Junior',
          height: '6-2',
          weight: '215',
          number: '12',
          hometown: 'Austin, TX',
          statistics: testStats,
        );

        final json = player.toJson();

        expect(json['statistics'], isNotNull);
        expect(json['statistics']['passing']['yards'], equals(2000));
        expect(json['statistics']['rushing']['yards'], equals(150));
        expect(json['statistics']['receiving']['yards'], equals(700));
        expect(json['statistics']['defense']['tackles'], equals(75));
      });
    });
  });
}
