import 'package:flutter/material.dart';
import '../../../../core/ai/services/ai_service.dart';
import '../../domain/entities/game_schedule.dart';
import '../../../../injection_container.dart';

/// AI-powered game insights and predictions widget
class AIGameInsightsWidget extends StatefulWidget {
  final GameSchedule game;

  const AIGameInsightsWidget({
    super.key,
    required this.game,
  });

  @override
  State<AIGameInsightsWidget> createState() => _AIGameInsightsWidgetState();
}

class _AIGameInsightsWidgetState extends State<AIGameInsightsWidget> {
  String? _aiPrediction;
  String? _keyInsights;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAIInsights();
  }

  Future<void> _loadAIInsights() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final aiService = sl<AIService>();
      
      // Generate AI prediction
      final gameStats = _buildGameStats();
      final prediction = await aiService.generateGamePrediction(
        homeTeam: widget.game.homeTeamName,
        awayTeam: widget.game.awayTeamName,
        gameStats: gameStats,
      );

      // Generate key insights
      final insights = await aiService.generateCompletion(
        prompt: _buildInsightsPrompt(),
        systemMessage: '''
You are a college football analyst providing key insights for fans.
Focus on 2-3 most important factors that could determine the game outcome.
Keep it concise and engaging for casual fans.
''',
        maxTokens: 150,
        temperature: 0.4,
      );

      if (mounted) {
        setState(() {
          _aiPrediction = prediction;
          _keyInsights = insights;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _buildGameStats() {
    final stats = <String, dynamic>{
      'gameType': 'College Football',
      'venue': 'Home game for ${widget.game.homeTeamName}',
    };

    if (widget.game.week != null) {
      stats['week'] = widget.game.week;
      
      // Add context based on week
      if (widget.game.week! > 10) {
        stats['context'] = 'Late season - playoff implications possible';
      } else if (widget.game.week! < 4) {
        stats['context'] = 'Early season - teams still finding rhythm';
      } else {
        stats['context'] = 'Mid-season conference play';
      }
    }

    if (widget.game.dateTimeUTC != null) {
      final gameTime = widget.game.dateTimeUTC!.toLocal();
      final hour = gameTime.hour;
      
      if (hour >= 19) {
        stats['timeContext'] = 'Night game - prime time atmosphere';
      } else if (hour >= 15) {
        stats['timeContext'] = 'Afternoon game - traditional college football';
      } else {
        stats['timeContext'] = 'Early game - teams need to start fast';
      }
    }

    return stats;
  }

  String _buildInsightsPrompt() {
    return '''
Analyze this college football matchup: ${widget.game.awayTeamName} @ ${widget.game.homeTeamName}

Game context: Week ${widget.game.week ?? 'TBD'} of college football season

Provide 2-3 key factors that could determine the outcome:
- What should fans watch for?
- Which team has advantages?
- What makes this game interesting?

Keep it concise and engaging for fans planning their game day experience.
''';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🧠', style: TextStyle(fontSize: 14)),
              SizedBox(width: 6),
              Text(
                'AI Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${widget.game.awayTeamName} @ ${widget.game.homeTeamName}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: _isLoading ? null : _loadAIInsights,
          icon: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                )
              : const Icon(Icons.refresh, color: Colors.orange, size: 20),
          tooltip: 'Refresh AI Analysis',
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              SizedBox(height: 12),
              Text(
                'AI is analyzing the matchup...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Unable to load AI analysis',
                style: TextStyle(
                  color: Colors.red[300],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Prediction Section
        if (_aiPrediction != null) ...[
          _buildInsightSection(
            icon: Icons.psychology,
            title: 'AI Prediction',
            content: _aiPrediction!,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
        ],
        
        // Key Insights Section
        if (_keyInsights != null) ...[
          _buildInsightSection(
            icon: Icons.lightbulb,
            title: 'Key Factors to Watch',
            content: _keyInsights!,
            color: Colors.orange,
          ),
        ],
      ],
    );
  }

  Widget _buildInsightSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
} 