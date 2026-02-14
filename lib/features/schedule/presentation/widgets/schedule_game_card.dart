import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/game_schedule.dart';
import '../../../recommendations/presentation/screens/game_details_screen.dart';
import 'enhanced_ai_insights_widget.dart';
import 'game_prediction_widget.dart';
import '../../../../config/theme_helper.dart';
import '../../../../core/utils/team_matching_helper.dart';
import '../../../../core/utils/team_logo_helper.dart';

/// A card widget displaying a game in the schedule.
/// Shows team logos, names, scores/time, venue info,
/// AI insights, and prediction widget.
class ScheduleGameCard extends StatelessWidget {
  final GameSchedule game;
  final List<String> favoriteTeams;
  final VoidCallback? onRefresh;

  const ScheduleGameCard({
    super.key,
    required this.game,
    required this.favoriteTeams,
    this.onRefresh,
  });

  bool get _isFavoriteGame =>
      TeamMatchingHelper.isTeamInFavorites(game.homeTeamName, favoriteTeams) ||
      TeamMatchingHelper.isTeamInFavorites(game.awayTeamName, favoriteTeams);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: _isFavoriteGame
            ? BorderSide(color: ThemeHelper.favoriteColor, width: 2)
            : BorderSide.none,
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
              // Score or time info with Venues button
              _buildScoreOrTimeRow(context),
              // Venue information
              if (game.stadium?.name != null) ...[
                const SizedBox(height: 6),
                _buildVenueInfo(),
              ],
              // Live game info
              if (game.isLive == true && game.period != null) ...[
                const SizedBox(height: 8),
                _buildLiveGameInfo(),
              ],
              // Enhanced AI Game Intelligence
              const SizedBox(height: 8),
              EnhancedAIInsightsWidget(
                game: game,
                isCompact: true,
              ),
              // Game Prediction Widget (only for upcoming games)
              if (game.dateTimeUTC != null &&
                  game.dateTimeUTC!.isAfter(DateTime.now()) &&
                  game.status != 'Final') ...[
                const SizedBox(height: 8),
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
                size: 32,
                fallbackColor: Colors.white70,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  game.awayTeamName,
                  style: const TextStyle(
                    fontSize: 16,
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
        // VS indicator with favorite icon
        Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ThemeHelper.favoriteColor.withOpacity(0.2),
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
            if (_isFavoriteGame) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.favorite,
                color: ThemeHelper.favoriteColor,
                size: 16,
              ),
            ],
          ],
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isFavoriteGame
                        ? ThemeHelper.favoriteColor
                        : Colors.white,
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
                fallbackColor: _isFavoriteGame
                    ? ThemeHelper.favoriteColor
                    : Colors.white70,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreOrTimeRow(BuildContext context) {
    return Row(
      children: [
        // Score display for completed/live games
        if (game.status == 'Final' || game.isLive == true) ...[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${game.awayScore ?? 0}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${game.homeScore ?? 0}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Time display for future games
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
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],

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
                  color: ThemeHelper.favoriteColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_city,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Venues',
                  style: TextStyle(
                    fontSize: 15,
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

  Widget _buildVenueInfo() {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: ThemeHelper.favoriteColor,
          size: 18,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            game.stadium!.name!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveGameInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            game.period!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (game.timeRemaining != null) ...[
            const SizedBox(width: 8),
            Text(
              game.timeRemaining!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
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
