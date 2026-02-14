import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/logging_service.dart';
import '../ai/services/ai_service.dart';

/// Service for tracking user behavior and learning preferences
class UserLearningService {
  static final UserLearningService _instance = UserLearningService._internal();
  factory UserLearningService() => _instance;
  UserLearningService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AIService _aiService = AIService();

  /// Track user interaction with games
  Future<void> trackGameInteraction({
    required String gameId,
    required String interactionType,
    required String homeTeam,
    required String awayTeam,
    int? durationSeconds,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final interaction = {
        'userId': userId,
        'gameId': gameId,
        'interactionType': interactionType, // 'view', 'favorite', 'predict', 'share'
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'timestamp': FieldValue.serverTimestamp(),
        'durationSeconds': durationSeconds,
        'additionalData': additionalData ?? {},
      };

      await _firestore
          .collection('user_interactions')
          .add(interaction);

      // Update user behavior summary asynchronously
      _updateUserBehaviorSummary(userId, interactionType, homeTeam, awayTeam);

      LoggingService.info(
        'Tracked $interactionType interaction for game $gameId',
        tag: 'UserLearning',
      );
    } catch (e) {
      LoggingService.error('Error tracking game interaction: $e', tag: 'UserLearning');
    }
  }

  /// Track venue interaction
  Future<void> trackVenueInteraction({
    required String venueId,
    required String venueName,
    required String interactionType,
    int? durationSeconds,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final interaction = {
        'userId': userId,
        'venueId': venueId,
        'venueName': venueName,
        'interactionType': interactionType, // 'view', 'favorite', 'directions', 'checkin'
        'timestamp': FieldValue.serverTimestamp(),
        'durationSeconds': durationSeconds,
        'additionalData': additionalData ?? {},
      };

      await _firestore
          .collection('venue_interactions')
          .add(interaction);

      LoggingService.info(
        'Tracked $interactionType interaction for venue $venueId',
        tag: 'UserLearning',
      );
    } catch (e) {
      LoggingService.error('Error tracking venue interaction: $e', tag: 'UserLearning');
    }
  }

  /// Track team preference changes
  Future<void> trackTeamPreference({
    required String teamName,
    required String action, // 'add', 'remove', 'view'
    Map<String, dynamic>? context,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final preference = {
        'userId': userId,
        'teamName': teamName,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
        'context': context ?? {},
      };

      await _firestore
          .collection('team_preferences')
          .add(preference);

      LoggingService.info(
        'Tracked team preference: $action for $teamName',
        tag: 'UserLearning',
      );
    } catch (e) {
      LoggingService.error('Error tracking team preference: $e', tag: 'UserLearning');
    }
  }

  /// Get AI-powered user insights
  Future<UserInsights> getUserInsights(String userId) async {
    try {
      // Get user behavior data from last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final interactions = await _firestore
          .collection('user_interactions')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final venueInteractions = await _firestore
          .collection('venue_interactions')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final teamPreferences = await _firestore
          .collection('team_preferences')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      // Analyze behavior patterns with AI
      final behaviorData = {
        'gameInteractions': interactions.docs.map((doc) => doc.data()).toList(),
        'venueInteractions': venueInteractions.docs.map((doc) => doc.data()).toList(),
        'teamPreferences': teamPreferences.docs.map((doc) => doc.data()).toList(),
      };

      final aiAnalysis = await _aiService.analyzeUserBehavior(behaviorData);
      
      return UserInsights.fromAIAnalysis(aiAnalysis, behaviorData);
    } catch (e) {
      LoggingService.error('Error getting user insights: $e', tag: 'UserLearning');
      return UserInsights.empty();
    }
  }

  /// Get personalized game recommendations
  Future<List<GameRecommendation>> getPersonalizedGameRecommendations({
    required List<Map<String, dynamic>> upcomingGames,
    int limit = 10,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final userInsights = await getUserInsights(userId);
      
      // Use AI to rank games based on user preferences
      final recommendations = await _aiService.generateGameRecommendations(
        upcomingGames: upcomingGames,
        userInsights: userInsights.toMap(),
        limit: limit,
      );

      return recommendations.map((rec) => GameRecommendation.fromMap(rec)).toList();
    } catch (e) {
      LoggingService.error('Error getting game recommendations: $e', tag: 'UserLearning');
      return [];
    }
  }

