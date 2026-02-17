import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../services/revenuecat_service.dart';
import 'payment_access_service.dart';
import 'payment_checkout_service.dart';
import 'payment_history_service.dart';
import 'payment_models.dart';

// Re-export all models so existing importers continue to work unchanged.
export 'payment_models.dart';

/// World Cup 2026 Payment Service
/// Handles one-time purchases for Fan Passes and Venue Premium
///
/// Consumer purchases (Fan Pass, Superfan Pass) now use RevenueCat for native IAP
/// Venue Premium stays on Stripe (B2B payment, exempt from IAP rules)
///
/// This is a facade that delegates to focused sub-services:
/// - [PaymentAccessService] for admin/clearance verification, fan pass status, feature access
/// - [PaymentCheckoutService] for checkout flows (fan pass + venue premium), native IAP
/// - [PaymentHistoryService] for transaction history, real-time listeners, pricing
class WorldCupPaymentService {
  static final WorldCupPaymentService _instance = WorldCupPaymentService._internal();
  factory WorldCupPaymentService() => _instance;
  WorldCupPaymentService._internal() {
    final functions = FirebaseFunctions.instance;
    final firestore = FirebaseFirestore.instance;
    final revenueCatService = RevenueCatService();

    _accessService = PaymentAccessService(
      functions: functions,
      firestore: firestore,
      revenueCatService: revenueCatService,
    );

    _historyService = PaymentHistoryService(
      functions: functions,
      firestore: firestore,
      accessService: _accessService,
      onCacheClear: clearCache,
    );

    _checkoutService = PaymentCheckoutService(
      functions: functions,
      revenueCatService: revenueCatService,
      accessService: _accessService,
      getVenuePremiumStatus: (venueId) =>
          _historyService.getVenuePremiumStatus(venueId),
      onCacheClear: clearCache,
    );
  }

  late final PaymentAccessService _accessService;
  late final PaymentCheckoutService _checkoutService;
  late final PaymentHistoryService _historyService;

  // ============================================================================
  // FAN PASS STATUS & ACCESS
  // ============================================================================

  /// Get current fan pass status
  Future<FanPassStatus> getFanPassStatus() => _accessService.getFanPassStatus();

  /// Check if the current user has access to a specific feature
  Future<bool> hasFeatureAccess(String feature) => _accessService.hasFeatureAccess(feature);

  // ============================================================================
  // BROWSER CHECKOUT TRACKING
  // ============================================================================

  bool get isBrowserCheckoutInProgress => _checkoutService.isBrowserCheckoutInProgress;
  void markBrowserCheckoutComplete() => _checkoutService.markBrowserCheckoutComplete();

  // ============================================================================
  // FAN PASS CHECKOUT
  // ============================================================================

  Future<String?> createFanPassCheckout({
    required FanPassType passType,
    String? successUrl,
    String? cancelUrl,
    bool returnToApp = false,
  }) =>
      _checkoutService.createFanPassCheckout(
        passType: passType,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
        returnToApp: returnToApp,
      );

  Future<bool> openFanPassCheckout({
    required FanPassType passType,
    required BuildContext context,
  }) =>
      _checkoutService.openFanPassCheckout(passType: passType, context: context);

  // ============================================================================
  // NATIVE IAP PURCHASE FUNCTIONS (RevenueCat)
  // ============================================================================

  Future<FanPassPurchaseResult> purchaseFanPass({
    required FanPassType passType,
    required BuildContext context,
  }) =>
      _checkoutService.purchaseFanPass(passType: passType, context: context);

  Future<RestorePurchasesResult> restorePurchases({required BuildContext context}) =>
      _checkoutService.restorePurchases(context: context);

  Future<String?> getNativePrice(FanPassType passType) =>
      _checkoutService.getNativePrice(passType);

  bool get isNativeIAPAvailable => _checkoutService.isNativeIAPAvailable;

  // ============================================================================
  // VENUE PREMIUM FUNCTIONS
  // ============================================================================

  Future<VenuePremiumStatus> getVenuePremiumStatus(String venueId) =>
      _historyService.getVenuePremiumStatus(venueId);

  Future<String?> createVenuePremiumCheckout({
    required String venueId,
    String? venueName,
    String? successUrl,
    String? cancelUrl,
  }) =>
      _checkoutService.createVenuePremiumCheckout(
        venueId: venueId,
        venueName: venueName,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );

  Future<bool> openVenuePremiumCheckout({
    required String venueId,
    String? venueName,
    required BuildContext context,
  }) =>
      _checkoutService.openVenuePremiumCheckout(
        venueId: venueId,
        venueName: venueName,
        context: context,
      );

  // ============================================================================
  // PRICING INFO
  // ============================================================================

  Future<WorldCupPricing?> getPricing() => _historyService.getPricing();

  // ============================================================================
  // LOCAL CACHE
  // ============================================================================

  FanPassStatus? _cachedFanPassStatus;
  DateTime? _fanPassStatusCacheTime;

  Future<FanPassStatus> getCachedFanPassStatus({bool forceRefresh = false}) async {
    if (await _accessService.isAdminUser()) {
      return _accessService.getAdminFanPassStatus();
    }

    final now = DateTime.now();
    final cacheValid = _fanPassStatusCacheTime != null &&
        now.difference(_fanPassStatusCacheTime!).inMinutes < 5;

    if (!forceRefresh && cacheValid && _cachedFanPassStatus != null) {
      return _cachedFanPassStatus!;
    }

    _cachedFanPassStatus = await getFanPassStatus();
    _fanPassStatusCacheTime = now;
    return _cachedFanPassStatus!;
  }

  void clearCache() {
    _cachedFanPassStatus = null;
    _fanPassStatusCacheTime = null;
    _accessService.clearCaches();
  }

  // ============================================================================
  // REAL-TIME LISTENERS
  // ============================================================================

  Stream<FanPassStatus> listenToFanPassStatus(String userId) =>
      _historyService.listenToFanPassStatus(userId);

  Stream<VenuePremiumStatus> listenToVenuePremiumStatus(String venueId) =>
      _historyService.listenToVenuePremiumStatus(venueId);

  // ============================================================================
  // TRANSACTION HISTORY
  // ============================================================================

  Future<List<PaymentTransaction>> getTransactionHistory() =>
      _historyService.getTransactionHistory();
}
