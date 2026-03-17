import 'dart:math' as math;

/// Computes match outcome probabilities and predicted scores.
///
/// Uses a composite strength score to calculate win/draw/loss probabilities,
/// then predicts the most likely scoreline using a Poisson distribution model
/// calibrated to World Cup scoring averages.
class PredictionProbabilityModel {
  // ========== PROBABILITY CALCULATION ==========

  /// Computes win, draw, loss probabilities from a composite score.
  ///
  /// The composite score S ranges from -1 (away heavily favored) to +1 (home
  /// heavily favored). Returns a map with keys 'home', 'draw', 'away' each
  /// containing probability values (0.0-1.0) that sum to 1.0.
  ///
  /// Knockout matches have reduced draw probability (70% of group stage rate).
  static Map<String, double> computeProbabilities(double S, bool isKnockout) {
    // Base probabilities adjusted by composite score
    var homeWin = 0.36 + 0.28 * S;
    var draw = 0.28 - 0.10 * S.abs();
    var awayWin = 1.0 - homeWin - draw;

    // Knockout matches have lower draw probability
    if (isKnockout) {
      draw *= 0.7;
      // Redistribute draw probability
      final drawReduction = (0.28 - 0.10 * S.abs()) * 0.3;
      if (S >= 0) {
        homeWin += drawReduction * 0.6;
        awayWin += drawReduction * 0.4;
      } else {
        homeWin += drawReduction * 0.4;
        awayWin += drawReduction * 0.6;
      }
    }

    // Clamp to [5%, 90%]
    homeWin = homeWin.clamp(0.05, 0.90);
    draw = draw.clamp(0.05, 0.90);
    awayWin = awayWin.clamp(0.05, 0.90);

    // Renormalize
    final total = homeWin + draw + awayWin;
    return {
      'home': homeWin / total,
      'draw': draw / total,
      'away': awayWin / total,
    };
  }

  // ========== SCORE PREDICTION (Poisson Model) ==========

  /// Predict the most likely scoreline using a Poisson distribution model.
  ///
  /// Estimates expected goals for each team from win/draw/away probabilities,
  /// then optionally adjusts for attack/defense strength imbalances using
  /// positional squad market values. Finally, evaluates all scorelines from
  /// 0-0 through 5-5 and returns the most probable one.
  ///
  /// The base expected goals use the World Cup average of ~2.5 goals per
  /// match, distributed according to each team's share of the outcome
  /// probabilities.
  static Map<String, int> predictScore(
    double homeProb,
    double drawProb,
    double awayProb,
    bool isKnockout, {
    double? homeAttack,
    double? homeDefense,
    double? awayAttack,
    double? awayDefense,
  }) {
    // World Cup average ~2.5 goals per match
    const totalExpectedGoals = 2.5;
    final totalProb = homeProb + drawProb + awayProb;

    // Base expected goals: each team gets goals proportional to their
    // win probability + half the draw probability (shared goal expectation)
    var homeExpected =
        totalExpectedGoals * (homeProb + drawProb * 0.5) / totalProb;
    var awayExpected =
        totalExpectedGoals * (awayProb + drawProb * 0.5) / totalProb;

    // --- Attack/Defense adjustment ---
    // If we have positional strength data for both teams, adjust expected
    // goals based on the matchup: home attack vs away defense, and vice versa.
    if (homeAttack != null &&
        homeDefense != null &&
        awayAttack != null &&
        awayDefense != null &&
        homeAttack > 0 &&
        homeDefense > 0 &&
        awayAttack > 0 &&
        awayDefense > 0) {
      // Ratio > 1 means attacker's unit outvalues defender's unit
      final homeAttackRatio = homeAttack / awayDefense;
      final awayAttackRatio = awayAttack / homeDefense;

      // Use log ratio so extreme differences are dampened, capped at +/-20%
      final homeAdjust =
          (math.log(homeAttackRatio) / math.log(3)).clamp(-0.20, 0.20);
      final awayAdjust =
          (math.log(awayAttackRatio) / math.log(3)).clamp(-0.20, 0.20);

      homeExpected *= (1.0 + homeAdjust);
      awayExpected *= (1.0 + awayAdjust);
    }

    // Clamp expected goals to a realistic range
    homeExpected = homeExpected.clamp(0.3, 3.5);
    awayExpected = awayExpected.clamp(0.3, 3.5);

    // Find the most likely scoreline using Poisson PMF
    double bestProb = 0;
    int bestHome = 0;
    int bestAway = 0;

    for (int h = 0; h <= 5; h++) {
      for (int a = 0; a <= 5; a++) {
        final p = poissonPMF(h, homeExpected) * poissonPMF(a, awayExpected);
        if (p > bestProb) {
          bestProb = p;
          bestHome = h;
          bestAway = a;
        }
      }
    }

    return {'home': bestHome, 'away': bestAway};
  }

  /// Poisson probability mass function: P(X = k) = (lambda^k * e^-lambda) / k!
  static double poissonPMF(int k, double lambda) {
    return math.pow(lambda, k) * math.exp(-lambda) / factorial(k);
  }

  /// Factorial for small non-negative integers (k <= 5 in practice)
  static int factorial(int n) {
    if (n <= 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  // ========== CONFIDENCE ==========

  /// Computes a confidence score (0-100) for the prediction.
  ///
  /// Based on two factors:
  /// - Factor clarity: How decisive the composite score is (abs value)
  /// - Max probability: How confident the outcome probabilities are
  ///
  /// Blends 60% max probability + 40% factor clarity, clamped to 25-92.
  static int computeConfidence(double composite, double homeP, double drawP, double awayP) {
    // Higher |composite| = more decisive factors = higher confidence
    final factorClarity = composite.abs();

    // Higher max probability = more confident outcome
    final maxProb = [homeP, drawP, awayP].reduce(math.max);

    // Blend: 60% from max probability, 40% from factor clarity
    final raw = (maxProb * 60 + factorClarity * 40).round();
    return raw.clamp(25, 92);
  }
}
