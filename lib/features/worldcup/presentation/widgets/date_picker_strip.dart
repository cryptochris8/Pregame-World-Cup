import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_theme.dart';

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
    if (widget.selectedDate != null &&
        widget.selectedDate != oldWidget.selectedDate) {
      _navigateToDateWeek(widget.selectedDate!);
    }
  }

  void _initializeWeek() {
    if (widget.selectedDate != null) {
      _navigateToDateWeek(widget.selectedDate!);
    } else {
      _currentWeekStart = _tournamentStart;
    }
  }

  void _navigateToDateWeek(DateTime date) {
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
      return '$startMonth ${start.day} - ${end.day}';
    } else {
      return '$startMonth ${start.day} - $endMonth ${end.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getCurrentWeekDates();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
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
                _NavButton(
                  icon: Icons.chevron_left,
                  onTap: _canGoBack() ? _goToPreviousWeek : null,
                  enabled: _canGoBack(),
                ),
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
                _NavButton(
                  icon: Icons.chevron_right,
                  onTap: _canGoForward() ? _goToNextWeek : null,
                  enabled: _canGoForward(),
                ),
                const SizedBox(width: 8),
                if (widget.selectedDate != null)
                  GestureDetector(
                    onTap: () => widget.onDateChanged(null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
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
              ? AppTheme.primaryOrange.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
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
    final dayOfWeek = DateFormat('E').format(date).substring(0, 3);
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
                    AppTheme.primaryOrange.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
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
            Text(
              dayOfWeek,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dayNumber,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (matchCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
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
              const SizedBox(height: 22),
            ],
          ],
        ),
      ),
    );
  }
}
