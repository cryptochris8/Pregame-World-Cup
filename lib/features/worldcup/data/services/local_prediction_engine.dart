import 'dart:math' as math;

import '../../../../core/services/logging_service.dart';
import '../../domain/entities/entities.dart';
import 'enhanced_match_data_service.dart';

/// Deterministic local prediction engine that generates match predictions
/// entirely from local JSON data — no external API calls.
///
/// Uses a 10-factor weighted scoring algorithm:
///   Betting Odds (23%), FIFA Ranking (18%), Recent Form (15%),
///   Squad Value (10%), Head-to-Head (10%), Manager (5%),
///   Host Advantage (5%), WC Experience (5%), Injury Impact (5%),
///   Confederation Records (4%)
///
/// Score prediction uses a Poisson distribution model calibrated to the
/// World Cup average of ~2.5 goals per match, with attack/defense strength
/// decomposition from positional squad market values.
class LocalPredictionEngine {
  final EnhancedMatchDataService _data;

  static const String _logTag = 'LocalPredictionEngine';

  // Host nation FIFA codes
  static const _hostNations = {'USA', 'MEX', 'CAN'};

  // Factor weights (sum = 1.0)
  static const _wBettingOdds = 0.23;
  static const _wFifaRanking = 0.18;
  static const _wRecentForm = 0.15;
  static const _wSquadValue = 0.10;
  static const _wHeadToHead = 0.10;
  static const _wManager = 0.05;
  static const _wHostAdvantage = 0.05;
  static const _wWcExperience = 0.05;
  static const _wInjuryImpact = 0.05;
  static const _wConfederationRecord = 0.04;

  LocalPredictionEngine({required EnhancedMatchDataService enhancedDataService})
      : _data = enhancedDataService;

  /// Generate a full prediction for a match using local data only.
  Future<AIMatchPrediction> generatePrediction({
    required WorldCupMatch match,
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  }) async {
    await _data.initialize();

    final homeCode = match.homeTeamCode ?? '';
    final awayCode = match.awayTeamCode ?? '';

    LoggingService.info(
      'Generating local prediction: ${match.homeTeamName} vs ${match.awayTeamName}',
      tag: _logTag,
    );

    // --- Compute each factor score (-1 to +1, positive = home-favored) ---
    final bettingScore = _scoreBettingOdds(homeCode, awayCode);
    final rankingScore = _scoreRanking(homeTeam, awayTeam);
    final formScore = _scoreRecentForm(homeCode, awayCode);
    final squadScore = _scoreSquadValue(homeCode, awayCode);
    final h2hScore = await _scoreHeadToHead(homeCode, awayCode);
    final managerScore = await _scoreManager(homeCode, awayCode);
    final hostScore = _scoreHostAdvantage(homeCode, awayCode);
    final wcExpScore = _scoreWorldCupExperience(homeTeam, awayTeam);
    final injuryScore = _scoreInjuryImpact(homeCode, awayCode);
    final confScore = _scoreConfederationRecord(homeTeam, awayTeam);

    // Weighted composite
    final composite = bettingScore * _wBettingOdds +
        rankingScore * _wFifaRanking +
        formScore * _wRecentForm +
        squadScore * _wSquadValue +
        h2hScore * _wHeadToHead +
        managerScore * _wManager +
        hostScore * _wHostAdvantage +
        wcExpScore * _wWcExperience +
        injuryScore * _wInjuryImpact +
        confScore * _wConfederationRecord;

    // --- Probabilities ---
    final probs = _computeProbabilities(composite, match.stage.isKnockout);
    final homeProb = probs['home']!;
    final drawProb = probs['draw']!;
    final awayProb = probs['away']!;

    // --- Attack/Defense strength decomposition ---
    final homeStrength = await _computeTeamStrength(homeCode);
    final awayStrength = await _computeTeamStrength(awayCode);

    // --- Score prediction (Poisson model with attack/defense adjustment) ---
    final scores = _predictScore(
      homeProb, drawProb, awayProb, match.stage.isKnockout,
      homeAttack: homeStrength?['attack'],
      homeDefense: homeStrength?['defense'],
      awayAttack: awayStrength?['attack'],
      awayDefense: awayStrength?['defense'],
    );
    final homeScore = scores['home']!;
    final awayScore = scores['away']!;

    // --- Confidence ---
    final confidence = _computeConfidence(composite, homeProb, drawProb, awayProb);

    // --- Outcome ---
    AIPredictedOutcome outcome;
    if (homeScore > awayScore) {
      outcome = AIPredictedOutcome.homeWin;
    } else if (awayScore > homeScore) {
      outcome = AIPredictedOutcome.awayWin;
    } else {
      outcome = AIPredictedOutcome.draw;
    }

    // --- Narrative generation ---
    final homeName = match.homeTeamName;
    final awayName = match.awayTeamName;

    final keyFactors = _generateKeyFactors(
      homeName: homeName,
      awayName: awayName,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeCode: homeCode,
      awayCode: awayCode,
      bettingScore: bettingScore,
      rankingScore: rankingScore,
      formScore: formScore,
      squadScore: squadScore,
      h2hScore: h2hScore,
      hostScore: hostScore,
      injuryScore: injuryScore,
    );

    final analysis = _generateAnalysis(
      homeName: homeName,
      awayName: awayName,
      homeScore: homeScore,
      awayScore: awayScore,
      confidence: confidence,
      composite: composite,
      match: match,
    );

    final quickInsight = _generateQuickInsight(
      homeName: homeTeam?.shortName ?? homeName,
      awayName: awayTeam?.shortName ?? awayName,
      homeScore: homeScore,
      awayScore: awayScore,
      confidence: confidence,
    );

    // Enhanced narrative sections
    final squadValueNarrative = _buildSquadValueNarrative(homeCode, awayCode);
    final managerMatchupStr = await _buildManagerMatchupNarrative(homeCode, awayCode);
    final historicalPatterns = _buildHistoricalPatterns(homeTeam, awayTeam);
    final isUpsetAlert = _checkUpsetAlert(homeCode, awayCode);
    final upsetAlertText = isUpsetAlert
        ? _buildUpsetAlertText(homeName, awayName, homeCode, awayCode)
        : null;
    final confidenceDebate = confidence < 60
        ? _buildConfidenceDebate(homeName, awayName, confidence, composite)
        : null;
    final homeRecentForm = _data.getRecentFormSummary(homeCode);
    final awayRecentForm = _data.getRecentFormSummary(awayCode);
    final bettingOddsSummary = _buildBettingOddsSummary(homeCode, awayCode, homeName, awayName);

    return AIMatchPrediction(
      matchId: match.matchId,
      predictedOutcome: outcome,
      predictedHomeScore: homeScore,
      predictedAwayScore: awayScore,
      confidence: confidence,
      homeWinProbability: (homeProb * 100).round(),
      drawProbability: (drawProb * 100).round(),
      awayWinProbability: (awayProb * 100).round(),
      keyFactors: keyFactors,
      analysis: analysis,
      quickInsight: quickInsight,
      provider: 'Local Engine',
      generatedAt: DateTime.now(),
      isUpsetAlert: isUpsetAlert,
      upsetAlertText: upsetAlertText,
      squadValueNarrative: squadValueNarrative,
      managerMatchup: managerMatchupStr,
      historicalPatterns: historicalPatterns,
      confidenceDebate: confidenceDebate,
      homeRecentForm: homeRecentForm,
      awayRecentForm: awayRecentForm,
      bettingOddsSummary: bettingOddsSummary,
    );
  }

