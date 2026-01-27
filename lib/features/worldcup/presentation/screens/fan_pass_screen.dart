import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../config/app_theme.dart';
import '../../domain/services/world_cup_payment_service.dart';
import 'transaction_history_screen.dart';

/// Fan Pass purchase screen
/// Displays tier comparison and handles checkout
class FanPassScreen extends StatefulWidget {
  const FanPassScreen({super.key});

  @override
  State<FanPassScreen> createState() => _FanPassScreenState();
}

class _FanPassScreenState extends State<FanPassScreen> {
  final WorldCupPaymentService _paymentService = WorldCupPaymentService();

  FanPassStatus? _currentStatus;
  WorldCupPricing? _pricing;
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final status = await _paymentService.getCachedFanPassStatus(forceRefresh: true);
      final pricing = await _paymentService.getPricing();

      setState(() {
        _currentStatus = status;
        _pricing = pricing;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchasePass(FanPassType passType) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to purchase')),
      );
      return;
    }

    setState(() => _isPurchasing = true);

    try {
      // Use native in-app purchase via RevenueCat
      final result = await _paymentService.purchaseFanPass(
        passType: passType,
        context: context,
      );

      if (!mounted) return;

      if (result.success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${passType.displayName} purchased successfully!'),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 3),
          ),
        );
        // Refresh the data to show new status
        await _loadData();
      } else if (result.userCancelled) {
        // User cancelled - no message needed
      } else if (result.usedFallback) {
        // Fallback to browser checkout was used
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complete your purchase in the browser. Return here when done.'),
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Purchase failed. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to restore purchases')),
      );
      return;
    }

    setState(() => _isPurchasing = true);

    try {
      final result = await _paymentService.restorePurchases(context: context);

      if (!mounted) return;

      if (result.success) {
        if (result.hasRestoredPurchases) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.restoredPassType.displayName} restored successfully!'),
              backgroundColor: AppTheme.successColor,
              duration: const Duration(seconds: 3),
            ),
          );
          // Refresh the data to show restored status
          await _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No previous purchases found'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Failed to restore purchases'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('World Cup 2026 Pass'),
        backgroundColor: AppTheme.backgroundDark,
        foregroundColor: AppTheme.textWhite,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const TransactionHistoryScreen(),
              ),
            ),
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Transaction History',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : RefreshIndicator(
              color: AppTheme.primaryOrange,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Current status banner
                    if (_currentStatus?.hasPass == true)
                      _buildCurrentPassBanner(),

                    // Tier comparison cards
                    _buildTierCard(
                      type: FanPassType.free,
                      isCurrentTier: _currentStatus?.passType == FanPassType.free,
                      pricing: null,
                    ),
                    const SizedBox(height: 16),

                    _buildTierCard(
                      type: FanPassType.fanPass,
                      isCurrentTier: _currentStatus?.passType == FanPassType.fanPass,
                      pricing: _pricing?.fanPass,
                    ),
                    const SizedBox(height: 16),

                    _buildTierCard(
                      type: FanPassType.superfanPass,
                      isCurrentTier: _currentStatus?.passType == FanPassType.superfanPass,
                      pricing: _pricing?.superfanPass,
                      isRecommended: true,
                    ),

                    const SizedBox(height: 32),

                    // Tournament info
                    _buildTournamentInfo(),

                    const SizedBox(height: 24),

                    // Restore Purchases button
                    _buildRestorePurchasesButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.mainGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.sports_soccer,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          const Text(
            'FIFA World Cup 2026',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'June 11 - July 19, 2026',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock premium features for the entire tournament',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPassBanner() {
    final passType = _currentStatus!.passType;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.successColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.successColor, size: 28),
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
                    if (_currentStatus?.purchasedAt != null)
                      Text(
                        'Purchased ${_formatDate(_currentStatus!.purchasedAt!)}',
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
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const TransactionHistoryScreen(),
              ),
            ),
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

  Widget _buildTierCard({
    required FanPassType type,
    required bool isCurrentTier,
    PriceInfo? pricing,
    bool isRecommended = false,
  }) {
    final features = _getFeaturesForTier(type);
    final canUpgrade = _canUpgradeTo(type);

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
                  color: AppTheme.primaryOrange.withOpacity(0.3),
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
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
                        feature.included ? Icons.check_circle : Icons.cancel,
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
                      color: AppTheme.successColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
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
                              colors: [AppTheme.primaryOrange, AppTheme.accentGold],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : const LinearGradient(
                              colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isRecommended ? AppTheme.primaryOrange : AppTheme.primaryPurple)
                              .withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isPurchasing ? null : () => _purchasePass(type),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isPurchasing
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

  Widget _buildTournamentInfo() {
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

  Widget _buildRestorePurchasesButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _isPurchasing ? null : _restorePurchases,
        icon: _isPurchasing
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

  List<_Feature> _getFeaturesForTier(FanPassType type) {
    switch (type) {
      case FanPassType.free:
        return [
          _Feature('Match schedules & results', true),
          _Feature('Venue discovery', true),
          _Feature('Basic notifications', true),
          _Feature('Follow teams', true),
          _Feature('Ad-free experience', false),
          _Feature('Advanced stats', false),
          _Feature('Custom alerts', false),
        ];
      case FanPassType.fanPass:
        return [
          _Feature('Everything in Free', true),
          _Feature('Ad-free experience', true),
          _Feature('Advanced match stats', true),
          _Feature('Custom match alerts', true),
          _Feature('Advanced social features', true),
          _Feature('Exclusive content', false),
          _Feature('AI match insights', false),
        ];
      case FanPassType.superfanPass:
        return [
          _Feature('Everything in Fan Pass', true),
          _Feature('Exclusive content', true),
          _Feature('AI match insights', true),
          _Feature('Priority features', true),
          _Feature('Downloadable content', true),
          _Feature('Early access to new features', true),
        ];
    }
  }

  bool _canUpgradeTo(FanPassType targetTier) {
    final currentTier = _currentStatus?.passType ?? FanPassType.free;

    switch (currentTier) {
      case FanPassType.free:
        return true; // Can upgrade to any paid tier
      case FanPassType.fanPass:
        return targetTier == FanPassType.superfanPass; // Can only upgrade to superfan
      case FanPassType.superfanPass:
        return false; // Already at max tier
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _Feature {
  final String name;
  final bool included;

  _Feature(this.name, this.included);
}
