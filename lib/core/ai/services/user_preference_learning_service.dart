import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../entities/user_interaction.dart';
import '../entities/learned_preference.dart';
import '../../services/logging_service.dart';
import 'ai_service.dart';

/// Service that learns from user behavior to improve AI recommendations
class UserPreferenceLearningService {
  static const String _logTag = 'UserPreferenceLearningService';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AIService _aiService;
  
  UserPreferenceLearningService(this._aiService);

  /// Record a user interaction for learning
  Future<void> recordInteraction(UserInteraction interaction) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('interactions')
          .add(interaction.toFirestore());
      
      LoggingService.info('Recorded user interaction: ${interaction.type}', tag: _logTag);
      
      // Trigger learning update if enough interactions
      await _maybeUpdateLearning(user.uid);
    } catch (e) {
      LoggingService.error('Failed to record interaction: $e', tag: _logTag);
    }
  }

  /// Record venue selection for learning
  Future<void> recordVenueSelection({
    required String venueId,
    required String venueName,
    required List<String> venueTypes,
    required String gameContext,
    required double userRating,
    String? userComment,
  }) async {
    await recordInteraction(UserInteraction(
      interactionId: '', // Will be set by Firestore
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      type: UserInteractionType.venueSelection,
      timestamp: DateTime.now(),
      data: {
        'venueId': venueId,
        'venueName': venueName,
        'venueTypes': venueTypes,
        'gameContext': gameContext,
        'userRating': userRating,
        if (userComment != null) 'userComment': userComment,
      },
    ));
  }

  /// Record venue rating for learning
  Future<void> recordVenueRating({
    required String venueId,
    required double rating,
    required List<String> positiveAspects,
    required List<String> negativeAspects,
  }) async {
    await recordInteraction(UserInteraction(
      interactionId: '',
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      type: UserInteractionType.venueRating,
      timestamp: DateTime.now(),
      data: {
        'venueId': venueId,
        'rating': rating,
        'positiveAspects': positiveAspects,
        'negativeAspects': negativeAspects,
      },
    ));
  }

  /// Record recommendation feedback
  Future<void> recordRecommendationFeedback({
    required String recommendationId,
    required bool wasHelpful,
    required String reason,
  }) async {
    await recordInteraction(UserInteraction(
      interactionId: '',
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      type: UserInteractionType.recommendationFeedback,
      timestamp: DateTime.now(),
      data: {
        'recommendationId': recommendationId,
        'wasHelpful': wasHelpful,
        'reason': reason,
      },
    ));
  }

  /// Get learned preferences for a user
  Future<List<LearnedPreference>> getLearnedPreferences(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('learned_preferences')
          .get();
      
      return snapshot.docs
          .map((doc) => LearnedPreference.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggingService.error('Failed to get learned preferences: $e', tag: _logTag);
      return [];
    }
  }

  /// Generate personalized recommendation prompt based on learned preferences
  Future<String> generatePersonalizedPrompt({
    required String basePrompt,
    required String userId,
  }) async {
    try {
      final learnedPreferences = await getLearnedPreferences(userId);
      
      if (learnedPreferences.isEmpty) {
        return basePrompt;
      }
      
      final preferenceTexts = learnedPreferences
          .where((pref) => pref.confidence > 0.6) // Only high confidence preferences
          .map((pref) => '${pref.category}: ${pref.description} (confidence: ${(pref.confidence * 100).round()}%)')
          .toList();
      
      if (preferenceTexts.isEmpty) {
        return basePrompt;
      }
      
      return '''
$basePrompt

USER LEARNED PREFERENCES (use these to personalize recommendations):
${preferenceTexts.join('\n')}

Consider these learned preferences when making recommendations.
''';
    } catch (e) {
      LoggingService.error('Failed to generate personalized prompt: $e', tag: _logTag);
      return basePrompt;
    }
  }

  /// Update learning based on recent interactions
  Future<void> _maybeUpdateLearning(String userId) async {
    try {
      // Check if we have enough new interactions to update learning
      final recentInteractions = await _getRecentInteractions(userId, limit: 10);
      
      if (recentInteractions.length < 5) {
        return; // Not enough data yet
      }
      
      // Generate AI insights about user preferences
      await _generateLearningInsights(userId, recentInteractions);
    } catch (e) {
      LoggingService.error('Failed to update learning: $e', tag: _logTag);
    }
  }

  /// Get recent user interactions
  Future<List<UserInteraction>> _getRecentInteractions(String userId, {int limit = 50}) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('interactions')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => UserInteraction.fromFirestore(doc))
        .toList();
  }

  /// Generate AI insights about user preferences
  Future<void> _generateLearningInsights(String userId, List<UserInteraction> interactions) async {
    try {
      // Analyze venue selections
      final venueSelections = interactions
          .where((i) => i.type == UserInteractionType.venueSelection)
          .toList();
      
      if (venueSelections.isNotEmpty) {
        await _analyzeVenuePreferences(userId, venueSelections);
      }
      
      // Analyze ratings and feedback
      final ratingsAndFeedback = interactions
          .where((i) => i.type == UserInteractionType.venueRating || 
                       i.type == UserInteractionType.recommendationFeedback)
          .toList();
      
      if (ratingsAndFeedback.isNotEmpty) {
        await _analyzeFeedbackPatterns(userId, ratingsAndFeedback);
      }
    } catch (e) {
      LoggingService.error('Failed to generate learning insights: $e', tag: _logTag);
    }
  }

  /// Analyze venue selection patterns
  Future<void> _analyzeVenuePreferences(String userId, List<UserInteraction> venueSelections) async {
    // Build analysis prompt
    final venueData = venueSelections.map((interaction) {
      final data = interaction.data;
      return '''
Venue: ${data['venueName']}
Types: ${data['venueTypes']}
Context: ${data['gameContext']}
User Rating: ${data['userRating']}
Comment: ${data['userComment'] ?? 'None'}
''';
    }).join('\n---\n');
    
    final prompt = '''
Analyze these venue selections to identify user preferences:

$venueData

Identify 2-3 key preferences this user has for sports venues. For each preference:
1. Category (e.g., "Venue Type", "Atmosphere", "Price", "Food", "Location")
2. Description (what they prefer)
3. Confidence (how sure you are, 0.0-1.0)

Format as JSON:
{
  "preferences": [
    {
      "category": "Venue Type",
      "description": "Prefers sports bars over fine dining",
      "confidence": 0.85
    }
  ]
}
''';
    
    try {
      final aiResponse = await _aiService.generateCompletion(
        prompt: prompt,
        maxTokens: 300,
        temperature: 0.3,
      );
      
      // Parse AI response and save preferences
      final preferences = _parsePreferencesFromAI(aiResponse);
      await _saveLearnedPreferences(userId, preferences);
    } catch (e) {
      LoggingService.error('Failed to analyze venue preferences: $e', tag: _logTag);
    }
  }

  /// Analyze feedback patterns
  Future<void> _analyzeFeedbackPatterns(String userId, List<UserInteraction> feedback) async {
    final feedbackData = feedback.map((interaction) {
      final data = interaction.data;
      if (interaction.type == UserInteractionType.venueRating) {
        return '''
Rating: ${data['rating']}/5
Positive: ${data['positiveAspects']}
Negative: ${data['negativeAspects']}
''';
      } else {
        return '''
Recommendation Feedback: ${data['wasHelpful'] ? 'Helpful' : 'Not Helpful'}
Reason: ${data['reason']}
''';
      }
    }).join('\n---\n');
    
    final prompt = '''
Analyze this user feedback to understand their preferences:

$feedbackData

What does this feedback tell us about the user's preferences? 
Identify key patterns and preferences.

Format as JSON:
{
  "preferences": [
    {
      "category": "Food Quality",
      "description": "Values high-quality food over price",
      "confidence": 0.75
    }
  ]
}
''';
    
    try {
      final aiResponse = await _aiService.generateCompletion(
        prompt: prompt,
        maxTokens: 250,
        temperature: 0.3,
      );
      
      final preferences = _parsePreferencesFromAI(aiResponse);
      await _saveLearnedPreferences(userId, preferences);
    } catch (e) {
      LoggingService.error('Failed to analyze feedback patterns: $e', tag: _logTag);
    }
  }

  /// Parse preferences from AI response
  List<LearnedPreference> _parsePreferencesFromAI(String aiResponse) {
    try {
      // Try to extract JSON from the response
      final jsonStart = aiResponse.indexOf('{');
      final jsonEnd = aiResponse.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0) {
        return [];
      }
      
      final jsonStr = aiResponse.substring(jsonStart, jsonEnd);
      final data = (json.decode(jsonStr) as Map<String, dynamic>?) ?? {};
      final prefs = (data['preferences'] as List?) ?? [];
      
      return prefs.map((pref) => LearnedPreference(
        preferenceId: '', // Will be set by Firestore
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        category: (pref['category'] as String?) ?? 'Unknown',
        description: (pref['description'] as String?) ?? 'No description',
        confidence: ((pref['confidence'] as num?) ?? 0.5).toDouble(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).toList();
    } catch (e) {
      LoggingService.error('Failed to parse AI preferences: $e', tag: _logTag);
      return [];
    }
  }

  /// Save learned preferences to Firestore
  Future<void> _saveLearnedPreferences(String userId, List<LearnedPreference> preferences) async {
    final batch = _firestore.batch();
    final collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('learned_preferences');
    
    for (final preference in preferences) {
      // Check if similar preference already exists
      final existing = await collection
          .where('category', isEqualTo: preference.category)
          .limit(1)
          .get();
      
      if (existing.docs.isNotEmpty) {
        // Update existing preference
        final docRef = existing.docs.first.reference;
        batch.update(docRef, {
          'description': preference.description,
          'confidence': preference.confidence,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new preference
        final docRef = collection.doc();
        batch.set(docRef, preference.toFirestore());
      }
    }
    
    await batch.commit();
    LoggingService.info('Saved ${preferences.length} learned preferences', tag: _logTag);
  }
} 