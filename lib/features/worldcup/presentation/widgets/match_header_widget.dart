import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/entities.dart';
import 'team_flag.dart';

/// Displays the match header with teams, flags, score/time, stage badge,
/// and group info. Used inside the SliverAppBar's FlexibleSpaceBar.
class MatchHeaderWidget extends StatelessWidget {
  final WorldCupMatch match;
  final Color stageColor;

  const MatchHeaderWidget({
    super.key,
    required this.match,
    required this.stageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            stageColor.withValues(alpha:0.8),
            stageColor,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Stage badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  match.stageDisplayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (match.group != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Group ${match.group}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.9),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Teams and score
              Row(
                children: [
                  // Home team
                  Expanded(
                    child: Column(
                      children: [
                        TeamFlag(
                          flagUrl: match.homeFlagUrl,
                          teamCode: match.homeTeamCode,
                          size: 56,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          match.homeTeamName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Score
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.white.withValues(alpha: 0.10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: _buildScoreDisplay(),
                  ),

                  // Away team
                  Expanded(
                    child: Column(
                      children: [
                        TeamFlag(
                          flagUrl: match.awayFlagUrl,
                          teamCode: match.awayTeamCode,
                          size: 56,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          match.awayTeamName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreDisplay() {
    if (match.status == MatchStatus.scheduled) {
      return Column(
        children: [
          const Text(
            'VS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (match.dateTime != null)
            Text(
              DateFormat.jm().format(match.dateTime!),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${match.homeScore ?? 0}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: match.isLive ? const Color(0xFFFF6B6B) : Colors.white,
              ),
            ),
            Text(
              ' - ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            Text(
              '${match.awayScore ?? 0}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: match.isLive ? const Color(0xFFFF6B6B) : Colors.white,
              ),
            ),
          ],
        ),
        if (match.status == MatchStatus.completed)
          Text(
            'Full Time',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        if (match.status == MatchStatus.halfTime)
          Text(
            'Half Time',
            style: TextStyle(
              fontSize: 11,
              color: Colors.orange.shade300,
            ),
          ),
      ],
    );
  }
}
