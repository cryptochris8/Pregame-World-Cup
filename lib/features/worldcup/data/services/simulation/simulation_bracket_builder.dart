import 'dart:math' as math;
import 'simulation_models.dart';
import 'simulation_match_engine.dart';

/// Builds knockout brackets and computes bracket advancement probabilities.
///
/// Handles:
/// - Constructing the round of 32 bracket from group stage results
/// - Precomputing pairwise advancement probabilities for bracket paths
/// - Applying FIFA World Cup bracket rules (group restrictions, etc.)
class SimulationBracketBuilder {
  /// Set of all valid team codes in the tournament.
  final Set<String> validTeamCodes;

  /// Match engine for computing match probabilities.
  final SimulationMatchEngine matchEngine;

  /// Creates a bracket builder.
  ///
  /// [validTeamCodes] - Set of all team codes participating in the tournament
  /// [matchEngine] - Match engine for probability calculations
  SimulationBracketBuilder(
    this.validTeamCodes,
    this.matchEngine,
  );

  /// Builds the round of 32 bracket based on group stage results.
  ///
  /// The World Cup round of 32 bracket follows a specific structure:
  /// - Group winners play third-place teams or runners-up from other groups
  /// - Teams from the same group cannot meet until later rounds
  /// - The bracket structure is predetermined by FIFA rules
  ///
  /// [groupStandings] - Map of group letter to sorted list of standings
  ///
  /// Returns a list of 16 matchups, where each matchup is a list of 2 team codes.
  List<List<String>> buildR32Bracket(
    Map<String, List<GroupStanding>> groupStandings,
  ) {
    // Extract 1st, 2nd, 3rd place teams from each group
    final winners = <String, String>{};
    final runnersUp = <String, String>{};
    final thirdPlace = <ThirdPlaceEntry>[];

    for (final entry in groupStandings.entries) {
      final group = entry.key;
      final standings = entry.value;

      if (standings.length >= 3) {
        winners[group] = standings[0].team;
        runnersUp[group] = standings[1].team;
        thirdPlace.add(ThirdPlaceEntry(
          group: group,
          team: standings[2].team,
          points: standings[2].points,
          goalDiff: standings[2].goalDiff,
          goalsScored: standings[2].goalsScored,
        ));
      }
    }

    // Sort third-place teams to determine top 4
    thirdPlace.sort((a, b) {
      if (a.points != b.points) return b.points.compareTo(a.points);
      if (a.goalDiff != b.goalDiff) return b.goalDiff.compareTo(a.goalDiff);
      if (a.goalsScored != b.goalsScored) {
        return b.goalsScored.compareTo(a.goalsScored);
      }
      return a.team.compareTo(b.team);
    });

    final qualifiedThird = thirdPlace.take(8).toList();

    // FIFA World Cup 2026 bracket structure (simplified version)
    // The actual structure is complex and depends on which third-place teams qualify
    // This is a simplified model that creates valid matchups
    final bracket = <List<String>>[];

    // Create matchups following general principles:
    // - Winners vs runners-up or third-place teams
    // - Avoid same-group matchups in R32
    final groups = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'];

    // Simplified bracket construction
    // In reality, FIFA has a complex predetermined structure
    final usedTeams = <String>{};

    // Match winners with runners-up from different groups
    for (final group in groups) {
      if (bracket.length >= 16) break;

      final winner = winners[group];
      if (winner == null || usedTeams.contains(winner)) continue;

      // Find a runner-up from a different group
      String? opponent;
      for (final otherGroup in groups) {
        if (otherGroup == group) continue;
        final runnerUp = runnersUp[otherGroup];
        if (runnerUp != null && !usedTeams.contains(runnerUp)) {
          opponent = runnerUp;
          break;
        }
      }

      // If no runner-up available, try third-place teams
      if (opponent == null) {
        for (final third in qualifiedThird) {
          if (third.group != group && !usedTeams.contains(third.team)) {
            opponent = third.team;
            break;
          }
        }
      }

      if (opponent != null) {
        bracket.add([winner, opponent]);
        usedTeams.add(winner);
        usedTeams.add(opponent);
      }
    }

    // Fill remaining slots with any remaining qualified teams
    final allQualified = <String>[
      ...winners.values,
      ...runnersUp.values,
      ...qualifiedThird.map((e) => e.team),
    ];

    for (final team in allQualified) {
      if (bracket.length >= 16) break;
      if (usedTeams.contains(team)) continue;

      // Find another unused team
      for (final opponent in allQualified) {
        if (opponent == team || usedTeams.contains(opponent)) continue;

        bracket.add([team, opponent]);
        usedTeams.add(team);
        usedTeams.add(opponent);
        break;
      }
    }

    return bracket;
  }

  /// Precomputes pairwise advancement probabilities for all team pairs.
  ///
  /// For each possible matchup between two teams, computes the probability
  /// that each team would advance through a knockout match.
  ///
  /// This is used to efficiently simulate bracket advancement without
  /// simulating every individual match.
  ///
  /// Returns a map where the key is a sorted pair of team codes (e.g., "ARG_BRA")
  /// and the value is the probability that the first team (alphabetically) wins.
  Map<String, double> precomputePairwiseProbs() {
    final pairwiseProbs = <String, double>{};
    final teams = validTeamCodes.toList();

    for (int i = 0; i < teams.length; i++) {
      for (int j = i + 1; j < teams.length; j++) {
        final t1 = teams[i];
        final t2 = teams[j];

        final probs = matchEngine.computeMatchProbabilities(t1, t2);

        // In knockout, draw goes to extra time
        // Probability t1 wins = P(win in regulation) + P(draw) * P(win in ET/pens)
        final winInReg = probs['win']!;
        final drawInReg = probs['draw']!;

        // For extra time/penalties, use same Elo expectation
        final elo1 = matchEngine.eloRatings[t1] ?? 1500.0;
        final elo2 = matchEngine.eloRatings[t2] ?? 1500.0;
        final diff = elo1 - elo2;
        final expected1 = 1.0 / (1.0 + math.pow(10, -diff / 400.0));

        final totalProb = winInReg + drawInReg * expected1;

        final key = [t1, t2]..sort();
        pairwiseProbs['${key[0]}_${key[1]}'] = t1 == key[0] ? totalProb : 1.0 - totalProb;
      }
    }

    return pairwiseProbs;
  }
}
