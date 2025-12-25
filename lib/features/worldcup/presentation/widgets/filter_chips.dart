import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';

/// Filter chips for match list filtering
class MatchFilterChips extends StatelessWidget {
  final MatchListFilter selectedFilter;
  final ValueChanged<MatchListFilter> onFilterChanged;
  final int? liveCount;
  final int? upcomingCount;
  final int? completedCount;
  final int? favoritesCount;

  const MatchFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.liveCount,
    this.upcomingCount,
    this.completedCount,
    this.favoritesCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip(
            label: 'All',
            filter: MatchListFilter.all,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Favorites',
            filter: MatchListFilter.favorites,
            icon: Icons.favorite,
            badge: favoritesCount,
            badgeColor: Colors.pink,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Today',
            filter: MatchListFilter.today,
            icon: Icons.today,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Live',
            filter: MatchListFilter.live,
            icon: Icons.play_circle_outline,
            badge: liveCount,
            badgeColor: Colors.red,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Upcoming',
            filter: MatchListFilter.upcoming,
            icon: Icons.schedule,
            badge: upcomingCount,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Completed',
            filter: MatchListFilter.completed,
            icon: Icons.check_circle_outline,
            badge: completedCount,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Groups',
            filter: MatchListFilter.groupStage,
            icon: Icons.grid_view,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Knockout',
            filter: MatchListFilter.knockout,
            icon: Icons.account_tree,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required MatchListFilter filter,
    IconData? icon,
    int? badge,
    Color? badgeColor,
  }) {
    final isSelected = selectedFilter == filter;

    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onFilterChanged(filter),
      avatar: icon != null
          ? Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.white70,
            )
          : null,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
            ),
          ),
          if (badge != null && badge > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: badgeColor ?? AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: AppTheme.backgroundCard,
      selectedColor: AppTheme.secondaryEmerald.withOpacity(0.3),
      checkmarkColor: AppTheme.secondaryEmerald,
      side: BorderSide(
        color: isSelected
            ? AppTheme.secondaryEmerald
            : Colors.white.withOpacity(0.2),
      ),
    );
  }
}

/// Stage filter chips
class StageFilterChips extends StatelessWidget {
  final MatchStage? selectedStage;
  final ValueChanged<MatchStage?> onStageChanged;

