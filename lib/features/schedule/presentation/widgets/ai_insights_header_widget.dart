import 'package:flutter/material.dart';

/// Header row for the Enhanced AI Insights panel.
///
/// Displays the "Enhanced AI Analysis" badge, the matchup title,
/// and a refresh button.
class AIInsightsHeaderWidget extends StatelessWidget {
  final String awayTeamName;
  final String homeTeamName;
  final bool isLoading;
  final VoidCallback onRefresh;

  const AIInsightsHeaderWidget({
    super.key,
    required this.awayTeamName,
    required this.homeTeamName,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[700]!, Colors.blue[700]!],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('\u{1F9E0}', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text(
                'Enhanced AI Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$awayTeamName @ $homeTeamName',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: isLoading ? null : onRefresh,
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                )
              : const Icon(Icons.refresh, color: Colors.orange, size: 20),
          tooltip: 'Refresh Analysis',
        ),
      ],
    );
  }
}
