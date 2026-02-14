import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../services/enhanced_sports_data_service.dart';
import '../../../injection_container.dart';
import '../../services/logging_service.dart';
import 'multi_provider_ai_service.dart';
import '../../../core/entities/player.dart';

/// Claude Sports Integration Service
/// 
/// This service combines real sports data from SportsData.io with Claude AI analysis
/// to provide comprehensive, accurate, and insightful sports information.
/// 
/// Key features:
/// - Real player data (no more fake names!)
/// - Claude-powered analysis of actual statistics
/// - Intelligent game predictions with real context
/// - Injury analysis with actual player names
/// - Depth chart analysis with coaching insights
class ClaudeSportsIntegrationService {
  static ClaudeSportsIntegrationService? _instance;
  static ClaudeSportsIntegrationService get instance => _instance ??= ClaudeSportsIntegrationService._();
  
  ClaudeSportsIntegrationService._();
  
  static const String _logTag = 'ClaudeSportsIntegration';
  
  final EnhancedSportsDataService _sportsData = sl<EnhancedSportsDataService>();
  final MultiProviderAIService _multiAI = sl<MultiProviderAIService>();
  
  /// Get comprehensive team analysis with real player data and Claude insights
  Future<Map<String, dynamic>?> getTeamAnalysisWithRealData(String teamKey, {int? season}) async {
    try {
      LoggingService.info('🏈 Starting comprehensive analysis for $teamKey...', tag: _logTag);
      
      // Step 1: Get real player data from SportsData.io
      final roster = await _sportsData.getTeamRoster(teamKey, season: season);
      final depthChart = await _sportsData.getTeamDepthChart(teamKey, season: season);
      final injuries = await _sportsData.getTeamInjuries(teamKey);
      
      if (roster.isEmpty) {
        LoggingService.warning('⚠️ No real player data available for $teamKey', tag: _logTag);
        return null;
      }
      
      LoggingService.info('✅ Got ${roster.length} real players for analysis', tag: _logTag);
      
      // Step 2: Organize player data for Claude analysis
      final playerData = _organizePlayerDataForAnalysis(roster, depthChart, injuries);
      
      // Step 3: Get Claude's analysis of the real data
      final claudeAnalysis = await _getClaudeTeamAnalysis(teamKey, playerData);
      
      return {
        'team': teamKey,
        'season': season ?? DateTime.now().year,
        'real_players': roster.map((p) => p.toJson()).toList(),
        'depth_chart': depthChart,
        'injury_report': injuries,
        'claude_analysis': claudeAnalysis,
        'data_quality': 'real_data_from_sportsdata_io',
        'analyzed_at': DateTime.now().toIso8601String(),
      };
      
    } catch (e) {
      LoggingService.error('❌ Error in team analysis: $e', tag: _logTag);
      return null;
    }
  }
  
  /// Get game prediction with real player matchups and Claude analysis
  Future<Map<String, dynamic>?> getGamePredictionWithRealPlayers({
    required String homeTeam,
    required String awayTeam,
    DateTime? gameDate,
    String? venue,
  }) async {
    try {
      LoggingService.info('🎯 Predicting $awayTeam @ $homeTeam with real player data...', tag: _logTag);
      
      // Get real roster data for both teams
      final homeRoster = await _sportsData.getTeamRoster(homeTeam);
      final awayRoster = await _sportsData.getTeamRoster(awayTeam);
      final homeInjuries = await _sportsData.getTeamInjuries(homeTeam);
      final awayInjuries = await _sportsData.getTeamInjuries(awayTeam);
      
      if (homeRoster.isEmpty || awayRoster.isEmpty) {
        LoggingService.warning('⚠️ Missing player data for prediction', tag: _logTag);
        return null;
      }
      
      // Analyze key player matchups
      final keyMatchups = _analyzeKeyPlayerMatchups(homeRoster, awayRoster);
      
      // Get Claude's prediction with real context
      final prediction = await _getClaudeGamePrediction({
        'home_team': homeTeam,
        'away_team': awayTeam,
        'game_date': gameDate?.toIso8601String(),
        'venue': venue,
        'home_roster': homeRoster.map((p) => p.toAnalysisJson()).toList(),
        'away_roster': awayRoster.map((p) => p.toAnalysisJson()).toList(),
        'home_injuries': homeInjuries,
        'away_injuries': awayInjuries,
        'key_matchups': keyMatchups,
      });
      
      return {
        'prediction': prediction,
        'key_players': {
          'home': _getKeyPlayers(homeRoster),
          'away': _getKeyPlayers(awayRoster),
        },
        'injury_impact': _assessInjuryImpact(homeInjuries, awayInjuries),
        'matchup_advantages': keyMatchups,
        'data_source': 'sportsdata_io_with_claude_analysis',
        'confidence': 'high_real_data',
      };
      
    } catch (e) {
      LoggingService.error('❌ Error in game prediction: $e', tag: _logTag);
      return null;
    }
  }
  
