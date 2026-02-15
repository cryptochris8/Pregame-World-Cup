import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/watch_party.dart';
import 'visibility_badge.dart';

/// Card widget displaying watch party summary for lists
class WatchPartyCard extends StatelessWidget {
  final WatchParty watchParty;
  final VoidCallback? onTap;
  final bool showVenue;
  final bool showHost;
  final bool compact;

  const WatchPartyCard({
    super.key,
    required this.watchParty,
    this.onTap,
    this.showVenue = true,
    this.showHost = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with name and visibility badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      watchParty.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  VisibilityBadge(visibility: watchParty.visibility),
                ],
              ),

              const SizedBox(height: 8),

              // Game info
              Row(
                children: [
                  Icon(
                    Icons.sports_soccer,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      watchParty.gameName,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Date & Time
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${dateFormat.format(watchParty.gameDateTime)} at ${timeFormat.format(watchParty.gameDateTime)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              if (showVenue) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        watchParty.venueName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Footer with attendee info and status
              Row(
                children: [
                  // Attendees count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(watchParty.status).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: _getStatusColor(watchParty.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          watchParty.attendeesText,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(watchParty.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Status badge
                  _buildStatusBadge(context),

                  const Spacer(),

                  // Time until start
                  if (watchParty.isUpcoming)
                    Text(
                      watchParty.timeUntilStart,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),

              // Virtual attendance indicator
              if (watchParty.allowVirtualAttendance) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.videocam,
                      size: 14,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Virtual: ${watchParty.virtualFeeText}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF059669),
                      ),
                    ),
                    if (watchParty.virtualAttendeesCount > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${watchParty.virtualAttendeesCount} virtual)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final status = watchParty.status;
    final color = _getStatusColor(status);
    final label = _getStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(WatchPartyStatus status) {
    switch (status) {
      case WatchPartyStatus.upcoming:
        return const Color(0xFF1E3A8A); // blue
      case WatchPartyStatus.live:
        return const Color(0xFFDC2626); // red
      case WatchPartyStatus.ended:
        return Colors.grey;
      case WatchPartyStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusLabel(WatchPartyStatus status) {
    switch (status) {
      case WatchPartyStatus.upcoming:
        return 'Upcoming';
      case WatchPartyStatus.live:
        return 'LIVE';
      case WatchPartyStatus.ended:
        return 'Ended';
      case WatchPartyStatus.cancelled:
        return 'Cancelled';
    }
  }
}
