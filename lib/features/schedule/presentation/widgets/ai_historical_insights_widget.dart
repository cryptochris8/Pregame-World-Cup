import 'package:flutter/material.dart';
import '../../domain/entities/game_schedule.dart';
import '../../../../core/ai/services/ai_game_analysis_service.dart';
import '../../../../core/ai/services/ai_historical_knowledge_service.dart';
import '../../../../injection_container.dart';

/// AI Historical Insights Widget
/// 
/// Displays AI-generated historical context, predictions, and analysis
/// for college football games using the AI Historical Knowledge Service.
class AIHistoricalInsightsWidget extends StatefulWidget {
  final GameSchedule game;
  final bool showFullAnalysis;

  const AIHistoricalInsightsWidget({
    super.key,
    required this.game,
    this.showFullAnalysis = false,
  });

  @override
  State<AIHistoricalInsightsWidget> createState() => _AIHistoricalInsightsWidgetState();
}

class _AIHistoricalInsightsWidgetState extends State<AIHistoricalInsightsWidget> {
  final AIGameAnalysisService _analysisService = sl<AIGameAnalysisService>();
  final AIHistoricalKnowledgeService _knowledgeService = sl<AIHistoricalKnowledgeService>();
  
  Map<String, dynamic>? _gameAnalysis;
  bool _isLoading = true;
  bool _hasError = false;
  String? _quickSummary;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Check if knowledge base is ready
      final isReady = await _knowledgeService.isKnowledgeBaseReady();
      
      if (!isReady) {
        // Show quick summary while knowledge base loads
        final quickSummary = await _analysisService.generateQuickSummary(widget.game);
        setState(() {
          _quickSummary = quickSummary;
          _isLoading = false;
        });
        return;
      }

      if (widget.showFullAnalysis) {
        // Generate comprehensive analysis
        final analysis = await _analysisService.generateGameAnalysis(widget.game);
        setState(() {
          _gameAnalysis = analysis;
          _isLoading = false;
        });
      } else {
        // Generate quick summary
        final quickSummary = await _analysisService.generateQuickSummary(widget.game);
        setState(() {
          _quickSummary = quickSummary;
          _isLoading = false;
        });
      }

    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      // Debug output removed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B), // Dark slate
            Color(0xFF334155), // Lighter slate
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF7C3AED), // Purple
                  Color(0xFF3B82F6), // Blue
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'AI Historical Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!widget.showFullAnalysis && _gameAnalysis == null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                      if (_isExpanded && _gameAnalysis == null) {
                        _loadFullAnalysis();
                      }
                    },
                    child: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_gameAnalysis != null) {
      return _buildFullAnalysisWidget();
    }

    if (_quickSummary != null) {
      return _buildQuickSummaryWidget();
    }

    return _buildNoDataWidget();
  }

  Widget _buildLoadingWidget() {
    return const Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
        ),
        SizedBox(width: 12),
        Text(
          'Analyzing historical data...',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return const Row(
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.orange,
          size: 20,
        ),
        SizedBox(width: 12),
        Text(
          'Analysis temporarily unavailable',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSummaryWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _quickSummary!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        if (!widget.showFullAnalysis && !_isExpanded)
          const SizedBox(height: 12),
        if (!widget.showFullAnalysis && !_isExpanded)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = true;
              });
              _loadFullAnalysis();
            },
            child: const Row(
              children: [
                Text(
                  'View detailed analysis',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.purple,
                  size: 12,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFullAnalysisWidget() {
    final analysis = _gameAnalysis!;
    final prediction = analysis['prediction'] as Map<String, dynamic>?;
    final keyFactors = analysis['keyFactors'] as List<dynamic>?;
    final aiInsights = analysis['aiInsights'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Summary
        if (_quickSummary != null) ...[
          Text(
            _quickSummary!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // AI Prediction
        if (prediction != null) ...[
          _buildSectionHeader('AI Prediction'),
          const SizedBox(height: 8),
          _buildPredictionWidget(prediction),
          const SizedBox(height: 16),
        ],

        // Key Factors
        if (keyFactors != null && keyFactors.isNotEmpty) ...[
          _buildSectionHeader('Key Factors'),
          const SizedBox(height: 8),
          ...keyFactors.map((factor) => _buildFactorItem(factor.toString())),
          const SizedBox(height: 16),
        ],

        // AI Insights
        if (aiInsights != null) ...[
          _buildSectionHeader('AI Analysis'),
          const SizedBox(height: 8),
          _buildAIInsightsWidget(aiInsights),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPredictionWidget(Map<String, dynamic> prediction) {
    final predictedWinner = prediction['predictedWinner'] as String?;
    final confidence = (prediction['confidence'] as double?) ?? 0.5;
    final predictedScore = prediction['predictedScore'] as Map<String, dynamic>?;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (predictedWinner != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Predicted Winner: $predictedWinner',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          
          Row(
            children: [
              const Icon(
                Icons.bar_chart,
                color: Colors.blue,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          if (predictedScore != null && predictedScore.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.scoreboard,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Predicted Score: ${predictedScore.entries.map((e) => '${e.key} ${e.value}').join(' - ')}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFactorItem(String factor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.circle,
            color: Colors.orange,
            size: 6,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              factor,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsWidget(Map<String, dynamic> aiInsights) {
    final summary = aiInsights['summary'] as String?;
    final keyInsights = aiInsights['keyInsights'] as List<dynamic>?;
    final historicalNotes = aiInsights['historicalNotes'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary != null && summary.isNotEmpty) ...[
          Text(
            summary,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (keyInsights != null && keyInsights.isNotEmpty) ...[
          const Text(
            'Key Insights:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          ...keyInsights.map((insight) => _buildFactorItem(insight.toString())),
          const SizedBox(height: 12),
        ],

        if (historicalNotes != null && historicalNotes.isNotEmpty) ...[
          const Text(
            'Historical Context:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            historicalNotes,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNoDataWidget() {
    return const Row(
      children: [
        Icon(
          Icons.info_outline,
          color: Colors.white70,
          size: 20,
        ),
        SizedBox(width: 12),
        Text(
          'Historical data loading...',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<void> _loadFullAnalysis() async {
    if (_gameAnalysis != null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final analysis = await _analysisService.generateGameAnalysis(widget.game);
      
      setState(() {
        _gameAnalysis = analysis;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      // Debug output removed
    }
  }
} 