  const StageFilterChips({
    super.key,
    this.selectedStage,
    required this.onStageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: Text(
              'All Stages',
              style: TextStyle(
                color: selectedStage == null ? Colors.white : Colors.white70,
              ),
            ),
            selected: selectedStage == null,
            onSelected: (_) => onStageChanged(null),
            backgroundColor: AppTheme.backgroundCard,
            selectedColor: AppTheme.secondaryEmerald.withOpacity(0.3),
            side: BorderSide(
              color: selectedStage == null
                  ? AppTheme.secondaryEmerald
                  : Colors.white.withOpacity(0.2),
            ),
          ),
          const SizedBox(width: 8),
          ...MatchStage.values.map((stage) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                _getStageName(stage),
                style: TextStyle(
                  color: selectedStage == stage ? Colors.white : Colors.white70,
                ),
              ),
              selected: selectedStage == stage,
              onSelected: (_) => onStageChanged(stage),
              backgroundColor: AppTheme.backgroundCard,
              selectedColor: _getStageColor(stage).withOpacity(0.3),
              side: BorderSide(
                color: selectedStage == stage
                    ? _getStageColor(stage)
                    : Colors.white.withOpacity(0.2),
              ),
            ),
          )),
        ],
      ),
    );
  }

  String _getStageName(MatchStage stage) {
    switch (stage) {
      case MatchStage.groupStage:
        return 'Group Stage';
      case MatchStage.roundOf32:
        return 'Round of 32';
      case MatchStage.roundOf16:
        return 'Round of 16';
      case MatchStage.quarterFinal:
        return 'Quarter-Finals';
      case MatchStage.semiFinal:
        return 'Semi-Finals';
      case MatchStage.thirdPlace:
        return '3rd Place';
      case MatchStage.final_:
        return 'Final';
    }
  }

  Color _getStageColor(MatchStage stage) {
    switch (stage) {
      case MatchStage.groupStage:
        return AppTheme.primaryBlue;
      case MatchStage.roundOf32:
        return AppTheme.secondaryEmerald;
      case MatchStage.roundOf16:
        return const Color(0xFF22C55E);
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

/// Group filter chips (A-L)
class GroupFilterChips extends StatelessWidget {
  final String? selectedGroup;
  final ValueChanged<String?> onGroupChanged;

  const GroupFilterChips({
    super.key,
    this.selectedGroup,
    required this.onGroupChanged,
  });

  @override
  Widget build(BuildContext context) {
    final groups = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: Text(
              'All Groups',
              style: TextStyle(
                color: selectedGroup == null ? Colors.white : Colors.white70,
              ),
            ),
            selected: selectedGroup == null,
            onSelected: (_) => onGroupChanged(null),
            backgroundColor: AppTheme.backgroundCard,
            selectedColor: AppTheme.secondaryEmerald.withOpacity(0.3),
            side: BorderSide(
              color: selectedGroup == null
                  ? AppTheme.secondaryEmerald
                  : Colors.white.withOpacity(0.2),
            ),
          ),
          const SizedBox(width: 8),
          ...groups.map((group) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                'Group $group',
                style: TextStyle(
                  color: selectedGroup == group ? Colors.white : Colors.white70,
                ),
              ),
              selected: selectedGroup == group,
              onSelected: (_) => onGroupChanged(group),
              backgroundColor: AppTheme.backgroundCard,
              selectedColor: AppTheme.primaryBlue.withOpacity(0.3),
              side: BorderSide(
                color: selectedGroup == group
                    ? AppTheme.primaryBlue
                    : Colors.white.withOpacity(0.2),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

/// Confederation filter chips
class ConfederationFilterChips extends StatelessWidget {
  final Confederation? selectedConfederation;
  final ValueChanged<Confederation?> onConfederationChanged;
  final Map<Confederation, int>? counts;

  const ConfederationFilterChips({
    super.key,
    this.selectedConfederation,
    required this.onConfederationChanged,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: Text(
              'All',
              style: TextStyle(
                color: selectedConfederation == null ? Colors.white : Colors.white70,
              ),
            ),
            selected: selectedConfederation == null,
            onSelected: (_) => onConfederationChanged(null),
            backgroundColor: AppTheme.backgroundCard,
            selectedColor: AppTheme.secondaryEmerald.withOpacity(0.3),
            side: BorderSide(
              color: selectedConfederation == null
                  ? AppTheme.secondaryEmerald
                  : Colors.white.withOpacity(0.2),
            ),
          ),
          const SizedBox(width: 8),
          ...Confederation.values.map((conf) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    conf.name,
                    style: TextStyle(
                      color: selectedConfederation == conf ? Colors.white : Colors.white70,
                    ),
                  ),
                  if (counts != null && counts![conf] != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(${counts![conf]})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ],
              ),
              selected: selectedConfederation == conf,
              onSelected: (_) => onConfederationChanged(conf),
              backgroundColor: AppTheme.backgroundCard,
              selectedColor: AppTheme.primaryOrange.withOpacity(0.3),
              side: BorderSide(
                color: selectedConfederation == conf
                    ? AppTheme.primaryOrange
                    : Colors.white.withOpacity(0.2),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

/// Team sort options
class TeamSortChips extends StatelessWidget {
  final TeamsSortOption selectedOption;
  final ValueChanged<TeamsSortOption> onOptionChanged;

  const TeamSortChips({
    super.key,
    required this.selectedOption,
    required this.onOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: TeamsSortOption.values.map((option) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(
              _getOptionLabel(option),
              style: TextStyle(
                color: selectedOption == option ? Colors.white : Colors.white70,
              ),
            ),
            selected: selectedOption == option,
            onSelected: (_) => onOptionChanged(option),
            backgroundColor: AppTheme.backgroundCard,
            selectedColor: AppTheme.primaryPurple.withOpacity(0.3),
            side: BorderSide(
              color: selectedOption == option
                  ? AppTheme.primaryPurple
                  : Colors.white.withOpacity(0.2),
            ),
          ),
        )).toList(),
      ),
    );
  }

  String _getOptionLabel(TeamsSortOption option) {
    switch (option) {
      case TeamsSortOption.alphabetical:
        return 'A-Z';
      case TeamsSortOption.fifaRanking:
        return 'FIFA Ranking';
      case TeamsSortOption.confederation:
        return 'Confederation';
      case TeamsSortOption.group:
        return 'Group';
    }
  }
}
