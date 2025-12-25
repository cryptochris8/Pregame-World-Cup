import '../services/ai_service.dart';
import '../services/ai_venue_recommendation_service.dart';
import '../../services/logging_service.dart';
import '../../../features/recommendations/domain/entities/place.dart';

/// Example usage of AI services for game day features
class AIUsageExample {
  static const String _logTag = 'AIUsageExample';
  
  final AIService _aiService = AIService();
  late final AIVenueRecommendationService _venueService;

  AIUsageExample() {
    _venueService = AIVenueRecommendationService(_aiService);
  }

  /// Example: Get AI-powered venue recommendations
  Future<void> demonstrateVenueRecommendations() async {
    try {
      LoggingService.info('🤖 Demonstrating AI venue recommendations...', tag: _logTag);
      
      // Mock venues data
             final venues = [
         const Place(
           placeId: 'place_1',
           name: 'Buffalo Wild Wings',
           types: ['restaurant', 'sports_bar'],
           rating: 4.2,
           priceLevel: 2,
           vicinity: '123 Game St',
         ),
         const Place(
           placeId: 'place_2', 
           name: 'The Sports Tavern',
           types: ['bar', 'restaurant'],
           rating: 4.5,
           priceLevel: 2,
           vicinity: '456 Fan Ave',
         ),
         const Place(
           placeId: 'place_3',
           name: 'Campus Pizza & Sports',
           types: ['restaurant', 'pizza_place'],
           rating: 4.0,
           priceLevel: 1,
           vicinity: '789 College Rd',
         ),
       ];

      // User preferences
      const userPreferences = '''
        I love watching college football with a crowd of fans. 
        I prefer places with big screens, good food, and a lively atmosphere.
        I'm looking for somewhere not too expensive but with quality food and drinks.
      ''';

      // Game context
      const gameContext = 'Alabama vs Georgia - SEC Championship Game';

      // Get AI recommendations
      final recommendations = await _venueService.generateVenueRecommendations(
        venues: venues,
        userPreferences: userPreferences,
        gameContext: gameContext,
        maxRecommendations: 2,
      );

      // Display results
      LoggingService.info('🎯 AI generated ${recommendations.length} recommendations:', tag: _logTag);
      for (final rec in recommendations) {
        LoggingService.info(
          '  • ${rec.title} (${(rec.confidence * 100).toStringAsFixed(0)}% match)\n'
          '    ${rec.description}\n'
          '    Reasons: ${rec.reasons.join(', ')}',
          tag: _logTag,
        );
      }
    } catch (e) {
      LoggingService.error('Failed to demonstrate venue recommendations: $e', tag: _logTag);
    }
  }

  /// Example: Get AI game predictions
  Future<void> demonstrateGamePredictions() async {
    try {
      LoggingService.info('🏈 Demonstrating AI game predictions...', tag: _logTag);

      final prediction = await _aiService.generateGamePrediction(
        homeTeam: 'Georgia Bulldogs',
        awayTeam: 'Alabama Crimson Tide',
        gameStats: {
          'homeRecord': '11-1',
          'awayRecord': '10-2',
          'homeRanking': 1,
          'awayRanking': 4,
          'venue': 'Mercedes-Benz Stadium',
          'importance': 'SEC Championship Game',
        },
      );

      LoggingService.info('🔮 AI Prediction: $prediction', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to demonstrate game predictions: $e', tag: _logTag);
    }
  }

  /// Example: Calculate venue similarity scores
  Future<void> demonstrateVenueScoring() async {
    try {
      LoggingService.info('📊 Demonstrating venue similarity scoring...', tag: _logTag);

             final venues = [
         const Place(
           placeId: 'place_1',
           name: 'Sports Bar & Grill',
           types: ['sports_bar', 'restaurant'],
           rating: 4.3,
         ),
         const Place(
           placeId: 'place_2',
           name: 'Fine Dining Restaurant', 
           types: ['restaurant', 'upscale'],
           rating: 4.8,
         ),
       ];

      const userPreferences = 'I want a casual sports bar with TVs and game day atmosphere';

      final scores = await _venueService.generateVenueScores(
        venues: venues,
        userPreferences: userPreferences,
      );

      LoggingService.info('🎯 Venue Similarity Scores:', tag: _logTag);
      for (final venue in venues) {
        final score = scores[venue.placeId] ?? 0.0;
        LoggingService.info(
          '  • ${venue.name}: ${(score * 100).toStringAsFixed(1)}% match',
          tag: _logTag,
        );
      }
    } catch (e) {
      LoggingService.error('Failed to demonstrate venue scoring: $e', tag: _logTag);
    }
  }

  /// Example: Test embeddings functionality
  Future<void> demonstrateEmbeddings() async {
    try {
      LoggingService.info('🧠 Demonstrating AI embeddings...', tag: _logTag);

      const text1 = 'sports bar with great game day atmosphere';
      const text2 = 'casual dining with big screen TVs';
      const text3 = 'fine dining restaurant with quiet ambiance';

      // Generate embeddings
      final embedding1 = await _aiService.generateEmbeddings(text1);
      final embedding2 = await _aiService.generateEmbeddings(text2);
      final embedding3 = await _aiService.generateEmbeddings(text3);

      // Calculate similarities
      final similarity12 = _aiService.calculateCosineSimilarity(embedding1, embedding2);
      final similarity13 = _aiService.calculateCosineSimilarity(embedding1, embedding3);
      final similarity23 = _aiService.calculateCosineSimilarity(embedding2, embedding3);

      LoggingService.info('🔗 Text Similarities:', tag: _logTag);
      LoggingService.info('  • Sports bar ↔ Casual dining: ${(similarity12 * 100).toStringAsFixed(1)}%', tag: _logTag);
      LoggingService.info('  • Sports bar ↔ Fine dining: ${(similarity13 * 100).toStringAsFixed(1)}%', tag: _logTag);
      LoggingService.info('  • Casual dining ↔ Fine dining: ${(similarity23 * 100).toStringAsFixed(1)}%', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to demonstrate embeddings: $e', tag: _logTag);
    }
  }

  /// Run all demonstrations
  Future<void> runAllDemos() async {
    LoggingService.info('🚀 Starting AI service demonstrations...', tag: _logTag);
    
    await _aiService.initialize();
    
    if (_aiService.isMockMode) {
      LoggingService.warning('⚠️  Running in MOCK MODE - Add your OpenAI API key to config/api_keys.dart for real AI features!', tag: _logTag);
    } else {
      LoggingService.info('✅ Connected to OpenAI API', tag: _logTag);
    }

    await demonstrateVenueRecommendations();
    await demonstrateGamePredictions();
    await demonstrateVenueScoring();
    await demonstrateEmbeddings();

    LoggingService.info('🎉 AI demonstrations completed!', tag: _logTag);
  }
} 