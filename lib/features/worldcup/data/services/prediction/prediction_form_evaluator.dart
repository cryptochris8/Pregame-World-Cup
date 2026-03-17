import 'opponent_rankings_data.dart';

/// Utilities for evaluating team form based on recent matches.
///
/// Provides functions to compute form points weighted by opponent quality
/// and competition importance, as well as bonus/penalty calculations for
/// World Cup experience and injuries.
class PredictionFormEvaluator {
  /// Compute form points from recent matches, weighted by opponent quality
  /// and competition importance.
  ///
  /// For each match:
  ///   - Base points: W=3, D=1, L=0
  ///   - Multiply by opponent quality weight (0.5-2.0)
  ///   - Multiply by competition importance (0.7-1.3)
  ///   - Losses get a penalty inversely proportional to opponent strength
  ///
  /// Returns null if no match data. Typical range: -1.0 to +3.0.
  static double? formPoints(List<Map<String, dynamic>>? matches) {
    if (matches == null || matches.isEmpty) return null;

    double totalWeighted = 0;
    double totalWeight = 0;

    for (final m in matches) {
      final match = m as Map<String, dynamic>;
      final result = match['result'] as String?;
      final opponent = match['opponent'] as String?;
      final competition = match['competition'] as String?;

      final opponentRank = estimateOpponentRank(opponent);
      final opponentWeight = opponentQualityWeight(opponentRank);
      final compMultiplier = competitionMultiplier(competition);

      double points;
      if (result == 'W') {
        points = 3.0 * opponentWeight * compMultiplier;
      } else if (result == 'D') {
        points = 1.0 * opponentWeight * compMultiplier;
      } else {
        // Loss: penalty inversely proportional to opponent strength
        // Losing to rank 1 team: -0.5 * (1/1.99) * comp = ~-0.25
        // Losing to rank 150 team: -0.5 * (1/0.5) * comp = -1.0
        points = -0.5 * (1.0 / opponentWeight) * compMultiplier;
      }

      totalWeighted += points;
      totalWeight += compMultiplier;
    }

    if (totalWeight == 0) return null;
    // Normalize so the scale is comparable to the old 0-3 range:
    // Perfect form (all wins vs top teams at continental level):
    //   3.0 * 2.0 * 1.3 = 7.8 per match, but we normalize by weight sum
    //   so a perfect run ~ 7.8 * N / (1.3 * N) = 6.0
    // We scale back to roughly 0-3 range by dividing by 2
    return (totalWeighted / totalWeight) / 2.0;
  }

  /// Estimate FIFA ranking for an opponent by name.
  /// Uses a lookup of approximate rankings for all known opponents.
  /// Returns 100 as default for truly unknown opponents.
  static int estimateOpponentRank(String? opponentName) {
    if (opponentName == null) return 100;
    return opponentRankings[opponentName] ?? 100;
  }

  /// Compute opponent quality weight from estimated FIFA ranking.
  /// Range: 0.5 (rank 200+) to 2.0 (rank ~1).
  static double opponentQualityWeight(int rank) {
    return ((200 - rank) / 100.0).clamp(0.5, 2.0);
  }

  /// Competition importance multiplier.
  /// World Cup qualifiers: 1.2x, continental championships: 1.3x,
  /// Nations League: 1.0x, friendlies: 0.7x.
  static double competitionMultiplier(String? competition) {
    if (competition == null) return 1.0;
    final lower = competition.toLowerCase();

    // Continental championships (highest importance after WC itself)
    if (lower.contains('afcon') ||
        lower.contains('africa cup') ||
        lower.contains('copa america') ||
        lower.contains('euro ') ||
        lower.contains('european championship') ||
        lower.contains('asian cup') ||
        lower.contains('gold cup') ||
        lower.contains('arab cup')) {
      return 1.3;
    }

    // World Cup qualifiers
    if (lower.contains('world cup qual') ||
        lower.contains('wcq') ||
        lower.contains('world cup qualifier')) {
      return 1.2;
    }

    // Nations League (competitive but not as high-stakes)
    if (lower.contains('nations league')) {
      return 1.0;
    }

    // Friendlies
    if (lower.contains('friendly') || lower.contains('kirin cup') ||
        lower.contains('soccer ashes') || lower.contains('al ain')) {
      return 0.7;
    }

    // Default for unknown competitions
    return 1.0;
  }

  /// Bonus score for best World Cup finish
  static double bestFinishBonus(String? bestFinish) {
    if (bestFinish == null) return 0;
    final lower = bestFinish.toLowerCase();
    if (lower.contains('winner') || lower.contains('champion')) return 5;
    if (lower.contains('runner')) return 3;
    if (lower.contains('semi') || lower.contains('third') || lower.contains('fourth')) return 2;
    if (lower.contains('quarter')) return 1;
    return 0;
  }

  /// Sum injury severity for a team's injured players
  static double injurySeverityTotal(List<Map<String, dynamic>> injuries) {
    double total = 0;
    for (final injury in injuries) {
      final status = (injury['availabilityStatus'] as String?) ?? '';
      switch (status) {
        case 'injured':
          total += 1.0;
          break;
        case 'major_doubt':
          total += 0.8;
          break;
        case 'doubt':
          total += 0.5;
          break;
        case 'minor_concern':
          total += 0.2;
          break;
      }
    }
    return total;
  }
}
