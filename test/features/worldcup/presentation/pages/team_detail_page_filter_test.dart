import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/world_cup_match.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/world_cup_match_enums.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/team_detail_page.dart';

/// Regression tests for `filterMatchesForTeam` — the helper that drives the
/// Team Detail page's matches list. Shipped empty in prior builds; these
/// lock in the behavior so it doesn't revert.
WorldCupMatch _match({
  required String id,
  required String home,
  required String away,
  DateTime? at,
}) {
  return WorldCupMatch(
    matchId: id,
    matchNumber: int.tryParse(id.replaceAll(RegExp(r'\D'), '')) ?? 0,
    stage: MatchStage.groupStage,
    homeTeamCode: home,
    homeTeamName: home,
    awayTeamCode: away,
    awayTeamName: away,
    dateTimeUtc: at,
  );
}

void main() {
  group('filterMatchesForTeam', () {
    final argUru = _match(
      id: 'm1', home: 'ARG', away: 'URU',
      at: DateTime.utc(2026, 6, 12, 18),
    );
    final braCrc = _match(
      id: 'm2', home: 'BRA', away: 'CRC',
      at: DateTime.utc(2026, 6, 14, 15),
    );
    final argBra = _match(
      id: 'm3', home: 'ARG', away: 'BRA',
      at: DateTime.utc(2026, 6, 20, 20),
    );
    final espFra = _match(
      id: 'm4', home: 'ESP', away: 'FRA',
      at: DateTime.utc(2026, 6, 15, 12),
    );
    final all = [argUru, braCrc, argBra, espFra];

    test('returns matches where the team is home OR away', () {
      final argMatches = filterMatchesForTeam(all, 'ARG');
      expect(argMatches.map((m) => m.matchId), ['m1', 'm3']);

      final braMatches = filterMatchesForTeam(all, 'BRA');
      expect(braMatches.map((m) => m.matchId), ['m2', 'm3']);
    });

    test('team code match is case-insensitive', () {
      expect(filterMatchesForTeam(all, 'arg').length, 2);
      expect(filterMatchesForTeam(all, 'Arg').length, 2);
      expect(filterMatchesForTeam(all, 'ARG').length, 2);
    });

    test('results are sorted chronologically, earliest first', () {
      final argMatches = filterMatchesForTeam(all, 'ARG');
      expect(argMatches.first.matchId, 'm1'); // June 12
      expect(argMatches.last.matchId, 'm3');  // June 20
    });

    test('returns empty list when team has no matches', () {
      expect(filterMatchesForTeam(all, 'MEX'), isEmpty);
    });

    test('returns empty list when input is empty', () {
      expect(filterMatchesForTeam([], 'ARG'), isEmpty);
    });

    test('returned list is unmodifiable (prevents caller mutation)', () {
      final argMatches = filterMatchesForTeam(all, 'ARG');
      expect(() => argMatches.clear(), throwsUnsupportedError);
    });

    test('matches with null date sort to the end', () {
      final withNull = _match(id: 'mx', home: 'ARG', away: 'CHI');
      final result = filterMatchesForTeam([withNull, argUru, argBra], 'ARG');
      expect(result.first.matchId, 'm1'); // dated
      expect(result.last.matchId, 'mx');  // null date
    });

    test('does not mutate the input list', () {
      final inputCopy = List<WorldCupMatch>.from(all);
      filterMatchesForTeam(all, 'ARG');
      expect(all, equals(inputCopy));
    });
  });
}
