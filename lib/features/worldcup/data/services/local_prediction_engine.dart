import 'dart:math' as math;

import '../../../../core/services/logging_service.dart';
import '../../domain/entities/entities.dart';
import 'enhanced_match_data_service.dart';

/// Deterministic local prediction engine that generates match predictions
/// entirely from local JSON data — no external API calls.
///
/// Uses a 9-factor weighted scoring algorithm:
///   Betting Odds (25%), FIFA Ranking (20%), Recent Form (15%),
///   Squad Value (10%), Head-to-Head (10%), Manager (5%),
///   Host Advantage (5%), WC Experience (5%), Injury Impact (5%)
class LocalPredictionEngine {
  final EnhancedMatchDataService _data;

  static const String _logTag = 'LocalPredictionEngine';

  // Host nation FIFA codes
  static const _hostNations = {'USA', 'MEX', 'CAN'};

  // Factor weights (sum = 1.0)
  static const _wBettingOdds = 0.25;
  static const _wFifaRanking = 0.20;
  static const _wRecentForm = 0.15;
  static const _wSquadValue = 0.10;
  static const _wHeadToHead = 0.10;
  static const _wManager = 0.05;
  static const _wHostAdvantage = 0.05;
  static const _wWcExperience = 0.05;
  static const _wInjuryImpact = 0.05;

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
    final h2hScore = _scoreHeadToHead(homeCode, awayCode);
    final managerScore = await _scoreManager(homeCode, awayCode);
    final hostScore = _scoreHostAdvantage(homeCode, awayCode);
    final wcExpScore = _scoreWorldCupExperience(homeTeam, awayTeam);
    final injuryScore = _scoreInjuryImpact(homeCode, awayCode);

    // Weighted composite
    final composite = bettingScore * _wBettingOdds +
        rankingScore * _wFifaRanking +
        formScore * _wRecentForm +
        squadScore * _wSquadValue +
        h2hScore * _wHeadToHead +
        managerScore * _wManager +
        hostScore * _wHostAdvantage +
        wcExpScore * _wWcExperience +
        injuryScore * _wInjuryImpact;

    // --- Probabilities ---
    final probs = _computeProbabilities(composite, match.stage.isKnockout);
    final homeProb = probs['home']!;
    final drawProb = probs['draw']!;
    final awayProb = probs['away']!;

    // --- Score prediction ---
    final scores = _predictScore(homeProb, drawProb, awayProb, match.stage.isKnockout);
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

  /// Factor 3: Recent form (W=3, D=1, L=0) over last matches
  double _scoreRecentForm(String homeCode, String awayCode) {
    final homeForm = _data.getRecentForm(homeCode);
    final awayForm = _data.getRecentForm(awayCode);

    final homePoints = _formPoints(homeForm);
    final awayPoints = _formPoints(awayForm);

    if (homePoints == null && awayPoints == null) return 0.0;
    final hp = homePoints ?? 1.5; // neutral default
    final ap = awayPoints ?? 1.5;

    if (hp + ap == 0) return 0.0;
    final diff = (hp - ap) / (hp + ap);
    return diff.clamp(-1.0, 1.0);
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

  /// Factor 5: Head-to-head historical record
  double _scoreHeadToHead(String homeCode, String awayCode) {
    // H2H data is loaded per-pair; use confederation matchup as proxy
    // since individual H2H requires loading specific files
    final homeOdds = _data.getBettingOdds(homeCode);
    final awayOdds = _data.getBettingOdds(awayCode);

    // Use tier comparison as H2H proxy (favorites historically beat underdogs)
    if (homeOdds == null || awayOdds == null) return 0.0;

    final homeTier = _tierToScore(homeOdds['tier'] as String?);
    final awayTier = _tierToScore(awayOdds['tier'] as String?);

    return _tanh((homeTier - awayTier) / 2.0);
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

  // ========== SCORE PREDICTION ==========

  Map<String, int> _predictScore(
    double homeProb,
    double drawProb,
    double awayProb,
    bool isKnockout,
  ) {
    // World Cup score distribution lookup
    // Maps dominant probability to most likely scoreline
    if (drawProb >= homeProb && drawProb >= awayProb) {
      // Draw most likely
      return homeProb > awayProb
          ? {'home': 1, 'away': 1}
          : {'home': 0, 'away': 0};
    }

    if (homeProb > awayProb) {
      // Home favored
      if (homeProb > 0.55) {
        return {'home': 2, 'away': 0};
      } else if (homeProb > 0.45) {
        return {'home': 2, 'away': 1};
      } else {
        return {'home': 1, 'away': 0};
      }
    } else {
      // Away favored
      if (awayProb > 0.55) {
        return {'home': 0, 'away': 2};
      } else if (awayProb > 0.45) {
        return {'home': 1, 'away': 2};
      } else {
        return {'home': 0, 'away': 1};
      }
    }
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

  /// Compute form points from recent matches (W=3, D=1, L=0), averaged per game
  double? _formPoints(Map<String, dynamic>? form) {
    if (form == null) return null;
    final matches = (form['recent_matches'] ?? form['matches']) as List<dynamic>?;
    if (matches == null || matches.isEmpty) return null;

    double total = 0;
    for (final m in matches) {
      final result = (m as Map<String, dynamic>)['result'] as String?;
      if (result == 'W') {
        total += 3;
      } else if (result == 'D') {
        total += 1;
      }
    }
    return total / matches.length;
  }

  /// Convert betting tier to numeric score
  double _tierToScore(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'favorite':
        return 3.0;
      case 'contender':
        return 2.0;
      case 'dark_horse':
      case 'dark horse':
        return 1.0;
      case 'outsider':
        return 0.0;
      case 'long_shot':
      case 'long shot':
        return -1.0;
      default:
        return 0.0;
    }
  }

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
