import 'package:flutter/material.dart';
import '../../../../core/services/logging_service.dart';

/// Widget for the Historical Analysis tab (labeled "Analysis") in the
/// Enhanced AI Insights view. Displays AI insights, team season data,
/// and head-to-head history.
class AIHistoricalAnalysisTabWidget extends StatelessWidget {
  final Map<String, dynamic>? analysisData;
  final String homeTeamName;
  final String awayTeamName;

  const AIHistoricalAnalysisTabWidget({
    super.key,
    required this.analysisData,
    required this.homeTeamName,
    required this.awayTeamName,
  });

  @override
  Widget build(BuildContext context) {
    LoggingService.info('Building Historical Analysis tab',
        tag: 'EnhancedInsights');
    final historicalData = analysisData?['historical'] is Map
        ? Map<String, dynamic>.from(analysisData!['historical'] as Map)
        : null;
    final aiInsights = analysisData?['aiInsights'] is Map
        ? Map<String, dynamic>.from(analysisData!['aiInsights'] as Map)
        : null;

    if (historicalData == null && aiInsights == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Analysis Summary
          if (aiInsights != null) ...[
            _buildHistoricalInsightsSection(aiInsights),
            const SizedBox(height: 20),
          ],

          // Home Team Season Analysis
          if (historicalData?['home'] != null) ...[
            _buildTeamSeasonSection(
                homeTeamName,
                Map<String, dynamic>.from(historicalData!['home'] as Map),
                Colors.blue),
            const SizedBox(height: 20),
          ],

          // Away Team Season Analysis
          if (historicalData?['away'] != null) ...[
            _buildTeamSeasonSection(
                awayTeamName,
                Map<String, dynamic>.from(historicalData!['away'] as Map),
                Colors.green),
            const SizedBox(height: 20),
          ],

          // Head-to-Head History
          if (historicalData?['headToHead'] != null) ...[
            _buildHeadToHeadSection(Map<String, dynamic>.from(
                historicalData!['headToHead'] as Map)),
          ],

          // Data Quality Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Season data based on ${DateTime.now().year - 1} historical performance and real game statistics',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build historical insights section with AI analysis
  Widget _buildHistoricalInsightsSection(Map<String, dynamic> insights) {
    final summary = insights['summary'] as String? ?? '';
    final analysis = insights['analysis'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'AI Historical Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (summary.isNotEmpty) ...[
            Text(
              summary,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (analysis.isNotEmpty) ...[
            Text(
              analysis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build team season analysis section
  Widget _buildTeamSeasonSection(
      String teamName, Map<String, dynamic> seasonData, Color teamColor) {
    final performance = seasonData['performance'] is Map
        ? Map<String, dynamic>.from(seasonData['performance'] as Map)
        : <String, dynamic>{};
    final narrative = seasonData['narrative'] as String? ?? '';
    final record = performance['record'] as String? ?? '';
    final avgPointsFor = performance['avgPointsFor']?.toString() ?? '';
    final avgPointsAgainst = performance['avgPointsAgainst']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: teamColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sports_football, color: teamColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$teamName Season Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: teamColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Season Statistics
          if (record.isNotEmpty || avgPointsFor.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: teamColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (record.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Record:',
                            style: TextStyle(color: Colors.white70)),
                        Text(record,
                            style: TextStyle(
                                color: teamColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (avgPointsFor.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Avg Points Scored:',
                            style: TextStyle(color: Colors.white70)),
                        Text(avgPointsFor,
                            style: TextStyle(
                                color: teamColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (avgPointsAgainst.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Avg Points Allowed:',
                            style: TextStyle(color: Colors.white70)),
                        Text(avgPointsAgainst,
                            style: TextStyle(
                                color: teamColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Season Narrative
          if (narrative.isNotEmpty) ...[
            const Text(
              'Season Story:',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              narrative,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build head-to-head history section
  Widget _buildHeadToHeadSection(Map<String, dynamic> headToHeadData) {
    final narrative = headToHeadData['narrative'] as String? ?? '';
    final totalMeetings = headToHeadData['totalMeetings']?.toString() ?? '';

    if (narrative.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Head-to-Head History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              if (totalMeetings.isNotEmpty) ...[
                const Spacer(),
                Text(
                  '$totalMeetings meetings',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            narrative,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
