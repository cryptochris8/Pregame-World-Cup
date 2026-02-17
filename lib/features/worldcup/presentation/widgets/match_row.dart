import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../../utils/timezone_utils.dart';
import 'live_indicator.dart';
import 'team_flag.dart';
import 'favorite_button.dart';

/// Compact match row for lists, displaying teams, score, and basic match info
/// in a single horizontal row.
class MatchRow extends StatelessWidget {
  final WorldCupMatch match;
  final VoidCallback? onTap;

  /// Whether this match is favorited
  final bool isFavorite;

  /// Callback when favorite button is toggled
  final VoidCallback? onFavoriteToggle;

  /// Whether to show the favorite button
  final bool showFavoriteButton;

  /// Current prediction for this match
  final MatchPrediction? prediction;

  /// Callback when prediction is made or updated
  final void Function(int homeScore, int awayScore)? onPrediction;

  /// Whether to show the prediction button
  final bool showPredictionButton;

  const MatchRow({
    super.key,
    required this.match,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.showFavoriteButton = true,
    this.prediction,
    this.onPrediction,
    this.showPredictionButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: match.isLive
            ? const LiveIndicator(size: 10)
            : Text(
                match.matchNumber.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
        title: Row(
          children: [
            TeamFlag(teamCode: match.homeTeamCode, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                match.homeTeamCode ?? 'TBD',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              match.status == MatchStatus.scheduled
                  ? 'vs'
                  : '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: match.isLive ? Colors.red : Colors.white,
              ),
            ),
            Expanded(
              child: Text(
                match.awayTeamCode ?? 'TBD',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 8),
            TeamFlag(teamCode: match.awayTeamCode, size: 24),
          ],
        ),
        subtitle: Text(
          _formatMatchRowDateTime(match),
          style: const TextStyle(fontSize: 12, color: Colors.white60),
        ),
        trailing: showFavoriteButton
            ? FavoriteButton(
                isFavorite: isFavorite,
                onPressed: onFavoriteToggle,
                size: 20,
              )
            : null,
      ),
    );
  }

  /// Format date/time for MatchRow with timezone support
  String _formatMatchRowDateTime(WorldCupMatch match) {
    final utcTime = match.dateTimeUtc;
    final venueTime = match.dateTime;

    if (utcTime == null && venueTime == null) return 'TBD';

    final venueTimezone = match.venue?.timeZone ?? 'America/New_York';

    if (utcTime != null) {
      return TimezoneUtils.formatMatchDateTime(
        utcDateTime: utcTime,
        venueTimezone: venueTimezone,
        mode: TimezoneDisplayMode.local,
      );
    }

    return DateFormat('MMM d, h:mm a').format(venueTime!);
  }
}
