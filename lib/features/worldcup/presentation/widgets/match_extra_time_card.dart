import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';

/// Displays extra time and penalty shootout information for knockout matches.
class MatchExtraTimeCard extends StatelessWidget {
  final WorldCupMatch match;

  const MatchExtraTimeCard({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryOrange.withValues(alpha:0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.timer, color: AppTheme.primaryOrange),
                SizedBox(width: 8),
                Text(
                  'Extra Time & Penalties',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (match.hasExtraTime)
              const Text(
                'Match went to extra time (AET)',
                style: TextStyle(color: AppTheme.primaryOrange),
              ),
            if (match.hasPenalties) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    match.homeTeamCode ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withValues(alpha:0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${match.homePenaltyScore} - ${match.awayPenaltyScore}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ),
                  Text(
                    match.awayTeamCode ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Penalty Shootout',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryOrange.withValues(alpha:0.8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
