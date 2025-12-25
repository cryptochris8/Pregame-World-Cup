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
    debugPrint('🏈 DEMO: Real Team Analysis with Claude');
    
    try {
      // Get comprehensive analysis for Alabama with real player data
      final analysis = await _integration.getTeamAnalysisWithRealData('ALA');
      
      if (analysis != null) {
        debugPrint('✅ SUCCESS: Got real data for ${analysis['real_players'].length} players');
        debugPrint('📊 Team Analysis: ${analysis['claude_analysis']?['summary'] ?? 'Analysis pending...'}');
        debugPrint('🏥 Injuries: ${analysis['injury_report'].length} players injured');
        debugPrint('📈 Data Quality: ${analysis['data_quality']}');
      } else {
        debugPrint('⚠️ No real data available for team analysis');
      }
    } catch (e) {
      debugPrint('❌ Demo failed: $e');
    }
  }
  
  /// Demonstrate game prediction with real player matchups
  static Future<void> demoRealGamePrediction() async {
    debugPrint('🎯 DEMO: Game Prediction with Real Players');
    
    try {
      // Predict Alabama vs Auburn with real player data
      final prediction = await _integration.getGamePredictionWithRealPlayers(
        homeTeam: 'ALA',
        awayTeam: 'AUB',
        gameDate: DateTime.now().add(Duration(days: 7)),
        venue: 'Bryant-Denny Stadium',
      );
      
      if (prediction != null) {
        debugPrint('✅ SUCCESS: Generated prediction with real player data');
        debugPrint('🏈 Key Players - Home: ${prediction['key_players']['home'].length}');
        debugPrint('🏈 Key Players - Away: ${prediction['key_players']['away'].length}');
        debugPrint('📊 Prediction: ${prediction['prediction']?['summary'] ?? 'Prediction pending...'}');
        debugPrint('🎯 Confidence: ${prediction['confidence']}');
        debugPrint('🏥 Injury Impact: ${prediction['injury_impact']['advantage']}');
      } else {
        debugPrint('⚠️ No real data available for game prediction');
      }
    } catch (e) {
      debugPrint('❌ Demo failed: $e');
    }
  }
  
  /// Demonstrate individual player analysis with Claude
  static Future<void> demoRealPlayerAnalysis() async {
    debugPrint('👤 DEMO: Real Player Analysis with Claude');
    
    try {
      // This would need a real player ID from SportsData.io
      // For demo, we'll show the process
      debugPrint('🔍 Process: Get real player → Analyze stats → Claude insights');
      debugPrint('📊 Features: Real stats, position analysis, draft potential, season outlook');
      debugPrint('✅ Benefits: No fake names, actual performance data, AI-powered insights');
    } catch (e) {
      debugPrint('❌ Demo failed: $e');
    }
  }
  
  /// Demonstrate injury analysis with real impact assessment
  static Future<void> demoRealInjuryAnalysis() async {
    debugPrint('🏥 DEMO: Real Injury Analysis with Claude');
    
    try {
      // Get injury analysis for Alabama
      final injuryReport = await _integration.getInjuryReportWithAnalysis('ALA');
      
      if (injuryReport != null) {
        debugPrint('✅ SUCCESS: Got real injury data');
        debugPrint('🏥 Injury Count: ${injuryReport['injury_count']}');
        debugPrint('📊 Impact Level: ${injuryReport['impact_level'] ?? 'Unknown'}');
        debugPrint('🧠 Claude Analysis: ${injuryReport['claude_analysis']}');
      } else {
        debugPrint('⚠️ No injury data available');
      }
    } catch (e) {
      debugPrint('❌ Demo failed: $e');
    }
  }
  
  /// Run all demos to showcase the integration
  static Future<void> runAllDemos() async {
    debugPrint('\n🚀 ============ REAL DATA + CLAUDE DEMOS ============\n');
    
    await demoRealTeamAnalysis();
    debugPrint('\n' + '─' * 50 + '\n');
    
    await demoRealGamePrediction();
    debugPrint('\n' + '─' * 50 + '\n');
    
    await demoRealPlayerAnalysis();
    debugPrint('\n' + '─' * 50 + '\n');
    
    await demoRealInjuryAnalysis();
    
    debugPrint('\n🎉 ============ DEMOS COMPLETE ============\n');
    debugPrint('🔑 Key Benefits:');
    debugPrint('   ✅ Real player names and statistics');
    debugPrint('   ✅ Claude AI analysis of actual data');
    debugPrint('   ✅ No more fake "John Smith" players');
    debugPrint('   ✅ Comprehensive injury impact assessment');
    debugPrint('   ✅ Data-driven game predictions');
  }
}

/// Quick test function to verify the integration works
class IntegrationHealthCheck {
  /// Quick health check of the real data + Claude integration
  static Future<bool> checkHealthStatus() async {
    try {
      final integration = sl<ClaudeSportsIntegrationService>();
      
      // Test basic service availability
      debugPrint('🔍 Testing Claude Sports Integration...');
      
      // Try to get data for a popular team
      final quickTest = await integration.getInjuryReportWithAnalysis('ALA');
      
      if (quickTest != null) {
        debugPrint('✅ Integration healthy: Claude + SportsData.io working');
        return true;
      } else {
        debugPrint('⚠️ Integration available but no data returned');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Integration health check failed: $e');
      return false;
    }
  }
} 