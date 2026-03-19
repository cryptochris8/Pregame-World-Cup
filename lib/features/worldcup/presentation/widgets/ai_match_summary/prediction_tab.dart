import 'package:flutter/material.dart';
import '../../../../../config/app_theme.dart';
import '../../../domain/entities/ai_match_prediction.dart';
import '../../../domain/entities/match_summary.dart';
import 'prediction_components.dart';

/// Rich prediction tab powered by LocalPredictionEngine data.
class PredictionTab extends StatelessWidget {
  final AIMatchPrediction prediction;
  final MatchSummary summary;
  final String? homeTeamCode;

  const PredictionTab({
    super.key,
    required this.prediction,
    required this.summary,
    this.homeTeamCode,
  });

  /// Whether summary team order is reversed relative to home/away.
  /// Summary stores teams alphabetically, but predictions use home/away.
  bool get _isReversed =>
      homeTeamCode != null && summary.team1Code != homeTeamCode;

  @override
  Widget build(BuildContext context) {
    // Reorder teams to match home/away when needed
    final displayTeam1Code = _isReversed ? summary.team2Code : summary.team1Code;
    final displayTeam2Code = _isReversed ? summary.team1Code : summary.team2Code;
    final displayTeam1Name = _isReversed ? summary.team2Name : summary.team1Name;
    final displayTeam2Name = _isReversed ? summary.team1Name : summary.team2Name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PredictionHeader(
          prediction: prediction,
          team1Code: displayTeam1Code,
          team2Code: displayTeam2Code,
          team1Name: displayTeam1Name,
          team2Name: displayTeam2Name,
        ),
        const SizedBox(height: 16),

        ConfidenceMeter(confidence: prediction.confidence),

        if (prediction.isUpsetAlert && prediction.upsetAlertText != null) ...[
          const SizedBox(height: 16),
          UpsetAlert(text: prediction.upsetAlertText!),
        ],

        if (prediction.keyFactors.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionWidget(
            title: 'Key Factors',
            icon: Icons.lightbulb,
            child: Column(
              children: prediction.keyFactors.map((factor) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.accentGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          factor,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        if (prediction.homeRecentForm != null ||
            prediction.awayRecentForm != null) ...[
          const SizedBox(height: 20),
          SectionWidget(
            title: 'Recent Form',
            icon: Icons.trending_up,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (prediction.homeRecentForm != null)
                  FormRow(teamName: displayTeam1Name, form: prediction.homeRecentForm!),
                if (prediction.homeRecentForm != null &&
                    prediction.awayRecentForm != null)
                  const SizedBox(height: 8),
                if (prediction.awayRecentForm != null)
                  FormRow(teamName: displayTeam2Name, form: prediction.awayRecentForm!),
              ],
            ),
          ),
        ],

        if (prediction.squadValueNarrative != null) ...[
          const SizedBox(height: 20),
          SectionWidget(
            title: 'Squad Value Showdown',
            icon: Icons.attach_money,
            child: Text(
              prediction.squadValueNarrative!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],

        if (prediction.managerMatchup != null) ...[
          const SizedBox(height: 20),
          SectionWidget(
            title: 'Manager Matchup',
            icon: Icons.person,
            child: Text(
              prediction.managerMatchup!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],

        if (prediction.historicalPatterns.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionWidget(
            title: 'Historical Patterns',
            icon: Icons.history,
            child: Column(
              children: prediction.historicalPatterns.take(3).map((pattern) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '\u2022 ',
                        style: TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          pattern,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        if (prediction.confidenceDebate != null) ...[
          const SizedBox(height: 20),
          ConfidenceDebateSection(text: prediction.confidenceDebate!),
        ],

        if (prediction.bettingOddsSummary != null) ...[
          const SizedBox(height: 20),
          SectionWidget(
            title: 'Betting Odds',
            icon: Icons.casino,
            child: Text(
              prediction.bettingOddsSummary!,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],

        if (prediction.analysis.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionWidget(
            title: 'Analysis',
            icon: Icons.psychology,
            child: Text(
              prediction.analysis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
