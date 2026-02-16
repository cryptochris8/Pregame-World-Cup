import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';
import '../../domain/services/world_cup_payment_service.dart';

/// Feature item used in tier cards
class TierFeature {
  final String name;
  final bool included;

  const TierFeature(this.name, this.included);
}

/// Card displaying a single fan pass tier with its features and purchase button
class FanPassTierCard extends StatelessWidget {
  final FanPassType type;
  final bool isCurrentTier;
  final PriceInfo? pricing;
  final bool isRecommended;
  final bool isPurchasing;
  final bool canUpgrade;
  final List<TierFeature> features;
  final VoidCallback? onPurchase;

  const FanPassTierCard({
    super.key,
    required this.type,
    required this.isCurrentTier,
    this.pricing,
    this.isRecommended = false,
    required this.isPurchasing,
    required this.canUpgrade,
    required this.features,
    this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended
              ? AppTheme.primaryOrange
              : isCurrentTier
                  ? AppTheme.successColor
                  : AppTheme.backgroundElevated,
          width: isRecommended || isCurrentTier ? 2 : 1,
        ),
        boxShadow: isRecommended
            ? [
                BoxShadow(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryOrange, AppTheme.accentGold],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: const Text(
                'BEST VALUE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      type.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    Text(
                      pricing?.displayPrice ?? type.price,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: type == FanPassType.free
                            ? AppTheme.textTertiary
                            : AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
                if (type != FanPassType.free)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      'One-time payment',
                      style: TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Features list
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            feature.included
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 18,
                            color: feature.included
                                ? AppTheme.successColor
                                : AppTheme.textTertiary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              feature.name,
                              style: TextStyle(
                                color: feature.included
                                    ? AppTheme.textLight
                                    : AppTheme.textTertiary,
                                decoration: feature.included
                                    ? null
                                    : TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 16),

                // Action button
                if (isCurrentTier)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              AppTheme.successColor.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'Current Plan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (canUpgrade && type != FanPassType.free)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: isRecommended
                          ? const LinearGradient(
                              colors: [
                                AppTheme.primaryOrange,
                                AppTheme.accentGold
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : const LinearGradient(
                              colors: [
                                AppTheme.primaryPurple,
                                AppTheme.primaryBlue
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isRecommended
                                  ? AppTheme.primaryOrange
                                  : AppTheme.primaryPurple)
                              .withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isPurchasing ? null : onPurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isPurchasing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Get ${type.displayName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
