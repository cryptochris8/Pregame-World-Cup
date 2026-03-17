import 'dart:math' as math;
import 'simulation_models.dart';

/// Engine for simulating individual matches and match sequences.
///
/// Handles all match-level simulation logic including:
/// - Computing win/draw/loss probabilities based on Elo ratings
/// - Simulating individual knockout matches
/// - Simulating entire group stages
/// - Generating goal counts for matches
///
/// Uses Elo-based probability calculations with adjustments for:
/// - Home advantage for host nations
/// - Base draw probability
/// - Knockout match rules (extra time, penalties)
class SimulationMatchEngine {
  /// Elo K-factor for rating calculations.
  static const double _eloK = 40.0;

  /// Base probability of a draw in regulation time.
  static const double _baseDrawProb = 0.25;

  /// Elo rating bonus for host nations.
  static const double _hostAdvantage = 100.0;

  /// Set of team codes that are host nations (USA, Canada, Mexico).
  static const Set<String> _hostNations = {'USA', 'CAN', 'MEX'};

  /// Map of team code to Elo rating.
  final Map<String, double> eloRatings;

  /// Creates a match engine with the given Elo ratings.
  ///
  /// [eloRatings] - Map of team codes to their Elo ratings
  SimulationMatchEngine(this.eloRatings);

  /// Computes win/draw/loss probabilities for a match between two teams.
  ///
  /// Returns a map with keys 'win', 'draw', 'loss' representing:
  /// - win: Probability team1 wins in regulation
  /// - draw: Probability of a draw in regulation
  /// - loss: Probability team2 wins in regulation
  ///
  /// [team1Code] - Code of the first team
  /// [team2Code] - Code of the second team
  Map<String, double> computeMatchProbabilities(
    String team1Code,
    String team2Code,
  ) {
    var elo1 = eloRatings[team1Code] ?? 1500.0;
    var elo2 = eloRatings[team2Code] ?? 1500.0;

    // Apply host advantage
    if (_hostNations.contains(team1Code)) elo1 += _hostAdvantage;
    if (_hostNations.contains(team2Code)) elo2 += _hostAdvantage;

    final diff = elo1 - elo2;
    final expected1 = 1.0 / (1.0 + math.pow(10, -diff / 400.0));

    // Allocate some probability to draw
    final drawProb = _baseDrawProb;
    final remaining = 1.0 - drawProb;

    final winProb = expected1 * remaining;
    final lossProb = remaining - winProb;

    return {
      'win': winProb,
      'draw': drawProb,
      'loss': lossProb,
    };
  }

  /// Simulates a knockout match between two teams.
  ///
  /// In knockout matches, there must be a winner (no draws allowed).
  /// If regulation ends in a draw, the match goes to extra time/penalties.
  ///
  /// Returns the team code of the winner.
  ///
  /// [team1Code] - Code of the first team
  /// [team2Code] - Code of the second team
  /// [rng] - Random number generator to use
  String simulateKnockoutMatch(
    String team1Code,
    String team2Code,
    math.Random rng,
  ) {
    final probs = computeMatchProbabilities(team1Code, team2Code);

    final r = rng.nextDouble();
    final winP = probs['win']!;
    final drawP = probs['draw']!;

    if (r < winP) {
      return team1Code;
    } else if (r < winP + drawP) {
      // Draw in regulation → extra time/penalties
      // Use same Elo expectation to decide winner
      final elo1 = eloRatings[team1Code] ?? 1500.0;
      final elo2 = eloRatings[team2Code] ?? 1500.0;
      final diff = elo1 - elo2;
      final expected1 = 1.0 / (1.0 + math.pow(10, -diff / 400.0));

      return rng.nextDouble() < expected1 ? team1Code : team2Code;
    } else {
      return team2Code;
    }
  }

