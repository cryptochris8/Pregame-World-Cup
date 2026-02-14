import 'package:flutter/material.dart';

/// Widget for the Prediction tab in the Enhanced AI Insights view.
/// Displays score prediction cards and confidence analysis.
class AIPredictionTabWidget extends StatelessWidget {
  final Map<String, dynamic> analysisData;
  final String homeTeamName;
  final String awayTeamName;

  const AIPredictionTabWidget({
    super.key,
    required this.analysisData,
    required this.homeTeamName,
    required this.awayTeamName,
  });

  @override
  Widget build(BuildContext context) {
    final prediction = analysisData['prediction'] is Map
        ? Map<String, dynamic>.from(analysisData['prediction'] as Map)
        : null;
    if (prediction == null) {
      return const Center(child: Text('No prediction data'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPredictionCard(prediction),
          const SizedBox(height: 16),
          _buildConfidenceAnalysis(prediction),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(Map<String, dynamic> prediction,
      {bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C3AED),
            Color(0xFF3B82F6),
            Color(0xFFEA580C),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.psychology,
                    color: Colors.white, size: isCompact ? 20 : 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Enhanced AI Analysis',
                  style: TextStyle(
                    fontSize: isCompact ? 16 : 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildScorePredictionCards(prediction),
          if (!isCompact) ...[
            const SizedBox(height: 12),
            Text(
              prediction['analysis'] ?? 'Competitive matchup expected',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build compact score prediction cards - OVERFLOW-PROOF VERSION
  Widget _buildScorePredictionCards(Map<String, dynamic> prediction) {
    final homeScore = prediction['homeScore']?.toString() ??
        prediction['predictedScore']?['home']?.toString() ??
        '--';
    final awayScore = prediction['awayScore']?.toString() ??
        prediction['predictedScore']?['away']?.toString() ??
        '--';
    final confidence = prediction['confidence']?.toString() ?? '';

    // Calculate winner from scores if not provided
    String? winner = prediction['winner']?.toString() ??
        prediction['predictedWinner']?.toString();
    if (winner == null || winner == 'null') {
      final homeScoreInt = int.tryParse(homeScore) ?? 0;
      final awayScoreInt = int.tryParse(awayScore) ?? 0;
      if (homeScoreInt > awayScoreInt) {
        winner = homeTeamName;
      } else if (awayScoreInt > homeScoreInt) {
        winner = awayTeamName;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'Score Prediction',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 12),
          // Away Team
          _buildTeamScoreRow(
            teamName: awayTeamName,
            score: awayScore,
            isWinner: winner == awayTeamName,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: const Center(
              child: Text(
                'vs',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Home Team
          _buildTeamScoreRow(
            teamName: homeTeamName,
            score: homeScore,
            isWinner: winner == homeTeamName,
          ),
          // Confidence
          if (confidence.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Confidence: $confidence',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamScoreRow({
    required String teamName,
    required String score,
    required bool isWinner,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWinner
            ? Colors.green.withOpacity(0.2)
            : const Color(0xFF334155),
        borderRadius: BorderRadius.circular(8),
        border: isWinner ? Border.all(color: Colors.green, width: 2) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_football,
              size: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              teamName,
              style: TextStyle(
                fontSize: isWinner ? 15 : 14,
                fontWeight: isWinner ? FontWeight.w700 : FontWeight.w600,
                color: isWinner ? Colors.green[300] : Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            score,
            style: TextStyle(
              fontSize: isWinner ? 26 : 24,
              fontWeight: FontWeight.bold,
              color: isWinner ? Colors.green[300] : Colors.white,
            ),
          ),
          if (isWinner) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  const Text(
                    'WINNER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceAnalysis(Map<String, dynamic> prediction) {
    final confidenceValue = prediction['confidence'];
    final confidence = confidenceValue is String
        ? double.tryParse(confidenceValue) ?? 0.5
        : (confidenceValue as double? ?? 0.5);

    final riskFactors = prediction['riskFactors'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confidence Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: confidence,
            backgroundColor: Colors.white24,
            valueColor:
                AlwaysStoppedAnimation<Color>(_getConfidenceColor(confidence)),
          ),
          const SizedBox(height: 8),
          Text(
            _getConfidenceDescription(confidence),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          if (riskFactors.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Risk Factors:',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...riskFactors
                .map((factor) => Text(
                      '  $factor',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ))
                .toList(),
          ],
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getConfidenceDescription(double confidence) {
    if (confidence >= 0.8) {
      return 'High confidence prediction based on strong data indicators';
    }
    if (confidence >= 0.6) {
      return 'Moderate confidence with some uncertainty factors';
    }
    return 'Low confidence due to limited data or high uncertainty';
  }
}
