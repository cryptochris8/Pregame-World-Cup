import 'package:flutter/material.dart';

/// Widget for the compact view content of the Enhanced AI Insights.
/// Shows a prediction summary, key factors preview, and a button to
/// open the detailed view.
class AICompactContentWidget extends StatelessWidget {
  final Map<String, dynamic> analysisData;
  final String homeTeamName;
  final String awayTeamName;
  final VoidCallback onViewDetailedAnalysis;

  const AICompactContentWidget({
    super.key,
    required this.analysisData,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.onViewDetailedAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final prediction = analysisData['prediction'] is Map
        ? Map<String, dynamic>.from(analysisData['prediction'] as Map)
        : null;

    // Get key factors from prediction data
    final keyFactors = prediction?['keyFactors'] as List<dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick prediction summary
        if (prediction != null) ...[
          _buildPredictionSummary(prediction),
          const SizedBox(height: 12),
        ],

        // Top 2 key factors preview
        if (keyFactors != null && keyFactors.isNotEmpty) ...[
          _buildKeyFactorsPreview(keyFactors),
          const SizedBox(height: 12),
        ],

        // Enticing call-to-action
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFEA580C),
                Color(0xFFFBBF24),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEA580C).withValues(alpha:0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: onViewDetailedAnalysis,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.analytics_outlined, size: 20),
            label: const Text(
              'View Detailed Analysis',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Condensed prediction summary for compact view
  Widget _buildPredictionSummary(Map<String, dynamic> prediction) {
    final confidenceValue = prediction['confidence'];
    final confidence = confidenceValue is String
        ? double.tryParse(confidenceValue) ?? 0.5
        : (confidenceValue as double? ?? 0.5);

    final homeScoreValue = prediction['homeScore'];
    final homeScore = homeScoreValue is String
        ? int.tryParse(homeScoreValue) ?? 0
        : (homeScoreValue as int? ?? 0);

    final awayScoreValue = prediction['awayScore'];
    final awayScore = awayScoreValue is String
        ? int.tryParse(awayScoreValue) ?? 0
        : (awayScoreValue as int? ?? 0);

    final isHomeWinner = homeScore > awayScore;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[300]!, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'AI Prediction: ',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${isHomeWinner ? homeTeamName : awayTeamName} wins',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$awayScore - $homeScore  •  ${(confidence * 100).toInt()}% confidence',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Preview of top key factors
  Widget _buildKeyFactorsPreview(List<dynamic> keyFactors) {
    final topFactors = keyFactors.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.orange, size: 16),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Key Factors',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...topFactors.map((factor) {
            final factorText = factor is String
                ? factor
                : (factor as Map<String, dynamic>?)?.values.first ??
                    'Key factor';
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('  ',
                      style: TextStyle(color: Colors.orange, fontSize: 12)),
                  Expanded(
                    child: Text(
                      factorText.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (keyFactors.length > 2)
            Text(
              '+${keyFactors.length - 2} more factors...',
              style: TextStyle(
                color: Colors.orange[300],
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
