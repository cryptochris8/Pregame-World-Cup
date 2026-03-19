import 'package:flutter/material.dart';
import '../../../../../config/app_theme.dart';
import '../../../domain/entities/match_summary.dart';
import '../team_flag.dart';
import 'prediction_components.dart';

/// Fallback prediction tab using basic Firestore MatchPredictionSummary data.
class FirestorePredictionTab extends StatelessWidget {
  final MatchSummary summary;

  const FirestorePredictionTab({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final prediction = summary.prediction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPurple.withValues(alpha: 0.2),
                AppTheme.primaryBlue.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryPurple.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              const Text(
                'AI PREDICTION',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TeamFlag(teamCode: summary.team1Code, size: 36),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      prediction.predictedScore,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TeamFlag(teamCode: summary.team2Code, size: 36),
                ],
              ),
              const SizedBox(height: 12),
              ConfidenceMeter(confidence: prediction.confidence),
            ],
          ),
        ),
        const SizedBox(height: 20),

        SectionWidget(
          title: 'Reasoning',
          icon: Icons.psychology,
          child: Text(
            prediction.reasoning,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),

        if (prediction.alternativeScenario != null) ...[
          const SizedBox(height: 20),
          SectionWidget(
            title: 'Alternative Scenario',
            icon: Icons.compare_arrows,
            child: Text(
              prediction.alternativeScenario!,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],

        if (summary.pastEncountersSummary != null) ...[
          const SizedBox(height: 20),
          SectionWidget(
            title: 'Past Encounters',
            icon: Icons.history_edu,
            child: Text(
              summary.pastEncountersSummary!,
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
