import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../../core/services/logging_service.dart';
import '../../../core/services/performance_monitor.dart';
import '../../../config/api_keys.dart';
import 'ai_fallback_helpers.dart';
import 'ai_venue_fallback_helpers.dart';

/// OpenAI API Service for AI-powered features
class AIService {
  static const String _logTag = 'AIService';
  static const String _baseUrl = 'https://api.openai.com/v1';

  // Rate limiting
  static const int _maxRequestsPerMinute = 60;
  static const Duration _rateLimitWindow = Duration(minutes: 1);

  final List<DateTime> _requestTimes = [];
  bool _isInitialized = false;
  late http.Client _httpClient;

  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  /// Initialize the AI service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _httpClient = http.Client();

      // Validate API key
      if (ApiKeys.openAI == 'sk-your-openai-api-key-here' || ApiKeys.openAI.isEmpty) {
        LoggingService.warning('OpenAI API key not configured - using mock mode', tag: _logTag);
        _isInitialized = true;
        return;
      }

      // Test API connection
      await _testConnection();
      _isInitialized = true;
      LoggingService.info('AI Service initialized successfully', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to initialize AI Service: $e', tag: _logTag);
      // Initialize in mock mode if API fails
      _isInitialized = true;
    }
  }

  // ==========================================================================
  // Core API methods
  // ==========================================================================

  /// Generate text completion using OpenAI GPT models
  Future<String> generateCompletion({
    required String prompt,
    String model = 'gpt-3.5-turbo',
    int maxTokens = 150,
    double temperature = 0.7,
    List<String>? stop,
    String? systemMessage,
  }) async {
    if (!_isInitialized) await initialize();

    // Check rate limits
    if (!_canMakeRequest()) {
      LoggingService.warning('Rate limit exceeded, using fallback response', tag: _logTag);
      return AIFallbackHelpers.generateFallbackResponse(prompt);
    }

    try {
      final callId = 'openai_completion_${DateTime.now().millisecondsSinceEpoch}';
      PerformanceMonitor.startApiCall(callId);

      // Build messages array
      const messages = <Map<String, String>>[];
      final messagesList = List<Map<String, String>>.from(messages);

      if (systemMessage != null) {
        messagesList.add({
          'role': 'system',
          'content': systemMessage,
        });
      }

      messagesList.add({
        'role': 'user',
        'content': prompt,
      });

      final response = await _makeRequest(
        endpoint: '/chat/completions',
        body: {
          'model': model,
          'messages': messagesList,
          'max_tokens': maxTokens,
          'temperature': temperature,
          if (stop != null) 'stop': stop,
        },
      );

      PerformanceMonitor.endApiCall(callId, success: true);

      final content = response['choices'][0]['message']['content'] as String;
      LoggingService.info('Generated completion successfully', tag: _logTag);

      return content.trim();
    } catch (e) {
      LoggingService.error('Error generating completion: $e', tag: _logTag);
      return AIFallbackHelpers.generateFallbackResponse(prompt);
    }
  }

  /// Generate embeddings for text using OpenAI's text-embedding model
  Future<List<double>> generateEmbeddings(String text, {String model = 'text-embedding-3-small'}) async {
    if (!_isInitialized) await initialize();

    // Check rate limits
    if (!_canMakeRequest()) {
      LoggingService.warning('Rate limit exceeded, using mock embedding', tag: _logTag);
      return AIFallbackHelpers.generateMockEmbedding(text);
    }

    try {
      final callId = 'openai_embedding_${DateTime.now().millisecondsSinceEpoch}';
      PerformanceMonitor.startApiCall(callId);

      final response = await _makeRequest(
        endpoint: '/embeddings',
        body: {
          'model': model,
          'input': text,
        },
      );

      PerformanceMonitor.endApiCall(callId, success: true);

      final embedding = List<double>.from(response['data'][0]['embedding']);
      LoggingService.info('Generated embedding successfully', tag: _logTag);

      return embedding;
    } catch (e) {
      LoggingService.error('Error generating embedding: $e', tag: _logTag);
      return AIFallbackHelpers.generateMockEmbedding(text);
    }
  }

  /// Calculate cosine similarity between two embedding vectors
  double calculateCosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      LoggingService.warning('Embedding dimension mismatch: ${a.length} vs ${b.length}', tag: _logTag);
      return 0.0;
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0.0 || normB == 0.0) return 0.0;

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  // ==========================================================================
  // Domain-specific prompt methods
  // ==========================================================================

  /// Generate venue recommendations using AI
  Future<String> generateVenueRecommendation({
    required String userPreferences,
    required String gameContext,
    required List<String> nearbyVenues,
  }) async {
    const systemMessage = '''
You are a helpful assistant that recommends sports venues for World Cup fans.
Consider the user's preferences, the game context, and nearby venues to provide personalized recommendations.
Keep responses concise and focused on 1-2 top recommendations with brief explanations.
''';

    final prompt = '''
User preferences: $userPreferences

Game context: $gameContext

Nearby venues: ${nearbyVenues.join(', ')}

Recommend the best venue(s) for watching this game:
''';

    return await generateCompletion(
      prompt: prompt,
      systemMessage: systemMessage,
      maxTokens: 200,
      temperature: 0.7,
    );
  }

  /// Generate game predictions using AI
  Future<String> generateGamePrediction({
    required String homeTeam,
    required String awayTeam,
    required Map<String, dynamic> gameStats,
  }) async {
    const systemMessage = '''
You are a sports analyst providing brief match predictions for international soccer.
Base your prediction on team performance, statistics, and context.
Keep responses to 2-3 sentences maximum.
''';

    final prompt = '''
Predict the outcome of: $awayTeam @ $homeTeam

Game context: ${gameStats.toString()}

Provide a brief prediction with key factors:
''';

    return await generateCompletion(
      prompt: prompt,
      systemMessage: systemMessage,
      maxTokens: 100,
      temperature: 0.3,
    );
  }

  /// Analyze user behavior patterns using AI
  Future<Map<String, dynamic>> analyzeUserBehavior(Map<String, dynamic> behaviorData) async {
    const systemMessage = '''
You are an AI analytics expert that analyzes user behavior patterns for a World Cup fan app.
Analyze the provided user interaction data and generate insights about their preferences.
Return a JSON response with team affinity scores, interaction patterns, preferred game types, and engagement metrics.
''';

    final prompt = '''
Analyze this user behavior data:

Game Interactions: ${behaviorData['gameInteractions']?.length ?? 0} interactions
Venue Interactions: ${behaviorData['venueInteractions']?.length ?? 0} interactions
Team Preferences: ${behaviorData['teamPreferences']?.length ?? 0} preferences

Sample data: ${AIVenueFallbackHelpers.summarizeBehaviorData(behaviorData)}

Generate insights in this JSON format:
{
  "teamAffinityScores": {"teamName": score},
  "interactionPatterns": {"patternType": frequency},
  "preferredGameTypes": ["type1", "type2"],
  "recommendedVenues": ["venue1", "venue2"],
  "engagementScore": 0.85
}
''';

    try {
      final response = await generateCompletion(
        prompt: prompt,
        systemMessage: systemMessage,
        maxTokens: 500,
        temperature: 0.3,
      );

      // Try to parse JSON response
      final startIndex = response.indexOf('{');
      final endIndex = response.lastIndexOf('}');

      if (startIndex != -1 && endIndex != -1) {
        final jsonStr = response.substring(startIndex, endIndex + 1);
        return (json.decode(jsonStr) as Map<String, dynamic>?) ?? {};
      }
    } catch (e) {
      LoggingService.error('Error analyzing user behavior: $e', tag: _logTag);
    }

    return AIFallbackHelpers.generateFallbackUserInsights(behaviorData);
  }

  /// Generate personalized game recommendations using AI
  Future<List<Map<String, dynamic>>> generateGameRecommendations({
    required List<Map<String, dynamic>> upcomingGames,
    required Map<String, dynamic> userInsights,
    int limit = 10,
  }) async {
    const systemMessage = '''
You are an AI recommendation engine for World Cup matches.
Rank upcoming games based on user preferences and behavior patterns.
Consider team affinity, interaction patterns, and user engagement history.
''';

    final prompt = '''
User insights: ${AIVenueFallbackHelpers.summarizeUserInsights(userInsights)}

Upcoming games (${upcomingGames.length} total):
${AIVenueFallbackHelpers.summarizeUpcomingGames(upcomingGames, limit: 5)}

Rank the top $limit games for this user and return as JSON array:
[
  {
    "gameId": "id",
    "homeTeam": "team",
    "awayTeam": "team",
    "score": 0.95,
    "reasons": ["reason1", "reason2"],
    "gameTime": "2025-08-30T19:30:00Z",
    "gameData": {}
  }
]
''';

    try {
      final response = await generateCompletion(
        prompt: prompt,
        systemMessage: systemMessage,
        maxTokens: 800,
        temperature: 0.4,
      );

      // Try to parse JSON response
      final startIndex = response.indexOf('[');
      final endIndex = response.lastIndexOf(']');

      if (startIndex != -1 && endIndex != -1) {
        final jsonStr = response.substring(startIndex, endIndex + 1);
        final recommendations = (json.decode(jsonStr) as List?) ?? [];
        return recommendations.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      LoggingService.error('Error generating game recommendations: $e', tag: _logTag);
    }

    return AIFallbackHelpers.generateFallbackGameRecommendations(upcomingGames, userInsights, limit);
  }

  /// Generate enhanced game predictions with confidence scores
  Future<Map<String, dynamic>> generateEnhancedGamePrediction({
    required String homeTeam,
    required String awayTeam,
    required Map<String, dynamic> gameStats,
    Map<String, dynamic>? historicalData,
  }) async {
    const systemMessage = '''
You are an international soccer expert providing detailed match predictions.
Analyze team statistics, historical data, and game context to predict outcomes.
Provide predictions with confidence scores and key factors.
''';

    final prompt = '''
Game: $awayTeam @ $homeTeam

Current stats: ${gameStats.toString()}
${historicalData != null ? 'Historical data: ${historicalData.toString()}' : ''}

Provide prediction in JSON format:
{
  "prediction": "home_win/away_win/tie",
  "confidence": 0.75,
  "predictedScore": {"home": 28, "away": 21},
  "keyFactors": ["factor1", "factor2", "factor3"],
  "analysis": "Brief analysis..."
}
''';

    try {
      final response = await generateCompletion(
        prompt: prompt,
        systemMessage: systemMessage,
        maxTokens: 400,
        temperature: 0.2,
      );

      // Try to parse JSON response
      final startIndex = response.indexOf('{');
      final endIndex = response.lastIndexOf('}');

      if (startIndex != -1 && endIndex != -1) {
        final jsonStr = response.substring(startIndex, endIndex + 1);
        return (json.decode(jsonStr) as Map<String, dynamic>?) ?? {};
      }
    } catch (e) {
      LoggingService.error('Error generating enhanced prediction: $e', tag: _logTag);
    }

    return AIFallbackHelpers.generateFallbackPrediction(homeTeam, awayTeam);
  }

  /// Generate AI-powered venue recommendations
  Future<String> generateVenueRecommendations({
    required List<dynamic> venues,
    required Map<String, dynamic> context,
  }) async {
    const systemMessage = '''
You are a venue recommendation expert helping World Cup fans find the best spots.
Analyze venue data, user behavior, and game context to provide personalized recommendations.
Consider factors like venue type, location, ratings, user preferences, and game predictions.
''';

    final venueContext = context['context'] ?? 'general';
    final userBehavior = context['user_behavior'];
    final gameInfo = context['game_info'];
    final userPrediction = context['user_prediction'];
    final aiPrediction = context['ai_prediction'];

    // Summarize venues for AI processing
    final venuesSummary = venues.take(20).map((venue) {
      final v = venue as dynamic;
      return '${v.name ?? 'Unknown'} (${v.types?.join(', ') ?? 'unknown type'}) - Rating: ${v.rating ?? 'N/A'}, Distance: ${v.distance ?? 'N/A'}km';
    }).join('\n');

    final prompt = '''
Context: $venueContext
Venues available:
$venuesSummary

${userBehavior != null ? 'User preferences: ${AIVenueFallbackHelpers.summarizeBehaviorForVenues(userBehavior)}' : ''}
${gameInfo != null ? 'Game: ${gameInfo['away_team']} @ ${gameInfo['home_team']} at ${gameInfo['game_time']}' : ''}
${userPrediction != null ? 'User prediction: ${userPrediction['predicted_outcome']} (confidence: ${userPrediction['confidence']})' : ''}
${aiPrediction != null ? 'AI prediction: ${aiPrediction['predicted_outcome']} (confidence: ${aiPrediction['confidence']})' : ''}

Recommend 5-10 venues in JSON format:
{
  "recommendations": [
    {
      "name": "venue_name",
      "score": 0.85,
      "reasoning": "why this venue is great",
      "tags": ["tag1", "tag2"],
      "context_match": "pre_game/post_game/general"
    }
  ]
}

Consider:
- Venue type suitability for context (sports bars for games, restaurants for pre-game)
- User behavior patterns and preferences
- Location proximity and convenience
- Ratings and popularity
- Game predictions and confidence levels
- Time of day and situational factors
''';

    try {
      final response = await generateCompletion(
        prompt: prompt,
        systemMessage: systemMessage,
        maxTokens: 800,
        temperature: 0.3,
      );

      return response;

    } catch (e) {
      LoggingService.error('Error generating venue recommendations: $e', tag: _logTag);
      return AIVenueFallbackHelpers.generateFallbackVenueRecommendations(venues, context);
    }
  }

  // ==========================================================================
  // Status / lifecycle
  // ==========================================================================

  /// Check if the service is available (API key configured and initialized)
  bool get isAvailable => _isInitialized && ApiKeys.openAI != 'sk-your-openai-api-key-here';

  /// Check if using mock mode
  bool get isMockMode => ApiKeys.openAI == 'sk-your-openai-api-key-here' || ApiKeys.openAI.isEmpty;

  /// Dispose of resources
  void dispose() {
    _httpClient.close();
    _requestTimes.clear();
    _isInitialized = false;
  }

  // ==========================================================================
  // Private / network helpers
  // ==========================================================================

  /// Test API connection
  Future<void> _testConnection() async {
    try {
      await _makeRequest(
        endpoint: '/models',
        isGet: true,
      );
      LoggingService.info('OpenAI API connection successful', tag: _logTag);
    } catch (e) {
      throw Exception('Failed to connect to OpenAI API: $e');
    }
  }

  /// Make HTTP request to OpenAI API
  Future<Map<String, dynamic>> _makeRequest({
    required String endpoint,
    Map<String, dynamic>? body,
    bool isGet = false,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = {
      'Authorization': 'Bearer ${ApiKeys.openAI}',
      'Content-Type': 'application/json',
    };

    _recordRequest();

    http.Response response;

    try {
      // OPTIMIZED: Reduced timeout from 10s to 5s for faster fallback
      if (isGet) {
        response = await _httpClient.get(url, headers: headers).timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('OpenAI API request timed out', const Duration(seconds: 5)),
        );
      } else {
        response = await _httpClient.post(
          url,
          headers: headers,
          body: json.encode(body),
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('OpenAI API request timed out', const Duration(seconds: 5)),
        );
      }
    } on TimeoutException catch (e) {
      LoggingService.warning('OpenAI API request timed out: $e', tag: _logTag);
      throw Exception('OpenAI API timeout - please try again');
    }

    if (response.statusCode == 200) {
      return (json.decode(response.body) as Map<String, dynamic>?) ?? {};
    } else if (response.statusCode == 429) {
      throw Exception('Rate limit exceeded. Please try again later.');
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key. Please check your OpenAI API key.');
    } else {
      final error = (json.decode(response.body) as Map<String, dynamic>?) ?? {};
      final errorMessage = error['error']?['message'] ?? 'Unknown error';
      throw Exception('OpenAI API error: $errorMessage');
    }
  }

  /// Check if we can make a request within rate limits
  bool _canMakeRequest() {
    final now = DateTime.now();

    // Remove old requests outside the rate limit window
    _requestTimes.removeWhere((time) => now.difference(time) > _rateLimitWindow);

    return _requestTimes.length < _maxRequestsPerMinute;
  }

  /// Record a request for rate limiting
  void _recordRequest() {
    _requestTimes.add(DateTime.now());
  }
}
