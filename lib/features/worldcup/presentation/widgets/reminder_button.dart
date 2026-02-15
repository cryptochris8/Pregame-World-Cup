import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/match_reminder.dart';
import '../../domain/entities/world_cup_match.dart';
import '../../data/services/match_reminder_service.dart';

/// A button widget to toggle match reminders
class ReminderButton extends StatefulWidget {
  final WorldCupMatch match;
  final bool showLabel;
  final double iconSize;
  final Color? activeColor;
  final Color? inactiveColor;

  const ReminderButton({
    super.key,
    required this.match,
    this.showLabel = false,
    this.iconSize = 24.0,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<ReminderButton> createState() => _ReminderButtonState();
}

class _ReminderButtonState extends State<ReminderButton> {
  final _reminderService = GetIt.I<MatchReminderService>();
  bool _hasReminder = false;
  ReminderTiming _currentTiming = ReminderTiming.thirtyMinutes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkReminderStatus();
  }

  Future<void> _checkReminderStatus() async {
    // Check cache first for instant UI
    final cachedStatus = _reminderService.hasReminderCached(widget.match.matchId);
    final cachedTiming = _reminderService.getReminderTimingCached(widget.match.matchId);

    if (mounted) {
      setState(() {
        _hasReminder = cachedStatus;
        if (cachedTiming != null) {
          _currentTiming = cachedTiming;
        }
      });
    }

    // Then verify with Firestore
    final hasReminder = await _reminderService.hasReminder(widget.match.matchId);
    if (mounted && hasReminder != _hasReminder) {
      setState(() {
        _hasReminder = hasReminder;
      });
    }
  }

  Future<void> _toggleReminder() async {
    if (_isLoading) return;

    // Don't allow reminders for past matches
    if (widget.match.dateTimeUtc == null ||
        widget.match.dateTimeUtc!.isBefore(DateTime.now().toUtc())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot set reminder for past matches'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _reminderService.toggleReminder(
        match: widget.match,
        timing: _currentTiming,
      );

      if (mounted) {
        setState(() {
          _hasReminder = result != null;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result != null
                  ? 'Reminder set for ${_currentTiming.displayName} before kickoff'
                  : 'Reminder removed',
            ),
            duration: const Duration(seconds: 2),
            action: result == null
                ? null
                : SnackBarAction(
                    label: 'Change',
                    onPressed: () => _showTimingSelector(),
                  ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update reminder'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showTimingSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Remind me before',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...ReminderTiming.values.map((timing) => ListTile(
                  leading: Icon(
                    _currentTiming == timing
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: _currentTiming == timing
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(timing.displayName),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    setState(() {
                      _currentTiming = timing;
                    });
                    // Update reminder with new timing
                    if (_hasReminder) {
                      await _reminderService.setReminder(
                        match: widget.match,
                        timing: timing,
                      );
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Reminder updated to ${timing.displayName} before'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? Colors.amber;
    final inactiveColor = widget.inactiveColor ?? Colors.grey;

    // Don't show for past matches
    if (widget.match.dateTimeUtc != null &&
        widget.match.dateTimeUtc!.isBefore(DateTime.now().toUtc())) {
      return const SizedBox.shrink();
    }

    if (widget.showLabel) {
      return TextButton.icon(
        onPressed: _isLoading ? null : _toggleReminder,
        onLongPress: _hasReminder ? _showTimingSelector : null,
        icon: _isLoading
            ? SizedBox(
                width: widget.iconSize,
                height: widget.iconSize,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                _hasReminder ? Icons.alarm_on : Icons.alarm_add,
                color: _hasReminder ? activeColor : inactiveColor,
                size: widget.iconSize,
              ),
        label: Text(
          _hasReminder ? 'Reminder Set' : 'Set Reminder',
          style: TextStyle(
            color: _hasReminder ? activeColor : inactiveColor,
          ),
        ),
      );
    }

    return IconButton(
      onPressed: _isLoading ? null : _toggleReminder,
      onLongPress: _hasReminder ? _showTimingSelector : null,
      tooltip: _hasReminder
          ? 'Reminder set (${_currentTiming.displayName} before)'
          : 'Set reminder',
      icon: _isLoading
          ? SizedBox(
              width: widget.iconSize,
              height: widget.iconSize,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              _hasReminder ? Icons.alarm_on : Icons.alarm_add,
              color: _hasReminder ? activeColor : inactiveColor,
              size: widget.iconSize,
            ),
    );
  }
}

/// A compact reminder indicator for match cards
class ReminderIndicator extends StatelessWidget {
  final String matchId;

  const ReminderIndicator({
    super.key,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    final reminderService = GetIt.I<MatchReminderService>();
    final hasReminder = reminderService.hasReminderCached(matchId);

    if (!hasReminder) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.alarm, size: 12, color: Colors.amber),
          SizedBox(width: 2),
          Text(
            'Reminder',
            style: TextStyle(
              fontSize: 10,
              color: Colors.amber,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
