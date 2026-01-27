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
    // Debug output removed
    
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
      
      // Debug output removed
      // Debug output removed
      // Debug output removed
      // Debug output removed
      // Debug output removed
      // Debug output removed
      
    } catch (e) {
      // Debug output removed
    }
  }
  
  /// Demonstrate comprehensive sports analysis
  static Future<void> demoSportsAnalysis() async {
    // Debug output removed
    
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
      
      // Debug output removed
      // Debug output removed
      
    } catch (e) {
      // Debug output removed
    }
  }
  
  /// Demonstrate historical analysis
  static Future<void> demoHistoricalAnalysis() async {
    // Debug output removed
    
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
      
      // Debug output removed
      // Debug output removed
      
    } catch (e) {
      // Debug output removed
    }
  }
  
  /// Demonstrate venue recommendations
  static Future<void> demoVenueRecommendations() async {
    // Debug output removed
    
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
      
      // Debug output removed
      for (final venue in venues) {
        // Debug output removed
        // Debug output removed
        // Debug output removed
        // Debug output removed
      }
      
    } catch (e) {
      // Debug output removed
    }
  }
  
  /// Demonstrate provider status and routing
  static Future<void> demoProviderStatus() async {
    // Debug output removed
    
    try {
      final status = _multiAI.getProviderStatus();
      
      // Debug output removed
      // Debug output removed
      // Debug output removed
      // Debug output removed
      // Debug output removed
      
      // Debug output removed
      final routing = status['optimal_routing'];
      // Debug output removed
      // Debug output removed
      // Debug output removed
      // Debug output removed
      // Debug output removed
      
    } catch (e) {
      // Debug output removed
    }
  }
  
  /// Run all demos
  static Future<void> runAllDemos() async {
    // Debug output removed
    // Debug output removed
    
    await demoProviderStatus();
    await Future.delayed(Duration(seconds: 2));
    
    await demoGamePrediction();
    await Future.delayed(Duration(seconds: 2));
    
    await demoSportsAnalysis();
    await Future.delayed(Duration(seconds: 2));
    
    await demoHistoricalAnalysis();
    await Future.delayed(Duration(seconds: 2));
    
    await demoVenueRecommendations();
    
    // Debug output removed
    // Debug output removed
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