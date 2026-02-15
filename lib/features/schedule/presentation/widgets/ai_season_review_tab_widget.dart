import 'package:flutter/material.dart';
import '../../../../core/ai/services/ai_team_season_summary_service.dart';

/// Widget for the Season Review tab in the Enhanced AI Insights view.
/// Displays comprehensive team season summaries with AI-powered analysis.
class AISeasonReviewTabWidget extends StatelessWidget {
  final String homeTeamName;
  final String awayTeamName;
  final AITeamSeasonSummaryService seasonSummaryService;

  const AISeasonReviewTabWidget({
    super.key,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.seasonSummaryService,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purple[800]!, Colors.blue[800]!],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.timeline, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '2024 Season Review',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'AI Powered',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Away Team Season Summary
          _buildTeamSeasonCard(awayTeamName, isAway: true),

          const SizedBox(height: 16),

          // Matchup Context
          _buildMatchupContextCard(),

          const SizedBox(height: 16),

          // Home Team Season Summary
          _buildTeamSeasonCard(homeTeamName, isAway: false),

          const SizedBox(height: 20),

          // Historical Context Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha:0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Season data based on 2024 historical performance and ESPN integration',
                    style: TextStyle(
                      color: Colors.white70,
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

  Widget _buildTeamSeasonCard(String teamName, {required bool isAway}) {
    return FutureBuilder<Map<String, dynamic>>(
      future:
          seasonSummaryService.generateTeamSeasonSummary(teamName, season: 2024),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSeasonSummaryLoading(teamName, isAway: isAway);
        } else if (snapshot.hasError) {
          return _buildSeasonSummaryError(teamName, isAway: isAway);
        } else if (snapshot.hasData) {
          return _buildSeasonSummaryContent(snapshot.data!, isAway: isAway);
        } else {
          return _buildSeasonSummaryFallback(teamName, isAway: isAway);
        }
      },
    );
  }

  Widget _buildSeasonSummaryLoading(String teamName, {required bool isAway}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAway
              ? Colors.red.withValues(alpha:0.3)
              : Colors.green.withValues(alpha:0.3),
        ),
      ),
      child: Column(
        children: [
          _buildTeamHeader(teamName, isAway: isAway),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                strokeWidth: 2,
              ),
              SizedBox(width: 12),
              Text(
                'Analyzing season data...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonSummaryError(String teamName, {required bool isAway}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAway
              ? Colors.red.withValues(alpha:0.3)
              : Colors.green.withValues(alpha:0.3),
        ),
      ),
      child: Column(
        children: [
          _buildTeamHeader(teamName, isAway: isAway),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Season analysis temporarily unavailable',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonSummaryContent(Map<String, dynamic> summary,
      {required bool isAway}) {
    final teamName = summary['teamName'] ?? 'Team';
    final seasonRecord = summary['seasonRecord'] is Map
        ? Map<String, dynamic>.from(summary['seasonRecord'] as Map)
        : <String, dynamic>{};
    final overall = seasonRecord['overall'] is Map
        ? Map<String, dynamic>.from(seasonRecord['overall'] as Map)
        : <String, dynamic>{'wins': 0, 'losses': 0};
    final keyInsights = summary['keyInsights'] as List<dynamic>? ?? [];
    final playersAnalysis = summary['playersAnalysis'] is Map
        ? Map<String, dynamic>.from(summary['playersAnalysis'] as Map)
        : <String, dynamic>{};
    final starPlayers = playersAnalysis['starPlayers'] as List<dynamic>? ?? [];
    final overallAssessment = summary['overallAssessment'] is Map
        ? Map<String, dynamic>.from(summary['overallAssessment'] as Map)
        : <String, dynamic>{};
    final postseasonAnalysis = summary['postseasonAnalysis'] is Map
        ? Map<String, dynamic>.from(summary['postseasonAnalysis'] as Map)
        : <String, dynamic>{};
    final highlightStats = summary['highlightStats'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAway
              ? Colors.red.withValues(alpha:0.3)
              : Colors.green.withValues(alpha:0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _buildHomeAwayBadge(isAway),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  teamName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getGradeColor(
                      overallAssessment['seasonGrade'] ?? 'C'),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  overallAssessment['seasonGrade'] ?? 'C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Season Record
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${overall['wins']}-${overall['losses']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Season Record',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        postseasonAnalysis['bowlEligibility']
                                    ?.toString()
                                    .contains('Eligible') ==
                                true
                            ? '🏆'
                            : '❌',
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        postseasonAnalysis['bowlEligibility'] ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick Stats Row
          if (highlightStats.isNotEmpty) ...[
            Row(
              children: highlightStats
                  .take(2)
                  .map((stat) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.orange.withValues(alpha:0.3)),
                          ),
                          child: Text(
                            stat.toString(),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Key Insights
          if (keyInsights.isNotEmpty) ...[
            const Text(
              'Season Highlights',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...keyInsights
                .take(2)
                .map((insight) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '  ',
                            style:
                                TextStyle(color: Colors.orange, fontSize: 14),
                          ),
                          Expanded(
                            child: Text(
                              insight.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                ,
            const SizedBox(height: 16),
          ],

          // Star Players Preview
          if (starPlayers.isNotEmpty) ...[
            const Text(
              'Key Players',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...starPlayers.take(2).map((player) {
              final playerData = player is Map
                  ? Map<String, dynamic>.from(player)
                  : <String, dynamic>{};
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        playerData['position'] ?? 'POS',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playerData['name'] ?? 'Player',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            playerData['year'] ?? 'Senior',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Season Assessment
          if (overallAssessment['assessment'] != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo[900]!, Colors.purple[900]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Season Assessment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    overallAssessment['assessment'].toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
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

  Widget _buildSeasonSummaryFallback(String teamName, {required bool isAway}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAway
              ? Colors.red.withValues(alpha:0.3)
              : Colors.green.withValues(alpha:0.3),
        ),
      ),
      child: Column(
        children: [
          _buildTeamHeader(teamName, isAway: isAway),
          const SizedBox(height: 16),
          const Text(
            'Season analysis coming soon - historical data being processed',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamHeader(String teamName, {required bool isAway}) {
    return Row(
      children: [
        _buildHomeAwayBadge(isAway),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            teamName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeAwayBadge(bool isAway) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAway ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAway ? 'AWAY' : 'HOME',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMatchupContextCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.orange[900]!, Colors.red[900]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.flash_on, color: Colors.white, size: 24),
          SizedBox(height: 8),
          Text(
            'Matchup Context',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Two programs with rich histories collide in what promises to be an exciting matchup based on their recent seasons.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return Colors.green;
      case 'B+':
      case 'B':
        return Colors.blue;
      case 'C+':
      case 'C':
        return Colors.orange;
      case 'D':
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
