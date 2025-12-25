import 'package:flutter/foundation.dart';
import '../../../injection_container.dart';
import '../services/multi_provider_ai_service.dart';

/// Multi-Provider AI Service Demo
/// 
/// This demo shows how to use the enhanced multi-provider AI service
/// that intelligently routes between OpenAI and Claude for optimal results.
class MultiProviderAIDemo {
  static final MultiProviderAIService _multiAI = sl<MultiProviderAIService>();
  
  /// Demonstrate enhanced game prediction
  static Future<void> demoGamePrediction() async {
    debugPrint('🎯 DEMO: Enhanced Game Prediction');
    
    try {
      final prediction = await _multiAI.generateEnhancedGamePrediction(
        homeTeam: 'Alabama',
        awayTeam: 'Auburn',
        gameStats: {
          'homeRecord': '10-2',
          'awayRecord': '8-4',
          'venue': 'Bryant-Denny Stadium',
          'rivalry': 'Iron Bowl',
          'lastMeeting': 'Alabama won 27-24 in 2024',
        },
      );
      
      debugPrint('📊 PREDICTION RESULT:');
      debugPrint('Winner: ${prediction['prediction']}');
      debugPrint('Confidence: ${prediction['confidence']}%');
      debugPrint('Key Factors: ${prediction['keyFactors']}');
      debugPrint('AI Provider: ${prediction['provider']}');
      debugPrint('Analysis: ${prediction['analysis']}');
      
    } catch (e) {
      debugPrint('❌ DEMO ERROR: Game prediction failed: $e');
    }
  }
  
  /// Demonstrate comprehensive sports analysis
  static Future<void> demoSportsAnalysis() async {
    debugPrint('🏈 DEMO: Comprehensive Sports Analysis');
    
    try {
      final analysis = await _multiAI.generateSportsAnalysis(
        homeTeam: 'Georgia',
        awayTeam: 'Florida',
        gameContext: {
          'venue': 'TIAA Bank Field',
          'neutralSite': true,
          'rivalry': 'World\'s Largest Outdoor Cocktail Party',
          'weather': 'Clear, 75°F',
          'timeSlot': 'CBS 3:30 PM',
        },
      );
      
      debugPrint('📋 ANALYSIS RESULT:');
      debugPrint('Strategic Analysis: $analysis');
      
    } catch (e) {
      debugPrint('❌ DEMO ERROR: Sports analysis failed: $e');
    }
  }
  
  /// Demonstrate historical analysis
  static Future<void> demoHistoricalAnalysis() async {
    debugPrint('📚 DEMO: Historical Analysis');
    
    try {
      final historical = await _multiAI.generateHistoricalAnalysis(
        team1: 'Ohio State',
        team2: 'Michigan',
        historicalData: {
          'allTimeRecord': 'Michigan leads 61-51-6',
          'lastDecade': 'Ohio State 8-2',
          'lastMeeting': 'Michigan won 30-24 in 2024',
          'rivalry': 'The Game',
          'streaks': 'Michigan won 3 straight (2021-2023)',
        },
      );
      
      debugPrint('🏛️ HISTORICAL RESULT:');
      debugPrint('Historical Context: $historical');
      
    } catch (e) {
      debugPrint('❌ DEMO ERROR: Historical analysis failed: $e');
    }
  }
  
  /// Demonstrate venue recommendations
  static Future<void> demoVenueRecommendations() async {
    debugPrint('🍻 DEMO: Venue Recommendations');
    
    try {
      final venues = await _multiAI.generateVenueRecommendations(
        userLocation: 'Tuscaloosa, AL',
        gameContext: 'Alabama vs Auburn - Iron Bowl',
        userPreferences: {
          'atmosphere': 'lively',
          'food': 'southern cuisine',
          'priceRange': 'moderate',
          'walkingDistance': true,
        },
      );
      
      debugPrint('🏟️ VENUE RECOMMENDATIONS:');
      for (final venue in venues) {
        debugPrint('Name: ${venue['name']}');
        debugPrint('Description: ${venue['description']}');
        debugPrint('Confidence: ${venue['confidence']}');
        debugPrint('---');
      }
      
    } catch (e) {
      debugPrint('❌ DEMO ERROR: Venue recommendations failed: $e');
    }
  }
  
  /// Demonstrate provider status and routing
  static Future<void> demoProviderStatus() async {
    debugPrint('⚙️ DEMO: Provider Status');
    
    try {
      final status = _multiAI.getProviderStatus();
      
      debugPrint('🤖 AI PROVIDER STATUS:');
      debugPrint('OpenAI Available: ${status['openai']['available']}');
      debugPrint('OpenAI Model: ${status['openai']['model']}');
      debugPrint('Claude Available: ${status['claude']['available']}');
      debugPrint('Claude Model: ${status['claude']['model']}');
      
      debugPrint('🎯 OPTIMAL ROUTING:');
      final routing = status['optimal_routing'];
      debugPrint('Game Predictions: ${routing['game_predictions']}');
      debugPrint('Sports Analysis: ${routing['sports_analysis']}');
      debugPrint('Venue Recommendations: ${routing['venue_recommendations']}');
      debugPrint('Embeddings: ${routing['embeddings']}');
      debugPrint('Quick Responses: ${routing['quick_responses']}');
      
    } catch (e) {
      debugPrint('❌ DEMO ERROR: Provider status failed: $e');
    }
  }
  
  /// Run all demos
  static Future<void> runAllDemos() async {
    debugPrint('🚀 STARTING MULTI-PROVIDER AI DEMOS');
    debugPrint('=' * 50);
    
    await demoProviderStatus();
    await Future.delayed(Duration(seconds: 2));
    
    await demoGamePrediction();
    await Future.delayed(Duration(seconds: 2));
    
    await demoSportsAnalysis();
    await Future.delayed(Duration(seconds: 2));
    
    await demoHistoricalAnalysis();
    await Future.delayed(Duration(seconds: 2));
    
    await demoVenueRecommendations();
    
    debugPrint('=' * 50);
    debugPrint('✅ ALL MULTI-PROVIDER AI DEMOS COMPLETED');
  }
}

/// Widget to trigger AI demos (for testing purposes)
import 'package:flutter/material.dart';

class AIServiceTestWidget extends StatelessWidget {
  const AIServiceTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Service Test'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7B2CBF), Color(0xFFE85D04)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🧠 Multi-Provider AI Service',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Claude + OpenAI Integration',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  MultiProviderAIDemo.runAllDemos();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🤖 AI Demos started! Check debug console'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  '🚀 Run AI Demos',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  MultiProviderAIDemo.demoProviderStatus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('⚙️ Checking AI provider status...'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  '⚙️ Check AI Status',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 