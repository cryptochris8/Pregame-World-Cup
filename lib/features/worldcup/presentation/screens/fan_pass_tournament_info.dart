import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';

/// Info card about the one-time purchase nature of the fan pass
class FanPassTournamentInfo extends StatelessWidget {
  const FanPassTournamentInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.backgroundElevated),
      ),
      child: const Column(
        children: [
          Icon(Icons.info_outline, color: AppTheme.textTertiary),
          SizedBox(height: 8),
          Text(
            'One-Time Purchase',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your pass is valid for the entire FIFA World Cup 2026 tournament. No recurring charges or subscriptions.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Button to restore previous purchases
class RestorePurchasesButton extends StatelessWidget {
  final bool isPurchasing;
  final VoidCallback onRestore;

  const RestorePurchasesButton({
    super.key,
    required this.isPurchasing,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: isPurchasing ? null : onRestore,
        icon: isPurchasing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.textTertiary,
                ),
              )
            : const Icon(Icons.restore, size: 18),
        label: const Text('Restore Purchases'),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.textTertiary,
        ),
      ),
    );
  }
}
