import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import 'team_flag.dart';
import 'favorite_button.dart';

/// Tile displaying a national team
class TeamTile extends StatelessWidget {
  final NationalTeam team;
  final VoidCallback? onTap;
  final bool showRanking;
  final bool showConfederation;
  final bool showGroup;

  /// Whether this team is favorited
  final bool isFavorite;

  /// Callback when favorite button is toggled
  final VoidCallback? onFavoriteToggle;

  /// Whether to show the favorite button
  final bool showFavoriteButton;

  const TeamTile({
    super.key,
    required this.team,
    this.onTap,
    this.showRanking = true,
    this.showConfederation = false,
    this.showGroup = true,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: TeamFlag(
          flagUrl: team.flagUrl,
          teamCode: team.fifaCode,
          size: 40,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                team.countryName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            if (team.isHostNation)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
                ),
                child: const Text(
                  'HOST',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            if (showRanking && team.fifaRanking != null) ...[
              const Icon(Icons.leaderboard, size: 12, color: Colors.white38),
              const SizedBox(width: 4),
              Text(
                '#${team.fifaRanking}',
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
              const SizedBox(width: 12),
            ],
            if (showConfederation) ...[
              Text(
                team.confederation.displayName,
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
              const SizedBox(width: 12),
            ],
            if (showGroup && team.group != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.5)),
                ),
                child: Text(
                  'Group ${team.group}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (team.worldCupTitles > 0) ...[
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, size: 14, color: AppTheme.accentGold),
                  const SizedBox(width: 2),
                  Text(
                    '${team.worldCupTitles}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showFavoriteButton)
              FavoriteButton(
                isFavorite: isFavorite,
                onPressed: onFavoriteToggle,
                size: 20,
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

/// Grid card for team display
class TeamCard extends StatelessWidget {
  final NationalTeam team;
  final VoidCallback? onTap;

  /// Whether this team is favorited
  final bool isFavorite;

  /// Callback when favorite button is toggled
  final VoidCallback? onFavoriteToggle;

  /// Whether to show the favorite button
  final bool showFavoriteButton;

  const TeamCard({
    super.key,
    required this.team,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TeamFlag(
                      flagUrl: team.flagUrl,
                      teamCode: team.fifaCode,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      team.shortName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (team.fifaRanking != null) ...[
                          Text(
                            '#${team.fifaRanking}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                        if (team.group != null) ...[
                          if (team.fifaRanking != null)
                            const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.5)),
                            ),
                            child: Text(
                              team.group!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (team.isHostNation) ...[
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.home,
                        size: 14,
                        color: AppTheme.accentGold,
                      ),
                    ],
                  ],
                ),
              ),
              if (showFavoriteButton)
                Positioned(
                  top: 4,
                  right: 4,
                  child: FavoriteButton(
                    isFavorite: isFavorite,
                    onPressed: onFavoriteToggle,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small team chip for filters/selections
class TeamChip extends StatelessWidget {
  final NationalTeam team;
  final bool selected;
  final VoidCallback? onTap;

  const TeamChip({
    super.key,
    required this.team,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      avatar: TeamFlag(
        flagUrl: team.flagUrl,
        teamCode: team.fifaCode,
        size: 20,
        circular: true,
      ),
      label: Text(team.fifaCode),
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected ? Colors.white : Colors.white70,
      ),
      backgroundColor: AppTheme.backgroundCard,
      selectedColor: AppTheme.secondaryEmerald.withOpacity(0.3),
      checkmarkColor: AppTheme.secondaryEmerald,
      side: BorderSide(
        color: selected
            ? AppTheme.secondaryEmerald
            : Colors.white.withOpacity(0.2),
      ),
    );
  }
}
