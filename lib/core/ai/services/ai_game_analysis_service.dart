import '../../../features/schedule/domain/entities/game_schedule.dart';
import '../../services/logging_service.dart';
import '../../services/team_mapping_service.dart';
import '../../../injection_container.dart';
import 'ai_historical_knowledge_service.dart';
import 'ai_service.dart';
import 'multi_provider_ai_service.dart';

/// AI Game Analysis Service
/// 
/// This service uses historical knowledge and Multi-Provider AI to generate intelligent
/// game analysis, predictions, and historical context for World Cup matches.
class AIGameAnalysisService {
  static AIGameAnalysisService? _instance;
  static AIGameAnalysisService get instance => _instance ??= AIGameAnalysisService._();
  
  AIGameAnalysisService._();
  
  final AIHistoricalKnowledgeService _knowledgeService = AIHistoricalKnowledgeService.instance;
  final AIService _aiService = sl<AIService>();
  final MultiProviderAIService _multiAI = sl<MultiProviderAIService>();
  
  /// Generate comprehensive AI analysis for a game
  Future<Map<String, dynamic>?> generateGameAnalysis(GameSchedule game) async {
    try {
      // Debug output removed
      LoggingService.info('🤖 Starting AI game analysis with team mapping', tag: 'AIAnalysis');
      
      // Step 1: Map team names to API keys for better data retrieval
      final homeTeamKey = TeamMappingService.getTeamKey(game.homeTeamName);
      final awayTeamKey = TeamMappingService.getTeamKey(game.awayTeamName);
      
      // Debug output removed
      LoggingService.info('🗺️ Team keys mapped: $homeTeamKey vs $awayTeamKey', tag: 'AIAnalysis');
      
      // Step 2: Gather historical context with mapped team names
      final historicalContext = await _gatherHistoricalContext(game.awayTeamName, game.homeTeamName);
      
      // Step 3: Generate AI insights using OpenAI
      final aiInsights = await _generateAIInsights(game, historicalContext);
      
      // Step 4: Create comprehensive analysis with team mapping info
      final analysis = <String, dynamic>{
        'gameId': game.gameId,
        'teams': {
          'away': {
            'name': game.awayTeamName,
            'key': awayTeamKey,
          },
          'home': {
            'name': game.homeTeamName, 
            'key': homeTeamKey,
          },
        },
        'historicalContext': historicalContext,
        'aiInsights': aiInsights,
        'prediction': await _generatePrediction(game, historicalContext),
        'keyFactors': await _identifyKeyFactors(game, historicalContext),
        'confidence': _calculateConfidence(historicalContext),
        'teamMapping': {
          'homeTeamKey': homeTeamKey,
          'awayTeamKey': awayTeamKey,
        },
        'generatedAt': DateTime.now().toIso8601String(),
      };
      
      // Debug output removed
      LoggingService.info('🤖 Analysis completed successfully', tag: 'AIAnalysis');
      return analysis;
      
    } catch (e) {
      // Debug output removed
      LoggingService.error('AI game analysis failed: $e', tag: 'AIAnalysis');
      return null;
    }
  }
  
  /// Gather historical context for the matchup
  Future<Map<String, dynamic>> _gatherHistoricalContext(String team1, String team2) async {
    try {
      final context = <String, dynamic>{
        'headToHead': null,
        'team1Trends': null,
        'team2Trends': null,
        'recentPerformance': <String, dynamic>{},
        'historicalAverages': <String, dynamic>{},
      };
      
      // Get head-to-head history
      final headToHead = await _knowledgeService.getHeadToHeadHistory(team1, team2);
      if (headToHead != null) {
        context['headToHead'] = headToHead;
      }
      
      // Get team trends
      final team1Trends = await _knowledgeService.getTeamTrends(team1);
      if (team1Trends != null) {
        context['team1Trends'] = team1Trends;
      }
      
      final team2Trends = await _knowledgeService.getTeamTrends(team2);
      if (team2Trends != null) {
        context['team2Trends'] = team2Trends;
      }
      
      // Calculate recent performance (last 2 seasons)
      context['recentPerformance'] = await _calculateRecentPerformance(team1, team2);
      
      return context;
      
    } catch (e) {
      // Debug output removed
      return {};
    }
  }
  
