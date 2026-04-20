import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/data/mock/world_cup_mock_data.dart';

/// Regression tests for WorldCupMockData.
///
/// These exist because a bug was shipped where only groups A-D were defined
/// in the mock, causing the Groups tab to show only the first 4 groups
/// whenever the app fell back to mock data (e.g., when Firestore had no
/// worldcup_groups documents seeded). 2026 World Cup has 48 teams split
/// into 12 groups of 4, so the mock must define all 12 groups A-L.
void main() {
  group('WorldCupMockData.groups', () {
    test('defines exactly 12 groups (A-L)', () {
      expect(WorldCupMockData.groups, hasLength(12));
    });

    test('covers every group letter A through L', () {
      final letters = WorldCupMockData.groups.map((g) => g.groupLetter).toSet();
      expect(letters, {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
      });
    });

    test('each group has exactly 4 teams', () {
      for (final g in WorldCupMockData.groups) {
        expect(g.standings, hasLength(4),
            reason: 'Group ${g.groupLetter} should have 4 teams');
      }
    });

    test('all 48 teams are unique across groups (no team in two groups)', () {
      final teamCodes = <String>[];
      for (final g in WorldCupMockData.groups) {
        teamCodes.addAll(g.standings.map((s) => s.teamCode));
      }
      expect(teamCodes, hasLength(48),
          reason: 'Expect 48 team appearances total across 12 groups');
      expect(teamCodes.toSet(), hasLength(48),
          reason: 'No team should appear in more than one group');
    });

    test('positions within each group are 1-4 with no duplicates', () {
      for (final g in WorldCupMockData.groups) {
        final positions = g.standings.map((s) => s.position).toList()..sort();
        expect(positions, [1, 2, 3, 4],
            reason: 'Group ${g.groupLetter} has invalid positions: $positions');
      }
    });
  });
}