  // ========== FACTOR SCORING (-1.0 to +1.0, positive = home-favored) ==========

  /// Factor 1: Betting odds implied probability comparison
  double _scoreBettingOdds(String homeCode, String awayCode) {
    final homeOdds = _data.getBettingOdds(homeCode);
    final awayOdds = _data.getBettingOdds(awayCode);
    if (homeOdds == null || awayOdds == null) return 0.0;

    final homeProb = ((homeOdds['implied_probability_pct'] as num?) ?? 0).toDouble();
    final awayProb = ((awayOdds['implied_probability_pct'] as num?) ?? 0).toDouble();

    if (homeProb + awayProb == 0) return 0.0;

    // Normalize difference to [-1, 1]
    final diff = (homeProb - awayProb) / (homeProb + awayProb);
    return diff.clamp(-1.0, 1.0);
  }

  /// Factor 2: FIFA ranking comparison using tanh curve
  double _scoreRanking(NationalTeam? homeTeam, NationalTeam? awayTeam) {
    final homeRank = homeTeam?.fifaRanking ?? 50;
    final awayRank = awayTeam?.fifaRanking ?? 50;

    // Lower rank = better. Positive diff means home is better.
    final diff = awayRank - homeRank;

    // tanh scaling: 20 ranks difference → ~0.96
    return _tanh(diff / 20.0);
  }

  /// Factor 3: Recent form weighted by opponent quality and competition type.
  ///
  /// Uses tanh scaling on the difference so that a ~1.5 point gap maps to
  /// approximately +/-0.8, providing smooth saturation.
  double _scoreRecentForm(String homeCode, String awayCode) {
    final homeForm = _data.getRecentForm(homeCode);
    final awayForm = _data.getRecentForm(awayCode);

    final homePoints = _formPoints(homeForm);
    final awayPoints = _formPoints(awayForm);

    if (homePoints == null && awayPoints == null) return 0.0;
    final hp = homePoints ?? 0.75; // neutral default (midpoint of typical range)
    final ap = awayPoints ?? 0.75;

    // Use tanh scaling: a difference of ~1.5 points maps to ~0.8
    return _tanh((hp - ap) / 1.5);
  }

