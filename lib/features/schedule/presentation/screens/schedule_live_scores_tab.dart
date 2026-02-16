import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../config/theme_helper.dart';
import '../bloc/schedule_bloc.dart';
import '../../domain/entities/game_schedule.dart';
import '../widgets/live_score_card.dart';

/// Tab displaying live game scores with auto-refresh support
class ScheduleLiveScoresTab extends StatelessWidget {
  const ScheduleLiveScoresTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        if (state is ScheduleLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          );
        } else if (state is ScheduleLoaded || state is UpcomingGamesLoaded) {
          // Start with filtered schedule (respects favorite teams filter)
          List<GameSchedule> filteredGames;
          if (state is ScheduleLoaded) {
            filteredGames = state.filteredSchedule;
          } else {
            filteredGames = (state as UpcomingGamesLoaded).filteredUpcomingGames;
          }

          // Then filter for live games only
          final liveGames = filteredGames.where((game) =>
            game.isLive == true ||
            game.status?.toLowerCase().contains('progress') == true ||
            game.status?.toLowerCase().contains('quarter') == true ||
            game.status?.toLowerCase().contains('half') == true
          ).toList();

          if (liveGames.isEmpty) {
            return _buildNoLiveGamesWidget(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: liveGames.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LiveScoreCard(
                  game: liveGames[index],
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNoLiveGamesWidget(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer,
            size: 64,
            color: ThemeHelper.favoriteColor,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noLiveGamesAvailable,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.worldCupMatchesDaily,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha:0.3)),
            ),
            child: Text(
              l10n.gameDayComingSoon,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
