import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme_helper.dart';
import '../../../../core/utils/team_logo_helper.dart';
import '../../domain/entities/game_schedule.dart';

/// A card widget that displays a single upcoming game in the schedule.
///
/// Shows team logos and names, game time, venue, TV channel,
/// and a favorite-team indicator when applicable.
class UpcomingGameCard extends StatelessWidget {
  final GameSchedule game;
  final bool isFavoriteGame;
  final VoidCallback onTap;

  const UpcomingGameCard({
    super.key,
    required this.game,
    required this.isFavoriteGame,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark blue-gray card background
        borderRadius: BorderRadius.circular(16),
        border: isFavoriteGame
            ? Border.all(color: ThemeHelper.favoriteColor, width: 2)
            : null,
        gradient: isFavoriteGame
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ThemeHelper.favoriteColor.withValues(alpha:0.1),
                  const Color(0xFF1E293B),
                ],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teams Row with Logos
              _buildTeamsRow(),

              const SizedBox(height: 16),

              // Game Info Row
              _buildGameTimeRow(),

              if (game.stadium?.name != null) ...[
                const SizedBox(height: 8),
                _buildVenueRow(),
              ],

              if (game.channel != null) ...[
                const SizedBox(height: 8),
                _buildChannelRow(),
              ],

              if (game.week != null) ...[
                const SizedBox(height: 8),
                _buildWeekRow(),
              ],

              // Favorite team indicator
              if (isFavoriteGame) ...[
                const SizedBox(height: 12),
                _buildFavoriteIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamsRow() {
    return Row(
      children: [
        // Away Team with Logo
        Expanded(
          child: Row(
            children: [
              TeamLogoHelper.getTeamLogoWidget(
                teamName: game.awayTeamName,
                size: 32,
                fallbackColor: Colors.white70,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  game.awayTeamName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // VS indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ThemeHelper.favoriteColor.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ThemeHelper.favoriteColor),
          ),
          child: Text(
            '@',
            style: TextStyle(
              color: ThemeHelper.favoriteColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        // Home Team with Logo
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  game.homeTeamName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isFavoriteGame ? ThemeHelper.favoriteColor : Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 12),
              TeamLogoHelper.getTeamLogoWidget(
                teamName: game.homeTeamName,
                size: 32,
                fallbackColor: isFavoriteGame ? ThemeHelper.favoriteColor : Colors.white70,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameTimeRow() {
    return Row(
      children: [
        Icon(Icons.access_time, color: ThemeHelper.favoriteColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _formatGameTime(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVenueRow() {
    return Row(
      children: [
        Icon(Icons.location_on, color: ThemeHelper.favoriteColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            game.stadium!.name!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildChannelRow() {
    return Row(
      children: [
        Icon(Icons.tv, color: ThemeHelper.favoriteColor, size: 20),
        const SizedBox(width: 8),
        Text(
          'TV: ${game.channel}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekRow() {
    return Row(
      children: [
        Icon(Icons.calendar_today, color: ThemeHelper.favoriteColor, size: 20),
        const SizedBox(width: 8),
        Text(
          'Week ${game.week}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeHelper.favoriteColor.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeHelper.favoriteColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: ThemeHelper.favoriteColor, size: 16),
          const SizedBox(width: 4),
          Text(
            'Favorite Team',
            style: TextStyle(
              color: ThemeHelper.favoriteColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatGameTime() {
    String gameTime = 'Time TBD';
    if (game.dateTimeUTC != null) {
      gameTime = DateFormat('EEE, MMM d, h:mm a').format(game.dateTimeUTC!.toLocal());
    } else if (game.dateTime != null) {
      gameTime = DateFormat('EEE, MMM d, h:mm a').format(game.dateTime!);
    } else if (game.day != null) {
      gameTime = DateFormat('EEee, MMM d').format(game.day!);
    }
    return gameTime;
  }
}
