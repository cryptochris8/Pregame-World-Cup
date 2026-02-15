import 'package:flutter/material.dart';

/// Loading indicator shown while AI analysis is being generated.
class AIInsightsLoadingWidget extends StatelessWidget {
  const AIInsightsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            SizedBox(height: 12),
            Text(
              'Analyzing matchup data...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state shown when AI analysis fails to load.
class AIInsightsErrorWidget extends StatelessWidget {
  final String errorMessage;

  const AIInsightsErrorWidget({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red[300],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
