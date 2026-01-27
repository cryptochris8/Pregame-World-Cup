import 'package:flutter/foundation.dart';
import '../../../injection_container.dart';
import '../services/claude_sports_integration_service.dart';

/// Real Data + Claude Integration Demo
/// 
/// This demo shows how to use the enhanced integration service that combines:
/// - Real player data from SportsData.io (no more fake names!)
/// - Claude AI analysis for comprehensive insights
/// - Intelligent game predictions with actual player context
class RealDataClaudeDemo {
  static final ClaudeSportsIntegrationService _integration = sl<ClaudeSportsIntegrationService>();
  
  /// Demonstrate real team analysis with Claude insights
  static Future<void> demoRealTeamAnalysis() async {
    // Debug output removed
    
    try {
      // Get comprehensive analysis for Alabama with real player data
      final analysis = await _integration.getTeamAnalysisWithRealData('ALA');
      
      if (analysis != null) {
        // Debug output removed
        // Debug output removed
        // Debug output removed
        // Debug output removed
      } else {
        // Debug output removed
      }
    } catch (e) {
      // Debug output removed
    }
  }
  
  /// Demonstrate game prediction with real player matchups
  static Future<void> demoRealGamePrediction() async {
    // Debug output removed
    
    try {
      // Predict Alabama vs Auburn with real player data
      final prediction = await _integration.getGamePredictionWithRealPlayers(
        homeTeam: 'ALA',
        awayTeam: 'AUB',
        gameDate: DateTime.now().add(Duration(days: 7)),
        venue: 'Bryant-Denny Stadium',
      );
      
      if (prediction != null) {
        // Debug output removed
        // Debug output removed
        // Debug output removed
        // Debug output removed
        // Debug output removed
        // Debug output removed
      } else {
        // Debug output removed
      }
    } catch (e) {
      // Debug output removed
    }
  }
  
  /// Demonstrate individual player analysis with Claude
  static Future<void> demoRealPlayerAnalysis() async {
    // Debug output removed
    
    try {
      // This would need a real player ID from SportsData.io
      // For demo, we'll show the process
      // Debug output removed
      // Debug output removed
      // Debug output removed
    } catch (e) {
      // Debug output removed
    }
  }
  
  /// Demonstrate injury analysis with real impact assessment
  static Future<void> demoRealInjuryAnalysis() async {
    // Debug output removed
    
    try {
      // Get injury analysis for Alabama
      final injuryReport = await _integration.getInjuryReportWithAnalysis('ALA');
      
      if (injuryReport != null) {
        // Debug output removed
        // Debug output removed
        // Debug output removed
        // Debug output removed
      } else {
        // Debug output removed
      }
    } catch (e) {
      // Debug output removed
    }
  }
  
  /// Run all demos to showcase the integration
  static Future<void> runAllDemos() async {
    // Debug output removed
    
    await demoRealTeamAnalysis();
    // Debug output removed
    
    await demoRealGamePrediction();
    // Debug output removed
    
    await demoRealPlayerAnalysis();
    // Debug output removed
    
    await demoRealInjuryAnalysis();
    
    // Debug output removed
    // Debug output removed
    // Debug output removed
    // Debug output removed
    // Debug output removed
    // Debug output removed
    // Debug output removed
  }
}

/// Quick test function to verify the integration works
class IntegrationHealthCheck {
  /// Quick health check of the real data + Claude integration
  static Future<bool> checkHealthStatus() async {
    try {
      final integration = sl<ClaudeSportsIntegrationService>();
      
      // Test basic service availability
      // Debug output removed
      
      // Try to get data for a popular team
      final quickTest = await integration.getInjuryReportWithAnalysis('ALA');
      
      if (quickTest != null) {
        // Debug output removed
        return true;
      } else {
        // Debug output removed
        return false;
      }
    } catch (e) {
      // Debug output removed
      return false;
    }
  }
} 