  /// Get detailed player analysis with Claude insights
  Future<Map<String, dynamic>?> getPlayerAnalysisWithClaude(String playerId, String teamKey) async {
    try {
      // Get real player data
      final player = await _sportsData.getPlayerDetails(playerId, teamKey);
      if (player == null) return null;
      
      // Get detailed statistics
      final stats = await _sportsData.getPlayerStatistics(playerId);
      
      // Get Claude's analysis
      final analysis = await _getClaudePlayerAnalysis(player, stats);
      
      return {
        'player': player.toJson(),
        'detailed_stats': stats,
        'claude_analysis': analysis,
        'strengths_weaknesses': analysis?['player_evaluation'],
        'season_outlook': analysis?['season_projection'],
      };
      
    } catch (e) {
      LoggingService.error('❌ Error in player analysis: $e', tag: _logTag);
      return null;
    }
  }
  
  /// Get injury report with Claude impact analysis
  Future<Map<String, dynamic>?> getInjuryReportWithAnalysis(String teamKey) async {
    try {
      // Get real injury data
      final injuries = await _sportsData.getTeamInjuries(teamKey);
      final roster = await _sportsData.getTeamRoster(teamKey);
      
      if (injuries.isEmpty) {
        return {
          'team': teamKey,
          'injury_count': 0,
          'impact_level': 'minimal',
          'claude_analysis': 'Team appears to be healthy with no significant injuries reported.',
        };
      }
      
      // Get Claude's analysis of injury impact
      final analysis = await _getClaudeInjuryAnalysis(injuries, roster);
      
      return {
        'team': teamKey,
        'injuries': injuries,
        'injury_count': injuries.length,
        'claude_analysis': analysis,
        'impact_assessment': analysis?['team_impact'],
        'depth_concerns': analysis?['depth_analysis'],
      };
      
    } catch (e) {
      LoggingService.error('❌ Error in injury analysis: $e', tag: _logTag);
      return null;
    }
  }
  
  // ==========================================
  // CLAUDE AI ANALYSIS METHODS
  // ==========================================
  
