import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';

/// Displays match information (match number, date, kick-off, stage, group)
/// in a styled card with icon-labeled rows.
class MatchInfoCard extends StatelessWidget {
  final WorldCupMatch match;

  const MatchInfoCard({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.numbers,
              'Match Number',
              '${match.matchNumber}',
            ),
            Divider(color: Colors.white.withOpacity(0.1)),
            _buildInfoRow(
              Icons.calendar_today,
              'Date',
              match.dateTime != null
                  ? DateFormat('EEEE, MMMM d, yyyy').format(match.dateTime!)
                  : 'TBD',
            ),
            Divider(color: Colors.white.withOpacity(0.1)),
            _buildInfoRow(
              Icons.schedule,
              'Kick-off',
              match.dateTime != null
                  ? DateFormat.jm().format(match.dateTime!)
                  : 'TBD',
            ),
            Divider(color: Colors.white.withOpacity(0.1)),
            _buildInfoRow(
              Icons.emoji_events,
              'Stage',
              match.stageDisplayName,
            ),
            if (match.group != null) ...[
              Divider(color: Colors.white.withOpacity(0.1)),
              _buildInfoRow(
                Icons.grid_view,
                'Group',
                'Group ${match.group}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white60),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
