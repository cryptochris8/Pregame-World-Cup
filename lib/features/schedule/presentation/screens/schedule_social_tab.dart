import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../config/theme_helper.dart';
import '../bloc/schedule_bloc.dart';
import '../widgets/schedule_social_game_card.dart';

/// Tab displaying upcoming games with social engagement features
class ScheduleSocialTab extends StatelessWidget {
  final VoidCallback onRefresh;

  const ScheduleSocialTab({
    super.key,
    required this.onRefresh,
  });

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
        } else if (state is ScheduleLoaded) {
          // Show upcoming games with social features
          final upcomingGames = state.schedule.where((game) =>
            game.dateTimeUTC != null &&
            game.dateTimeUTC!.isAfter(DateTime.now()) &&
            game.status != 'Final'
          ).toList();

          if (upcomingGames.isEmpty) {
            return _buildNoUpcomingGamesWidget(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: upcomingGames.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ScheduleSocialGameCard(
                  game: upcomingGames[index],
                  onRefresh: onRefresh,
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNoUpcomingGamesWidget(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups,
            size: 64,
            color: ThemeHelper.favoriteColor,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noUpcomingGames,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.socialFeaturesAvailable,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
