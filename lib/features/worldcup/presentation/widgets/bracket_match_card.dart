import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import 'live_indicator.dart';
import 'team_flag.dart';

/// Card displaying a knockout bracket match
class BracketMatchCard extends StatelessWidget {
  final BracketMatch match;
  final VoidCallback? onTap;
  final bool showConnector;
  final bool isLeft;

  const BracketMatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.showConnector = false,
    this.isLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(8),
          border: match.isLive
              ? Border.all(color: Colors.red, width: 2)
              : match.isCompleted
                  ? Border.all(color: Colors.white.withValues(alpha:0.2))
                  : Border.all(color: Colors.white.withValues(alpha:0.1)),
          boxShadow: match.isLive
              ? [BoxShadow(color: Colors.red.withValues(alpha:0.3), blurRadius: 8)]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with stage and live indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getStageLabel(),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (match.isLive)
                        const LiveIndicator(size: 6, label: 'LIVE'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Team 1
                  _buildTeamRow(match.team1, isWinner: _isTeamWinner(1)),

                  // Score divider
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    height: 1,
                    color: Colors.white.withValues(alpha:0.1),
                  ),

                  // Team 2
                  _buildTeamRow(match.team2, isWinner: _isTeamWinner(2)),

                  // Date/time footer
                  if (match.dateTime != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _formatDateTime(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamRow(BracketSlot slot, {bool isWinner = false}) {
    final hasTeam = slot.teamCode != null;

    return Row(
      children: [
        TeamFlag(
          teamCode: slot.teamCode,
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            slot.teamCode ?? slot.placeholder,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
              color: hasTeam ? Colors.white : Colors.white38,
              fontStyle: hasTeam ? null : FontStyle.italic,
            ),
          ),
        ),
        if (match.isCompleted || match.isLive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isWinner
                  ? AppTheme.secondaryEmerald.withValues(alpha:0.2)
                  : Colors.white.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${slot.score ?? 0}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isWinner ? AppTheme.secondaryEmerald : Colors.white60,
              ),
            ),
          ),
      ],
    );
  }

  bool _isTeamWinner(int teamNumber) {
    if (!match.isCompleted) return false;

    final team1Score = match.team1.score ?? 0;
    final team2Score = match.team2.score ?? 0;

    if (team1Score == team2Score) {
      // Check penalties
      final team1Pen = match.team1PenaltyScore ?? 0;
      final team2Pen = match.team2PenaltyScore ?? 0;
      if (teamNumber == 1) return team1Pen > team2Pen;
      return team2Pen > team1Pen;
    }

    if (teamNumber == 1) return team1Score > team2Score;
    return team2Score > team1Score;
  }

  String _getStageLabel() {
    switch (match.stage) {
      case MatchStage.roundOf32:
        return 'Round of 32';
      case MatchStage.roundOf16:
        return 'Round of 16';
      case MatchStage.quarterFinal:
        return 'Quarter-Final';
      case MatchStage.semiFinal:
        return 'Semi-Final';
      case MatchStage.thirdPlace:
        return '3rd Place';
      case MatchStage.final_:
        return 'FINAL';
      default:
        return '';
    }
  }

  String _formatDateTime() {
    if (match.dateTime == null) return 'TBD';

    if (match.isCompleted) return 'Final';
    if (match.isLive) return 'Live';

    return DateFormat('MMM d, h:mm a').format(match.dateTime!);
  }
}

/// Connector line for bracket visualization
class BracketConnector extends StatelessWidget {
  final bool isLeft;
  final double height;

  const BracketConnector({
    super.key,
    required this.isLeft,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(30, height),
      painter: _BracketConnectorPainter(isLeft: isLeft),
    );
  }
}

class _BracketConnectorPainter extends CustomPainter {
  final bool isLeft;

  _BracketConnectorPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha:0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (isLeft) {
      // Right connector (team on left, connecting to right)
      path.moveTo(0, size.height / 4);
      path.lineTo(size.width / 2, size.height / 4);
      path.lineTo(size.width / 2, size.height * 3 / 4);
      path.lineTo(0, size.height * 3 / 4);

      path.moveTo(size.width / 2, size.height / 2);
      path.lineTo(size.width, size.height / 2);
    } else {
      // Left connector (team on right, connecting to left)
      path.moveTo(size.width, size.height / 4);
      path.lineTo(size.width / 2, size.height / 4);
      path.lineTo(size.width / 2, size.height * 3 / 4);
      path.lineTo(size.width, size.height * 3 / 4);

      path.moveTo(size.width / 2, size.height / 2);
      path.lineTo(0, size.height / 2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Winner trophy display
class WinnerDisplay extends StatelessWidget {
  final String? teamCode;
  final String? teamName;
  final String? flagUrl;

  const WinnerDisplay({
    super.key,
    this.teamCode,
    this.teamName,
    this.flagUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (teamCode == null) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha:0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.emoji_events, size: 48, color: Colors.white.withValues(alpha:0.3)),
              const SizedBox(height: 8),
              const Text(
                'World Cup Champion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white38,
                ),
              ),
              const Text(
                'TBD',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha:0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha:0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.emoji_events, size: 48, color: AppTheme.accentGold),
            const SizedBox(height: 8),
            const Text(
              '2026 World Cup Champion',
              style: TextStyle(fontSize: 14, color: AppTheme.accentGold),
            ),
            const SizedBox(height: 8),
            TeamFlag(
              flagUrl: flagUrl,
              teamCode: teamCode,
              size: 64,
            ),
            const SizedBox(height: 8),
            Text(
              teamName ?? teamCode ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
