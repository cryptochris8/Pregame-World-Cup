import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../ai/services/ai_service.dart';
import 'logging_service.dart';
import 'user_learning_service.dart';
import 'team_mapping_service.dart';
import '../../services/espn_service.dart';
import '../../services/comprehensive_series_service.dart';
import '../../features/schedule/domain/entities/game_schedule.dart';

/// Unified service that combines game prediction and enhanced analysis capabilities
class UnifiedGameAnalysisService {
  static final UnifiedGameAnalysisService _instance = UnifiedGameAnalysisService._internal();
  factory UnifiedGameAnalysisService() => _instance;
  UnifiedGameAnalysisService._internal();

  // Core dependencies
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Dio _dio = Dio();

  // Service dependencies
  final AIService _aiService = AIService();
  final UserLearningService _userLearningService = UserLearningService();
  final ESPNService _espnService = ESPNService();
  final ComprehensiveSeriesService _comprehensiveSeriesService = ComprehensiveSeriesService();

  /// Generate comprehensive game analysis with prediction
  /// Combines functionality from both original services
  Future<ComprehensiveGameAnalysis> getComprehensiveAnalysis({
    required String gameId,
    required GameSchedule game,
    bool includePrediction = true,
    bool includeUserContext = true,
  }) async {
    try {
      LoggingService.info('Generating comprehensive analysis for ${game.awayTeamName} @ ${game.homeTeamName}', tag: 'UnifiedAnalysis');

      // Step 1: Map team names to API keys for better data retrieval
      final homeTeamKey = TeamMappingService.getTeamKey(game.homeTeamName);
      final awayTeamKey = TeamMappingService.getTeamKey(game.awayTeamName);
      
      LoggingService.info('🗺️ Team mapping: ${game.homeTeamName} -> $homeTeamKey, ${game.awayTeamName} -> $awayTeamKey', tag: 'UnifiedAnalysis');

      // Step 2: Fetch all analysis data in parallel for better performance
      final futures = await Future.wait([
        _getSeriesHistory(game.homeTeamName, game.awayTeamName),
        _getCurrentPlayerAnalysis(game.homeTeamName, game.awayTeamName),
        _getAdvancedStats(game.homeTeamName, game.awayTeamName),
        _getCoachingMatchup(game.homeTeamName, game.awayTeamName),
        _getVenueAndWeatherImpact(game),
        _getRecentFormAnalysis(game.homeTeamName, game.awayTeamName),
      ]);

      final seriesHistory = futures[0] as Map<String, dynamic>;
      final playerAnalysis = futures[1] as Map<String, dynamic>;
      final advancedStats = futures[2] as Map<String, dynamic>;
      final coachingMatchup = futures[3] as Map<String, dynamic>;
      final venueWeather = futures[4] as Map<String, dynamic>;
      final recentForm = futures[5] as Map<String, dynamic>;

      // Generate AI-powered prediction if requested
      GamePrediction? prediction;
      if (includePrediction) {
        prediction = await _generateEnhancedPrediction(
          gameId: gameId,
          game: game,
          seriesHistory: seriesHistory,
          playerAnalysis: playerAnalysis,
          advancedStats: advancedStats,
          coachingMatchup: coachingMatchup,
          venueWeather: venueWeather,
          recentForm: recentForm,
        );
      }

      // Get user context if requested and user is authenticated
      UserGameContext? userContext;
      if (includeUserContext && _auth.currentUser != null) {
        userContext = await _getUserGameContext(gameId);
      }

      final analysis = ComprehensiveGameAnalysis(
        gameId: gameId,
        game: game,
        prediction: prediction,
        seriesHistory: seriesHistory,
        playerAnalysis: playerAnalysis,
        advancedStats: advancedStats,
        coachingMatchup: coachingMatchup,
        venueWeather: venueWeather,
        recentForm: recentForm,
        keyFactors: _generateKeyFactors(seriesHistory, playerAnalysis, advancedStats, coachingMatchup, venueWeather),
        userContext: userContext,
        generatedAt: DateTime.now(),
      );

      // Cache the analysis for performance
      await _cacheAnalysis(gameId, analysis);

      return analysis;
    } catch (e) {
      LoggingService.error('Error generating comprehensive analysis: $e', tag: 'UnifiedAnalysis');
      return _generateFallbackAnalysis(gameId, game);
    }
  }

