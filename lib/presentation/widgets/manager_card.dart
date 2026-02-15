import 'package:flutter/material.dart';
import '../../domain/models/manager.dart';
import 'manager_photo.dart';

/// Manager Card Widget - displays a compact manager summary in a list.
/// Shows photo, name, team, nationality, and key stats.
class ManagerCard extends StatelessWidget {
  final Manager manager;
  final VoidCallback onTap;

  const ManagerCard({
    super.key,
    required this.manager,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Manager photo from Firebase Storage
              ManagerPhoto(
                photoUrl: manager.photoUrl,
                managerName: manager.fullName,
                size: 80,
                circular: true,
              ),

              const SizedBox(width: 16),

              // Manager info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manager.commonName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      manager.currentTeam,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${manager.nationality} • ${manager.age} years',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _MiniChip(
                          label: '${manager.yearsOfExperience}y exp',
                          icon: Icons.work_outline,
                        ),
                        _MiniChip(
                          label: manager.stats.formattedWinPercentage,
                          icon: Icons.trending_up,
                        ),
                        _MiniChip(
                          label: '${manager.stats.titlesWon} titles',
                          icon: Icons.emoji_events,
                        ),
                        if (manager.isControversial)
                          const _MiniChip(
                            label: 'Controversial',
                            icon: Icons.warning_amber,
                            color: Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const _MiniChip({
    required this.label,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? Colors.blue),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color ?? Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }
}
