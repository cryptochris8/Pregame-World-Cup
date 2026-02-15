import 'package:flutter/material.dart';
import '../../../../core/services/logging_service.dart';

/// Widget for the Key Factors tab in the Enhanced AI Insights view.
/// Displays key factors to watch for a matchup.
class AIKeyFactorsTabWidget extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const AIKeyFactorsTabWidget({
    super.key,
    required this.analysisData,
  });

  @override
  Widget build(BuildContext context) {
    final prediction = analysisData['prediction'] is Map
        ? Map<String, dynamic>.from(analysisData['prediction'] as Map)
        : null;
    final keyFactors = prediction?['keyFactors'] as List<dynamic>?;

    LoggingService.info(
        'KEY FACTORS TAB: Analysis data keys: ${analysisData.keys}',
        tag: 'EnhancedInsights');

    if (keyFactors == null || keyFactors.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange, size: 48),
              SizedBox(height: 16),
              Text(
                'No key factors available',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Key factors will appear here when analysis is complete.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Factors to Watch',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...keyFactors.map((factor) => _buildKeyFactorCard(factor)),
        ],
      ),
    );
  }

  Widget _buildKeyFactorCard(dynamic factor) {
    // Handle both String and Map formats
    if (factor is String) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha:0.5), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Key Factor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                factor,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Map format - use structured display
    final factorMap =
        factor is Map ? Map<String, dynamic>.from(factor) : <String, dynamic>{};
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: _getImpactColor(factorMap['impact']), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getImpactColor(factorMap['impact']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    factorMap['category'] ?? 'Factor',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${factorMap['impact'] ?? 'Medium'} Impact',
                  style: TextStyle(
                    color: _getImpactColor(factorMap['impact']),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            factorMap['factor'] ?? 'Key factor to watch',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            factorMap['details'] ?? 'Details not available',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getImpactColor(String? impact) {
    switch (impact?.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
