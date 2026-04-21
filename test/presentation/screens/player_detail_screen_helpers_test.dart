import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/domain/models/player.dart';
import 'package:pregame_world_cup/presentation/screens/player_detail_screen.dart';

/// Tests for `playerHasTournamentHistory` — the gate that decides whether
/// the Player Detail screen shows Tournament Appearances / Goals /
/// Previous Tournaments rows. Zero-ing out these rows for the ~1,200
/// players without stat data keeps the UI from misleadingly claiming
/// every uncapped player "appeared 0 times in a tournament".
void main() {
  group('playerHasTournamentHistory', () {
    test('returns false when every tournament field is empty / zero', () {
      expect(playerHasTournamentHistory(_player()), isFalse);
    });

    test('returns true when player has at least 1 tournament appearance', () {
      expect(
        playerHasTournamentHistory(_player(worldCupAppearances: 1)),
        isTrue,
      );
    });

    test('returns true when player has tournament goals but 0 appearances (defensive)', () {
      expect(
        playerHasTournamentHistory(_player(worldCupGoals: 2)),
        isTrue,
      );
    });

    test('returns true when player has tournament assists', () {
      expect(
        playerHasTournamentHistory(_player(worldCupAssists: 3)),
        isTrue,
      );
    });

    test('returns true when previousWorldCups list is non-empty', () {
      expect(
        playerHasTournamentHistory(_player(previousWorldCups: [2022])),
        isTrue,
      );
    });

    test('returns true when worldCupTournamentStats is non-empty', () {
      final stats = WorldCupTournamentStats(
        year: 2022,
        matches: 4,
        goals: 1,
        assists: 2,
        stage: 'Round of 16',
        keyMoment: 'Goal vs Iran',
      );
      expect(
        playerHasTournamentHistory(
          _player(worldCupTournamentStats: [stats]),
        ),
        isTrue,
      );
    });

    test('returns true for a real player like Pulisic (4 / 1 / 2 / [2022])', () {
      final pulisic = _player(
        worldCupAppearances: 4,
        worldCupGoals: 1,
        worldCupAssists: 2,
        previousWorldCups: [2022],
      );
      expect(playerHasTournamentHistory(pulisic), isTrue);
    });
  });
}

Player _player({
  int worldCupAppearances = 0,
  int worldCupGoals = 0,
  int worldCupAssists = 0,
  List<int> previousWorldCups = const [],
  List<WorldCupTournamentStats> worldCupTournamentStats = const [],
}) {
  return Player(
    playerId: 'test',
    teamCode: 'TST',
    firstName: 'Test',
    lastName: 'Player',
    fullName: 'Test Player',
    commonName: 'Test',
    jerseyNumber: 10,
    position: 'LW',
    dateOfBirth: DateTime(1998, 9, 18),
    age: 27,
    height: 177,
    weight: 70,
    preferredFoot: 'Right',
    club: 'Test FC',
    clubLeague: 'Test League',
    photoUrl: '',
    marketValue: 0,
    caps: 0,
    goals: 0,
    assists: 0,
    worldCupAppearances: worldCupAppearances,
    worldCupGoals: worldCupGoals,
    worldCupAssists: worldCupAssists,
    previousWorldCups: previousWorldCups,
    worldCupTournamentStats: worldCupTournamentStats,
    stats: PlayerStats(
      club: ClubStats(
        season: '2024-25',
        appearances: 0,
        goals: 0,
        assists: 0,
        minutesPlayed: 0,
      ),
      international: InternationalStats(
        appearances: 0,
        goals: 0,
        assists: 0,
        minutesPlayed: 0,
      ),
    ),
    honors: const [],
    strengths: const [],
    weaknesses: const [],
    playStyle: '',
    keyMoment: '',
    comparisonToLegend: '',
    worldCup2026Prediction: '',
    socialMedia: SocialMedia(instagram: '', twitter: '', followers: 0),
    trivia: const [],
  );
}
