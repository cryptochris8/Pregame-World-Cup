import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/calendar_event.dart';
import '../../domain/services/calendar_service.dart';

/// Button widget to add a single event to calendar
class AddToCalendarButton extends StatelessWidget {
  final CalendarEvent event;
  final bool showLabel;
  final bool compact;

  const AddToCalendarButton({
    super.key,
    required this.event,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () => _showOptions(context),
        tooltip: 'Add to Calendar',
      );
    }

    if (showLabel) {
      return OutlinedButton.icon(
        onPressed: () => _showOptions(context),
        icon: const Icon(Icons.calendar_today, size: 18),
        label: const Text('Add to Calendar'),
      );
    }

    return IconButton.outlined(
      onPressed: () => _showOptions(context),
      icon: const Icon(Icons.calendar_today),
      tooltip: 'Add to Calendar',
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CalendarOptionsSheet(event: event),
    );
  }
}

/// Bottom sheet with calendar export options
class CalendarOptionsSheet extends StatefulWidget {
  final CalendarEvent event;

  const CalendarOptionsSheet({
    super.key,
    required this.event,
  });

  @override
  State<CalendarOptionsSheet> createState() => _CalendarOptionsSheetState();
}

class _CalendarOptionsSheetState extends State<CalendarOptionsSheet> {
  final CalendarService _calendarService = CalendarService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Add to Calendar',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Event preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatDateTime(widget.event.startTime),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Options
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else ...[
              _buildOption(
                context,
                icon: Icons.calendar_month,
                iconColor: Colors.blue,
                title: 'Google Calendar',
                onTap: () => _addToGoogle(context),
              ),
              _buildOption(
                context,
                icon: Icons.apple,
                iconColor: Colors.grey.shade800,
                title: 'Apple Calendar',
                onTap: () => _downloadICS(context),
              ),
              _buildOption(
                context,
                icon: Icons.share,
                iconColor: Colors.green,
                title: 'Share .ics File',
                onTap: () => _shareICS(context),
              ),
              _buildOption(
                context,
                icon: Icons.link,
                iconColor: Colors.orange,
                title: 'Copy Google Calendar Link',
                onTap: () => _copyGoogleLink(context),
              ),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title),
      onTap: onTap,
    );
  }

  Future<void> _addToGoogle(BuildContext context) async {
    setState(() => _isLoading = true);

    final result = await _calendarService.addToGoogleCalendar(widget.event);

    setState(() => _isLoading = false);

    if (context.mounted) {
      Navigator.pop(context);
      _showResult(context, result);
    }
  }

  Future<void> _downloadICS(BuildContext context) async {
    setState(() => _isLoading = true);

    final result = await _calendarService.shareICalFile(
      [widget.event],
      filename: 'match_${widget.event.id}.ics',
    );

    setState(() => _isLoading = false);

    if (context.mounted) {
      Navigator.pop(context);
      _showResult(context, result);
    }
  }

  Future<void> _shareICS(BuildContext context) async {
    setState(() => _isLoading = true);

    final result = await _calendarService.shareICalFile(
      [widget.event],
      filename: 'match_${widget.event.id}.ics',
    );

    setState(() => _isLoading = false);

    if (context.mounted) {
      Navigator.pop(context);
      _showResult(context, result);
    }
  }

  void _copyGoogleLink(BuildContext context) {
    final url = _calendarService.generateGoogleCalendarUrl(widget.event);
    Clipboard.setData(ClipboardData(text: url));

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Calendar link copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showResult(BuildContext context, CalendarResult result) {
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to calendar'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to add to calendar'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$weekday, $month $day at $hour:$minute';
  }
}

/// Inline calendar button for match cards
class MatchCalendarButton extends StatelessWidget {
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final DateTime matchTime;
  final String? venueName;
  final String? venueCity;
  final String? stage;

  const MatchCalendarButton({
    super.key,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchTime,
    this.venueName,
    this.venueCity,
    this.stage,
  });

  @override
  Widget build(BuildContext context) {
    final event = CalendarEvent.fromMatch(
      matchId: matchId,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      matchTime: matchTime,
      venueName: venueName,
      venueCity: venueCity,
      stage: stage,
    );

    return AddToCalendarButton(
      event: event,
      compact: true,
    );
  }
}