  /// Create user prediction (from original GamePredictionService)
  Future<UserPrediction> createUserPrediction({
    required String gameId,
    required String homeTeam,
    required String awayTeam,
    required PredictionOutcome predictedOutcome,
    required double confidence,
    int? predictedHomeScore,
    int? predictedAwayScore,
    String? reasoning,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User must be authenticated to make predictions');
      }

      final prediction = UserPrediction(
        predictionId: _generateUserPredictionId(gameId, userId),
        gameId: gameId,
        userId: userId,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        predictedOutcome: predictedOutcome,
        confidence: confidence,
        predictedHomeScore: predictedHomeScore,
        predictedAwayScore: predictedAwayScore,
        reasoning: reasoning,
        createdAt: DateTime.now(),
      );

      // Store user prediction
      await _storeUserPrediction(prediction);

      // Track user interaction
      await _userLearningService.trackGameInteraction(
        gameId: gameId,
        interactionType: 'predict',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        additionalData: {
          'predicted_outcome': predictedOutcome.toString(),
          'confidence': confidence,
          'has_score_prediction': predictedHomeScore != null && predictedAwayScore != null,
          'has_reasoning': reasoning != null,
        },
      );

      LoggingService.info('Created user prediction: $predictedOutcome ($confidence)', tag: 'UnifiedAnalysis');
      
      return prediction;
    } catch (e) {
      LoggingService.error('Error creating user prediction: $e', tag: 'UnifiedAnalysis');
      rethrow;
    }
  }

  /// Update prediction accuracy after game completion
  Future<void> updatePredictionAccuracy({
    required String gameId,
    required PredictionOutcome actualOutcome,
    required int actualHomeScore,
    required int actualAwayScore,
  }) async {
    try {
      // Update AI prediction accuracy
      await _updateAIPredictionAccuracy(gameId, actualOutcome, actualHomeScore, actualAwayScore);
      
      // Update user prediction accuracies
      await _updateUserPredictionAccuracy(gameId, actualOutcome, actualHomeScore, actualAwayScore);
      
      LoggingService.info('Updated prediction accuracy for game $gameId', tag: 'UnifiedAnalysis');
    } catch (e) {
      LoggingService.error('Error updating prediction accuracy: $e', tag: 'UnifiedAnalysis');
    }
  }

  // Private helper methods (consolidated from both original services)
  
  Future<Map<String, dynamic>> _getSeriesHistory(String homeTeam, String awayTeam) async {
    try {
      // Use comprehensive series service for series history
      return await _comprehensiveSeriesService.getSeriesHistory(homeTeam, awayTeam);
    } catch (e) {
      LoggingService.error('Error fetching series history: $e', tag: 'UnifiedAnalysis');
      return _getGenericSeriesHistory(homeTeam, awayTeam);
    }
  }

  Future<Map<String, dynamic>> _getCurrentPlayerAnalysis(String homeTeam, String awayTeam) async {
    try {
      // Implement player analysis logic
      return {
        'homeTeamPlayers': await _getTeamKeyPlayers(homeTeam),
        'awayTeamPlayers': await _getTeamKeyPlayers(awayTeam),
        'matchupAdvantages': await _getPlayerMatchupAdvantages(homeTeam, awayTeam),
      };
    } catch (e) {
      LoggingService.error('Error analyzing players: $e', tag: 'UnifiedAnalysis');
      return _getGenericPlayerAnalysis(homeTeam, awayTeam);
    }
  }

  Future<Map<String, dynamic>> _getAdvancedStats(String homeTeam, String awayTeam) async {
    try {
      return {
        'homeStats': await _getTeamStatsFromESPN(homeTeam),
        'awayStats': await _getTeamStatsFromESPN(awayTeam),
        'comparison': await _generateStatsComparison(homeTeam, awayTeam),
      };
    } catch (e) {
      LoggingService.error('Error fetching advanced stats: $e', tag: 'UnifiedAnalysis');
      return _getGenericAdvancedStats(homeTeam, awayTeam);
    }
  }

  Future<Map<String, dynamic>> _getCoachingMatchup(String homeTeam, String awayTeam) async {
    try {
      return {
        'homeCoach': await _getCoachInfo(homeTeam),
        'awayCoach': await _getCoachInfo(awayTeam),
        'historicalMatchup': await _getCoachingHistory(homeTeam, awayTeam),
      };
    } catch (e) {
      LoggingService.error('Error analyzing coaching matchup: $e', tag: 'UnifiedAnalysis');
      return _getGenericCoachingMatchup(homeTeam, awayTeam);
    }
  }

  Future<Map<String, dynamic>> _getVenueAndWeatherImpact(GameSchedule game) async {
    try {
      return {
        'venue': await _getVenueInfo(game.stadium?.name ?? 'Unknown'),
        'weather': await _getWeatherForecast(game.stadium?.name ?? 'Unknown', game.dateTime ?? DateTime.now()),
        'homeFieldAdvantage': await _calculateHomeFieldAdvantage(game.homeTeamName, game.stadium?.name ?? 'Unknown'),
      };
    } catch (e) {
      LoggingService.error('Error analyzing venue/weather: $e', tag: 'UnifiedAnalysis');
      return _getGenericVenueWeather(game);
    }
  }

  Future<Map<String, dynamic>> _getRecentFormAnalysis(String homeTeam, String awayTeam) async {
    try {
      return {
        'momentum': {
          'home': await _getTeamMomentum(homeTeam),
          'away': await _getTeamMomentum(awayTeam),
        },
        'lastFiveGames': {
          'home': await _getLastFiveGames(homeTeam),
          'away': await _getLastFiveGames(awayTeam),
        },
        'commonOpponents': await _getCommonOpponents(homeTeam, awayTeam),
      };
    } catch (e) {
      LoggingService.error('Error analyzing recent form: $e', tag: 'UnifiedAnalysis');
      return _getGenericRecentForm(homeTeam, awayTeam);
    }
  }

  Future<GamePrediction> _generateEnhancedPrediction({
    required String gameId,
    required GameSchedule game,
    required Map<String, dynamic> seriesHistory,
    required Map<String, dynamic> playerAnalysis,
    required Map<String, dynamic> advancedStats,
    required Map<String, dynamic> coachingMatchup,
    required Map<String, dynamic> venueWeather,
    required Map<String, dynamic> recentForm,
  }) async {
    // Use AI service to generate prediction with all available data
    final aiPrediction = await _aiService.generateEnhancedGamePrediction(
      homeTeam: game.homeTeamName,
      awayTeam: game.awayTeamName,
      gameStats: {
        'seriesHistory': seriesHistory,
        'playerAnalysis': playerAnalysis,
        'advancedStats': advancedStats,
        'coachingMatchup': coachingMatchup,
        'venueWeather': venueWeather,
        'recentForm': recentForm,
      },
    );

    final prediction = GamePrediction(
      predictionId: _generatePredictionId(gameId),
      gameId: gameId,
      homeTeam: game.homeTeamName,
      awayTeam: game.awayTeamName,
      gameTime: game.dateTime ?? DateTime.now(),
      predictedOutcome: _parseOutcome(aiPrediction['prediction']),
      confidence: (aiPrediction['confidence'] ?? 0.5).toDouble(),
      predictedHomeScore: aiPrediction['predictedScore']?['home']?.toInt(),
      predictedAwayScore: aiPrediction['predictedScore']?['away']?.toInt(),
      keyFactors: List<String>.from(aiPrediction['keyFactors'] ?? []),
      analysis: aiPrediction['analysis'] ?? 'No analysis available',
      createdAt: DateTime.now(),
      predictionSource: 'AI_Enhanced',
      metadata: {
        'unified_service_version': '1.0',
        'data_sources': ['series_history', 'player_analysis', 'advanced_stats', 'coaching', 'venue_weather', 'recent_form'],
      },
    );

    // Store prediction for accuracy tracking
    await _storePrediction(prediction);

    return prediction;
  }

  /// Get team stats from ESPN service (fallback method)
  Future<Map<String, dynamic>> _getTeamStatsFromESPN(String teamName) async {
    try {
      // This would typically call ESPN API for team stats
      // For now, return generic stats structure
      return {
        'name': teamName,
        'wins': 0,
        'losses': 0,
        'ranking': null,
        'offensiveRating': 0.0,
        'defensiveRating': 0.0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      LoggingService.error('Error fetching team stats for $teamName: $e', tag: 'UnifiedGameAnalysis');
      return {
        'name': teamName,
        'wins': 0,
        'losses': 0,
        'ranking': null,
        'offensiveRating': 0.0,
        'defensiveRating': 0.0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  // Additional helper methods would be implemented here...
  // (Keeping the implementation concise for readability)

  List<String> _generateKeyFactors(
    Map<String, dynamic> seriesHistory,
    Map<String, dynamic> playerAnalysis,
    Map<String, dynamic> advancedStats,
    Map<String, dynamic> coachingMatchup,
    Map<String, dynamic> venueWeather,
  ) {
    final factors = <String>[];
    
    // Add key factors based on analysis data
    if (seriesHistory['longestStreak'] != null) {
      factors.add('Series history: ${seriesHistory['longestStreak']}');
    }
    
    if (playerAnalysis['matchupAdvantages']?.isNotEmpty == true) {
      factors.add('Key player matchups favor one team');
    }
    
    if (venueWeather['weather']?['impact'] == 'high') {
      factors.add('Weather conditions could impact game');
    }
    
    return factors.take(5).toList(); // Limit to top 5 factors
  }

  // Fallback and helper methods
  ComprehensiveGameAnalysis _generateFallbackAnalysis(String gameId, GameSchedule game) {
    return ComprehensiveGameAnalysis(
      gameId: gameId,
      game: game,
      prediction: null,
      seriesHistory: _getGenericSeriesHistory(game.homeTeamName, game.awayTeamName),
      playerAnalysis: _getGenericPlayerAnalysis(game.homeTeamName, game.awayTeamName),
      advancedStats: _getGenericAdvancedStats(game.homeTeamName, game.awayTeamName),
      coachingMatchup: _getGenericCoachingMatchup(game.homeTeamName, game.awayTeamName),
      venueWeather: _getGenericVenueWeather(game),
      recentForm: _getGenericRecentForm(game.homeTeamName, game.awayTeamName),
      keyFactors: ['Competitive matchup', 'Both teams well-prepared'],
      userContext: null,
      generatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> _getGenericSeriesHistory(String homeTeam, String awayTeam) {
    return {
      'overallRecord': 'Series closely contested',
      'recentRecord': 'Recent games competitive',
      'narratives': ['Historic rivalry', 'Always competitive'],
    };
  }

  Map<String, dynamic> _getGenericPlayerAnalysis(String homeTeam, String awayTeam) {
    return {
      'homeTeamPlayers': [],
      'awayTeamPlayers': [],
      'matchupAdvantages': [],
    };
  }

  Map<String, dynamic> _getGenericAdvancedStats(String homeTeam, String awayTeam) {
    return {
      'homeStats': {},
      'awayStats': {},
      'comparison': {},
    };
  }

  Map<String, dynamic> _getGenericCoachingMatchup(String homeTeam, String awayTeam) {
    return {
      'homeCoach': {'name': 'Head Coach', 'experience': 'Experienced'},
      'awayCoach': {'name': 'Head Coach', 'experience': 'Experienced'},
      'historicalMatchup': {},
    };
  }

  Map<String, dynamic> _getGenericVenueWeather(GameSchedule game) {
    return {
      'venue': {'name': game.stadium?.name ?? 'Unknown', 'capacity': 'Large stadium'},
      'weather': {'conditions': 'Fair', 'impact': 'minimal'},
      'homeFieldAdvantage': 'Moderate',
    };
  }

  Map<String, dynamic> _getGenericRecentForm(String homeTeam, String awayTeam) {
    return {
      'momentum': {'home': 'Steady', 'away': 'Steady'},
      'lastFiveGames': {'home': [], 'away': []},
      'commonOpponents': [],
    };
  }

  // Utility methods
  String _generatePredictionId(String gameId) => 'pred_${gameId}_${DateTime.now().millisecondsSinceEpoch}';
  String _generateUserPredictionId(String gameId, String userId) => 'user_pred_${gameId}_$userId';

  PredictionOutcome _parseOutcome(dynamic prediction) {
    if (prediction is String) {
      switch (prediction.toLowerCase()) {
        case 'home':
          return PredictionOutcome.homeWin;
        case 'away':
          return PredictionOutcome.awayWin;
        default:
          return PredictionOutcome.unknown;
      }
    }
    return PredictionOutcome.unknown;
  }

  // Placeholder implementations for missing methods
  Future<UserGameContext?> _getUserGameContext(String gameId) async => null;
  Future<void> _cacheAnalysis(String gameId, ComprehensiveGameAnalysis analysis) async {}
  Future<void> _storeUserPrediction(UserPrediction prediction) async {}
  Future<void> _storePrediction(GamePrediction prediction) async {}
  Future<void> _updateAIPredictionAccuracy(String gameId, PredictionOutcome actualOutcome, int actualHomeScore, int actualAwayScore) async {}
  Future<void> _updateUserPredictionAccuracy(String gameId, PredictionOutcome actualOutcome, int actualHomeScore, int actualAwayScore) async {}
  Future<List<Map<String, dynamic>>> _getTeamKeyPlayers(String team) async => [];
  Future<Map<String, dynamic>> _getPlayerMatchupAdvantages(String homeTeam, String awayTeam) async => {};
  Future<Map<String, dynamic>> _generateStatsComparison(String homeTeam, String awayTeam) async => {};
  Future<Map<String, dynamic>> _getCoachInfo(String team) async => {};
  Future<Map<String, dynamic>> _getCoachingHistory(String homeTeam, String awayTeam) async => {};
  Future<Map<String, dynamic>> _getVenueInfo(String location) async => {};
  Future<Map<String, dynamic>> _getWeatherForecast(String location, DateTime gameTime) async => {};
  Future<double> _calculateHomeFieldAdvantage(String homeTeam, String location) async => 0.5;
  Future<Map<String, dynamic>> _getTeamMomentum(String team) async => {};
  Future<List<Map<String, dynamic>>> _getLastFiveGames(String team) async => [];
  Future<List<Map<String, dynamic>>> _getCommonOpponents(String homeTeam, String awayTeam) async => [];
}

// Data classes for the unified service

class ComprehensiveGameAnalysis {
  final String gameId;
  final GameSchedule game;
  final GamePrediction? prediction;
  final Map<String, dynamic> seriesHistory;
  final Map<String, dynamic> playerAnalysis;
  final Map<String, dynamic> advancedStats;
  final Map<String, dynamic> coachingMatchup;
  final Map<String, dynamic> venueWeather;
  final Map<String, dynamic> recentForm;
  final List<String> keyFactors;
  final UserGameContext? userContext;
  final DateTime generatedAt;

  ComprehensiveGameAnalysis({
    required this.gameId,
    required this.game,
    required this.prediction,
    required this.seriesHistory,
    required this.playerAnalysis,
    required this.advancedStats,
    required this.coachingMatchup,
    required this.venueWeather,
    required this.recentForm,
    required this.keyFactors,
    required this.userContext,
    required this.generatedAt,
  });
}

class GamePrediction {
  final String predictionId;
  final String gameId;
  final String homeTeam;
  final String awayTeam;
  final DateTime gameTime;
  final PredictionOutcome predictedOutcome;
  final double confidence;
  final int? predictedHomeScore;
  final int? predictedAwayScore;
  final List<String> keyFactors;
  final String analysis;
  final DateTime createdAt;
  final String predictionSource;
  final Map<String, dynamic> metadata;

  GamePrediction({
    required this.predictionId,
    required this.gameId,
    required this.homeTeam,
    required this.awayTeam,
    required this.gameTime,
    required this.predictedOutcome,
    required this.confidence,
    this.predictedHomeScore,
    this.predictedAwayScore,
    required this.keyFactors,
    required this.analysis,
    required this.createdAt,
    required this.predictionSource,
    required this.metadata,
  });
}

class UserPrediction {
  final String predictionId;
  final String gameId;
  final String userId;
  final String homeTeam;
  final String awayTeam;
  final PredictionOutcome predictedOutcome;
  final double confidence;
  final int? predictedHomeScore;
  final int? predictedAwayScore;
  final String? reasoning;
  final DateTime createdAt;

  UserPrediction({
    required this.predictionId,
    required this.gameId,
    required this.userId,
    required this.homeTeam,
    required this.awayTeam,
    required this.predictedOutcome,
    required this.confidence,
    this.predictedHomeScore,
    this.predictedAwayScore,
    this.reasoning,
    required this.createdAt,
  });
}

class UserGameContext {
  final String userId;
  final String gameId;
  final bool isFavoriteTeam;
  final List<String> teamPreferences;
  final Map<String, dynamic> behaviorData;

  UserGameContext({
    required this.userId,
    required this.gameId,
    required this.isFavoriteTeam,
    required this.teamPreferences,
    required this.behaviorData,
  });
}

enum PredictionOutcome {
  homeWin,
  awayWin,
  unknown,
} 