  /// Factor 4: Squad market value ratio
  double _scoreSquadValue(String homeCode, String awayCode) {
    final home = _data.getSquadValue(homeCode);
    final away = _data.getSquadValue(awayCode);
    if (home == null || away == null) return 0.0;

    final homeVal = ((home['totalValue'] as num?) ?? 0).toDouble();
    final awayVal = ((away['totalValue'] as num?) ?? 0).toDouble();

    if (homeVal + awayVal == 0) return 0.0;

    // Log ratio so extreme differences don't dominate
    final ratio = homeVal / (awayVal > 0 ? awayVal : 1.0);
    return _tanh(math.log(ratio) / math.log(3));
  }

  /// Factor 5: Head-to-head historical record from actual H2H JSON data.
  ///
  /// Loads the H2H file for the team pairing and computes a score based on:
  ///   - Overall win percentage (40% of H2H score)
  ///   - World Cup-specific record (40% of H2H score)
  ///   - Goal difference ratio (20% of H2H score)
  ///
  /// Returns neutral 0.0 if no H2H file exists for the pairing.
  Future<double> _scoreHeadToHead(String homeCode, String awayCode) async {
    final h2h = await _data.getHeadToHead(homeCode, awayCode);
    if (h2h == null) return 0.0;

    final team1Code = (h2h['team1Code'] as String?) ?? '';
    final totalMatches = ((h2h['totalMatches'] as num?) ?? 0).toInt();
    if (totalMatches == 0) return 0.0;

    // Determine which team in the H2H file corresponds to home/away
    final bool homeIsTeam1 = team1Code.toUpperCase() == homeCode.toUpperCase();

    final team1Wins = ((h2h['team1Wins'] as num?) ?? 0).toDouble();
    final team2Wins = ((h2h['team2Wins'] as num?) ?? 0).toDouble();
    final team1Goals = ((h2h['team1Goals'] as num?) ?? 0).toDouble();
    final team2Goals = ((h2h['team2Goals'] as num?) ?? 0).toDouble();
    final wcMatches = ((h2h['worldCupMatches'] as num?) ?? 0).toInt();
    final team1WcWins = ((h2h['team1WorldCupWins'] as num?) ?? 0).toDouble();
    final team2WcWins = ((h2h['team2WorldCupWins'] as num?) ?? 0).toDouble();

    // Map to home/away perspective
    final homeWins = homeIsTeam1 ? team1Wins : team2Wins;
    final awayWins = homeIsTeam1 ? team2Wins : team1Wins;
    final homeGoals = homeIsTeam1 ? team1Goals : team2Goals;
    final awayGoals = homeIsTeam1 ? team2Goals : team1Goals;
    final homeWcWins = homeIsTeam1 ? team1WcWins : team2WcWins;
    final awayWcWins = homeIsTeam1 ? team2WcWins : team1WcWins;

    // --- 1. Overall win percentage (40% of H2H score) ---
    // Normalize: homeWinPct - awayWinPct, range [-1, 1]
    final homeWinPct = homeWins / totalMatches;
    final awayWinPct = awayWins / totalMatches;
    final overallScore = (homeWinPct - awayWinPct).clamp(-1.0, 1.0);

    // --- 2. World Cup-specific record (40% of H2H score) ---
    double wcScore = 0.0;
    if (wcMatches > 0) {
      final homeWcPct = homeWcWins / wcMatches;
      final awayWcPct = awayWcWins / wcMatches;
      wcScore = (homeWcPct - awayWcPct).clamp(-1.0, 1.0);
    }

    // --- 3. Goal difference ratio (20% of H2H score) ---
    double goalScore = 0.0;
    final totalGoals = homeGoals + awayGoals;
    if (totalGoals > 0) {
      goalScore = ((homeGoals - awayGoals) / totalGoals).clamp(-1.0, 1.0);
    }

    // Weighted blend
    final composite = overallScore * 0.4 + wcScore * 0.4 + goalScore * 0.2;
    return composite.clamp(-1.0, 1.0);
  }

