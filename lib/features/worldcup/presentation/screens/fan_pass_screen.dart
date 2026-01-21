import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
            backgroundColor: const Color(0xFF059669),
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
            backgroundColor: Colors.red,
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
              backgroundColor: const Color(0xFF059669),
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
            backgroundColor: Colors.red,
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
      appBar: AppBar(
        title: const Text('World Cup 2026 Pass'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
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
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
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
        ),
      ],
    );
  }

  Widget _buildCurrentPassBanner() {
    final passType = _currentStatus!.passType;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF059669).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF059669)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF059669), size: 28),
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
                        color: Color(0xFF059669),
                      ),
                    ),
                    if (_currentStatus?.purchasedAt != null)
                      Text(
                        'Purchased ${_formatDate(_currentStatus!.purchasedAt!)}',
                        style: TextStyle(
                          color: Colors.grey[600],
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  'View Transaction History',
                  style: TextStyle(
                    color: Colors.grey[600],
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended
              ? const Color(0xFF3B82F6)
              : isCurrentTier
                  ? const Color(0xFF059669)
                  : Colors.grey[300]!,
          width: isRecommended || isCurrentTier ? 2 : 1,
        ),
        boxShadow: isRecommended
            ? [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: const Text(
                'BEST VALUE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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
                      ),
                    ),
                    Text(
                      pricing?.displayPrice ?? type.price,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: type == FanPassType.free
                            ? Colors.grey[600]
                            : const Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
                if (type != FanPassType.free)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'One-time payment',
                      style: TextStyle(
                        color: Colors.grey[500],
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
                            ? const Color(0xFF059669)
                            : Colors.grey[400],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature.name,
                          style: TextStyle(
                            color: feature.included
                                ? Colors.black87
                                : Colors.grey[500],
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
                      color: const Color(0xFF059669).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Current Plan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (canUpgrade && type != FanPassType.free)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isPurchasing ? null : () => _purchasePass(type),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRecommended
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                              style: const TextStyle(fontWeight: FontWeight.bold),
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: Colors.grey),
          const SizedBox(height: 8),
          const Text(
            'One-Time Purchase',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your pass is valid for the entire FIFA World Cup 2026 tournament. No recurring charges or subscriptions.',
            style: TextStyle(
              color: Colors.grey[600],
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
                  color: Colors.grey,
                ),
              )
            : const Icon(Icons.restore, size: 18),
        label: const Text('Restore Purchases'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[600],
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