  /// Update user behavior summary (internal method)
  Future<void> _updateUserBehaviorSummary(
    String userId,
    String interactionType,
    String homeTeam,
    String awayTeam,
  ) async {
    try {
      final summaryRef = _firestore
          .collection('user_behavior_summary')
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        final summaryDoc = await transaction.get(summaryRef);
        
        Map<String, dynamic> data = summaryDoc.exists 
            ? summaryDoc.data()! 
            : {
                'userId': userId,
                'totalInteractions': 0,
                'teamInteractions': <String, int>{},
                'interactionTypes': <String, int>{},
                'lastUpdated': FieldValue.serverTimestamp(),
              };

        // Update counters
        data['totalInteractions'] = (data['totalInteractions'] ?? 0) + 1;
        
        // Update interaction type counts
        final interactionTypes = Map<String, int>.from(data['interactionTypes'] ?? {});
        interactionTypes[interactionType] = (interactionTypes[interactionType] ?? 0) + 1;
        data['interactionTypes'] = interactionTypes;
        
        // Update team interaction counts
        final teamInteractions = Map<String, int>.from(data['teamInteractions'] ?? {});
        teamInteractions[homeTeam] = (teamInteractions[homeTeam] ?? 0) + 1;
        teamInteractions[awayTeam] = (teamInteractions[awayTeam] ?? 0) + 1;
        data['teamInteractions'] = teamInteractions;
        
        data['lastUpdated'] = FieldValue.serverTimestamp();

        transaction.set(summaryRef, data);
      });
    } catch (e) {
      LoggingService.error('Error updating user behavior summary: $e', tag: 'UserLearning');
    }
  }

  /// Get user's most engaged teams
  Future<List<String>> getMostEngagedTeams(String userId, {int limit = 5}) async {
    try {
      final summaryDoc = await _firestore
          .collection('user_behavior_summary')
          .doc(userId)
          .get();

      if (!summaryDoc.exists) return [];

      final data = summaryDoc.data()!;
      final teamInteractions = Map<String, int>.from(data['teamInteractions'] ?? {});

      // Sort teams by interaction count
      final sortedTeams = teamInteractions.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedTeams
          .take(limit)
          .map((entry) => entry.key)
          .toList();
    } catch (e) {
      LoggingService.error('Error getting most engaged teams: $e', tag: 'UserLearning');
      return [];
    }
  }
}

/// User insights generated from behavior analysis
class UserInsights {
  final Map<String, double> teamAffinityScores;
  final Map<String, double> interactionPatterns;
  final List<String> preferredGameTypes;
  final List<String> recommendedVenues;
  final double engagementScore;
  final Map<String, dynamic> rawData;

  const UserInsights({
    required this.teamAffinityScores,
    required this.interactionPatterns,
    required this.preferredGameTypes,
    required this.recommendedVenues,
    required this.engagementScore,
    required this.rawData,
  });

  factory UserInsights.fromAIAnalysis(
    Map<String, dynamic> aiAnalysis,
    Map<String, dynamic> behaviorData,
  ) {
    return UserInsights(
      teamAffinityScores: Map<String, double>.from(
        aiAnalysis['teamAffinityScores'] ?? {},
      ),
      interactionPatterns: Map<String, double>.from(
        aiAnalysis['interactionPatterns'] ?? {},
      ),
      preferredGameTypes: List<String>.from(
        aiAnalysis['preferredGameTypes'] ?? [],
      ),
      recommendedVenues: List<String>.from(
        aiAnalysis['recommendedVenues'] ?? [],
      ),
      engagementScore: (aiAnalysis['engagementScore'] ?? 0.0).toDouble(),
      rawData: behaviorData,
    );
  }

  factory UserInsights.empty() {
    return const UserInsights(
      teamAffinityScores: {},
      interactionPatterns: {},
      preferredGameTypes: [],
      recommendedVenues: [],
      engagementScore: 0.0,
      rawData: {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamAffinityScores': teamAffinityScores,
      'interactionPatterns': interactionPatterns,
      'preferredGameTypes': preferredGameTypes,
      'recommendedVenues': recommendedVenues,
      'engagementScore': engagementScore,
      'rawData': rawData,
    };
  }
}

/// Game recommendation with AI-generated scoring
class GameRecommendation {
  final String gameId;
  final String homeTeam;
  final String awayTeam;
  final double recommendationScore;
  final List<String> reasons;
  final DateTime gameTime;
  final Map<String, dynamic> gameData;

  const GameRecommendation({
    required this.gameId,
    required this.homeTeam,
    required this.awayTeam,
    required this.recommendationScore,
    required this.reasons,
    required this.gameTime,
    required this.gameData,
  });

  factory GameRecommendation.fromMap(Map<String, dynamic> map) {
    return GameRecommendation(
      gameId: map['gameId'] ?? '',
      homeTeam: map['homeTeam'] ?? '',
      awayTeam: map['awayTeam'] ?? '',
      recommendationScore: (map['score'] ?? 0.0).toDouble(),
      reasons: List<String>.from(map['reasons'] ?? []),
      gameTime: DateTime.parse(map['gameTime'] ?? DateTime.now().toIso8601String()),
      gameData: Map<String, dynamic>.from(map['gameData'] ?? {}),
    );
  }
} 