import '../../../../core/services/logging_service.dart';
import '../../domain/entities/entities.dart';
import 'enhanced_match_data_service.dart';
import 'prediction/prediction_factor_scorer.dart';
import 'prediction/prediction_probability_model.dart';
import 'prediction/prediction_narrative_builder.dart';

/// Deterministic local prediction engine that generates match predictions
/// entirely from local JSON data — no external API calls.
///
/// This coordinator orchestrates the prediction process by delegating to
/// specialized components:
/// - PredictionFactorScorer: Computes individual factor scores
/// - PredictionProbabilityModel: Calculates probabilities and predicted scores
/// - PredictionNarrativeBuilder: Generates human-readable analysis
///
/// Uses a 10-factor weighted scoring algorithm:
///   Betting Odds (23%), Elo Rating (18%), Recent Form (15%),
///   Squad Value (10%), Head-to-Head (10%), Manager (5%),
///   Host Advantage (5%), WC Experience (5%), Injury Impact (5%),
///   Confederation Records (4%)
class LocalPredictionEngine {
  final EnhancedMatchDataService _data;
  late final PredictionFactorScorer _factorScorer;
  late final PredictionNarrativeBuilder _narrativeBuilder;

  static const String _logTag = 'LocalPredictionEngine';

  // Factor weights (sum = 1.0)
  static const _wBettingOdds = 0.23;
  static const _wEloRating = 0.18;
  static const _wRecentForm = 0.15;
  static const _wSquadValue = 0.10;
  static const _wHeadToHead = 0.10;
  static const _wManager = 0.05;
  static const _wHostAdvantage = 0.05;
  static const _wWcExperience = 0.05;
  static const _wInjuryImpact = 0.05;
  static const _wConfederationRecord = 0.04;

  LocalPredictionEngine({required EnhancedMatchDataService enhancedDataService})
      : _data = enhancedDataService {
    _factorScorer = PredictionFactorScorer(_data);
    _narrativeBuilder = PredictionNarrativeBuilder(_data);
  }

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
    final bettingScore = _factorScorer.scoreBettingOdds(homeCode, awayCode);
    final eloScore = _factorScorer.scoreEloRating(homeCode, awayCode, homeTeam, awayTeam);
    final formScore = _factorScorer.scoreRecentForm(homeCode, awayCode);
    final squadScore = _factorScorer.scoreSquadValue(homeCode, awayCode);
    final h2hScore = await _factorScorer.scoreHeadToHead(homeCode, awayCode);
    final managerScore = await _factorScorer.scoreManager(homeCode, awayCode);
    final hostScore = _factorScorer.scoreHostAdvantage(homeCode, awayCode);
    final wcExpScore = _factorScorer.scoreWorldCupExperience(homeTeam, awayTeam);
    final injuryScore = _factorScorer.scoreInjuryImpact(homeCode, awayCode);
    final confScore = _factorScorer.scoreConfederationRecord(homeTeam, awayTeam);

    // Weighted composite
    final composite = bettingScore * _wBettingOdds +
        eloScore * _wEloRating +
        formScore * _wRecentForm +
        squadScore * _wSquadValue +
        h2hScore * _wHeadToHead +
        managerScore * _wManager +
        hostScore * _wHostAdvantage +
        wcExpScore * _wWcExperience +
        injuryScore * _wInjuryImpact +
        confScore * _wConfederationRecord;

    // --- Probabilities ---
    final probs = PredictionProbabilityModel.computeProbabilities(
      composite,
      match.stage.isKnockout,
    );
    final homeProb = probs['home']!;
    final drawProb = probs['draw']!;
    final awayProb = probs['away']!;

    // --- Attack/Defense strength decomposition ---
    final homeStrength = await _factorScorer.computeTeamStrength(homeCode);
    final awayStrength = await _factorScorer.computeTeamStrength(awayCode);

    // --- Score prediction (Poisson model with attack/defense adjustment) ---
    final scores = PredictionProbabilityModel.predictScore(
      homeProb, drawProb, awayProb, match.stage.isKnockout,
      homeAttack: homeStrength?['attack'],
      homeDefense: homeStrength?['defense'],
      awayAttack: awayStrength?['attack'],
      awayDefense: awayStrength?['defense'],
    );
    final homeScore = scores['home']!;
    final awayScore = scores['away']!;

    // --- Confidence ---
    final confidence = PredictionProbabilityModel.computeConfidence(
      composite,
      homeProb,
      drawProb,
      awayProb,
    );

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

    final keyFactors = _narrativeBuilder.generateKeyFactors(
      homeName: homeName,
      awayName: awayName,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeCode: homeCode,
      awayCode: awayCode,
      bettingScore: bettingScore,
      eloScore: eloScore,
      formScore: formScore,
      squadScore: squadScore,
      h2hScore: h2hScore,
      hostScore: hostScore,
      injuryScore: injuryScore,
    );

    // --- Load match summary for narrative enrichment ---
    final matchSummary = await _data.getMatchSummary(homeCode, awayCode);

    final analysis = _narrativeBuilder.generateAnalysis(
      homeName: homeName,
      awayName: awayName,
      homeScore: homeScore,
      awayScore: awayScore,
      confidence: confidence,
      composite: composite,
      match: match,
      matchSummary: matchSummary,
    );

    final quickInsight = _narrativeBuilder.generateQuickInsight(
      homeName: homeTeam?.shortName ?? homeName,
      awayName: awayTeam?.shortName ?? awayName,
      homeScore: homeScore,
      awayScore: awayScore,
      confidence: confidence,
      matchSummary: matchSummary,
    );

    // Enhanced narrative sections
    final squadValueNarrative = _narrativeBuilder.buildSquadValueNarrative(homeCode, awayCode);
    final managerMatchupStr = await _narrativeBuilder.buildManagerMatchupNarrative(homeCode, awayCode);
    final historicalPatterns = _narrativeBuilder.buildHistoricalPatterns(homeTeam, awayTeam);
    final isUpsetAlert = _narrativeBuilder.checkUpsetAlert(homeCode, awayCode);
    final upsetAlertText = isUpsetAlert
        ? _narrativeBuilder.buildUpsetAlertText(homeName, awayName, homeCode, awayCode)
        : null;
    final confidenceDebate = confidence < 60
        ? _narrativeBuilder.buildConfidenceDebate(homeName, awayName, confidence, composite)
        : null;
    final homeRecentForm = _data.getRecentFormSummary(homeCode);
    final awayRecentForm = _data.getRecentFormSummary(awayCode);
    final bettingOddsSummary = _narrativeBuilder.buildBettingOddsSummary(homeCode, awayCode, homeName, awayName);

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
}