  /// Get Claude's comprehensive team analysis
  Future<Map<String, dynamic>?> _getClaudeTeamAnalysis(String teamKey, Map<String, dynamic> playerData) async {
    final prompt = '''
    Analyze this soccer team using real player data:
    
    Team: $teamKey
    Real Player Data: ${json.encode(playerData)}
    
    Provide comprehensive analysis including:
    1. Offensive strengths and weaknesses based on actual players
    2. Defensive capabilities with specific player analysis
    3. Key players to watch (by name, not generic)
    4. Depth chart concerns or advantages
    5. Coaching scheme fit with current personnel
    6. Season outlook based on actual roster
    
    Focus on REAL PLAYERS with REAL NAMES and REAL STATISTICS.
    ''';
    
    try {
      final analysisText = await _multiAI.generateSportsAnalysis(
        homeTeam: teamKey,
        awayTeam: '', // Single team analysis
        gameContext: {'analysis_type': 'comprehensive_team', 'prompt': prompt},
      );
      
      // Convert text response to structured format
      return {
        'summary': analysisText ?? 'Analysis not available',
        'type': 'comprehensive_team',
        'team': teamKey,
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      LoggingService.error('❌ Error in Claude team analysis: $e', tag: _logTag);
      return null;
    }
  }
  
  /// Get Claude's game prediction with real player context
  Future<Map<String, dynamic>?> _getClaudeGamePrediction(Map<String, dynamic> gameContext) async {
    final prompt = '''
    Predict this soccer match using REAL PLAYER DATA:
    
    Game: ${gameContext['away_team']} @ ${gameContext['home_team']}
    Date: ${gameContext['game_date'] ?? 'TBD'}
    Venue: ${gameContext['venue'] ?? 'TBD'}
    
    REAL HOME ROSTER: ${json.encode(gameContext['home_roster'])}
    REAL AWAY ROSTER: ${json.encode(gameContext['away_roster'])}
    
    HOME INJURIES: ${json.encode(gameContext['home_injuries'])}
    AWAY INJURIES: ${json.encode(gameContext['away_injuries'])}
    
    KEY MATCHUPS: ${json.encode(gameContext['key_matchups'])}
    
    Provide detailed prediction including:
    1. Final score prediction with confidence
    2. Key individual player matchups (specific names)
    3. Which team's strengths/weaknesses will decide the game
    4. Impact of injuries on game outcome
    5. X-factors and players who could swing the result
    
    Base analysis on ACTUAL PLAYERS, not generic positions.
    ''';
    
    return await _multiAI.generateEnhancedGamePrediction(
      homeTeam: gameContext['home_team'],
      awayTeam: gameContext['away_team'],
      gameStats: gameContext,
    );
  }
  
  /// Get Claude's individual player analysis
  Future<Map<String, dynamic>?> _getClaudePlayerAnalysis(Player player, Map<String, dynamic>? stats) async {
    final prompt = '''
    Analyze this soccer player:
    
    Player: ${player.name}
    Position: ${player.position}
    Team: ${player.teamKey ?? 'Unknown'}
    Class: ${player.playerClass}
    Stats: ${json.encode(stats)}
    
    Provide detailed analysis:
    1. Player strengths and areas for improvement
    2. Statistical analysis and trends
    3. Draft potential (if applicable)
    4. Role in team's success
    5. Season outlook and key games to watch
    
    Be specific about THIS PLAYER, not generic position analysis.
    ''';
    
    try {
      // Use Claude for detailed player analysis
      final analysisText = await _multiAI.generateSportsAnalysis(
        homeTeam: player.teamKey ?? '',
        awayTeam: '',
        gameContext: {'analysis_type': 'player_breakdown', 'prompt': prompt},
      );
      
      return {
        'player_evaluation': analysisText ?? 'Analysis not available',
        'season_projection': 'Analysis pending...',
        'type': 'player_analysis',
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      LoggingService.error('❌ Error in Claude player analysis: $e', tag: _logTag);
      return null;
    }
  }
  
  /// Get Claude's injury impact analysis
  Future<Map<String, dynamic>?> _getClaudeInjuryAnalysis(List<Map<String, dynamic>> injuries, List<Player> roster) async {
    final prompt = '''
    Analyze the impact of these REAL INJURIES on team performance:
    
    Injured Players: ${json.encode(injuries)}
    Full Roster: ${roster.map((p) => p.toAnalysisJson()).toList()}
    
    Provide analysis:
    1. Overall impact on team performance
    2. Position group depth concerns
    3. Players who need to step up
    4. Strategic adjustments needed
    5. Timeline for recovery impact
    
    Focus on SPECIFIC PLAYERS and REAL DEPTH CHART implications.
    ''';
    
    try {
      final analysisText = await _multiAI.generateSportsAnalysis(
        homeTeam: '',
        awayTeam: '',
        gameContext: {'analysis_type': 'injury_impact', 'prompt': prompt},
      );
      
      return {
        'team_impact': analysisText ?? 'Impact analysis not available',
        'depth_analysis': 'Depth analysis pending...',
        'type': 'injury_analysis',
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      LoggingService.error('❌ Error in Claude injury analysis: $e', tag: _logTag);
      return null;
    }
  }
  
  // ==========================================
  // UTILITY METHODS
  // ==========================================
  
  /// Organize player data for AI analysis
  Map<String, dynamic> _organizePlayerDataForAnalysis(
    List<Player> roster, 
    Map<String, dynamic>? depthChart, 
    List<Map<String, dynamic>> injuries
  ) {
    return {
      'total_players': roster.length,
      'by_position': _groupPlayersByPosition(roster),
      'key_players': _getKeyPlayers(roster),
      'depth_chart': depthChart,
      'injury_list': injuries.map((inj) => inj['Name'] ?? 'Unknown').toList(),
      'statistical_leaders': _getStatisticalLeaders(roster),
    };
  }
  
  /// Group players by position
  Map<String, List<Map<String, dynamic>>> _groupPlayersByPosition(List<Player> roster) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    
    for (final player in roster) {
      final position = player.position;
      grouped.putIfAbsent(position, () => []);
      grouped[position]!.add(player.toAnalysisJson());
    }
    
    return grouped;
  }
  
  /// Get key players based on statistics and position importance
  List<Map<String, dynamic>> _getKeyPlayers(List<Player> roster) {
    return roster
        .where((p) => p.statistics != null && 
                     (p.statistics!.passing.yards > 100 || 
                      p.statistics!.rushing.yards > 100 ||
                      p.statistics!.receiving.yards > 100 ||
                      p.statistics!.defense.tackles > 10))
        .take(10)
        .map((p) => p.toAnalysisJson())
        .toList();
  }
  
  /// Analyze key player matchups between teams
  List<Map<String, dynamic>> _analyzeKeyPlayerMatchups(List<Player> homeRoster, List<Player> awayRoster) {
    final matchups = <Map<String, dynamic>>[];
    
    // QB vs Defense matchups
    final homeQB = homeRoster.where((p) => p.position == 'QB').firstOrNull;
    final awayDefense = awayRoster.where((p) => ['LB', 'DB', 'S', 'CB'].contains(p.position)).toList();
    
    if (homeQB != null && awayDefense.isNotEmpty) {
      matchups.add({
        'type': 'QB vs Defense',
        'home_player': homeQB.toAnalysisJson(),
        'away_players': awayDefense.take(3).map((p) => p.toAnalysisJson()).toList(),
      });
    }
    
    // Similar logic for other key matchups...
    
    return matchups;
  }
  
  /// Get statistical leaders from roster
  Map<String, dynamic> _getStatisticalLeaders(List<Player> roster) {
    final withStats = roster.where((p) => p.statistics != null).toList();
    
    return {
      'passing_leader': withStats.isNotEmpty 
          ? withStats.reduce((a, b) => 
              (a.statistics?.passing.yards ?? 0) > (b.statistics?.passing.yards ?? 0) ? a : b).toAnalysisJson()
          : null,
      'rushing_leader': withStats.isNotEmpty
          ? withStats.reduce((a, b) => 
              (a.statistics?.rushing.yards ?? 0) > (b.statistics?.rushing.yards ?? 0) ? a : b).toAnalysisJson()
          : null,
      'receiving_leader': withStats.isNotEmpty
          ? withStats.reduce((a, b) => 
              (a.statistics?.receiving.yards ?? 0) > (b.statistics?.receiving.yards ?? 0) ? a : b).toAnalysisJson()
          : null,
    };
  }
  
  /// Assess injury impact on team performance
  Map<String, dynamic> _assessInjuryImpact(List<Map<String, dynamic>> homeInjuries, List<Map<String, dynamic>> awayInjuries) {
    return {
      'home_impact': _calculateInjuryImpact(homeInjuries),
      'away_impact': _calculateInjuryImpact(awayInjuries),
      'advantage': homeInjuries.length < awayInjuries.length ? 'home' : 
                   awayInjuries.length < homeInjuries.length ? 'away' : 'neutral',
    };
  }
  
  /// Calculate injury impact score
  String _calculateInjuryImpact(List<Map<String, dynamic>> injuries) {
    if (injuries.isEmpty) return 'none';
    if (injuries.length <= 2) return 'minimal';
    if (injuries.length <= 5) return 'moderate';
    return 'significant';
  }
}

/// Extension for Player class to add analysis-specific JSON conversion
extension PlayerAnalysis on Player {
  Map<String, dynamic> toAnalysisJson() {
    return {
      'name': name,
      'position': position,
      'class': playerClass,
      'number': number,
      'primary_stat': primaryStat,
      'passing_yards': statistics?.passing.yards ?? 0,
      'rushing_yards': statistics?.rushing.yards ?? 0,
      'receiving_yards': statistics?.receiving.yards ?? 0,
      'tackles': statistics?.defense.tackles ?? 0,
    };
  }
} 