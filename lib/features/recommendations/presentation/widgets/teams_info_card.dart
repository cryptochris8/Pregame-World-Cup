import 'package:flutter/material.dart';
import '../../../../config/theme_helper.dart';

/// Card displaying away and home team information side by side.
class TeamsInfoCard extends StatelessWidget {
  final String awayTeamName;
  final String homeTeamName;

  const TeamsInfoCard({
    super.key,
    required this.awayTeamName,
    required this.homeTeamName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ThemeHelper.cardDecoration(context, elevated: true),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teams',
              style: ThemeHelper.h3(context, color: ThemeHelper.favoriteColor),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.sports_soccer,
                        size: 48,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        awayTeamName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Away',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 2,
                  height: 80,
                  color: Colors.white30,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.home,
                        size: 48,
                        color: Colors.orange[300],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        homeTeamName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Home',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