  /// Factor 6: Manager WC experience and career win rate
  Future<double> _scoreManager(String homeCode, String awayCode) async {
    final homeManager = await _data.getManagerProfile(homeCode);
    final awayManager = await _data.getManagerProfile(awayCode);
    if (homeManager == null || awayManager == null) return 0.0;

    final homeWinRate = ((homeManager['careerWinPercentage'] as num?) ?? 50).toDouble();
    final awayWinRate = ((awayManager['careerWinPercentage'] as num?) ?? 50).toDouble();

    // Check WC experience
    final homeWcExp = (homeManager['worldCupExperience'] as Map<String, dynamic>?);
    final awayWcExp = (awayManager['worldCupExperience'] as Map<String, dynamic>?);
    final homeWcGames = ((homeWcExp?['matchesAsCoach'] as num?) ?? 0).toDouble();
    final awayWcGames = ((awayWcExp?['matchesAsCoach'] as num?) ?? 0).toDouble();

    // Blend win rate difference + WC experience
    final winRateDiff = (homeWinRate - awayWinRate) / 100.0;
    final expDiff = (homeWcGames - awayWcGames) / 20.0; // 20 games = large diff

    return (winRateDiff * 0.6 + _tanh(expDiff) * 0.4).clamp(-1.0, 1.0);
  }

  /// Factor 7: Host nation advantage
  double _scoreHostAdvantage(String homeCode, String awayCode) {
    final homeIsHost = _hostNations.contains(homeCode);
    final awayIsHost = _hostNations.contains(awayCode);

    if (homeIsHost && !awayIsHost) return 0.3;
    if (awayIsHost && !homeIsHost) return -0.3;
    return 0.0;
  }

  /// Factor 8: World Cup experience (appearances + titles)
  double _scoreWorldCupExperience(NationalTeam? homeTeam, NationalTeam? awayTeam) {
    if (homeTeam == null || awayTeam == null) return 0.0;

    // Score = appearances * 1 + titles * 5 + bestFinish bonus
    final homeExp = homeTeam.worldCupAppearances +
        homeTeam.worldCupTitles * 5 +
        _bestFinishBonus(homeTeam.bestFinish);
    final awayExp = awayTeam.worldCupAppearances +
        awayTeam.worldCupTitles * 5 +
        _bestFinishBonus(awayTeam.bestFinish);

    if (homeExp + awayExp == 0) return 0.0;
    return _tanh((homeExp - awayExp).toDouble() / 15.0);
  }

  /// Factor 9: Injury impact on key players
  double _scoreInjuryImpact(String homeCode, String awayCode) {
    final homeInjuries = _data.getInjuryConcerns(homeCode);
    final awayInjuries = _data.getInjuryConcerns(awayCode);

    // Weight injuries by severity
    final homeImpact = _injurySeverityTotal(homeInjuries);
    final awayImpact = _injurySeverityTotal(awayInjuries);

    // More injuries = worse for that team, so flip sign for home
    if (homeImpact + awayImpact == 0) return 0.0;
    return _tanh((awayImpact - homeImpact) / 3.0);
  }

  /// Factor 10: Confederation historical record at World Cups
  ///
  /// Looks up the head-to-head record between the two teams' confederations
  /// from `confederation_records.json` and scores based on historical win
  /// percentages. Returns 0.0 for intra-confederation matches or missing data.
  double _scoreConfederationRecord(
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  ) {
    if (homeTeam == null || awayTeam == null) return 0.0;

    final homeConf = homeTeam.confederation.displayName;
    final awayConf = awayTeam.confederation.displayName;

    // Same confederation → no inter-confederation advantage
    if (homeConf == awayConf) return 0.0;

    final record = _data.getConfederationMatchup(homeConf, awayConf);
    if (record == null) return 0.0;

    final conf1 = record['confederation1'] as String? ?? '';
    final conf1WinPct = ((record['confederation1WinPct'] as num?) ?? 0).toDouble();
    final conf2WinPct = ((record['confederation2WinPct'] as num?) ?? 0).toDouble();

    // Map to home/away perspective
    final homeWinPct = (conf1 == homeConf) ? conf1WinPct : conf2WinPct;
    final awayWinPct = (conf1 == homeConf) ? conf2WinPct : conf1WinPct;

    if (homeWinPct + awayWinPct == 0) return 0.0;

    // Normalize difference to [-1, 1]
    final diff = (homeWinPct - awayWinPct) / (homeWinPct + awayWinPct);
    return diff.clamp(-1.0, 1.0);
  }

  // ========== ATTACK/DEFENSE STRENGTH DECOMPOSITION ==========

