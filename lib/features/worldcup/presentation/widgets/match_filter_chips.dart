import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';
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
      selectedColor: AppTheme.secondaryEmerald.withValues(alpha: 0.3),
      checkmarkColor: AppTheme.secondaryEmerald,
      side: BorderSide(
        color: isSelected
            ? AppTheme.secondaryEmerald
            : Colors.white.withValues(alpha: 0.2),
      ),
    );
  }
}
