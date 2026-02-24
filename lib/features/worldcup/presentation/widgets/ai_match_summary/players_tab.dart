import 'package:flutter/material.dart';
import '../../../../../config/app_theme.dart';
import '../../../domain/entities/match_summary.dart';
import '../team_flag.dart';

/// Players tab showing players to watch grouped by team.
class PlayersTab extends StatelessWidget {
  final MatchSummary summary;

  const PlayersTab({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final team1Players = summary.playersToWatch
        .where((p) => p.teamCode == summary.team1Code)
        .toList();
    final team2Players = summary.playersToWatch
        .where((p) => p.teamCode == summary.team2Code)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (team1Players.isNotEmpty) ...[
          _TeamPlayersSection(
            teamName: summary.team1Name,
            teamCode: summary.team1Code,
            players: team1Players,
          ),
          const SizedBox(height: 24),
        ],
        if (team2Players.isNotEmpty)
          _TeamPlayersSection(
            teamName: summary.team2Name,
            teamCode: summary.team2Code,
            players: team2Players,
          ),
      ],
    );
  }
}

class _TeamPlayersSection extends StatelessWidget {
  final String teamName;
  final String teamCode;
  final List<PlayerToWatch> players;

  const _TeamPlayersSection({
    required this.teamName,
    required this.teamCode,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TeamFlag(teamCode: teamCode, size: 24),
            const SizedBox(width: 8),
            Text(
              teamName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...players.map((player) => _PlayerCard(player: player)),
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final PlayerToWatch player;

  const _PlayerCard({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  player.position,
                  style: const TextStyle(
                    color: AppTheme.primaryPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  player.reason,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
