import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../schedule/domain/entities/game_schedule.dart';
import '../../../../config/theme_helper.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/utils/team_logo_helper.dart';

/// Card displaying game details including teams, time, venue, week, and TV channel.
class GameInfoCard extends StatelessWidget {
  final GameSchedule game;

  const GameInfoCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Format game time using the existing structure
    String gameTime = 'Time TBD';
    if (game.dateTimeUTC != null) {
      gameTime = DateFormat('EEE, MMM d, yyyy h:mm a').format(game.dateTimeUTC!.toLocal());
    } else if (game.dateTime != null) {
      gameTime = DateFormat('EEE, MMM d, yyyy h:mm a').format(game.dateTime!);
    } else if (game.day != null) {
      gameTime = DateFormat('EEE, MMM d, yyyy').format(game.day!);
    }

    // Get venue info from stadium
    String venueInfo = game.stadium?.name ?? 'Venue TBD';
    if (game.stadium?.city != null && game.stadium?.state != null) {
      venueInfo += ', ${game.stadium!.city}, ${game.stadium!.state}';
    }

    return Container(
      decoration: AppTheme.cardGradientDecoration,
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Game Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeHelper.favoriteColor,
                ),
              ),
              const SizedBox(height: 16),

              // Teams Row with Logos
              Row(
                children: [
                  // Away Team with Logo
                  Expanded(
                    child: Row(
                      children: [
                        TeamLogoHelper.getTeamLogoWidget(
                          teamName: game.awayTeamName,
                          size: 28,
                          fallbackColor: Colors.white70,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            game.awayTeamName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // @ indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.sports_soccer,
                      color: ThemeHelper.favoriteColor,
                      size: 24
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 12),
                        TeamLogoHelper.getTeamLogoWidget(
                          teamName: game.homeTeamName,
                          size: 28,
                          fallbackColor: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: Colors.white30),
              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.access_time, color: ThemeHelper.favoriteColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      gameTime,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, color: ThemeHelper.favoriteColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      venueInfo,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (game.week != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: ThemeHelper.favoriteColor, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Week ${game.week}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              if (game.channel != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.tv, color: ThemeHelper.favoriteColor, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'TV: ${game.channel}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
