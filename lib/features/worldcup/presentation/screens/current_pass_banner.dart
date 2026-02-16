import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';
import '../../domain/services/world_cup_payment_service.dart';

/// Banner showing the user's current active pass status
class CurrentPassBanner extends StatelessWidget {
  final FanPassStatus currentStatus;
  final VoidCallback onViewTransactionHistory;

  const CurrentPassBanner({
    super.key,
    required this.currentStatus,
    required this.onViewTransactionHistory,
  });

  @override
  Widget build(BuildContext context) {
    final passType = currentStatus.passType;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.successColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppTheme.successColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You have ${passType.displayName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.successColor,
                      ),
                    ),
                    if (currentStatus.purchasedAt != null)
                      Text(
                        'Purchased ${_formatDate(currentStatus.purchasedAt!)}',
                        style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onViewTransactionHistory,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 16,
                  color: AppTheme.textTertiary,
                ),
                SizedBox(width: 6),
                Text(
                  'View Transaction History',
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
