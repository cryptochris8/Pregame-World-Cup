import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

/// Displays the World Cup-specific head-to-head record between two teams.
class MatchupWorldCupRecord extends StatelessWidget {
  final int team1Wins;
  final int team2Wins;
  final int worldCupMatches;
  final int worldCupDraws;
  final String team1Name;
  final String team2Name;

  const MatchupWorldCupRecord({
    super.key,
    required this.team1Wins,
    required this.team2Wins,
    required this.worldCupMatches,
    required this.worldCupDraws,
    required this.team1Name,
    required this.team2Name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: AppTheme.accentGold, size: 16),
              SizedBox(width: 6),
              Text(
                'World Cup Meetings',
                style: TextStyle(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    team1Wins.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    team1Name,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$worldCupMatches matches',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    team2Wins.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    team2Name,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (worldCupDraws > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '$worldCupDraws draw${worldCupDraws > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
