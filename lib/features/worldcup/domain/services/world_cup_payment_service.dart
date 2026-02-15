import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/logging_service.dart';
import '../../../../services/revenuecat_service.dart';
import 'payment_models.dart';

// Re-export all models so existing importers continue to work unchanged.
export 'payment_models.dart';

/// World Cup 2026 Payment Service
/// Handles one-time purchases for Fan Passes and Venue Premium
///
/// Consumer purchases (Fan Pass, Superfan Pass) now use RevenueCat for native IAP
/// Venue Premium stays on Stripe (B2B payment, exempt from IAP rules)
class WorldCupPaymentService {
  static final WorldCupPaymentService _instance = WorldCupPaymentService._internal();
  factory WorldCupPaymentService() => _instance;
  WorldCupPaymentService._internal();

  static const String _logTag = 'WorldCupPayment';
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RevenueCatService _revenueCatService = RevenueCatService();

  // Session cache for admin/clearance lookups to avoid repeated Firestore reads.
  // Key: email (lowercase), Value: true if admin/clearance.
  final Map<String, bool> _adminCache = {};
  final Map<String, bool> _clearanceCache = {};

  // Hardcoded fallback lists - used ONLY when Firestore query fails.
  // The source of truth is Firestore collections: admin_users, clearance_users.
  static const List<String> _fallbackAdminEmails = [
    'chriscam8@gmail.com',
  ];
  static const List<String> _fallbackClearanceEmails = [
    'coopercrawford013@gmail.com',
    'johnnycaboshi@gmail.com',
  ];

