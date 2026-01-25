import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/calendar_event.dart';
import '../../domain/services/calendar_service.dart';

/// Screen for exporting matches to calendar
class CalendarExportScreen extends StatefulWidget {
  final List<CalendarEvent> events;
  final String? title;
  final String? subtitle;

  const CalendarExportScreen({
    super.key,
    required this.events,
    this.title,
    this.subtitle,
  });

  @override
  State<CalendarExportScreen> createState() => _CalendarExportScreenState();
}

class _CalendarExportScreenState extends State<CalendarExportScreen> {
  final CalendarService _calendarService = CalendarService();
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Export to Calendar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          if (widget.subtitle != null) ...[
            Text(
              widget.subtitle!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Event count
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.events.length} ${widget.events.length == 1 ? 'Event' : 'Events'}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ready to export',
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
          const SizedBox(height: 24),

          // Export options
          Text(
            'Export Options',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Google Calendar
          _buildExportOption(
            theme,
            icon: Icons.calendar_month,
            iconColor: Colors.blue,
            title: 'Google Calendar',
            subtitle: 'Open in Google Calendar',
            onTap: () => _exportToGoogle(context),
          ),

          // Apple Calendar / Download iCal
          _buildExportOption(
            theme,
            icon: Icons.apple,
            iconColor: Colors.grey.shade800,
            title: 'Apple Calendar',
            subtitle: 'Download .ics file',
            onTap: () => _downloadICalFile(context),
          ),

          // Share iCal file
          _buildExportOption(
            theme,
            icon: Icons.share,
            iconColor: Colors.green,
            title: 'Share Calendar File',
            subtitle: 'Share .ics file to any app',
            onTap: () => _shareICalFile(context),
          ),

          const SizedBox(height: 24),

          // Calendar subscription
          Text(
            'Calendar Subscription',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Subscribe to get automatic updates when matches are added or times change.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          // Copy feed URL
          _buildExportOption(
            theme,
            icon: Icons.link,
            iconColor: Colors.orange,
            title: 'Copy Calendar Feed URL',
            subtitle: 'For calendar subscription',
            onTap: () => _copyFeedUrl(context),
          ),

          const SizedBox(height: 24),

          // Event preview
          Text(
            'Events Preview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...widget.events.take(5).map((event) => _buildEventPreview(theme, event)),

          if (widget.events.length > 5) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '+ ${widget.events.length - 5} more events',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportOption(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: _isExporting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right),
        onTap: _isExporting ? null : onTap,
      ),
    );
  }

  Widget _buildEventPreview(ThemeData theme, CalendarEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _getMonthAbbr(event.startTime.month),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    '${event.startTime.day}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatTime(event.startTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  if (event.location != null)
                    Text(
                      event.location!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToGoogle(BuildContext context) async {
    if (widget.events.isEmpty) return;

    setState(() => _isExporting = true);

    // For single event, open Google Calendar directly
    if (widget.events.length == 1) {
      final result = await _calendarService.addToGoogleCalendar(widget.events.first);
      _showResult(context, result, 'Google Calendar');
    } else {
      // For multiple events, share iCal file
      await _shareICalFile(context);
    }

    setState(() => _isExporting = false);
  }

  Future<void> _downloadICalFile(BuildContext context) async {
    setState(() => _isExporting = true);

    final result = await _calendarService.shareICalFile(
      widget.events,
      filename: 'world_cup_matches.ics',
      calendarName: widget.title ?? 'World Cup 2026',
    );

    _showResult(context, result, 'Calendar');
    setState(() => _isExporting = false);
  }

  Future<void> _shareICalFile(BuildContext context) async {
    setState(() => _isExporting = true);

    final result = await _calendarService.shareICalFile(
      widget.events,
      filename: 'world_cup_matches.ics',
      calendarName: widget.title ?? 'World Cup 2026',
    );

    _showResult(context, result, 'Share');
    setState(() => _isExporting = false);
  }

  void _copyFeedUrl(BuildContext context) {
    final feedUrl = _calendarService.generateICalFeedUrl();
    Clipboard.setData(ClipboardData(text: feedUrl));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calendar feed URL copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showResult(BuildContext context, CalendarResult result, String destination) {
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported to $destination'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Export failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getMonthAbbr(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
