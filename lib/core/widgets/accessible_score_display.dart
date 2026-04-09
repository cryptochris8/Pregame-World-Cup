import 'package:flutter/material.dart';

class AccessibleScoreDisplay extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final TextStyle? scoreStyle;
  final TextStyle? separatorStyle;

  const AccessibleScoreDisplay({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    this.scoreStyle,
    this.separatorStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveScoreStyle = scoreStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        );
    final effectiveSeparatorStyle = separatorStyle ??
        TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        );

    return Semantics(
      label: '$homeTeam $homeScore, $awayTeam $awayScore',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$homeScore', style: effectiveScoreStyle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('-', style: effectiveSeparatorStyle),
            ),
            Text('$awayScore', style: effectiveScoreStyle),
          ],
        ),
      ),
    );
  }
}