  /// Compute attack, defense, and midfield strength scores for a team
  /// based on positional market values from the squad roster.
  ///
  /// Positions are classified as:
  ///   - Attack: ST, LW, RW, CF, SS (strikers and wingers)
  ///   - Midfield: CAM, CM, CDM, LM, RM (all midfield roles)
  ///   - Defense: CB, LB, RB, LWB, RWB, GK (defenders and goalkeepers)
  ///
  /// Returns a map with keys 'attack', 'defense', 'midfield' containing
  /// the total market value for each unit, or null if data unavailable.
  Future<Map<String, double>?> _computeTeamStrength(String teamCode) async {
    final teamData = await _data.getTeamSquadPlayers(teamCode);
    if (teamData == null) return null;

    final players = teamData['players'] as List<dynamic>?;
    if (players == null || players.isEmpty) return null;

    double attackValue = 0;
    double defenseValue = 0;
    double midfieldValue = 0;

    for (final p in players) {
      final player = p as Map<String, dynamic>;
      final position = (player['position'] as String?) ?? '';
      final value = ((player['marketValue'] as num?) ?? 0).toDouble();

      if (_isAttackPosition(position)) {
        attackValue += value;
      } else if (_isDefensePosition(position)) {
        defenseValue += value;
      } else {
        // Midfield and any unrecognized positions
        midfieldValue += value;
      }
    }

    return {
      'attack': attackValue,
      'defense': defenseValue,
      'midfield': midfieldValue,
    };
  }

  /// Whether a position code is an attacking role
  bool _isAttackPosition(String position) {
    const attackPositions = {'ST', 'LW', 'RW', 'CF', 'SS'};
    return attackPositions.contains(position.toUpperCase());
  }

  /// Whether a position code is a defensive role (including GK)
  bool _isDefensePosition(String position) {
    const defensePositions = {'CB', 'LB', 'RB', 'LWB', 'RWB', 'GK'};
    return defensePositions.contains(position.toUpperCase());
  }

  // ========== PROBABILITY CALCULATION ==========

