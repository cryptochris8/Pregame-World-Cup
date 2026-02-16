import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/logging_service.dart';
import 'payment_access_service.dart';
import 'payment_models.dart';

/// Handles transaction history, real-time status listeners, and pricing info.
///
/// Extracted from [WorldCupPaymentService] to keep the facade lean.
class PaymentHistoryService {
  static const String _logTag = 'WorldCupPayment';

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;
  final PaymentAccessService _accessService;

  /// Callback invoked when a real-time listener detects a status change
  /// so the facade can clear its own caches.
  final VoidCallback? onCacheClear;

  PaymentHistoryService({
    required FirebaseFunctions functions,
    required FirebaseFirestore firestore,
    required PaymentAccessService accessService,
    this.onCacheClear,
  })  : _functions = functions,
        _firestore = firestore,
        _accessService = accessService;

  // ---------------------------------------------------------------------------
  // Pricing
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Venue premium status
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Real-time listeners
  // ---------------------------------------------------------------------------

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

      onCacheClear?.call();

      final features = <String, bool>{};
      if (data['features'] != null && data['features'] is Map) {
        (data['features'] as Map).forEach((key, value) {
          if (value is bool) {
            features[key.toString()] = value;
          }
        });
      } else {
        features.addAll(_accessService.createFanPassStatus(passType).features);
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

  // ---------------------------------------------------------------------------
  // Transaction history
  // ---------------------------------------------------------------------------

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
}