  /// Check if current user is an admin/test account.
  Future<bool> _isAdminUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return false;
    final email = user.email!.toLowerCase();
    return _isAdminOrClearanceEmail(
      email: email,
      collection: 'admin_users',
      cache: _adminCache,
      fallbackList: _fallbackAdminEmails,
    );
  }

  /// Check if current user is on the clearance list.
  Future<bool> _isClearanceUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return false;
    final email = user.email!.toLowerCase();
    return _isAdminOrClearanceEmail(
      email: email,
      collection: 'clearance_users',
      cache: _clearanceCache,
      fallbackList: _fallbackClearanceEmails,
    );
  }

  /// Helper that checks if an email exists in a Firestore collection,
  /// with session caching and hardcoded fallback on error.
  Future<bool> _isAdminOrClearanceEmail({
    required String email,
    required String collection,
    required Map<String, bool> cache,
    required List<String> fallbackList,
  }) async {
    if (cache.containsKey(email)) {
      return cache[email]!;
    }

    try {
      final snapshot = await _firestore
          .collection(collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      final found = snapshot.docs.isNotEmpty;
      cache[email] = found;
      return found;
    } catch (e) {
      LoggingService.warning(
        'Firestore $collection query failed, using hardcoded fallback: $e',
        tag: _logTag,
      );
      final found = fallbackList.contains(email);
      cache[email] = found;
      return found;
    }
  }

  /// Get full Superfan Pass status for admin users
  FanPassStatus _getAdminFanPassStatus() {
    return FanPassStatus(
      hasPass: true,
      passType: FanPassType.superfanPass,
      purchasedAt: DateTime.now(),
      features: const {
        'basicSchedules': true,
        'venueDiscovery': true,
        'matchNotifications': true,
        'basicTeamFollowing': true,
        'communityAccess': true,
        'adFree': true,
        'advancedStats': true,
        'customAlerts': true,
        'advancedSocialFeatures': true,
        'exclusiveContent': true,
        'priorityFeatures': true,
        'aiMatchInsights': true,
        'downloadableContent': true,
      },
    );
  }

  // ============================================================================
  // FAN PASS FUNCTIONS
  // ============================================================================

  /// Get current fan pass status
  Future<FanPassStatus> getFanPassStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return FanPassStatus.free();
      }

      if (await _isAdminUser()) {
        return _getAdminFanPassStatus();
      }

      if (await _isClearanceUser()) {
        LoggingService.info('User on clearance list - granting Superfan Pass', tag: _logTag);
        return _getAdminFanPassStatus();
      }

      // Check RevenueCat entitlements first (native IAP purchases)
      if (_revenueCatService.isConfigured) {
        final revenueCatPassType = await _revenueCatService.getPassType();
        if (revenueCatPassType != FanPassType.free) {
          LoggingService.info('Found RevenueCat entitlement: $revenueCatPassType', tag: _logTag);
          return _createFanPassStatus(revenueCatPassType);
        }
      }

      // Fallback to Firestore for legacy Stripe purchases
      final callable = _functions.httpsCallable('getFanPassStatus');
      final result = await callable.call();
      final data = result.data as Map<String, dynamic>;

      return FanPassStatus(
        hasPass: data['hasPass'] ?? false,
        passType: FanPassType.fromString(data['passType'] ?? 'free'),
        purchasedAt: data['purchasedAt'] != null
            ? DateTime.parse(data['purchasedAt'])
            : null,
        features: Map<String, bool>.from(data['features'] ?? {}),
      );
    } catch (e) {
      LoggingService.error('Error getting fan pass status: $e', tag: _logTag);
      return FanPassStatus.free();
    }
  }

  /// Create a FanPassStatus from a FanPassType
  FanPassStatus _createFanPassStatus(FanPassType passType) {
    final features = <String, bool>{
      'basicSchedules': true,
      'venueDiscovery': true,
      'matchNotifications': true,
      'basicTeamFollowing': true,
      'communityAccess': true,
      'adFree': passType != FanPassType.free,
      'advancedStats': passType != FanPassType.free,
      'customAlerts': passType != FanPassType.free,
      'advancedSocialFeatures': passType != FanPassType.free,
      'exclusiveContent': passType == FanPassType.superfanPass,
      'priorityFeatures': passType == FanPassType.superfanPass,
      'aiMatchInsights': passType == FanPassType.superfanPass,
      'downloadableContent': passType == FanPassType.superfanPass,
    };

    return FanPassStatus(
      hasPass: passType != FanPassType.free,
      passType: passType,
      purchasedAt: DateTime.now(),
      features: features,
    );
  }

  // ============================================================================
  // BROWSER CHECKOUT TRACKING
  // ============================================================================

  bool _browserCheckoutInProgress = false;
  bool get isBrowserCheckoutInProgress => _browserCheckoutInProgress;
  void markBrowserCheckoutComplete() {
    _browserCheckoutInProgress = false;
  }

  // ============================================================================
  // FAN PASS CHECKOUT
  // ============================================================================

  Future<String?> createFanPassCheckout({
    required FanPassType passType,
    String? successUrl,
    String? cancelUrl,
    bool returnToApp = false,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Must be logged in to purchase');
      }

      final callable = _functions.httpsCallable('createFanPassCheckout');
      final result = await callable.call({
        'passType': passType.value,
        'successUrl': successUrl,
        'cancelUrl': cancelUrl,
        'returnToApp': returnToApp,
      });

      final data = result.data as Map<String, dynamic>;
      return data['url'] as String?;
    } catch (e) {
      LoggingService.error('Error creating fan pass checkout: $e', tag: _logTag);
      rethrow;
    }
  }

  Future<bool> openFanPassCheckout({
    required FanPassType passType,
    required BuildContext context,
  }) async {
    try {
      final url = await createFanPassCheckout(
        passType: passType,
        returnToApp: true,
      );

      if (url == null) {
        if (context.mounted) {
          _showErrorDialog(context, 'Failed to create checkout session');
        }
        return false;
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        _browserCheckoutInProgress = true;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        if (context.mounted) {
          _showErrorDialog(context, 'Could not open checkout page');
        }
        return false;
      }
    } catch (e) {
      LoggingService.error('Error opening checkout: $e', tag: _logTag);
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to start checkout: ${e.toString()}');
      }
      return false;
    }
  }

  Future<bool> hasFeatureAccess(String feature) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      if (await _isAdminUser()) return true;

      final callable = _functions.httpsCallable('checkFanPassAccess');
      final result = await callable.call({'feature': feature});
      final data = result.data as Map<String, dynamic>;

      return data['hasAccess'] ?? false;
    } catch (e) {
      LoggingService.error('Error checking feature access: $e', tag: _logTag);
      return false;
    }
  }

  // ============================================================================
  // NATIVE IAP PURCHASE FUNCTIONS (RevenueCat)
  // ============================================================================

  Future<FanPassPurchaseResult> purchaseFanPass({
    required FanPassType passType,
    required BuildContext context,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return FanPassPurchaseResult(
        success: false,
        errorMessage: 'Please sign in to purchase',
      );
    }

    if (passType == FanPassType.free) {
      return FanPassPurchaseResult(
        success: false,
        errorMessage: 'Cannot purchase free tier',
      );
    }

    if (!_revenueCatService.isConfigured) {
      LoggingService.warning('RevenueCat not configured, falling back to browser checkout', tag: _logTag);
      final success = await openFanPassCheckout(passType: passType, context: context);
      return FanPassPurchaseResult(
        success: success,
        usedFallback: true,
        errorMessage: success ? null : 'Failed to open checkout',
      );
    }

    final result = await _revenueCatService.purchaseFanPassByType(passType);

    if (result.success) {
      clearCache();
      LoggingService.info('Fan pass purchased successfully via RevenueCat', tag: _logTag);
    }

    return FanPassPurchaseResult(
      success: result.success,
      errorMessage: result.errorMessage,
      userCancelled: result.userCancelled,
    );
  }

  Future<RestorePurchasesResult> restorePurchases({required BuildContext context}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return RestorePurchasesResult(
        success: false,
        errorMessage: 'Please sign in to restore purchases',
      );
    }

    if (!_revenueCatService.isConfigured) {
      return RestorePurchasesResult(
        success: false,
        errorMessage: 'In-app purchases not available',
      );
    }

    final result = await _revenueCatService.restorePurchases();

    if (result.success) {
      clearCache();

      if (result.hasRestoredPurchases) {
        LoggingService.info('Purchases restored: ${result.restoredPassType}', tag: _logTag);
      } else {
        LoggingService.info('No purchases to restore', tag: _logTag);
      }
    }

    return RestorePurchasesResult(
      success: result.success,
      hasRestoredPurchases: result.hasRestoredPurchases,
      restoredPassType: result.restoredPassType,
      errorMessage: result.errorMessage,
    );
  }

  Future<String?> getNativePrice(FanPassType passType) async {
    if (!_revenueCatService.isConfigured) return null;
    return _revenueCatService.getPriceForPassType(passType);
  }

  bool get isNativeIAPAvailable => _revenueCatService.isConfigured;

  // ============================================================================
  // VENUE PREMIUM FUNCTIONS
  // ============================================================================

  Future<VenuePremiumStatus> getVenuePremiumStatus(String venueId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return VenuePremiumStatus.free();
      }

      final callable = _functions.httpsCallable('getVenuePremiumStatus');
      final result = await callable.call({'venueId': venueId});
      final data = result.data as Map<String, dynamic>;

      return VenuePremiumStatus(
        isPremium: data['isPremium'] ?? false,
        tier: data['tier'] ?? 'free',
        purchasedAt: data['purchasedAt'] != null
            ? DateTime.parse(data['purchasedAt'])
            : null,
        features: Map<String, bool>.from(data['features'] ?? {}),
      );
    } catch (e) {
      LoggingService.error('Error getting venue premium status: $e', tag: _logTag);
      return VenuePremiumStatus.free();
    }
  }

  Future<String?> createVenuePremiumCheckout({
    required String venueId,
    String? venueName,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Must be logged in to purchase');
      }

      final callable = _functions.httpsCallable('createVenuePremiumCheckout');
      final result = await callable.call({
        'venueId': venueId,
        'venueName': venueName,
        'successUrl': successUrl,
        'cancelUrl': cancelUrl,
      });

      final data = result.data as Map<String, dynamic>;
      return data['url'] as String?;
    } catch (e) {
      LoggingService.error('Error creating venue premium checkout: $e', tag: _logTag);
      rethrow;
    }
  }

  Future<bool> openVenuePremiumCheckout({
    required String venueId,
    String? venueName,
    required BuildContext context,
  }) async {
    try {
      final url = await createVenuePremiumCheckout(
        venueId: venueId,
        venueName: venueName,
      );

      if (url == null) {
        if (context.mounted) {
          _showErrorDialog(context, 'Failed to create checkout session');
        }
        return false;
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        if (context.mounted) {
          _showErrorDialog(context, 'Could not open checkout page');
        }
        return false;
      }
    } catch (e) {
      LoggingService.error('Error opening venue checkout: $e', tag: _logTag);
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to start checkout: ${e.toString()}');
      }
      return false;
    }
  }

  // ============================================================================
  // PRICING INFO
  // ============================================================================

  Future<WorldCupPricing?> getPricing() async {
    try {
      final callable = _functions.httpsCallable('getWorldCupPricing');
      final result = await callable.call();
      final data = result.data as Map<String, dynamic>;

      return WorldCupPricing.fromMap(data);
    } catch (e) {
      LoggingService.error('Error getting pricing: $e', tag: _logTag);
      return WorldCupPricing.defaults();
    }
  }

  // ============================================================================
  // LOCAL CACHE
  // ============================================================================

  FanPassStatus? _cachedFanPassStatus;
  DateTime? _fanPassStatusCacheTime;

  Future<FanPassStatus> getCachedFanPassStatus({bool forceRefresh = false}) async {
    if (await _isAdminUser()) {
      return _getAdminFanPassStatus();
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
    _adminCache.clear();
    _clearanceCache.clear();
  }

  // ============================================================================
  // REAL-TIME LISTENERS
  // ============================================================================

  Stream<FanPassStatus> listenToFanPassStatus(String userId) {
    return _firestore
        .collection('world_cup_fan_passes')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return FanPassStatus.free();
      }

      final data = snapshot.data()!;
      final passType = FanPassType.fromString(data['passType'] ?? 'free');
      final isActive = data['status'] == 'active';

      if (!isActive) {
        return FanPassStatus.free();
      }

      clearCache();

      final features = <String, bool>{};
      if (data['features'] != null && data['features'] is Map) {
        (data['features'] as Map).forEach((key, value) {
          if (value is bool) {
            features[key.toString()] = value;
          }
        });
      } else {
        features.addAll(_createFanPassStatus(passType).features);
      }

      LoggingService.info(
        'Real-time fan pass update: $passType (active=$isActive)',
        tag: _logTag,
      );

      return FanPassStatus(
        hasPass: true,
        passType: passType,
        purchasedAt: (data['purchasedAt'] as Timestamp?)?.toDate(),
        features: features,
      );
    });
  }

  Stream<VenuePremiumStatus> listenToVenuePremiumStatus(String venueId) {
    return _firestore
        .collection('venue_enhancements')
        .doc(venueId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return VenuePremiumStatus.free();
      }

      final data = snapshot.data()!;
      final isPremium = data['subscriptionTier'] == 'premium';

      if (!isPremium) {
        return VenuePremiumStatus.free();
      }

      LoggingService.info(
        'Real-time venue premium update: venueId=$venueId (premium=$isPremium)',
        tag: _logTag,
      );

      return VenuePremiumStatus(
        isPremium: true,
        tier: 'premium',
        purchasedAt: (data['premiumPurchasedAt'] as Timestamp?)?.toDate(),
        features: const {
          'showsMatches': true,
          'matchScheduling': true,
          'tvSetup': true,
          'gameSpecials': true,
          'atmosphereSettings': true,
          'liveCapacity': true,
          'featuredListing': true,
          'analytics': true,
        },
      );
    });
  }

  // ============================================================================
  // TRANSACTION HISTORY
  // ============================================================================

  Future<List<PaymentTransaction>> getTransactionHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final List<PaymentTransaction> transactions = [];

      // Get fan pass purchases
      final fanPassDoc = await _firestore
          .collection('world_cup_fan_passes')
          .doc(user.uid)
          .get();

      if (fanPassDoc.exists) {
        final data = fanPassDoc.data()!;
        if (data['status'] == 'active') {
          transactions.add(PaymentTransaction(
            id: fanPassDoc.id,
            type: TransactionType.fanPass,
            productName: data['passType'] == 'superfan_pass'
                ? 'Superfan Pass'
                : 'Fan Pass',
            amount: data['passType'] == 'superfan_pass' ? 2999 : 1499,
            currency: 'usd',
            status: TransactionStatus.completed,
            createdAt: (data['purchasedAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            metadata: {
              'passType': data['passType'],
              'stripeSessionId': data['stripeSessionId'],
            },
          ));
        }
      }

      // Get venue premium purchases
      final venuePurchases = await _firestore
          .collection('world_cup_venue_purchases')
          .where('userId', isEqualTo: user.uid)
          .orderBy('purchasedAt', descending: true)
          .get();

      for (final doc in venuePurchases.docs) {
        final data = doc.data();
        transactions.add(PaymentTransaction(
          id: doc.id,
          type: TransactionType.venuePremium,
          productName: 'Venue Premium',
          amount: 9900,
          currency: 'usd',
          status: TransactionStatus.completed,
          createdAt: (data['purchasedAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
          metadata: {
            'venueId': data['venueId'],
            'venueName': data['venueName'],
            'stripeSessionId': data['stripeSessionId'],
          },
        ));
      }

      // Get virtual attendance payments
      final virtualPayments = await _firestore
          .collection('watch_party_virtual_payments')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      for (final doc in virtualPayments.docs) {
        final data = doc.data();
        transactions.add(PaymentTransaction(
          id: doc.id,
          type: TransactionType.virtualAttendance,
          productName: 'Virtual Attendance',
          amount: (data['amount'] as num?)?.toInt() ?? 0,
          currency: data['currency'] ?? 'usd',
          status: _parseTransactionStatus(data['status']),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
          metadata: {
            'watchPartyId': data['watchPartyId'],
            'watchPartyName': data['watchPartyName'],
          },
        ));
      }

      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return transactions;
    } catch (e) {
      LoggingService.error('Error getting transaction history: $e', tag: _logTag);
      return [];
    }
  }

  TransactionStatus _parseTransactionStatus(String? status) {
    switch (status) {
      case 'completed':
      case 'succeeded':
        return TransactionStatus.completed;
      case 'pending':
        return TransactionStatus.pending;
      case 'refunded':
        return TransactionStatus.refunded;
      case 'failed':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.pending;
    }
  }

  // ============================================================================
  // UI HELPERS
  // ============================================================================

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
