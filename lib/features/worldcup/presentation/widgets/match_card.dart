import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../../utils/timezone_utils.dart';
import '../bloc/bloc.dart';
import 'live_indicator.dart';
import 'team_flag.dart';
import 'favorite_button.dart';
import 'prediction_dialog.dart';
import 'reminder_button.dart';

/// Card displaying a World Cup match
class MatchCard extends StatelessWidget {
  final WorldCupMatch match;
  final VoidCallback? onTap;
  final bool compact;

  /// Whether this match is favorited
  final bool isFavorite;

  /// Callback when favorite button is toggled
  final VoidCallback? onFavoriteToggle;

  /// Whether to show the favorite button
  final bool showFavoriteButton;

  /// Whether to show the reminder button
  final bool showReminderButton;

  /// Current prediction for this match
  final MatchPrediction? prediction;

  /// Callback when prediction is made or updated
  final void Function(int homeScore, int awayScore)? onPrediction;

  /// Whether to show the prediction button
  final bool showPredictionButton;

  /// AI prediction for this match (optional)
  final AIMatchPrediction? aiPrediction;

  /// Whether to show AI insights
  final bool showAIInsight;

  /// Home team details (for AI context)
  final NationalTeam? homeTeam;

  /// Away team details (for AI context)
  final NationalTeam? awayTeam;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.compact = false,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.showFavoriteButton = true,
    this.showReminderButton = true,
    this.prediction,
    this.onPrediction,
    this.showPredictionButton = true,
    this.aiPrediction,
    this.showAIInsight = true,
    this.homeTeam,
    this.awayTeam,
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
        border: match.isLive
            ? Border.all(color: Colors.red, width: 2)
            : Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: match.isLive ? 12 : 8,
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
            padding: EdgeInsets.all(compact ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header row
                _buildHeader(context),
                SizedBox(height: compact ? 8 : 12),

                // Teams and score
                TeamVsRow(
                  homeTeamCode: match.homeTeamCode,
                  homeTeamName: match.homeTeamName,
                  homeFlagUrl: match.homeFlagUrl,
                  homeScore: match.homeScore,
                  awayTeamCode: match.awayTeamCode,
                  awayTeamName: match.awayTeamName,
                  awayFlagUrl: match.awayFlagUrl,
                  awayScore: match.awayScore,
                  isLive: match.isLive,
                  showScores: match.status != MatchStatus.scheduled,
                  flagSize: compact ? 32 : 40,
                ),

                // Extra time / penalties info
                if (match.hasExtraTime || match.hasPenalties) ...[
                  const SizedBox(height: 8),
                  _buildExtraTimeInfo(),
                ],

                // Footer
                if (!compact) ...[
                  const SizedBox(height: 12),
                  _buildFooter(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Stage badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStageColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getStageColor().withOpacity(0.5)),
          ),
          child: Text(
            match.stageDisplayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _getStageColor(),
            ),
          ),
        ),

        // Group letter (for group stage)
        if (match.group != null) ...[
          const SizedBox(width: 8),
          Text(
            'Group ${match.group}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],

        const Spacer(),

        // Live indicator or match number
        if (match.isLive)
          const LiveBadge()
        else
          Text(
            'Match ${match.matchNumber}',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white38,
            ),
          ),

        // Reminder button (only for scheduled matches)
        if (showReminderButton && match.status == MatchStatus.scheduled) ...[
          const SizedBox(width: 4),
          ReminderButton(
            match: match,
            iconSize: compact ? 18 : 20,
            activeColor: Colors.amber,
            inactiveColor: Colors.white38,
          ),
        ],

        // Favorite button
        if (showFavoriteButton) ...[
          const SizedBox(width: 4),
          FavoriteButton(
            isFavorite: isFavorite,
            onPressed: onFavoriteToggle,
            size: compact ? 18 : 20,
          ),
        ],
      ],
    );
  }

  Widget _buildExtraTimeInfo() {
    final parts = <String>[];

    if (match.hasExtraTime) {
      parts.add('AET');
    }
    if (match.hasPenalties) {
      parts.add('${match.homePenaltyScore}-${match.awayPenaltyScore} pen');
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.5)),
        ),
        child: Text(
          parts.join(' | '),
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.primaryOrange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Date/time
            const Icon(
              Icons.schedule,
              size: 14,
              color: Colors.white38,
            ),
            const SizedBox(width: 4),
            Text(
              _formatDateTime(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),

            const Spacer(),

            // Venue
            if (match.venueName != null) ...[
              const Icon(
                Icons.stadium,
                size: 14,
                color: Colors.white38,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  match.venueName!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),

        // AI Insight and Prediction buttons row
        if (showAIInsight || showPredictionButton) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              // AI Insight chip
              if (showAIInsight && match.status == MatchStatus.scheduled) ...[
                _AIInsightChip(
                  match: match,
                  aiPrediction: aiPrediction,
                  homeTeam: homeTeam,
                  awayTeam: awayTeam,
                ),
                const Spacer(),
              ],

              // Prediction button
              if (showPredictionButton)
                Flexible(
                  child: QuickPredictionButton(
                    match: match,
                    prediction: prediction,
                    onPrediction: onPrediction,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatDateTime() {
    if (match.status == MatchStatus.inProgress) {
      return match.minute != null ? "${match.minute}'" : 'In Progress';
    }

    if (match.status == MatchStatus.halfTime) {
      return 'Half Time';
    }

    if (match.status == MatchStatus.completed) {
      return 'Final';
    }

    // Use UTC time if available, otherwise fall back to venue local time
    final utcTime = match.dateTimeUtc;
    final venueTime = match.dateTime;

    if (utcTime == null && venueTime == null) return 'TBD';

    // Get venue timezone (default to America/New_York for US venues)
    final venueTimezone = match.venue?.timeZone ?? 'America/New_York';

    // If we have UTC time, convert to user's local timezone
    if (utcTime != null) {
      return TimezoneUtils.formatRelativeDate(
        utcDateTime: utcTime,
        venueTimezone: venueTimezone,
        mode: TimezoneDisplayMode.local,
      );
    }

    // Fallback: use venue local time as-is (less accurate but functional)
    final matchDate = venueTime!;
    final now = DateTime.now();

    // Check if today
    if (matchDate.year == now.year &&
        matchDate.month == now.month &&
        matchDate.day == now.day) {
      return 'Today ${DateFormat.jm().format(matchDate)}';
    }

    // Check if tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    if (matchDate.year == tomorrow.year &&
        matchDate.month == tomorrow.month &&
        matchDate.day == tomorrow.day) {
      return 'Tomorrow ${DateFormat.jm().format(matchDate)}';
    }

    return DateFormat('MMM d, h:mm a').format(matchDate);
  }

  Color _getStageColor() {
    switch (match.stage) {
      case MatchStage.groupStage:
        return AppTheme.primaryBlue;
      case MatchStage.roundOf32:
        return AppTheme.secondaryEmerald;
      case MatchStage.roundOf16:
        return const Color(0xFF22C55E); // Bright green
      case MatchStage.quarterFinal:
        return AppTheme.primaryOrange;
      case MatchStage.semiFinal:
        return AppTheme.primaryPurple;
      case MatchStage.thirdPlace:
        return AppTheme.accentGold;
      case MatchStage.final_:
        return AppTheme.accentGold;
    }
  }
}

/// Compact match row for lists
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
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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

    // Get venue timezone (default to America/New_York for US venues)
    final venueTimezone = match.venue?.timeZone ?? 'America/New_York';

    // If we have UTC time, convert to user's local timezone
    if (utcTime != null) {
      return TimezoneUtils.formatMatchDateTime(
        utcDateTime: utcTime,
        venueTimezone: venueTimezone,
        mode: TimezoneDisplayMode.local,
      );
    }

    // Fallback: use venue local time as-is
    return DateFormat('MMM d, h:mm a').format(venueTime!);
  }
}

/// AI Insight chip for match cards
class _AIInsightChip extends StatelessWidget {
  final WorldCupMatch match;
  final AIMatchPrediction? aiPrediction;
  final NationalTeam? homeTeam;
  final NationalTeam? awayTeam;

  const _AIInsightChip({
    required this.match,
    this.aiPrediction,
    this.homeTeam,
    this.awayTeam,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Try to get cubit from context
    WorldCupAICubit? aiCubit;
    try {
      aiCubit = context.read<WorldCupAICubit>();
    } catch (_) {
      // Cubit not available
    }

    // If we have a pre-loaded prediction, display it
    if (aiPrediction != null) {
      return _buildPredictionChip(theme, aiPrediction!);
    }

    // If cubit is available, use BlocBuilder
    if (aiCubit != null) {
      return BlocBuilder<WorldCupAICubit, WorldCupAIState>(
        builder: (context, state) {
          final prediction = state.getPrediction(match.matchId);
          final isLoading = state.isLoadingMatch(match.matchId);

          if (isLoading) {
            return _buildLoadingChip(theme, colorScheme);
          }

          if (prediction != null && prediction.isValid) {
            return _buildPredictionChip(theme, prediction);
          }

          return _buildLoadButton(context, theme, colorScheme);
        },
      );
    }

    // No cubit available, show disabled state
    return const SizedBox.shrink();
  }

  Widget _buildLoadingChip(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'AI...',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppTheme.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionChip(ThemeData theme, AIMatchPrediction prediction) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryPurple,
            AppTheme.primaryDeepPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.psychology,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            prediction.quickInsight,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: () {
        final cubit = context.read<WorldCupAICubit>();
        cubit.loadPredictionWithTeams(match, homeTeam, awayTeam);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryPurple.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.psychology_outlined,
              size: 14,
              color: AppTheme.primaryPurple,
            ),
            const SizedBox(width: 4),
            Text(
              'AI Predict',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
