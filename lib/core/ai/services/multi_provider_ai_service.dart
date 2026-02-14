import '../../services/logging_service.dart';
import '../../../injection_container.dart';
import 'ai_service.dart';
import 'claude_service.dart';

/// Multi-Provider AI Service
/// 
/// Intelligently routes AI requests to the optimal provider:
/// - OpenAI: Embeddings, quick responses, venue recommendations
/// - Claude: Deep sports analysis, strategic insights, detailed predictions
/// - Automatic fallback between providers
class MultiProviderAIService {
  static MultiProviderAIService? _instance;
  static MultiProviderAIService get instance => _instance ??= MultiProviderAIService._();
  
  MultiProviderAIService._();
  
  AIService? _openAI;
  ClaudeService? _claude;
  bool _isInitialized = false;
  
  static const String _logTag = 'MultiProviderAIService';
  
  /// Initialize both AI providers
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    LoggingService.info('🚀 Initializing Multi-Provider AI Service...', tag: _logTag);
    
    // Initialize OpenAI service (graceful failure)
    try {
      _openAI = sl<AIService>();
      await _openAI!.initialize();
      LoggingService.info('✅ OpenAI service ready', tag: _logTag);
    } catch (e) {
      LoggingService.error('❌ OpenAI initialization failed: $e', tag: _logTag);
      _openAI = null;
    }
    
    // Initialize Claude service (graceful failure)
    try {
      _claude = ClaudeService();
      await _claude!.initialize();
      LoggingService.info('✅ Claude service ready', tag: _logTag);
    } catch (e) {
      LoggingService.error('❌ Claude initialization failed: $e', tag: _logTag);
      _claude = null;
    }
    
    LoggingService.info(
      '🎯 Multi-Provider AI initialized!\n'
      '   🤖 OpenAI: ${_openAI?.isAvailable == true ? "Available" : "Unavailable"}\n'
      '   🧠 Claude: ${_claude?.isAvailable == true ? "Available" : "Unavailable"}',
      tag: _logTag,
    );
    