  Map<String, double> _computeProbabilities(double S, bool isKnockout) {
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
  Map<String, int> _predictScore(
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
        final p = _poissonPMF(h, homeExpected) * _poissonPMF(a, awayExpected);
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
  double _poissonPMF(int k, double lambda) {
    return math.pow(lambda, k) * math.exp(-lambda) / _factorial(k);
  }

  /// Factorial for small non-negative integers (k <= 5 in practice)
  int _factorial(int n) {
    if (n <= 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  // ========== CONFIDENCE ==========

  int _computeConfidence(double composite, double homeP, double drawP, double awayP) {
    // Higher |composite| = more decisive factors = higher confidence
    final factorClarity = composite.abs();

    // Higher max probability = more confident outcome
    final maxProb = [homeP, drawP, awayP].reduce(math.max);

    // Blend: 60% from max probability, 40% from factor clarity
    final raw = (maxProb * 60 + factorClarity * 40).round();
    return raw.clamp(25, 92);
  }

  // ========== NARRATIVE GENERATION ==========

  List<String> _generateKeyFactors({
    required String homeName,
    required String awayName,
    required NationalTeam? homeTeam,
    required NationalTeam? awayTeam,
    required String homeCode,
    required String awayCode,
    required double bettingScore,
    required double rankingScore,
    required double formScore,
    required double squadScore,
    required double h2hScore,
    required double hostScore,
    required double injuryScore,
  }) {
    final factors = <_FactorEntry>[];

    // Ranking
    if (homeTeam?.fifaRanking != null && awayTeam?.fifaRanking != null) {
      final fav = rankingScore > 0 ? homeName : awayName;
      final favRank = rankingScore > 0 ? homeTeam!.fifaRanking : awayTeam!.fifaRanking;
      final undRank = rankingScore > 0 ? awayTeam!.fifaRanking : homeTeam!.fifaRanking;
      factors.add(_FactorEntry(
        rankingScore.abs(),
        '$fav ranked #$favRank vs #$undRank in FIFA rankings',
      ));
    }

    // Form
    if (formScore.abs() > 0.1) {
      final better = formScore > 0 ? homeName : awayName;
      final betterCode = formScore > 0 ? homeCode : awayCode;
      final summary = _data.getRecentFormSummary(betterCode) ?? 'strong recent form';
      factors.add(_FactorEntry(
        formScore.abs(),
        '$better in $summary',
      ));
    }

    // Betting odds
    if (bettingScore.abs() > 0.1) {
      final fav = bettingScore > 0 ? homeName : awayName;
      factors.add(_FactorEntry(
        bettingScore.abs(),
        'Betting markets favor $fav',
      ));
    }

    // Squad value
    if (squadScore.abs() > 0.15) {
      final richer = squadScore > 0 ? homeName : awayName;
      final richerCode = squadScore > 0 ? homeCode : awayCode;
      final sv = _data.getSquadValue(richerCode);
      final valStr = sv?['totalValueFormatted'] ?? 'higher value';
      factors.add(_FactorEntry(
        squadScore.abs(),
        '$richer boast a $valStr squad',
      ));
    }

    // Host advantage
    if (hostScore.abs() > 0) {
      final host = hostScore > 0 ? homeName : awayName;
      factors.add(_FactorEntry(
        0.3,
        '$host have home crowd support as tournament hosts',
      ));
    }

    // Injuries
    if (injuryScore.abs() > 0.1) {
      final hurt = injuryScore < 0 ? homeCode : awayCode;
      final hurtName = injuryScore < 0 ? homeName : awayName;
      final injuries = _data.getInjuryConcerns(hurt);
      if (injuries.isNotEmpty) {
        final names = injuries.take(2).map((i) => i['playerName']).join(', ');
        factors.add(_FactorEntry(
          injuryScore.abs(),
          '$hurtName missing key players: $names',
        ));
      }
    }

    // WC experience
    if (homeTeam != null && awayTeam != null) {
      final homeTitles = homeTeam.worldCupTitles;
      final awayTitles = awayTeam.worldCupTitles;
      if (homeTitles > 0 || awayTitles > 0) {
        final more = homeTitles >= awayTitles ? homeName : awayName;
        final count = math.max(homeTitles, awayTitles);
        factors.add(_FactorEntry(
          0.2,
          '$more bring $count World Cup title${count == 1 ? '' : 's'} of pedigree',
        ));
      }
    }

    // Sort by impact and take top 5
    factors.sort((a, b) => b.weight.compareTo(a.weight));
    return factors.take(5).map((f) => f.text).toList();
  }

  String _generateAnalysis({
    required String homeName,
    required String awayName,
    required int homeScore,
    required int awayScore,
    required int confidence,
    required double composite,
    required WorldCupMatch match,
  }) {
    final winner = homeScore > awayScore
        ? homeName
        : awayScore > homeScore
            ? awayName
            : null;
    final stage = match.stage.displayName;

    if (winner != null) {
      final margin = (homeScore - awayScore).abs();
      final marginDesc = margin >= 2 ? 'comfortably' : 'narrowly';
      return 'Our analysis points to $winner winning $marginDesc $homeScore-$awayScore '
          'in this $stage clash. '
          '${confidence >= 65 ? 'Multiple factors align strongly in their favor.' : 'However, this could be a tight affair with margins thin between the two sides.'}';
    } else {
      return 'This $stage match looks evenly balanced, with a $homeScore-$awayScore draw '
          'the most likely outcome. '
          'Neither side holds a decisive advantage across the key factors.';
    }
  }

  String _generateQuickInsight({
    required String homeName,
    required String awayName,
    required int homeScore,
    required int awayScore,
    required int confidence,
  }) {
    if (homeScore > awayScore) {
      return '$homeName $homeScore-$awayScore ($confidence%)';
    } else if (awayScore > homeScore) {
      return '$awayName $awayScore-$homeScore ($confidence%)';
    } else {
      return 'Draw $homeScore-$awayScore ($confidence%)';
    }
  }

  String? _buildSquadValueNarrative(String homeCode, String awayCode) {
    final comparison = _data.getSquadValueComparison(homeCode, awayCode);
    return comparison?['narrative'] as String?;
  }

  Future<String?> _buildManagerMatchupNarrative(String homeCode, String awayCode) async {
    final homeManager = await _data.getManagerProfile(homeCode);
    final awayManager = await _data.getManagerProfile(awayCode);
    if (homeManager == null || awayManager == null) return null;

    final hName = '${homeManager['firstName']} ${homeManager['lastName']}';
    final aName = '${awayManager['firstName']} ${awayManager['lastName']}';
    final hForm = homeManager['preferredFormation'] ?? 'unknown';
    final aForm = awayManager['preferredFormation'] ?? 'unknown';
    final hStyle = homeManager['coachingStyle'] ?? 'pragmatic';
    final aStyle = awayManager['coachingStyle'] ?? 'pragmatic';

    return '$hName ($hForm, $hStyle) vs $aName ($aForm, $aStyle)';
  }

  List<String> _buildHistoricalPatterns(NationalTeam? homeTeam, NationalTeam? awayTeam) {
    final patterns = _data.getRelevantPatterns(
      homeConfederation: homeTeam?.confederation.displayName,
      awayConfederation: awayTeam?.confederation.displayName,
      isHostNation: homeTeam?.isHostNation ?? false,
    );
    return patterns.map((p) => (p['title'] as String?) ?? '').where((s) => s.isNotEmpty).toList();
  }

  bool _checkUpsetAlert(String homeCode, String awayCode) {
    final upset = _data.getUpsetPotential(homeCode, awayCode);
    return upset?['isUpsetAlert'] == true;
  }

  String _buildUpsetAlertText(
    String homeName,
    String awayName,
    String homeCode,
    String awayCode,
  ) {
    final upset = _data.getUpsetPotential(homeCode, awayCode);
    if (upset == null) return '';

    final underdog = upset['underdog'] == homeCode ? homeName : awayName;
    final chance = upset['underdogChance'] ?? 'a real';
    return 'Upset Alert: $underdog have $chance chance of springing a surprise here.';
  }

  String? _buildConfidenceDebate(
    String homeName,
    String awayName,
    int confidence,
    double composite,
  ) {
    if (confidence >= 60) return null;

    if (confidence < 40) {
      return 'This match is extremely difficult to call. $homeName and $awayName '
          'are closely matched across nearly every metric — rankings, form, '
          'squad value, and betting odds all point to a coin-flip contest.';
    }
    return 'While one side has a slight edge, key factors like form and injuries '
        'could easily swing this result. Do not be surprised by any outcome '
        'in this $homeName vs $awayName clash.';
  }

  String? _buildBettingOddsSummary(
    String homeCode,
    String awayCode,
    String homeName,
    String awayName,
  ) {
    final homeOdds = _data.getBettingOdds(homeCode);
    final awayOdds = _data.getBettingOdds(awayCode);
    if (homeOdds == null || awayOdds == null) return null;

    final homeTier = homeOdds['tier'] as String? ?? 'unknown';
    final awayTier = awayOdds['tier'] as String? ?? 'unknown';
    final homeProb = homeOdds['implied_probability_pct'] ?? 0;
    final awayProb = awayOdds['implied_probability_pct'] ?? 0;

    return '$homeName ($homeTier, $homeProb% to win tournament) vs '
        '$awayName ($awayTier, $awayProb% to win tournament)';
  }

  // ========== HELPERS ==========

  /// Hyperbolic tangent for smooth [-1, 1] mapping
  double _tanh(double x) {
    final e2x = math.exp(2 * x);
    return (e2x - 1) / (e2x + 1);
  }

  /// Compute form points from recent matches, weighted by opponent quality
  /// and competition importance.
  ///
  /// For each match:
  ///   - Base points: W=3, D=1, L=0
  ///   - Opponent weight: `max(0.5, min(2.0, (200 - opponentRank) / 100))`
  ///     so rank 1 -> 1.99, rank 50 -> 1.5, rank 100 -> 1.0, rank 200 -> 0.5
  ///   - Competition multiplier: WC qualifier 1.2, continental 1.3, friendly 0.7, etc.
  ///   - For wins: `3.0 * opponentWeight * competitionMultiplier`
  ///   - For draws: `1.0 * opponentWeight * competitionMultiplier`
  ///   - For losses: penalty = `-0.5 * (1.0 / opponentWeight) * competitionMultiplier`
  ///     (losing to weak teams penalizes more than losing to strong teams)
  ///
  /// Returns weighted average points per match.
  double? _formPoints(Map<String, dynamic>? form) {
    if (form == null) return null;
    final matches = (form['recent_matches'] ?? form['matches']) as List<dynamic>?;
    if (matches == null || matches.isEmpty) return null;

    double totalWeighted = 0;
    double totalWeight = 0;

    for (final m in matches) {
      final match = m as Map<String, dynamic>;
      final result = match['result'] as String?;
      final opponent = match['opponent'] as String?;
      final competition = match['competition'] as String?;

      final opponentRank = _estimateOpponentRank(opponent);
      final opponentWeight = _opponentQualityWeight(opponentRank);
      final compMultiplier = _competitionMultiplier(competition);

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
  int _estimateOpponentRank(String? opponentName) {
    if (opponentName == null) return 100;
    return _opponentRankings[opponentName] ?? 100;
  }

  /// Compute opponent quality weight from estimated FIFA ranking.
  /// Range: 0.5 (rank 200+) to 2.0 (rank ~1).
  double _opponentQualityWeight(int rank) {
    return ((200 - rank) / 100.0).clamp(0.5, 2.0);
  }

  /// Competition importance multiplier.
  /// World Cup qualifiers: 1.2x, continental championships: 1.3x,
  /// Nations League: 1.0x, friendlies: 0.7x.
  double _competitionMultiplier(String? competition) {
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

  /// Approximate FIFA rankings for all known opponents in the recent form data.
  /// Rankings are based on the FIFA/Coca-Cola Men's World Ranking (Jan 2026).
  /// Non-WC teams use estimated rankings from publicly available data.
  static const Map<String, int> _opponentRankings = {
    // WC 2026 qualified teams (48 teams)
    'Spain': 1,
    'Argentina': 2,
    'France': 3,
    'England': 4,
    'Brazil': 5,
    'Belgium': 6,
    'Netherlands': 7,
    'Morocco': 8,
    'Portugal': 9,
    'Colombia': 10,
    'Italy': 11,
    'Senegal': 12,
    'Germany': 13,
    'Croatia': 14,
    'Uruguay': 15,
    'Japan': 16,
    'United States': 17,
    'Mexico': 18,
    'Ecuador': 19,
    'Denmark': 20,
    'Turkey': 21,
    'Egypt': 22,
    'Serbia': 23,
    'South Korea': 24,
    'Switzerland': 25,
    'Iran': 26,
    'Australia': 27,
    'Nigeria': 28,
    'Norway': 29,
    'Poland': 30,
    'Canada': 31,
    'Saudi Arabia': 32,
    'Cameroon': 33,
    'Panama': 34,
    'Qatar': 35,
    'Paraguay': 36,
    'Slovenia': 37,
    'Costa Rica': 38,
    'Bolivia': 39,
    'Uzbekistan': 40,
    'Jamaica': 41,
    'Indonesia': 42,
    'Albania': 43,
    'Chile': 44,
    'Peru': 45,
    'Honduras': 46,
    'New Zealand': 47,
    'Trinidad and Tobago': 48,
    // Non-WC opponents (estimated from FIFA rankings)
    'Algeria': 35,
    'Andorra': 155,
    'Angola': 80,
    'Armenia': 95,
    'Azerbaijan': 110,
    'Bahrain': 85,
    'Belarus': 90,
    'Benin': 90,
    'Bermuda': 170,
    'Bosnia and Herzegovina': 55,
    'Botswana': 140,
    'Bulgaria': 70,
    'Burkina Faso': 50,
    'Cape Verde': 60,
    'Central African Republic': 130,
    'Chad': 160,
    'China': 75,
    'Comoros': 110,
    'Congo': 85,
    'Cote d\'Ivoire': 38,
    'Ivory Coast': 38,
    'Cuba': 170,
    'Curacao': 80,
    'Cyprus': 105,
    'Czech Republic': 40,
    'DR Congo': 55,
    'Dominican Republic': 150,
    'El Salvador': 75,
    'Equatorial Guinea': 90,
    'Estonia': 115,
    'Eswatini': 150,
    'Faroe Islands': 120,
    'Fiji': 160,
    'Finland': 60,
    'Gabon': 85,
    'Georgia': 50,
    'Ghana': 45,
    'Gibraltar': 195,
    'Greece': 45,
    'Guadeloupe': 165,
    'Guatemala': 80,
    'Haiti': 85,
    'Hungary': 35,
    'Iceland': 65,
    'Iraq': 55,
    'Israel': 70,
    'Jordan': 65,
    'Kazakhstan': 100,
    'Kenya': 95,
    'Kosovo': 100,
    'Kuwait': 140,
    'Kyrgyz Republic': 95,
    'Kyrgyzstan': 95,
    'Latvia': 110,
    'Lesotho': 145,
    'Liberia': 120,
    'Libya': 95,
    'Liechtenstein': 190,
    'Lithuania': 115,
    'Luxembourg': 85,
    'Malaysia': 130,
    'Mali': 45,
    'Malta': 165,
    'Mauritius': 175,
    'Moldova': 115,
    'Montenegro': 70,
    'Mozambique': 95,
    'New Caledonia': 160,
    'Nicaragua': 140,
    'North Korea': 110,
    'North Macedonia': 65,
    'Northern Ireland': 55,
    'Oman': 75,
    'Palestine': 100,
    'Puerto Rico': 170,
    'Republic of Ireland': 55,
    'Romania': 35,
    'Rwanda': 120,
    'San Marino': 210,
    'Scotland': 40,
    'Seychelles': 195,
    'Slovakia': 45,
    'South Africa': 55,
    'Sudan': 120,
    'Suriname': 130,
    'Sweden': 40,
    'Tanzania': 115,
    'Tunisia': 35,
    'UAE': 65,
    'United Arab Emirates': 65,
    'Uganda': 80,
    'Ukraine': 25,
    'Venezuela': 45,
    'Wales': 60,
    'Zambia': 80,
    'Zimbabwe': 105,
  };

  /// Bonus score for best World Cup finish
  double _bestFinishBonus(String? bestFinish) {
    if (bestFinish == null) return 0;
    final lower = bestFinish.toLowerCase();
    if (lower.contains('winner') || lower.contains('champion')) return 5;
    if (lower.contains('runner')) return 3;
    if (lower.contains('semi') || lower.contains('third') || lower.contains('fourth')) return 2;
    if (lower.contains('quarter')) return 1;
    return 0;
  }

  /// Sum injury severity for a team's injured players
  double _injurySeverityTotal(List<Map<String, dynamic>> injuries) {
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

/// Internal helper for sorting factors by weight
class _FactorEntry {
  final double weight;
  final String text;
  _FactorEntry(this.weight, this.text);
}
