import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import 'team_flag.dart';

/// Table displaying group standings
class StandingsTable extends StatelessWidget {
  final WorldCupGroup group;
  final VoidCallback? Function(String teamCode)? onTeamTap;
  final bool compact;

  const StandingsTable({
    super.key,
    required this.group,
    this.onTeamTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 16,
        vertical: compact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Group ${group.groupLetter}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (group.isComplete)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryEmerald.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Complete',
                        style: TextStyle(
                          color: AppTheme.secondaryEmerald,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Column headers
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.backgroundElevated,
              child: Row(
                children: [
                  const SizedBox(width: 24), // Position
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Team',
                      style: _headerStyle,
                    ),
                  ),
                  SizedBox(width: 32, child: Center(child: Text('P', style: _headerStyle))),
                  SizedBox(width: 32, child: Center(child: Text('W', style: _headerStyle))),
                  SizedBox(width: 32, child: Center(child: Text('D', style: _headerStyle))),
                  SizedBox(width: 32, child: Center(child: Text('L', style: _headerStyle))),
                  if (!compact) ...[
                    SizedBox(width: 40, child: Center(child: Text('GF', style: _headerStyle))),
                    SizedBox(width: 40, child: Center(child: Text('GA', style: _headerStyle))),
                  ],
                  SizedBox(width: 40, child: Center(child: Text('GD', style: _headerStyle))),
                  SizedBox(width: 40, child: Center(child: Text('Pts', style: _headerStyle))),
                ],
              ),
            ),

            // Team rows
            ...group.standings.map((standing) => _buildTeamRow(context, standing)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRow(BuildContext context, GroupTeamStanding standing) {
    final isQualified = standing.position <= 2;
    final isBestThird = standing.position == 3;

    return InkWell(
      onTap: onTeamTap?.call(standing.teamCode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isQualified
              ? AppTheme.secondaryEmerald.withOpacity(0.1)
              : isBestThird
                  ? AppTheme.primaryOrange.withOpacity(0.1)
                  : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        child: Row(
          children: [
            // Position
            SizedBox(
              width: 24,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getPositionColor(standing.position),
                  boxShadow: [
                    BoxShadow(
                      color: _getPositionColor(standing.position).withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${standing.position}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Team
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  TeamFlag(teamCode: standing.teamCode, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      standing.teamCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Stats
            SizedBox(
              width: 32,
              child: Center(
                child: Text('${standing.played}', style: _statStyle),
              ),
            ),
            SizedBox(
              width: 32,
              child: Center(
                child: Text('${standing.won}', style: _statStyle),
              ),
            ),
            SizedBox(
              width: 32,
              child: Center(
                child: Text('${standing.drawn}', style: _statStyle),
              ),
            ),
            SizedBox(
              width: 32,
              child: Center(
                child: Text('${standing.lost}', style: _statStyle),
              ),
            ),
            if (!compact) ...[
              SizedBox(
                width: 40,
                child: Center(
                  child: Text('${standing.goalsFor}', style: _statStyle),
                ),
              ),
              SizedBox(
                width: 40,
                child: Center(
                  child: Text('${standing.goalsAgainst}', style: _statStyle),
                ),
              ),
            ],
            SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  '${standing.goalDifference >= 0 ? '+' : ''}${standing.goalDifference}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: standing.goalDifference > 0
                        ? AppTheme.secondaryEmerald
                        : standing.goalDifference < 0
                            ? AppTheme.secondaryRose
                            : Colors.white60,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 40,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${standing.points}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return AppTheme.secondaryEmerald;
      case 2:
        return const Color(0xFF22C55E); // Lighter green
      case 3:
        return AppTheme.primaryOrange;
      case 4:
        return AppTheme.textTertiary;
      default:
        return AppTheme.textTertiary;
    }
  }

  TextStyle get _headerStyle => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.white60,
      );

  TextStyle get _statStyle => const TextStyle(
        fontSize: 13,
        color: Colors.white70,
      );
}

/// Compact group card showing just group letter and leaders
class GroupCard extends StatelessWidget {
  final WorldCupGroup group;
  final VoidCallback? onTap;

  const GroupCard({
    super.key,
    required this.group,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final leader = group.standings.isNotEmpty ? group.standings.first : null;
    final second = group.standings.length > 1 ? group.standings[1] : null;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Group ${group.groupLetter}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Colors.white38),
                  ],
                ),
                const SizedBox(height: 12),
                if (leader != null) _buildTeamRow(leader, 1),
                if (second != null) ...[
                  const SizedBox(height: 8),
                  _buildTeamRow(second, 2),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamRow(GroupTeamStanding standing, int position) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: position == 1 ? AppTheme.secondaryEmerald : const Color(0xFF22C55E),
            boxShadow: [
              BoxShadow(
                color: (position == 1 ? AppTheme.secondaryEmerald : const Color(0xFF22C55E)).withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$position',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        TeamFlag(teamCode: standing.teamCode, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            standing.teamCode,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${standing.points} pts',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
