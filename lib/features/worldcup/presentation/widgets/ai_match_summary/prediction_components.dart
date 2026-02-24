import 'package:flutter/material.dart';
import '../../../../../config/app_theme.dart';
import '../../../domain/entities/ai_match_prediction.dart';
import '../team_flag.dart';

/// Reusable section header with icon and title.
class SectionWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const SectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryPurple,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// Confidence meter with percentage, label, and progress bar.
class ConfidenceMeter extends StatelessWidget {
  final int confidence;

  const ConfidenceMeter({super.key, required this.confidence});

  Color _getColor() {
    if (confidence >= 75) return AppTheme.secondaryEmerald;
    if (confidence >= 50) return AppTheme.primaryOrange;
    return AppTheme.primaryRed;
  }

  String _getLabel() {
    if (confidence >= 80) return 'High Confidence';
    if (confidence >= 60) return 'Moderate Confidence';
    if (confidence >= 40) return 'Low Confidence';
    return 'Uncertain';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$confidence%',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _getLabel(),
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

/// Win/draw/loss probability bars.
class ProbabilityBars extends StatelessWidget {
  final AIMatchPrediction prediction;
  final String team1Name;
  final String team2Name;

  const ProbabilityBars({
    super.key,
    required this.prediction,
    required this.team1Name,
    required this.team2Name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProbabilityRow(
          label: team1Name,
          probability: prediction.homeWinProbability,
          color: AppTheme.secondaryEmerald,
        ),
        const SizedBox(height: 6),
        _ProbabilityRow(
          label: 'Draw',
          probability: prediction.drawProbability,
          color: AppTheme.primaryOrange,
        ),
        const SizedBox(height: 6),
        _ProbabilityRow(
          label: team2Name,
          probability: prediction.awayWinProbability,
          color: AppTheme.primaryBlue,
        ),
      ],
    );
  }
}

class _ProbabilityRow extends StatelessWidget {
  final String label;
  final int probability;
  final Color color;

  const _ProbabilityRow({
    required this.label,
    required this.probability,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: probability / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '$probability%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// Upset alert banner.
class UpsetAlert extends StatelessWidget {
  final String text;

  const UpsetAlert({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(alpha: 0.2),
            Colors.orange.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          const Text(
            'UPSET ALERT',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Recent form row for one team.
class FormRow extends StatelessWidget {
  final String teamName;
  final String form;

  const FormRow({super.key, required this.teamName, required this.form});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            teamName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            form,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

/// Confidence debate section for close matches.
class ConfidenceDebateSection extends StatelessWidget {
  final String text;

  const ConfidenceDebateSection({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.balance, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why This Is Close',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Prediction header with score, flags, and probability bars.
class PredictionHeader extends StatelessWidget {
  final AIMatchPrediction prediction;
  final String team1Code;
  final String team2Code;
  final String team1Name;
  final String team2Name;

  const PredictionHeader({
    super.key,
    required this.prediction,
    required this.team1Code,
    required this.team2Code,
    required this.team1Name,
    required this.team2Name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TeamFlag(teamCode: team1Code, size: 36),
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
                  prediction.scoreDisplay,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TeamFlag(teamCode: team2Code, size: 36),
            ],
          ),
          const SizedBox(height: 16),
          ProbabilityBars(
            prediction: prediction,
            team1Name: team1Name,
            team2Name: team2Name,
          ),
        ],
      ),
    );
  }
}