  /// Calculate recent performance for both teams
  Future<Map<String, dynamic>> _calculateRecentPerformance(String team1, String team2) async {
    final recentSeasons = [2023, 2024];
    final performance = <String, dynamic>{
      team1: {'wins': 0, 'losses': 0, 'avgPointsFor': 0.0, 'avgPointsAgainst': 0.0},
      team2: {'wins': 0, 'losses': 0, 'avgPointsFor': 0.0, 'avgPointsAgainst': 0.0},
    };
    
    for (final season in recentSeasons) {
      final seasonStats = await _knowledgeService.getSeasonStatistics(season);
      if (seasonStats != null && seasonStats['teamRecords'] != null) {
        final teamRecords = seasonStats['teamRecords'] as Map<String, dynamic>;
        
        // Update team1 performance
        if (teamRecords.containsKey(team1)) {
          final record = teamRecords[team1];
          performance[team1]['wins'] += record['wins'] ?? 0;
          performance[team1]['losses'] += record['losses'] ?? 0;
          performance[team1]['avgPointsFor'] += (record['pointsFor'] ?? 0) / (record['wins'] + record['losses'] ?? 1);
          performance[team1]['avgPointsAgainst'] += (record['pointsAgainst'] ?? 0) / (record['wins'] + record['losses'] ?? 1);
        }
        
        // Update team2 performance
        if (teamRecords.containsKey(team2)) {
          final record = teamRecords[team2];
          performance[team2]['wins'] += record['wins'] ?? 0;
          performance[team2]['losses'] += record['losses'] ?? 0;
          performance[team2]['avgPointsFor'] += (record['pointsFor'] ?? 0) / (record['wins'] + record['losses'] ?? 1);
          performance[team2]['avgPointsAgainst'] += (record['pointsAgainst'] ?? 0) / (record['wins'] + record['losses'] ?? 1);
        }
      }
    }
    
    // Average across seasons
    for (final team in [team1, team2]) {
      performance[team]['avgPointsFor'] = performance[team]['avgPointsFor'] / recentSeasons.length;
      performance[team]['avgPointsAgainst'] = performance[team]['avgPointsAgainst'] / recentSeasons.length;
      performance[team]['winPercentage'] = performance[team]['wins'] / (performance[team]['wins'] + performance[team]['losses']).clamp(1, double.infinity);
    }
    
    return performance;
  }
  
  /// Generate AI insights using Multi-Provider AI
  Future<Map<String, dynamic>?> _generateAIInsights(GameSchedule game, Map<String, dynamic> historicalContext) async {
    try {
      // Use multi-provider for enhanced sports analysis
      final analysis = await _multiAI.generateSportsAnalysis(
        homeTeam: game.homeTeamName,
        awayTeam: game.awayTeamName,
        gameContext: {
          'date': game.dateTime?.toIso8601String(),
          'venue': game.stadium?.name ?? 'Unknown Venue',
          'historical_context': historicalContext,
        },
      );
      
      return {
        'summary': _extractSummary(analysis),
        'keyInsights': _extractKeyInsights(analysis),
        'historicalNotes': _extractHistoricalNotes(analysis),
        'fullAnalysis': analysis,
        'provider': _multiAI.getBestProviderFor('analysis'),
        'generated_at': DateTime.now().toIso8601String(),
      };
      
    } catch (e) {
      // Debug output removed
      
      // Fallback to basic OpenAI service
      try {
        final prompt = _buildAnalysisPrompt(game, historicalContext);
        final aiResponse = await _aiService.generateCompletion(prompt: prompt);
        
        return {
          'summary': _extractSummary(aiResponse),
          'keyInsights': _extractKeyInsights(aiResponse),
          'historicalNotes': _extractHistoricalNotes(aiResponse),
          'fullAnalysis': aiResponse,
          'provider': 'OpenAI (fallback)',
          'generated_at': DateTime.now().toIso8601String(),
        };
            } catch (fallbackError) {
        // Debug output removed
      }
      
      return null;
    }
  }
  
