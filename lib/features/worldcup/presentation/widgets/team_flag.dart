import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

/// Displays a team's flag with optional country code
class TeamFlag extends StatelessWidget {
  final String? flagUrl;
  final String? teamCode;
  final double size;
  final bool showCode;
  final bool circular;

  const TeamFlag({
    super.key,
    this.flagUrl,
    this.teamCode,
    this.size = 32,
    this.showCode = false,
    this.circular = false,
  });

  /// Create from NationalTeam
  factory TeamFlag.fromTeam(
    NationalTeam team, {
    double size = 32,
    bool showCode = false,
    bool circular = false,
  }) {
    return TeamFlag(
      flagUrl: team.flagUrl,
      teamCode: team.fifaCode,
      size: size,
      showCode: showCode,
      circular: circular,
    );
  }

  @override
  Widget build(BuildContext context) {
    final flagWidget = Container(
      width: size,
      height: circular ? size : size * 0.67, // 3:2 aspect ratio for flags
      decoration: BoxDecoration(
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(4),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildFlagImage(),
    );

    if (!showCode || teamCode == null) {
      return flagWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        flagWidget,
        const SizedBox(height: 4),
        Text(
          teamCode!,
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildFlagImage() {
    if (flagUrl != null && flagUrl!.isNotEmpty) {
      return Image.network(
        flagUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: teamCode != null
            ? Text(
                teamCode!.substring(0, teamCode!.length.clamp(0, 2)),
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              )
            : Icon(
                Icons.flag,
                size: size * 0.5,
                color: Colors.grey.shade400,
              ),
      ),
    );
  }
}

/// Row displaying two teams facing each other
class TeamVsRow extends StatelessWidget {
  final String? homeTeamCode;
  final String? homeTeamName;
  final String? homeFlagUrl;
  final int? homeScore;
  final String? awayTeamCode;
  final String? awayTeamName;
  final String? awayFlagUrl;
  final int? awayScore;
  final bool isLive;
  final bool showScores;
  final double flagSize;

  const TeamVsRow({
    super.key,
    this.homeTeamCode,
    this.homeTeamName,
    this.homeFlagUrl,
    this.homeScore,
    this.awayTeamCode,
    this.awayTeamName,
    this.awayFlagUrl,
    this.awayScore,
    this.isLive = false,
    this.showScores = true,
    this.flagSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Home team
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  homeTeamName ?? homeTeamCode ?? 'TBD',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TeamFlag(
                flagUrl: homeFlagUrl,
                teamCode: homeTeamCode,
                size: flagSize,
              ),
            ],
          ),
        ),

        // Score or VS
        SizedBox(
          width: 80,
          child: showScores && (homeScore != null || awayScore != null)
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${homeScore ?? '-'} - ${awayScore ?? '-'}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isLive ? Colors.red : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : const Text(
                  'vs',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),

        // Away team
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TeamFlag(
                flagUrl: awayFlagUrl,
                teamCode: awayTeamCode,
                size: flagSize,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  awayTeamName ?? awayTeamCode ?? 'TBD',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