    _isInitialized = true;
  }
  
  /// Generate enhanced game prediction using the best AI for the task
  Future<Map<String, dynamic>> generateEnhancedGamePrediction({
    required String homeTeam,
    required String awayTeam,
    required Map<String, dynamic> gameStats,
  }) async {
    try {
      // Use Claude for deep strategic analysis, OpenAI as fallback
      if (_claude?.isAvailable == true) {
        LoggingService.info('Using Claude for enhanced game prediction', tag: _logTag);
        
        final claudePrediction = await _claude!.generateGamePrediction(
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          gameStats: gameStats,
        );
        
        // Enhance with OpenAI embeddings for similar games if available
        if (_openAI?.isAvailable == true) {
          final embedding = await _openAI!.generateEmbeddings(
            '$homeTeam vs $awayTeam prediction analysis'
          );
          claudePrediction['embedding'] = embedding;
        }
        
        claudePrediction['provider'] = 'Claude Sonnet 4';
        return claudePrediction;
        
      } else if (_openAI?.isAvailable == true) {
        LoggingService.info('Using OpenAI fallback for game prediction', tag: _logTag);
        
        final openAIPrediction = await _openAI!.generateGamePrediction(
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          gameStats: gameStats,
        );
        
        return {
          'prediction': openAIPrediction,
          'confidence': 65,
          'keyFactors': ['Statistical analysis', 'Recent team performance'],
          'analysis': openAIPrediction,
          'provider': 'OpenAI GPT-3.5',
        };
      }
      
      // Fallback response
      return _generateFallbackPrediction(homeTeam, awayTeam);
      
    } catch (e) {
      LoggingService.error('Enhanced game prediction failed: $e', tag: _logTag);
      return _generateFallbackPrediction(homeTeam, awayTeam);
    }
  }
  
  /// Generate comprehensive sports analysis using Claude's superior reasoning
  Future<String> generateSportsAnalysis({
    required String homeTeam,
    required String awayTeam,
    required Map<String, dynamic> gameContext,
  }) async {
    try {
      if (_claude?.isAvailable == true) {
        LoggingService.info('Using Claude for comprehensive sports analysis', tag: _logTag);
        return await _claude!.generateSportsAnalysis(
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          gameContext: gameContext,
        );
      } else if (_openAI?.isAvailable == true) {
        LoggingService.info('Using OpenAI fallback for sports analysis', tag: _logTag);
        return await _openAI!.generateCompletion(
          prompt: 'Analyze the matchup between $awayTeam and $homeTeam considering: ${gameContext.toString()}',
          systemMessage: 'You are an international soccer analyst. Provide insights about this upcoming match.',
          maxTokens: 300,
        );
      }
      
      return 'This should be an exciting matchup between $awayTeam and $homeTeam! Both teams have their strengths.';
      
    } catch (e) {
      LoggingService.error('Sports analysis failed: $e', tag: _logTag);
      return 'Analysis temporarily unavailable. Check back soon for detailed insights!';
    }
  }
  
  /// Generate venue recommendations (use OpenAI for this)
  Future<String> generateVenueRecommendations({
    required String userPreferences,
    required String gameContext,
    required List<String> nearbyVenues,
  }) async {
    try {
      LoggingService.info('🏟️ Generating venue recommendations with OpenAI...', tag: _logTag);
      
      // Use OpenAI for venue recommendations (faster, optimized for this)
      final recommendation = await _openAI!.generateVenueRecommendation(
        userPreferences: userPreferences,
        gameContext: gameContext,
        nearbyVenues: nearbyVenues,
      );
      
      LoggingService.info('✅ Venue recommendations generated', tag: _logTag);
      return recommendation;
    } catch (e) {
      LoggingService.error('❌ Error generating venue recommendations: $e', tag: _logTag);
      
      // Fallback response
      final venueList = nearbyVenues.take(2).join(' and ');
      return 'Consider watching at $venueList for a great game day experience!';
    }
  }
  
  /// Generate historical analysis using Claude's superior context understanding
  Future<String> generateHistoricalAnalysis({
    required String team1,
    required String team2,
    required Map<String, dynamic> historicalData,
  }) async {
    try {
      if (_claude?.isAvailable == true) {
        LoggingService.info('Using Claude for historical analysis', tag: _logTag);
        return await _claude!.generateHistoricalAnalysis(
          team1: team1,
          team2: team2,
          historicalData: historicalData,
        );
      } else if (_openAI?.isAvailable == true) {
        LoggingService.info('Using OpenAI fallback for historical analysis', tag: _logTag);
        return await _openAI!.generateCompletion(
          prompt: 'Provide historical context for $team1 vs $team2: ${historicalData.toString()}',
          systemMessage: 'You are an international soccer historian.',
          maxTokens: 250,
        );
      }
      
      return 'The $team1 vs $team2 matchup has an interesting history with competitive games over the years.';
      
    } catch (e) {
      LoggingService.error('Historical analysis failed: $e', tag: _logTag);
      return 'Historical analysis temporarily unavailable.';
    }
  }
  
  /// Generate embeddings using OpenAI (Claude doesn't support embeddings)
  Future<List<double>> generateEmbedding(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      LoggingService.info('🔤 Generating embedding with OpenAI...', tag: _logTag);
      
      // Use OpenAI for embeddings (Claude doesn't support this)
      final embedding = await _openAI!.generateEmbeddings(
        text,
        model: 'text-embedding-3-small',
      );
      
      LoggingService.info('✅ Embedding generated successfully', tag: _logTag);
      return embedding;
    } catch (e) {
      LoggingService.error('❌ Error generating embedding: $e', tag: _logTag);
      return List.generate(1536, (i) => 0.0); // Return zero vector as fallback
    }
  }
  
  /// Quick chat responses (OpenAI optimized for speed)
  Future<String> generateQuickResponse({
    required String prompt,
    String? systemMessage,
  }) async {
    try {
      if (_openAI?.isAvailable == true) {
        return await _openAI!.generateCompletion(
          prompt: prompt,
          systemMessage: systemMessage,
          maxTokens: 150,
          temperature: 0.8,
        );
      } else if (_claude?.isAvailable == true) {
        return await _claude!.generateCompletion(
          prompt: prompt,
          systemMessage: systemMessage,
          maxTokens: 150,
          temperature: 0.8,
        );
      }
      
      return 'I\'m here to help with your Pregame experience! Ask me about games, venues, or predictions.';
      
    } catch (e) {
      LoggingService.error('Quick response failed: $e', tag: _logTag);
      return 'Sorry, I\'m having trouble responding right now. Please try again!';
    }
  }
  
  /// Get provider status and capabilities
  Map<String, dynamic> getProviderStatus() {
    return {
      'openai': {
        'available': _openAI?.isAvailable == true,
        'capabilities': ['embeddings', 'quick_responses', 'venue_recommendations'],
        'model': 'GPT-3.5-turbo',
      },
      'claude': {
        'available': _claude?.isAvailable == true,
        'capabilities': ['deep_analysis', 'strategic_insights', 'detailed_predictions'],
        'model': _claude?.currentModel ?? 'Unavailable',
      },
      'optimal_routing': {
        'game_predictions': _claude?.isAvailable == true ? 'Claude' : 'OpenAI',
        'sports_analysis': _claude?.isAvailable == true ? 'Claude' : 'OpenAI', 
        'venue_recommendations': _openAI?.isAvailable == true ? 'OpenAI' : 'Claude',
        'embeddings': _openAI?.isAvailable == true ? 'OpenAI' : 'None',
        'quick_responses': _openAI?.isAvailable == true ? 'OpenAI' : 'Claude',
      }
    };
  }
  
  /// Generate fallback prediction when all services fail
  Map<String, dynamic> _generateFallbackPrediction(String homeTeam, String awayTeam) {
    return {
      'prediction': 'Competitive game expected between $awayTeam and $homeTeam',
      'confidence': 50,
      'keyFactors': [
        'Both teams have shown strong performance this season',
        'Home field advantage could be a factor',
        'Check recent injury reports for updates'
      ],
      'analysis': 'This matchup promises to be exciting with both teams bringing unique strengths to the field.',
      'provider': 'Fallback',
    };
  }
  
  /// Check if any AI service is available
  bool get isAnyServiceAvailable => (_openAI?.isAvailable == true) || (_claude?.isAvailable == true);
  
  /// Get the best provider for a specific task
  String getBestProviderFor(String taskType) {
    switch (taskType.toLowerCase()) {
      case 'prediction':
      case 'analysis':
      case 'strategic':
        return _claude?.isAvailable == true ? 'Claude' : (_openAI?.isAvailable == true ? 'OpenAI' : 'None');
      case 'venue':
      case 'recommendation':
      case 'embedding':
        return _openAI?.isAvailable == true ? 'OpenAI' : (_claude?.isAvailable == true ? 'Claude' : 'None');
      case 'quick':
      case 'chat':
        return _openAI?.isAvailable == true ? 'OpenAI' : (_claude?.isAvailable == true ? 'Claude' : 'None');
      default:
        return isAnyServiceAvailable ? 'Available' : 'None';
    }
  }
} 