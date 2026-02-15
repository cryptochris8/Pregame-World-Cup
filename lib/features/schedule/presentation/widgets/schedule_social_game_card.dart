import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/game_schedule.dart';
import '../../../recommendations/presentation/screens/game_details_screen.dart';
import 'game_prediction_widget.dart';
import '../../../../config/theme_helper.dart';
import '../../../../core/utils/team_logo_helper.dart';

/// A card widget displaying a game with social features.
/// Shows team logos, names, game time, social stats
/// (predictions, comments, photos), and prediction widget.
class ScheduleSocialGameCard extends StatelessWidget {
  final GameSchedule game;
  final VoidCallback? onRefresh;

  const ScheduleSocialGameCard({
    super.key,
    required this.game,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameDetailsScreen(game: game),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teams Row with Logos
              _buildTeamsRow(),
              const SizedBox(height: 12),
              // Game time and Venues button
              _buildTimeAndVenuesRow(context),
              const SizedBox(height: 12),
              // Social stats
              _buildSocialStats(),
              // Add prediction widget for upcoming games
              if (game.dateTimeUTC != null &&
                  game.dateTimeUTC!.isAfter(DateTime.now()) &&
                  game.status != 'Final') ...[
                const SizedBox(height: 12),
                GamePredictionWidget(
                  game: game,
                  onPredictionMade: () {
                    onRefresh?.call();
                  },
                ),
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
                size: 28,
                fallbackColor: Colors.white70,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  game.awayTeamName,
                  style: const TextStyle(
                    fontSize: 14,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ThemeHelper.favoriteColor.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ThemeHelper.favoriteColor),
          ),
          child: Text(
            '@',
            style: TextStyle(
              color: ThemeHelper.favoriteColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 10),
              TeamLogoHelper.getTeamLogoWidget(
                teamName: game.homeTeamName,
                size: 28,
                fallbackColor: Colors.white70,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeAndVenuesRow(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ThemeHelper.favoriteColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _formatGameTime(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(),
        // Venues Button
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameDetailsScreen(game: game),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ThemeHelper.favoriteColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ThemeHelper.favoriteColor.withValues(alpha:0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_city,
                  size: 16,
                  color: Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  'Venues',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSocialStat(
          Icons.psychology,
          'Predictions',
          game.userPredictions ?? 0,
        ),
        _buildSocialStat(
          Icons.comment,
          'Comments',
          game.userComments ?? 0,
        ),
        _buildSocialStat(
          Icons.photo_camera,
          'Photos',
          game.userPhotos ?? 0,
        ),
      ],
    );
  }

  Widget _buildSocialStat(IconData icon, String label, int count) {
    return Column(
      children: [
        Icon(
          icon,
          color: ThemeHelper.favoriteColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatGameTime() {
    if (game.isLive == true) return 'LIVE';
    if (game.status == 'Final') return 'Final';

    if (game.dateTimeUTC != null) {
      return DateFormat('MMM d, h:mm a').format(game.dateTimeUTC!.toLocal());
    } else if (game.dateTime != null) {
      return DateFormat('MMM d, h:mm a').format(game.dateTime!);
    } else if (game.day != null) {
      return DateFormat('MMM d').format(game.day!);
    }

    return 'Time TBD';
  }
}
