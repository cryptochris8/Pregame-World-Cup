import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/head_to_head.dart';

/// Displays a list of notable historical matches between two teams.
class MatchupNotableMatches extends StatelessWidget {
  final List<HistoricalMatch> matches;
  final int maxNotableMatches;
  final bool showAllMatches;
  final String team1Code;
  final String team2Code;
  final String? team1Name;
  final String? team2Name;
  final String h2hTeam1Code;
  final VoidCallback onShowMore;

  const MatchupNotableMatches({
    super.key,
    required this.matches,
    required this.maxNotableMatches,
    required this.showAllMatches,
    required this.team1Code,
    required this.team2Code,
    this.team1Name,
    this.team2Name,
    required this.h2hTeam1Code,
    required this.onShowMore,
  });

  @override
  Widget build(BuildContext context) {
    final displayCount = showAllMatches
        ? matches.length
        : (matches.length > maxNotableMatches
            ? maxNotableMatches
            : matches.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Notable Matches',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...matches
            .take(displayCount)
            .map((match) => _buildHistoricalMatchCard(match)),
        if (matches.length > maxNotableMatches && !showAllMatches)
          TextButton(
            onPressed: onShowMore,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Show ${matches.length - maxNotableMatches} more',
                    style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.accentGold,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHistoricalMatchCard(HistoricalMatch match) {
    final team1IsH2HTeam1 = team1Code == h2hTeam1Code;
    final t1Score = team1IsH2HTeam1 ? match.team1Score : match.team2Score;
    final t2Score = team1IsH2HTeam1 ? match.team2Score : match.team1Score;

    // Determine winner for highlighting
    final isT1Winner = match.winnerCode == team1Code;
    final isT2Winner = match.winnerCode == team2Code;
    final isDraw = match.isDraw;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournament and stage
          Row(
            children: [
              Expanded(
                child: Text(
                  match.tournament,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (match.stage != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStageColor(match.stage!).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    match.stage!,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStageColor(match.stage!),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Score row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                team1Name ?? team1Code,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isT1Winner ? FontWeight.bold : FontWeight.normal,
                  color: isT1Winner
                      ? AppTheme.secondaryEmerald
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDraw
                      ? Colors.grey.withValues(alpha: 0.3)
                      : (isT1Winner
                          ? AppTheme.secondaryEmerald.withValues(alpha: 0.2)
                          : AppTheme.secondaryEmerald.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$t1Score - $t2Score',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                team2Name ?? team2Code,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isT2Winner ? FontWeight.bold : FontWeight.normal,
                  color: isT2Winner
                      ? AppTheme.secondaryEmerald
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Year and location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                match.year.toString(),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              if (match.location != null) ...[
                Text(
                  ' | ',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                Text(
                  match.location!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
          // Description
          if (match.description != null) ...[
            const SizedBox(height: 6),
            Text(
              match.description!,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.4),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Color _getStageColor(String stage) {
    final stageLower = stage.toLowerCase();
    if (stageLower.contains('final') &&
        !stageLower.contains('quarter') &&
        !stageLower.contains('semi')) {
      return AppTheme.accentGold;
    } else if (stageLower.contains('semi')) {
      return Colors.purpleAccent;
    } else if (stageLower.contains('quarter')) {
      return Colors.blueAccent;
    } else if (stageLower.contains('round of 16') ||
        stageLower.contains('knockout')) {
      return Colors.tealAccent;
    } else {
      return Colors.white70;
    }
  }
}