  /// Build comprehensive prompt for AI analysis
  String _buildAnalysisPrompt(GameSchedule game, Map<String, dynamic> historicalContext) {
    final buffer = StringBuffer();
    
    buffer.writeln('Analyze this international soccer matchup and provide expert insights:');
    buffer.writeln('');
    buffer.writeln('GAME: ${game.awayTeamName} @ ${game.homeTeamName}');
    buffer.writeln('DATE: ${game.dateTime?.toString() ?? 'TBD'}');
          buffer.writeln('VENUE: ${game.stadium?.name ?? 'TBD'}');
    buffer.writeln('');
    
    // Add historical context if available
    if (historicalContext['headToHead'] != null) {
      final headToHead = historicalContext['headToHead'] as Map<String, dynamic>;
      final allTimeRecord = headToHead['allTimeRecord'] as Map<String, dynamic>;
      buffer.writeln('HEAD-TO-HEAD HISTORY:');
      buffer.writeln('All-time record: ${allTimeRecord['team1Wins']} - ${allTimeRecord['team2Wins']} (${allTimeRecord['totalGames']} games)');
      buffer.writeln('');
    }
    
    // Add recent performance
    if (historicalContext['recentPerformance'] != null) {
      final recent = historicalContext['recentPerformance'] as Map<String, dynamic>;
      buffer.writeln('RECENT PERFORMANCE (2023-2024):');
      for (final team in [game.awayTeamName, game.homeTeamName]) {
        if (recent.containsKey(team)) {
          final perf = recent[team];
          buffer.writeln('$team: ${perf['wins']}-${perf['losses']} (${(perf['winPercentage'] * 100).toStringAsFixed(1)}% win rate)');
          buffer.writeln('  Avg Points: ${perf['avgPointsFor'].toStringAsFixed(1)} for, ${perf['avgPointsAgainst'].toStringAsFixed(1)} against');
        }
      }
      buffer.writeln('');
    }
    
    buffer.writeln('Please provide:');
    buffer.writeln('1. SUMMARY: A 2-3 sentence overview of this matchup');
    buffer.writeln('2. KEY INSIGHTS: 3-4 bullet points about what makes this game interesting');
    buffer.writeln('3. HISTORICAL NOTES: Any relevant historical context or storylines');
    buffer.writeln('4. PREDICTION: Your analysis-based prediction with reasoning');
    buffer.writeln('');
    buffer.writeln('Focus on international soccer expertise, team dynamics, and historical significance.');
    
    return buffer.toString();
  }
  
