import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../config/app_theme.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/services/world_cup_payment_service.dart';
import 'transaction_history_screen.dart';
import 'fan_pass_header.dart';
import 'current_pass_banner.dart';
import 'fan_pass_tier_card.dart';
import 'fan_pass_tournament_info.dart';

/// Fan Pass purchase screen
/// Displays tier comparison and handles checkout
class FanPassScreen extends StatefulWidget {
  const FanPassScreen({super.key});

  @override
  State<FanPassScreen> createState() => _FanPassScreenState();
}

class _FanPassScreenState extends State<FanPassScreen>
    with WidgetsBindingObserver {
  static const String _logTag = 'FanPassScreen';

  final WorldCupPaymentService _paymentService = WorldCupPaymentService();

  FanPassStatus? _currentStatus;
  WorldCupPricing? _pricing;
  bool _isLoading = true;
  bool _isPurchasing = false;

  /// Subscription listening for real-time fan pass status changes after
  /// the user completes a browser checkout (Stripe fallback flow).
  StreamSubscription<FanPassStatus>? _fanPassStatusSubscription;

  /// Timeout timer that cancels the listener after 5 minutes to avoid
  /// keeping an open Firestore connection indefinitely.
  Timer? _listenerTimeoutTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopListeningForPassActivation();
    super.dispose();
  }

  // ============================================================================
  // APP LIFECYCLE - Auto-refresh after returning from browser checkout
  // ============================================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed &&
        _paymentService.isBrowserCheckoutInProgress) {
      LoggingService.info(
        'App resumed after browser checkout - refreshing fan pass status',
        tag: _logTag,
      );

      // Mark checkout as complete so we don't keep refreshing
      _paymentService.markBrowserCheckoutComplete();

      // Clear cache and force-refresh the status
      _paymentService.clearCache();
      _refreshAfterCheckout();
    }
  }

  /// Refresh fan pass status after the user returns from a browser checkout.
  /// Adds a short delay to give the Stripe webhook time to process.
  Future<void> _refreshAfterCheckout() async {
    if (!mounted) return;

    // Show a brief "checking" indicator
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.checkingPurchaseStatus),
        duration: const Duration(seconds: 2),
      ),
    );

    // Small delay to give the webhook a moment to fire
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final previousStatus = _currentStatus;
    await _loadData();

    if (!mounted) return;

    // If the pass was just activated, show a success message
    if (_currentStatus?.hasPass == true && previousStatus?.hasPass != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).passActivatedSuccessfully(_currentStatus!.passType.displayName),
          ),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
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

  /// Start listening for real-time fan pass activation from Firestore.
  void _startListeningForPassActivation() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _stopListeningForPassActivation();

    LoggingService.info(
      'Starting real-time listener for fan pass activation',
      tag: _logTag,
    );

    _fanPassStatusSubscription = _paymentService
        .listenToFanPassStatus(user.uid)
        .listen((status) {
      if (!mounted) return;

      if (status.hasPass && _currentStatus?.hasPass != true) {
        LoggingService.info(
          'Fan pass activated via real-time listener: ${status.passType.displayName}',
          tag: _logTag,
        );

        _stopListeningForPassActivation();

        setState(() {
          _currentStatus = status;
          _isPurchasing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).passActivatedSuccessfully(status.passType.displayName),
            ),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 4),
          ),
        );

        _loadData();
      }
    }, onError: (error) {
      LoggingService.error(
        'Error in fan pass status listener: $error',
        tag: _logTag,
      );
    });

    _listenerTimeoutTimer = Timer(const Duration(minutes: 5), () {
      LoggingService.info(
        'Fan pass listener timed out after 5 minutes',
        tag: _logTag,
      );
      _stopListeningForPassActivation();
    });
  }

  void _stopListeningForPassActivation() {
    _fanPassStatusSubscription?.cancel();
    _fanPassStatusSubscription = null;
    _listenerTimeoutTimer?.cancel();
    _listenerTimeoutTimer = null;
  }

  Future<void> _purchasePass(FanPassType passType) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseSignInToPurchase)),
      );
      return;
    }

    setState(() => _isPurchasing = true);

    try {
      final result = await _paymentService.purchaseFanPass(
        passType: passType,
        context: context,
      );

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).passPurchasedSuccessfully(passType.displayName)),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 3),
          ),
        );
        await _loadData();
      } else if (result.userCancelled) {
        // User cancelled - no message needed
      } else if (result.usedFallback) {
        _startListeningForPassActivation();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).completePurchaseInBrowser),
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? AppLocalizations.of(context).purchaseFailedRetry),
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
        SnackBar(content: Text(AppLocalizations.of(context).pleaseSignInToRestore)),
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
              content: Text(AppLocalizations.of(context).passRestoredSuccessfully(result.restoredPassType.displayName)),
              backgroundColor: AppTheme.successColor,
              duration: const Duration(seconds: 3),
            ),
          );
          await _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).noPreviousPurchases),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? AppLocalizations.of(context).failedToRestorePurchases),
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

  void _navigateToTransactionHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TransactionHistoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).worldCup2026Pass),
        backgroundColor: AppTheme.backgroundDark,
        foregroundColor: AppTheme.textWhite,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _navigateToTransactionHistory,
            icon: const Icon(Icons.receipt_long),
            tooltip: AppLocalizations.of(context).transactionHistory,
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
                    const FanPassHeader(),
                    const SizedBox(height: 24),

                    if (_currentStatus?.hasPass == true)
                      CurrentPassBanner(
                        currentStatus: _currentStatus!,
                        onViewTransactionHistory: _navigateToTransactionHistory,
                      ),

                    FanPassTierCard(
                      type: FanPassType.free,
                      isCurrentTier: _currentStatus?.passType == FanPassType.free,
                      isPurchasing: _isPurchasing,
                      canUpgrade: _canUpgradeTo(FanPassType.free),
                      features: _getFeaturesForTier(FanPassType.free),
                    ),
                    const SizedBox(height: 16),

                    FanPassTierCard(
                      type: FanPassType.fanPass,
                      isCurrentTier: _currentStatus?.passType == FanPassType.fanPass,
                      pricing: _pricing?.fanPass,
                      isPurchasing: _isPurchasing,
                      canUpgrade: _canUpgradeTo(FanPassType.fanPass),
                      features: _getFeaturesForTier(FanPassType.fanPass),
                      onPurchase: () => _purchasePass(FanPassType.fanPass),
                    ),
                    const SizedBox(height: 16),

                    FanPassTierCard(
                      type: FanPassType.superfanPass,
                      isCurrentTier: _currentStatus?.passType == FanPassType.superfanPass,
                      pricing: _pricing?.superfanPass,
                      isRecommended: true,
                      isPurchasing: _isPurchasing,
                      canUpgrade: _canUpgradeTo(FanPassType.superfanPass),
                      features: _getFeaturesForTier(FanPassType.superfanPass),
                      onPurchase: () => _purchasePass(FanPassType.superfanPass),
                    ),

                    const SizedBox(height: 32),

                    const FanPassTournamentInfo(),

                    const SizedBox(height: 24),

                    RestorePurchasesButton(
                      isPurchasing: _isPurchasing,
                      onRestore: _restorePurchases,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<TierFeature> _getFeaturesForTier(FanPassType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case FanPassType.free:
        return [
          TierFeature(l10n.matchSchedulesResults, true),
          TierFeature(l10n.venueDiscovery, true),
          TierFeature(l10n.basicNotifications, true),
          TierFeature(l10n.followTeams, true),
          TierFeature(l10n.adFreeExperience, false),
          TierFeature(l10n.advancedStats, false),
          TierFeature(l10n.customAlerts, false),
        ];
      case FanPassType.fanPass:
        return [
          TierFeature(l10n.everythingInFree, true),
          TierFeature(l10n.adFreeExperience, true),
          TierFeature(l10n.advancedMatchStats, true),
          TierFeature(l10n.customMatchAlerts, true),
          TierFeature(l10n.advancedSocialFeatures, true),
          TierFeature(l10n.exclusiveContent, false),
          TierFeature(l10n.aiMatchInsights, false),
        ];
      case FanPassType.superfanPass:
        return [
          TierFeature(l10n.everythingInFanPass, true),
          TierFeature(l10n.exclusiveContent, true),
          TierFeature(l10n.aiMatchInsights, true),
          TierFeature(l10n.priorityFeatures, true),
          TierFeature(l10n.downloadableContent, true),
          TierFeature(l10n.earlyAccessFeatures, true),
        ];
    }
  }

  bool _canUpgradeTo(FanPassType targetTier) {
    final currentTier = _currentStatus?.passType ?? FanPassType.free;

    switch (currentTier) {
      case FanPassType.free:
        return true;
      case FanPassType.fanPass:
        return targetTier == FanPassType.superfanPass;
      case FanPassType.superfanPass:
        return false;
    }
  }
}
