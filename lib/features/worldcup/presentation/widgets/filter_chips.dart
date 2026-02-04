import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

/// Horizontal date picker strip for World Cup tournament dates
/// Shows one week at a time with navigation arrows
/// June 11, 2026 through July 19, 2026
class DatePickerStrip extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateChanged;
  final Map<DateTime, int>? matchCounts;

  const DatePickerStrip({
    super.key,
    this.selectedDate,
    required this.onDateChanged,
    this.matchCounts,
  });

  @override
  State<DatePickerStrip> createState() => _DatePickerStripState();
}

class _DatePickerStripState extends State<DatePickerStrip> {
  // World Cup 2026 dates: June 11, 2026 - July 19, 2026
  static final DateTime _tournamentStart = DateTime(2026, 6, 11);
  static final DateTime _tournamentEnd = DateTime(2026, 7, 19);

  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _initializeWeek();
  }

  @override
  void didUpdateWidget(DatePickerStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If selected date changes and is outside current week, navigate to that week
    if (widget.selectedDate != null &&
        widget.selectedDate != oldWidget.selectedDate) {
      _navigateToDateWeek(widget.selectedDate!);
    }
  }

  void _initializeWeek() {
    if (widget.selectedDate != null) {
      _navigateToDateWeek(widget.selectedDate!);
    } else {
      // Start at tournament start
      _currentWeekStart = _tournamentStart;
    }
  }

  void _navigateToDateWeek(DateTime date) {
    // Find the week that contains this date
    DateTime weekStart = _tournamentStart;
    while (weekStart.add(const Duration(days: 7)).isBefore(date) ||
           weekStart.add(const Duration(days: 7)).isAtSameMomentAs(date)) {
      final nextWeek = weekStart.add(const Duration(days: 7));
      if (nextWeek.isAfter(_tournamentEnd)) break;
      weekStart = nextWeek;
    }
    setState(() {
      _currentWeekStart = weekStart;
    });
  }

  List<DateTime> _getCurrentWeekDates() {
    List<DateTime> dates = [];
    DateTime current = _currentWeekStart;
    for (int i = 0; i < 7; i++) {
      if (current.isAfter(_tournamentEnd)) break;
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  bool _canGoBack() {
    return _currentWeekStart.isAfter(_tournamentStart);
  }

  bool _canGoForward() {
    final nextWeekStart = _currentWeekStart.add(const Duration(days: 7));
    return !nextWeekStart.isAfter(_tournamentEnd);
  }

  void _goToPreviousWeek() {
    if (_canGoBack()) {
      setState(() {
        _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
        // Clamp to tournament start
        if (_currentWeekStart.isBefore(_tournamentStart)) {
          _currentWeekStart = _tournamentStart;
        }
      });
    }
  }

  void _goToNextWeek() {
    if (_canGoForward()) {
      setState(() {
        _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _getMatchCount(DateTime date) {
    if (widget.matchCounts == null) return 0;
    for (final entry in widget.matchCounts!.entries) {
      if (_isSameDay(entry.key, date)) {
        return entry.value;
      }
    }
    return 0;
  }

  String _getWeekRangeText() {
    final dates = _getCurrentWeekDates();
    if (dates.isEmpty) return '';
    final start = dates.first;
    final end = dates.last;
    final startMonth = DateFormat('MMM').format(start);
    final endMonth = DateFormat('MMM').format(end);

    if (startMonth == endMonth) {
      return '${startMonth} ${start.day} - ${end.day}';
    } else {
      return '${startMonth} ${start.day} - ${endMonth} ${end.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getCurrentWeekDates();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row with navigation
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Row(
              children: [
                // Previous week button
                _NavButton(
                  icon: Icons.chevron_left,
                  onTap: _canGoBack() ? _goToPreviousWeek : null,
                  enabled: _canGoBack(),
                ),

                // Week range text
                Expanded(
                  child: Center(
                    child: Text(
                      _getWeekRangeText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Next week button
                _NavButton(
                  icon: Icons.chevron_right,
                  onTap: _canGoForward() ? _goToNextWeek : null,
                  enabled: _canGoForward(),
                ),

                const SizedBox(width: 8),

                // Clear button
                if (widget.selectedDate != null)
                  GestureDetector(
                    onTap: () => widget.onDateChanged(null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Date items row
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: weekDates.map((date) {
                final isSelected = widget.selectedDate != null &&
                    _isSameDay(date, widget.selectedDate!);
                final matchCount = _getMatchCount(date);
                final isToday = _isSameDay(date, DateTime.now());

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _CompactDateItem(
                      date: date,
                      isSelected: isSelected,
                      isToday: isToday,
                      matchCount: matchCount,
                      onTap: () => widget.onDateChanged(date),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  const _NavButton({
    required this.icon,
    this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.primaryOrange.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppTheme.primaryOrange : Colors.white24,
        ),
      ),
    );
  }
}

class _CompactDateItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final int matchCount;
  final VoidCallback onTap;

  const _CompactDateItem({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.matchCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayOfWeek = DateFormat('E').format(date).substring(0, 3); // Mon, Tue
    final dayNumber = date.day.toString();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryOrange,
                    AppTheme.primaryOrange.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryOrange
                : isToday
                    ? AppTheme.secondaryEmerald
                    : Colors.transparent,
            width: isSelected || isToday ? 2 : 0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day of week
            Text(
              dayOfWeek,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            // Day number
            Text(
              dayNumber,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Match count dot
            if (matchCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.3)
                      : AppTheme.secondaryEmerald,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$matchCount',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 22), // Spacer to keep consistent height
            ],
          ],
        ),
      ),
    );
  }
}
