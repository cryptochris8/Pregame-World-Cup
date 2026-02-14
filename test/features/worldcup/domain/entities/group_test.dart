import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/group.dart';

void main() {
  group('GroupTeamStanding', () {
    GroupTeamStanding createTestStanding({
      String teamCode = 'USA',
      String teamName = 'United States',
      String? flagUrl,
      int position = 1,
      int played = 3,
      int won = 2,
      int drawn = 1,
      int lost = 0,
      int goalsFor = 5,
      int goalsAgainst = 2,
      int points = 7,
      List<String> form = const ['W', 'D', 'W'],
      bool? hasQualified,
      String? qualificationStatus,
    }) {
      return GroupTeamStanding(
        teamCode: teamCode,
        teamName: teamName,
        flagUrl: flagUrl,
        position: position,
        played: played,
        won: won,
        drawn: drawn,
        lost: lost,
        goalsFor: goalsFor,
        goalsAgainst: goalsAgainst,
        points: points,
        form: form,
        hasQualified: hasQualified,
        qualificationStatus: qualificationStatus,
      );
    }

    group('Constructor', () {
      test('creates standing with required fields', () {
        final standing = createTestStanding();

        expect(standing.teamCode, equals('USA'));
        expect(standing.teamName, equals('United States'));
        expect(standing.position, equals(1));
        expect(standing.played, equals(3));
        expect(standing.won, equals(2));
        expect(standing.drawn, equals(1));
        expect(standing.lost, equals(0));
        expect(standing.goalsFor, equals(5));
        expect(standing.goalsAgainst, equals(2));
        expect(standing.points, equals(7));
      });

      test('creates standing with defaults', () {
        const standing = GroupTeamStanding(
          teamCode: 'ARG',
          teamName: 'Argentina',
          position: 1,
        );

        expect(standing.played, equals(0));
        expect(standing.won, equals(0));
        expect(standing.drawn, equals(0));
        expect(standing.lost, equals(0));
        expect(standing.goalsFor, equals(0));
        expect(standing.goalsAgainst, equals(0));
        expect(standing.points, equals(0));
        expect(standing.form, isEmpty);
      });

      test('creates standing with qualification info', () {
        final standing = createTestStanding(
          hasQualified: true,
          qualificationStatus: 'winner',
        );

        expect(standing.hasQualified, isTrue);
        expect(standing.qualificationStatus, equals('winner'));
      });
    });

    group('goalDifference', () {
      test('calculates positive goal difference', () {
        final standing = createTestStanding(goalsFor: 8, goalsAgainst: 3);
        expect(standing.goalDifference, equals(5));
      });

      test('calculates negative goal difference', () {
        final standing = createTestStanding(goalsFor: 2, goalsAgainst: 7);
        expect(standing.goalDifference, equals(-5));
      });

      test('calculates zero goal difference', () {
        final standing = createTestStanding(goalsFor: 4, goalsAgainst: 4);
        expect(standing.goalDifference, equals(0));
      });
    });

    group('Map serialization', () {
      test('toMap serializes all fields', () {
        final standing = createTestStanding(
          hasQualified: true,
          qualificationStatus: 'winner',
        );
        final map = standing.toMap();

        expect(map['teamCode'], equals('USA'));
        expect(map['teamName'], equals('United States'));
        expect(map['position'], equals(1));
        expect(map['played'], equals(3));
        expect(map['won'], equals(2));
        expect(map['drawn'], equals(1));
        expect(map['lost'], equals(0));
        expect(map['goalsFor'], equals(5));
        expect(map['goalsAgainst'], equals(2));
        expect(map['points'], equals(7));
        expect(map['form'], equals(['W', 'D', 'W']));
        expect(map['hasQualified'], isTrue);
        expect(map['qualificationStatus'], equals('winner'));
      });

      test('fromMap deserializes correctly', () {
        final map = {
          'teamCode': 'BRA',
          'teamName': 'Brazil',
          'position': 2,
          'played': 3,
          'won': 1,
          'drawn': 2,
          'lost': 0,
          'goalsFor': 4,
          'goalsAgainst': 3,
          'points': 5,
          'form': ['W', 'D', 'D'],
          'hasQualified': true,
          'qualificationStatus': 'runner-up',
        };

        final standing = GroupTeamStanding.fromMap(map);

        expect(standing.teamCode, equals('BRA'));
        expect(standing.teamName, equals('Brazil'));
        expect(standing.position, equals(2));
        expect(standing.points, equals(5));
        expect(standing.goalDifference, equals(1));
        expect(standing.form, hasLength(3));
        expect(standing.hasQualified, isTrue);
        expect(standing.qualificationStatus, equals('runner-up'));
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestStanding(
          teamCode: 'GER',
          teamName: 'Germany',
          hasQualified: false,
          qualificationStatus: 'eliminated',
        );
        final map = original.toMap();
        final restored = GroupTeamStanding.fromMap(map);

        expect(restored.teamCode, equals(original.teamCode));
        expect(restored.teamName, equals(original.teamName));
        expect(restored.position, equals(original.position));
        expect(restored.points, equals(original.points));
        expect(restored.goalDifference, equals(original.goalDifference));
        expect(restored.hasQualified, equals(original.hasQualified));
        expect(restored.qualificationStatus, equals(original.qualificationStatus));
      });

      test('fromMap handles missing optional fields', () {
        final map = <String, dynamic>{
          'teamCode': 'ARG',
          'teamName': 'Argentina',
          'position': 1,
        };

        final standing = GroupTeamStanding.fromMap(map);

        expect(standing.played, equals(0));
        expect(standing.points, equals(0));
        expect(standing.form, isEmpty);
        expect(standing.hasQualified, isNull);
        expect(standing.qualificationStatus, isNull);
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final original = createTestStanding();
        final updated = original.copyWith(
          points: 9,
          won: 3,
          hasQualified: true,
        );

        expect(updated.points, equals(9));
        expect(updated.won, equals(3));
        expect(updated.hasQualified, isTrue);
        expect(updated.teamCode, equals(original.teamCode));
        expect(updated.teamName, equals(original.teamName));
      });

      test('preserves unchanged fields', () {
        final original = createTestStanding(
          teamCode: 'FRA',
          teamName: 'France',
          goalsFor: 10,
        );
        final updated = original.copyWith(position: 2);

        expect(updated.teamCode, equals('FRA'));
        expect(updated.teamName, equals('France'));
        expect(updated.goalsFor, equals(10));
      });
    });

    group('Equatable', () {
      test('two standings with same props are equal', () {
        final standing1 = createTestStanding();
        final standing2 = createTestStanding();

        expect(standing1, equals(standing2));
      });

      test('two standings with different points are not equal', () {
        final standing1 = createTestStanding(points: 7);
        final standing2 = createTestStanding(points: 9);

        expect(standing1, isNot(equals(standing2)));
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        final standing = createTestStanding(
          teamName: 'United States',
          position: 1,
          played: 3,
          won: 2,
          drawn: 1,
          lost: 0,
          goalsFor: 5,
          goalsAgainst: 2,
          points: 7,
        );
        final str = standing.toString();

        expect(str, contains('1.'));
        expect(str, contains('United States'));
        expect(str, contains('P:3'));
        expect(str, contains('W:2'));
        expect(str, contains('D:1'));
        expect(str, contains('L:0'));
        expect(str, contains('GD:3'));
        expect(str, contains('Pts:7'));
      });
    });
  });

  group('WorldCupGroup', () {
    GroupTeamStanding createStanding(String code, String name, int pos, int pts) {
      return GroupTeamStanding(
        teamCode: code,
        teamName: name,
        position: pos,
        points: pts,
        played: 3,
      );
    }

    WorldCupGroup createTestGroup({
      String groupLetter = 'A',
      List<GroupTeamStanding>? standings,
      List<String> matchIds = const [],
      int currentMatchDay = 0,
      bool isComplete = false,
      String? winnerTeamCode,
      String? runnerUpTeamCode,
      String? thirdPlaceTeamCode,
      bool? thirdPlaceQualified,
      DateTime? updatedAt,
    }) {
      return WorldCupGroup(
        groupLetter: groupLetter,
        standings: standings ?? [
          createStanding('USA', 'United States', 1, 9),
          createStanding('MEX', 'Mexico', 2, 6),
          createStanding('CAN', 'Canada', 3, 3),
          createStanding('JAM', 'Jamaica', 4, 0),
        ],
        matchIds: matchIds,
        currentMatchDay: currentMatchDay,
        isComplete: isComplete,
        winnerTeamCode: winnerTeamCode,
        runnerUpTeamCode: runnerUpTeamCode,
        thirdPlaceTeamCode: thirdPlaceTeamCode,
        thirdPlaceQualified: thirdPlaceQualified,
        updatedAt: updatedAt,
      );
    }

    group('Constructor', () {
      test('creates group with required fields', () {
        final group = createTestGroup();

        expect(group.groupLetter, equals('A'));
        expect(group.standings, hasLength(4));
        expect(group.isComplete, isFalse);
      });

      test('creates group with all fields', () {
        final group = createTestGroup(
          matchIds: ['m1', 'm2', 'm3', 'm4', 'm5', 'm6'],
          currentMatchDay: 3,
          isComplete: true,
          winnerTeamCode: 'USA',
          runnerUpTeamCode: 'MEX',
          thirdPlaceTeamCode: 'CAN',
          thirdPlaceQualified: false,
        );

        expect(group.matchIds, hasLength(6));
        expect(group.currentMatchDay, equals(3));
        expect(group.isComplete, isTrue);
        expect(group.winnerTeamCode, equals('USA'));
        expect(group.runnerUpTeamCode, equals('MEX'));
        expect(group.thirdPlaceTeamCode, equals('CAN'));
        expect(group.thirdPlaceQualified, isFalse);
      });
    });

    group('getTeamAtPosition', () {
      test('returns team at valid position', () {
        final group = createTestGroup();

        final first = group.getTeamAtPosition(1);
        final second = group.getTeamAtPosition(2);

        expect(first, isNotNull);
        expect(first!.teamCode, equals('USA'));
        expect(second, isNotNull);
        expect(second!.teamCode, equals('MEX'));
      });

      test('returns null for invalid position', () {
        final group = createTestGroup();
        final result = group.getTeamAtPosition(5);
        expect(result, isNull);
      });
    });

    group('sortedStandings', () {
      test('returns standings sorted by position', () {
        final standings = [
          createStanding('D', 'Team D', 4, 0),
          createStanding('B', 'Team B', 2, 6),
          createStanding('A', 'Team A', 1, 9),
          createStanding('C', 'Team C', 3, 3),
        ];
        final group = createTestGroup(standings: standings);

        final sorted = group.sortedStandings;

        expect(sorted[0].position, equals(1));
        expect(sorted[1].position, equals(2));
        expect(sorted[2].position, equals(3));
        expect(sorted[3].position, equals(4));
      });
    });

    group('qualifyingTeams', () {
      test('returns teams that have qualified', () {
        final standings = [
          const GroupTeamStanding(teamCode: 'A', teamName: 'Team A', position: 1, hasQualified: true),
          const GroupTeamStanding(teamCode: 'B', teamName: 'Team B', position: 2, hasQualified: true),
          const GroupTeamStanding(teamCode: 'C', teamName: 'Team C', position: 3, hasQualified: false),
          const GroupTeamStanding(teamCode: 'D', teamName: 'Team D', position: 4, hasQualified: false),
        ];
        final group = createTestGroup(standings: standings);

        final qualifying = group.qualifyingTeams;

        expect(qualifying, hasLength(2));
        expect(qualifying.every((t) => t.hasQualified == true), isTrue);
      });

      test('returns empty list when no teams qualified', () {
        final standings = [
          const GroupTeamStanding(teamCode: 'A', teamName: 'Team A', position: 1),
          const GroupTeamStanding(teamCode: 'B', teamName: 'Team B', position: 2),
        ];
        final group = createTestGroup(standings: standings);

        final qualifying = group.qualifyingTeams;
        expect(qualifying, isEmpty);
      });
    });

    group('Map serialization', () {
      test('toMap serializes all fields', () {
        final group = createTestGroup(
          matchIds: ['m1', 'm2'],
          currentMatchDay: 2,
          isComplete: true,
          winnerTeamCode: 'USA',
        );
        final map = group.toMap();

        expect(map['groupLetter'], equals('A'));
        expect(map['standings'], hasLength(4));
        expect(map['matchIds'], equals(['m1', 'm2']));
        expect(map['currentMatchDay'], equals(2));
        expect(map['isComplete'], isTrue);
        expect(map['winnerTeamCode'], equals('USA'));
      });

      test('fromMap deserializes correctly', () {
        final map = {
          'groupLetter': 'B',
          'standings': [
            {'teamCode': 'ARG', 'teamName': 'Argentina', 'position': 1, 'points': 9},
            {'teamCode': 'BRA', 'teamName': 'Brazil', 'position': 2, 'points': 6},
          ],
          'matchIds': ['m1', 'm2', 'm3'],
          'currentMatchDay': 3,
          'isComplete': true,
          'winnerTeamCode': 'ARG',
          'runnerUpTeamCode': 'BRA',
        };

        final group = WorldCupGroup.fromMap(map);

        expect(group.groupLetter, equals('B'));
        expect(group.standings, hasLength(2));
        expect(group.matchIds, hasLength(3));
        expect(group.currentMatchDay, equals(3));
        expect(group.isComplete, isTrue);
        expect(group.winnerTeamCode, equals('ARG'));
        expect(group.runnerUpTeamCode, equals('BRA'));
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestGroup(
          matchIds: ['m1', 'm2', 'm3', 'm4', 'm5', 'm6'],
          currentMatchDay: 3,
          isComplete: true,
          winnerTeamCode: 'USA',
          runnerUpTeamCode: 'MEX',
        );
        final map = original.toMap();
        final restored = WorldCupGroup.fromMap(map);

        expect(restored.groupLetter, equals(original.groupLetter));
        expect(restored.standings.length, equals(original.standings.length));
        expect(restored.matchIds, equals(original.matchIds));
        expect(restored.currentMatchDay, equals(original.currentMatchDay));
        expect(restored.isComplete, equals(original.isComplete));
        expect(restored.winnerTeamCode, equals(original.winnerTeamCode));
      });
    });

    group('Firestore serialization', () {
      test('toFirestore serializes correctly', () {
        final group = createTestGroup(
          matchIds: ['m1'],
          isComplete: true,
        );
        final data = group.toFirestore();

        expect(data['standings'], hasLength(4));
        expect(data['matchIds'], equals(['m1']));
        expect(data['isComplete'], isTrue);
      });

      test('fromFirestore deserializes correctly', () {
        final data = {
          'standings': [
            {'teamCode': 'GER', 'teamName': 'Germany', 'position': 1},
          ],
          'matchIds': ['m1', 'm2'],
          'currentMatchDay': 1,
          'isComplete': false,
        };

        final group = WorldCupGroup.fromFirestore(data, 'C');

        expect(group.groupLetter, equals('C'));
        expect(group.standings, hasLength(1));
        expect(group.standings.first.teamCode, equals('GER'));
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final original = createTestGroup();
        final updated = original.copyWith(
          isComplete: true,
          winnerTeamCode: 'USA',
          currentMatchDay: 3,
        );

        expect(updated.isComplete, isTrue);
        expect(updated.winnerTeamCode, equals('USA'));
        expect(updated.currentMatchDay, equals(3));
        expect(updated.groupLetter, equals(original.groupLetter));
        expect(updated.standings, equals(original.standings));
      });
    });

    group('applyTiebreakers', () {
      test('sorts teams by points then goal difference', () {
        final standings = [
          const GroupTeamStanding(teamCode: 'A', teamName: 'A', position: 0, points: 6, goalsFor: 4, goalsAgainst: 4),
          const GroupTeamStanding(teamCode: 'B', teamName: 'B', position: 0, points: 6, goalsFor: 8, goalsAgainst: 2),
          const GroupTeamStanding(teamCode: 'C', teamName: 'C', position: 0, points: 9, goalsFor: 5, goalsAgainst: 1),
          const GroupTeamStanding(teamCode: 'D', teamName: 'D', position: 0, points: 0, goalsFor: 1, goalsAgainst: 8),
        ];

        final sorted = WorldCupGroup.applyTiebreakers(standings);

        expect(sorted[0].teamCode, equals('C')); // 9 points
        expect(sorted[1].teamCode, equals('B')); // 6 points, GD +6
        expect(sorted[2].teamCode, equals('A')); // 6 points, GD 0
        expect(sorted[3].teamCode, equals('D')); // 0 points

        // Check positions assigned
        expect(sorted[0].position, equals(1));
        expect(sorted[1].position, equals(2));
        expect(sorted[2].position, equals(3));
        expect(sorted[3].position, equals(4));
      });

      test('uses goals scored as secondary tiebreaker', () {
        final standings = [
          const GroupTeamStanding(teamCode: 'A', teamName: 'A', position: 0, points: 6, goalsFor: 5, goalsAgainst: 3),
          const GroupTeamStanding(teamCode: 'B', teamName: 'B', position: 0, points: 6, goalsFor: 8, goalsAgainst: 6),
        ];

        final sorted = WorldCupGroup.applyTiebreakers(standings);

        // Both have GD +2, but B has more goals scored
        expect(sorted[0].teamCode, equals('B'));
        expect(sorted[1].teamCode, equals('A'));
      });
    });

    group('Equatable', () {
      test('two groups with same props are equal', () {
        final group1 = createTestGroup();
        final group2 = createTestGroup();

        expect(group1, equals(group2));
      });

      test('two groups with different groupLetter are not equal', () {
        final group1 = createTestGroup(groupLetter: 'A');
        final group2 = createTestGroup(groupLetter: 'B');

        expect(group1, isNot(equals(group2)));
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        final group = createTestGroup(groupLetter: 'A');
        expect(group.toString(), equals('Group A'));
      });
    });
  });

  group('GroupUtils', () {
    test('allGroupLetters contains A-L', () {
      expect(GroupUtils.allGroupLetters, hasLength(12));
      expect(GroupUtils.allGroupLetters, contains('A'));
      expect(GroupUtils.allGroupLetters, contains('L'));
      expect(GroupUtils.allGroupLetters, isNot(contains('M')));
    });

    test('constants are correct', () {
      expect(GroupUtils.teamsPerGroup, equals(4));
      expect(GroupUtils.matchesPerGroup, equals(6));
      expect(GroupUtils.totalGroups, equals(12));
      expect(GroupUtils.totalGroupMatches, equals(72));
    });

    test('isValidGroupLetter validates correctly', () {
      expect(GroupUtils.isValidGroupLetter('A'), isTrue);
      expect(GroupUtils.isValidGroupLetter('a'), isTrue);
      expect(GroupUtils.isValidGroupLetter('L'), isTrue);
      expect(GroupUtils.isValidGroupLetter('M'), isFalse);
      expect(GroupUtils.isValidGroupLetter('Z'), isFalse);
    });

    test('getGroupIndex returns correct index', () {
      expect(GroupUtils.getGroupIndex('A'), equals(0));
      expect(GroupUtils.getGroupIndex('B'), equals(1));
      expect(GroupUtils.getGroupIndex('L'), equals(11));
      expect(GroupUtils.getGroupIndex('a'), equals(0));
    });

    test('getGroupLetter returns correct letter', () {
      expect(GroupUtils.getGroupLetter(0), equals('A'));
      expect(GroupUtils.getGroupLetter(1), equals('B'));
      expect(GroupUtils.getGroupLetter(11), equals('L'));
    });

    test('getGroupLetter throws for invalid index', () {
      expect(() => GroupUtils.getGroupLetter(-1), throwsArgumentError);
      expect(() => GroupUtils.getGroupLetter(12), throwsArgumentError);
    });
  });
}