  /// Extract summary from AI response
  String _extractSummary(String aiResponse) {
    final lines = aiResponse.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].toUpperCase().contains('SUMMARY')) {
        // Get the next few lines that contain the summary
        final summaryLines = <String>[];
        for (int j = i + 1; j < lines.length && j < i + 5; j++) {
          final line = lines[j].trim();
          if (line.isNotEmpty && !line.toUpperCase().contains('KEY INSIGHTS') && !line.toUpperCase().contains('HISTORICAL')) {
            summaryLines.add(line);
          } else if (line.toUpperCase().contains('KEY INSIGHTS') || line.toUpperCase().contains('HISTORICAL')) {
            break;
          }
        }
        return summaryLines.join(' ').trim();
      }
    }
    
    // Fallback: use first paragraph
    final paragraphs = aiResponse.split('\n\n');
    return paragraphs.isNotEmpty ? paragraphs[0].trim() : aiResponse.substring(0, 200.clamp(0, aiResponse.length));
  }
  
  /// Extract key insights from AI response
  List<String> _extractKeyInsights(String aiResponse) {
    final insights = <String>[];
    final lines = aiResponse.split('\n');
    bool inInsightsSection = false;
    
    for (final line in lines) {
      if (line.toUpperCase().contains('KEY INSIGHTS')) {
        inInsightsSection = true;
        continue;
      }
      
      if (inInsightsSection) {
        if (line.toUpperCase().contains('HISTORICAL') || line.toUpperCase().contains('PREDICTION')) {
          break;
        }
        
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && (trimmed.startsWith('•') || trimmed.startsWith('-') || trimmed.startsWith('*') || RegExp(r'^\d+\.').hasMatch(trimmed))) {
          insights.add(trimmed.replaceFirst(RegExp(r'^[•\-*\d\.]\s*'), ''));
        }
      }
    }
    
    return insights;
  }
  
  /// Extract historical notes from AI response
  String _extractHistoricalNotes(String aiResponse) {
    final lines = aiResponse.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].toUpperCase().contains('HISTORICAL')) {
        final noteLines = <String>[];
        for (int j = i + 1; j < lines.length; j++) {
          final line = lines[j].trim();
          if (line.isNotEmpty && !line.toUpperCase().contains('PREDICTION')) {
            noteLines.add(line);
          } else if (line.toUpperCase().contains('PREDICTION')) {
            break;
          }
        }
        return noteLines.join(' ').trim();
      }
    }
    return '';
  }
  
  /// Generate prediction based on historical data
  Future<Map<String, dynamic>> _generatePrediction(GameSchedule game, Map<String, dynamic> historicalContext) async {
    try {
      final prediction = <String, dynamic>{
        'predictedWinner': null,
        'confidence': 0.5,
        'predictedScore': <String, int>{},
        'keyFactors': <String>[],
        'reasoning': '',
      };
      
      // Simple prediction logic based on recent performance
      if (historicalContext['recentPerformance'] != null) {
        final recent = historicalContext['recentPerformance'] as Map<String, dynamic>;
        final awayPerf = recent[game.awayTeamName];
        final homePerf = recent[game.homeTeamName];
        
        if (awayPerf != null && homePerf != null) {
          final awayWinRate = awayPerf['winPercentage'] ?? 0.5;
          final homeWinRate = homePerf['winPercentage'] ?? 0.5;
          
          // Home field advantage
          final adjustedHomeWinRate = homeWinRate + 0.1; // 10% home field advantage
          
          if (adjustedHomeWinRate > awayWinRate) {
            prediction['predictedWinner'] = game.homeTeamName;
            prediction['confidence'] = (adjustedHomeWinRate - awayWinRate + 0.5).clamp(0.5, 0.95);
          } else {
            prediction['predictedWinner'] = game.awayTeamName;
            prediction['confidence'] = (awayWinRate - adjustedHomeWinRate + 0.5).clamp(0.5, 0.95);
          }
          
          // Predicted scores based on historical averages
          prediction['predictedScore'] = {
            game.awayTeamName: (awayPerf['avgPointsFor'] ?? 21.0).round(),
            game.homeTeamName: (homePerf['avgPointsFor'] ?? 21.0).round(),
          };
          
          prediction['reasoning'] = 'Based on recent performance and home field advantage';
        }
      }
      
      return prediction;
      
    } catch (e) {
      // Debug output removed
      return {
        'predictedWinner': null,
        'confidence': 0.5,
        'predictedScore': {},
        'keyFactors': [],
        'reasoning': 'Insufficient data for prediction',
      };
    }
  }
  
  /// Identify key factors for the game
  Future<List<String>> _identifyKeyFactors(GameSchedule game, Map<String, dynamic> historicalContext) async {
    final factors = <String>[];
    
    try {
      // Home field advantage
      factors.add('Home field advantage for ${game.homeTeamName}');
      
      // Head-to-head history
      if (historicalContext['headToHead'] != null) {
        final headToHead = historicalContext['headToHead'] as Map<String, dynamic>;
        final allTimeRecord = headToHead['allTimeRecord'] as Map<String, dynamic>;
        final totalGames = allTimeRecord['totalGames'] ?? 0;
        
        if (totalGames > 0) {
          factors.add('Teams have met $totalGames times historically');
        }
      }
      
      // Recent performance trends
      if (historicalContext['recentPerformance'] != null) {
        final recent = historicalContext['recentPerformance'] as Map<String, dynamic>;
        for (final team in [game.awayTeamName, game.homeTeamName]) {
          if (recent.containsKey(team)) {
            final perf = recent[team];
            final winRate = (perf['winPercentage'] ?? 0.5) * 100;
            if (winRate > 70) {
              factors.add('$team has strong recent form (${winRate.toStringAsFixed(0)}% win rate)');
            } else if (winRate < 30) {
              factors.add('$team struggling recently (${winRate.toStringAsFixed(0)}% win rate)');
            }
          }
        }
      }
      
      // Venue factors
      if (game.stadium?.name != null && game.stadium!.name!.isNotEmpty) {
        factors.add('Game at ${game.stadium!.name}');
      }
      
    } catch (e) {
      // Debug output removed
    }
    
    return factors;
  }
  
  /// Calculate confidence level based on available data
  double _calculateConfidence(Map<String, dynamic> historicalContext) {
    double confidence = 0.3; // Base confidence
    
    // Increase confidence based on available data
    if (historicalContext['headToHead'] != null) {
      confidence += 0.2;
    }
    
    if (historicalContext['recentPerformance'] != null) {
      confidence += 0.3;
    }
    
    if (historicalContext['team1Trends'] != null && historicalContext['team2Trends'] != null) {
      confidence += 0.2;
    }
    
    return confidence.clamp(0.3, 0.95);
  }
  
  /// Generate a quick summary for a game (lightweight version)
  Future<String> generateQuickSummary(GameSchedule game) async {
    try {
      final headToHead = await _knowledgeService.getHeadToHeadHistory(game.awayTeamName, game.homeTeamName);
      
      if (headToHead != null) {
        final allTimeRecord = headToHead['allTimeRecord'] as Map<String, dynamic>;
        final totalGames = allTimeRecord['totalGames'] ?? 0;
        final team1Wins = allTimeRecord['team1Wins'] ?? 0;
        final team2Wins = allTimeRecord['team2Wins'] ?? 0;
        
        return 'Historical matchup: $totalGames meetings, $team1Wins-$team2Wins all-time record';
      }
      
      return 'First-time matchup or limited historical data available';
      
    } catch (e) {
      // Debug output removed
      return 'Analysis unavailable';
    }
  }
} 