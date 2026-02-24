import 'package:flutter/material.dart';
import '../../../../../config/app_theme.dart';
import '../../../domain/entities/match_summary.dart';
import 'prediction_components.dart';

/// Analysis tab showing historical analysis, storylines, tactical preview, and fun facts.
class AnalysisTab extends StatelessWidget {
  final MatchSummary summary;

  const AnalysisTab({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionWidget(
          title: 'Historical Analysis',
          icon: Icons.history,
          child: Text(
            summary.historicalAnalysis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SectionWidget(
          title: 'Key Storylines',
          icon: Icons.article,
          child: Column(
            children: summary.keyStorylines.map((storyline) {
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
                        color: AppTheme.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        storyline,
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
        const SizedBox(height: 20),
        SectionWidget(
          title: 'Tactical Preview',
          icon: Icons.sports_soccer,
          child: Text(
            summary.tacticalPreview,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
        if (summary.funFacts.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionWidget(
            title: 'Fun Facts',
            icon: Icons.lightbulb_outline,
            child: Column(
              children: summary.funFacts.map((fact) {
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
                          fact,
                          style: const TextStyle(
                            color: Colors.white60,
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
      ],
    );
  }
}
