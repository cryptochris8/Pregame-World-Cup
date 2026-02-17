import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/logging_service.dart';
import '../../../../services/revenuecat_service.dart';
import 'payment_models.dart';

/// Handles admin/clearance verification, fan pass status resolution,
/// and feature-access checks.
///
/// Extracted from [WorldCupPaymentService] to keep the facade lean.
class PaymentAccessService {
  static const String _logTag = 'WorldCupPayment';

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;
  final RevenueCatService _revenueCatService;

  // Session cache for admin/clearance lookups to avoid repeated Firestore reads.
  final Map<String, bool> _adminCache = {};
  final Map<String, bool> _clearanceCache = {};

  PaymentAccessService({
    required FirebaseFunctions functions,
    required FirebaseFirestore firestore,
    required RevenueCatService revenueCatService,
  })  : _functions = functions,
        _firestore = firestore,
        _revenueCatService = revenueCatService;

  // ---------------------------------------------------------------------------
  // Admin / clearance helpers
  // ---------------------------------------------------------------------------

  /// Check if current user is an admin/test account.
  Future<bool> isAdminUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return false;
    final email = user.email!.toLowerCase();
    return _isAdminOrClearanceEmail(
      email: email,
      collection: 'admin_users',
      cache: _adminCache,
    );
  }

  /// Check if current user is on the clearance list.
  Future<bool> isClearanceUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return false;
    final email = user.email!.toLowerCase();
    return _isAdminOrClearanceEmail(
      email: email,
      collection: 'clearance_users',
      cache: _clearanceCache,
    );
  }

  /// Helper that checks if an email exists in a Firestore collection,
  /// with session caching.
  Future<bool> _isAdminOrClearanceEmail({
    required String email,
    required String collection,
    required Map<String, bool> cache,
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
        'Firestore $collection query failed: $e',
        tag: _logTag,
      );
      return false;
    }
  }

  /// Get full Superfan Pass status for admin users.
  FanPassStatus getAdminFanPassStatus() {
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

  // ---------------------------------------------------------------------------
  // Fan pass status
  // ---------------------------------------------------------------------------

  /// Get current fan pass status.
  Future<FanPassStatus> getFanPassStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return FanPassStatus.free();
      }

      if (await isAdminUser()) {
        return getAdminFanPassStatus();
      }

      if (await isClearanceUser()) {
        LoggingService.info('User on clearance list - granting Superfan Pass', tag: _logTag);
        return getAdminFanPassStatus();
      }

      // Check RevenueCat entitlements first (native IAP purchases)
      if (_revenueCatService.isConfigured) {
        final revenueCatPassType = await _revenueCatService.getPassType();
        if (revenueCatPassType != FanPassType.free) {
          LoggingService.info('Found RevenueCat entitlement: $revenueCatPassType', tag: _logTag);
          return createFanPassStatus(revenueCatPassType);
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

  /// Create a FanPassStatus from a FanPassType.
  FanPassStatus createFanPassStatus(FanPassType passType) {
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

  /// Check if the current user has access to a specific feature.
  Future<bool> hasFeatureAccess(String feature) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      if (await isAdminUser()) return true;

      final callable = _functions.httpsCallable('checkFanPassAccess');
      final result = await callable.call({'feature': feature});
      final data = result.data as Map<String, dynamic>;

      return data['hasAccess'] ?? false;
    } catch (e) {
      LoggingService.error('Error checking feature access: $e', tag: _logTag);
      return false;
    }
  }

  /// Clear the admin/clearance caches.
  void clearCaches() {
    _adminCache.clear();
    _clearanceCache.clear();
  }
}
