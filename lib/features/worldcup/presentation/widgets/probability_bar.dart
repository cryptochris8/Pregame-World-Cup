import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/ai_match_prediction.dart';

/// A horizontal three-segment probability bar showing win/draw/loss percentages.
///
/// Displays home win, draw, and away win probabilities as proportionally-sized
/// color segments in a single bar, with percentage labels below each segment.
class ProbabilityBar extends StatelessWidget {
  /// The AI prediction containing probability percentages.
  final AIMatchPrediction prediction;

  /// Display name for the home team.
  final String homeTeamName;

  /// Display name for the away team.
  final String awayTeamName;

  /// Color for the home team segment.
  final Color homeColor;

  /// Color for the away team segment.
  final Color awayColor;

  /// Height of the bar.
  final double barHeight;

  const ProbabilityBar({
    super.key,
    required this.prediction,
    required this.homeTeamName,
    required this.awayTeamName,
    this.homeColor = AppTheme.primaryPurple,
    this.awayColor = AppTheme.primaryOrange,
    this.barHeight = 32,
  });

  static const Color _drawColor = Color(0xFF6B7280); // Neutral gray

  @override
  Widget build(BuildContext context) {
    final homePercent = prediction.homeWinProbability;
    final drawPercent = prediction.drawProbability;
    final awayPercent = prediction.awayWinProbability;

    // Ensure percentages sum to 100 for proper layout
    final total = homePercent + drawPercent + awayPercent;
    final homeFlex = total > 0 ? homePercent : 33;
    final drawFlex = total > 0 ? drawPercent : 34;
    final awayFlex = total > 0 ? awayPercent : 33;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Team name labels row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                homeTeamName,
                style: TextStyle(
                  color: homeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Text(
              'Draw',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Flexible(
              child: Text(
                awayTeamName,
                style: TextStyle(
                  color: awayColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // The probability bar
        ClipRRect(
          borderRadius: BorderRadius.circular(barHeight / 2),
          child: SizedBox(
            height: barHeight,
            child: Row(
              children: [
                // Home segment
                Flexible(
                  flex: homeFlex,
                  child: Container(
                    decoration: BoxDecoration(color: homeColor),
                    alignment: Alignment.center,
                    child: _SegmentLabel(
                      percentage: homePercent,
                      minFlexForLabel: 15,
                    ),
                  ),
                ),
                // Draw segment
                Flexible(
                  flex: drawFlex,
                  child: Container(
                    decoration: const BoxDecoration(color: _drawColor),
                    alignment: Alignment.center,
                    child: _SegmentLabel(
                      percentage: drawPercent,
                      minFlexForLabel: 15,
                    ),
                  ),
                ),
                // Away segment
                Flexible(
                  flex: awayFlex,
                  child: Container(
                    decoration: BoxDecoration(color: awayColor),
                    alignment: Alignment.center,
                    child: _SegmentLabel(
                      percentage: awayPercent,
                      minFlexForLabel: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Percentage labels below
        Row(
          children: [
            Flexible(
              flex: homeFlex,
              child: Center(
                child: Text(
                  '$homePercent%',
                  style: TextStyle(
                    color: homeColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: drawFlex,
              child: Center(
                child: Text(
                  '$drawPercent%',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: awayFlex,
              child: Center(
                child: Text(
                  '$awayPercent%',
                  style: TextStyle(
                    color: awayColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Label shown inside a bar segment when there is enough room.
class _SegmentLabel extends StatelessWidget {
  final int percentage;
  final int minFlexForLabel;

  const _SegmentLabel({
    required this.percentage,
    this.minFlexForLabel = 15,
  });

  @override
  Widget build(BuildContext context) {
    // Only show inline label if segment is wide enough
    if (percentage < minFlexForLabel) {
      return const SizedBox.shrink();
    }

    return Text(
      '$percentage%',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.clip,
      maxLines: 1,
    );
  }
}