  /// Simulates the complete group stage for all groups.
  ///
  /// Each group plays a round-robin (every team plays every other team once).
  /// Returns standings for all 8 groups.
  ///
  /// [groups] - Map of group letter to list of team codes in that group
  /// [rng] - Random number generator to use
  ///
  /// Returns a map of group letter to list of [GroupStanding] objects,
  /// sorted by final group position (1st to 4th).
  Map<String, List<GroupStanding>> simulateGroupStage(
    Map<String, List<String>> groups,
    math.Random rng,
  ) {
    final standings = <String, List<GroupStanding>>{};

    for (final entry in groups.entries) {
      final group = entry.key;
      final teams = entry.value;

      // Initialize stats for each team
      final stats = <String, Map<String, int>>{};
      for (final t in teams) {
        stats[t] = {'pts': 0, 'gd': 0, 'gf': 0};
      }

      // Round-robin: play all pairs
      for (int i = 0; i < teams.length; i++) {
        for (int j = i + 1; j < teams.length; j++) {
          final t1 = teams[i];
          final t2 = teams[j];

          final probs = computeMatchProbabilities(t1, t2);
          final r = rng.nextDouble();

          final g1 = simulateGoals(t1, rng);
          final g2 = simulateGoals(t2, rng);

          if (r < probs['win']!) {
            // Team 1 wins
            stats[t1]!['pts'] = stats[t1]!['pts']! + 3;
            stats[t1]!['gf'] = stats[t1]!['gf']! + g1;
            stats[t1]!['gd'] = stats[t1]!['gd']! + (g1 - g2);
            stats[t2]!['gf'] = stats[t2]!['gf']! + g2;
            stats[t2]!['gd'] = stats[t2]!['gd']! + (g2 - g1);
          } else if (r < probs['win']! + probs['draw']!) {
            // Draw
            stats[t1]!['pts'] = stats[t1]!['pts']! + 1;
            stats[t2]!['pts'] = stats[t2]!['pts']! + 1;
            final gDraw = math.min(g1, g2);
            stats[t1]!['gf'] = stats[t1]!['gf']! + gDraw;
            stats[t2]!['gf'] = stats[t2]!['gf']! + gDraw;
          } else {
            // Team 2 wins
            stats[t2]!['pts'] = stats[t2]!['pts']! + 3;
            stats[t2]!['gf'] = stats[t2]!['gf']! + g2;
            stats[t2]!['gd'] = stats[t2]!['gd']! + (g2 - g1);
            stats[t1]!['gf'] = stats[t1]!['gf']! + g1;
            stats[t1]!['gd'] = stats[t1]!['gd']! + (g1 - g2);
          }
        }
      }

      // Convert to standings and sort
      final groupStandings = teams
          .map((t) => GroupStanding(
                team: t,
                points: stats[t]!['pts']!,
                goalDiff: stats[t]!['gd']!,
                goalsScored: stats[t]!['gf']!,
              ))
          .toList();

      groupStandings.sort((a, b) {
        if (a.points != b.points) return b.points.compareTo(a.points);
        if (a.goalDiff != b.goalDiff) return b.goalDiff.compareTo(a.goalDiff);
        if (a.goalsScored != b.goalsScored) {
          return b.goalsScored.compareTo(a.goalsScored);
        }
        return a.team.compareTo(b.team); // Tiebreaker
      });

      standings[group] = groupStandings;
    }

    return standings;
  }

  /// Simulates the number of goals a team scores in a match.
  ///
  /// Uses a simple Poisson-like distribution based on team strength.
  /// Returns a goal count between 0 and 5.
  ///
  /// [teamCode] - Code of the team scoring
  /// [rng] - Random number generator to use
  int simulateGoals(String teamCode, math.Random rng) {
    final elo = eloRatings[teamCode] ?? 1500.0;
    // Higher Elo → slightly more goals on average
    // Average team (1500) → ~1.5 goals
    // Strong team (1800) → ~2.0 goals
    final lambda = 1.0 + (elo - 1500.0) / 600.0;

    // Simple Poisson approximation
    final r = rng.nextDouble();
    if (r < math.exp(-lambda)) return 0;
    if (r < math.exp(-lambda) * (1 + lambda)) return 1;
    if (r < math.exp(-lambda) * (1 + lambda + lambda * lambda / 2)) return 2;
    if (r < math.exp(-lambda) * (1 + lambda + lambda * lambda / 2 + math.pow(lambda, 3) / 6)) {
      return 3;
    }
    return rng.nextInt(3) + 2; // 2-4 goals for very high rolls
  }
}
