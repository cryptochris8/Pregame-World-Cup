import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/logging_service.dart';

/// World Cup 2026 Payment Service
/// Handles one-time purchases for Fan Passes and Venue Premium
class WorldCupPaymentService {
  static final WorldCupPaymentService _instance = WorldCupPaymentService._internal();
  factory WorldCupPaymentService() => _instance;
  WorldCupPaymentService._internal();

  static const String _logTag = 'WorldCupPayment';
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

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

  /// Purchase a fan pass
  /// Returns the checkout URL to open in browser/webview
  Future<String?> createFanPassCheckout({
    required FanPassType passType,
    String? successUrl,
    String? cancelUrl,
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
      });

      final data = result.data as Map<String, dynamic>;
      return data['url'] as String?;
    } catch (e) {
      LoggingService.error('Error creating fan pass checkout: $e', tag: _logTag);
      rethrow;
    }
  }

  /// Open checkout in browser
  Future<bool> openFanPassCheckout({
    required FanPassType passType,
    required BuildContext context,
  }) async {
    try {
      final url = await createFanPassCheckout(passType: passType);

      if (url == null) {
        _showErrorDialog(context, 'Failed to create checkout session');
        return false;
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        _showErrorDialog(context, 'Could not open checkout page');
        return false;
      }
    } catch (e) {
      LoggingService.error('Error opening checkout: $e', tag: _logTag);
      _showErrorDialog(context, 'Failed to start checkout: ${e.toString()}');
      return false;
    }
  }

  /// Check if user has access to a specific feature
  Future<bool> hasFeatureAccess(String feature) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

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
  // VENUE PREMIUM FUNCTIONS
  // ============================================================================

  /// Get venue premium status
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

  /// Create venue premium checkout
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

  /// Open venue premium checkout in browser
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
        _showErrorDialog(context, 'Failed to create checkout session');
        return false;
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        _showErrorDialog(context, 'Could not open checkout page');
        return false;
      }
    } catch (e) {
      LoggingService.error('Error opening venue checkout: $e', tag: _logTag);
      _showErrorDialog(context, 'Failed to start checkout: ${e.toString()}');
      return false;
    }
  }

  // ============================================================================
  // PRICING INFO
  // ============================================================================

  /// Get pricing information for display
  Future<WorldCupPricing?> getPricing() async {
    try {
      final callable = _functions.httpsCallable('getWorldCupPricing');
      final result = await callable.call();
      final data = result.data as Map<String, dynamic>;

      return WorldCupPricing.fromMap(data);
    } catch (e) {
      LoggingService.error('Error getting pricing: $e', tag: _logTag);
      // Return default pricing for display
      return WorldCupPricing.defaults();
    }
  }

  // ============================================================================
  // LOCAL CACHE
  // ============================================================================

  /// Cache for fan pass status (to avoid repeated calls)
  FanPassStatus? _cachedFanPassStatus;
  DateTime? _fanPassStatusCacheTime;

  /// Get cached fan pass status (refreshes every 5 minutes)
  Future<FanPassStatus> getCachedFanPassStatus({bool forceRefresh = false}) async {
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

  /// Clear cached status (call after purchase)
  void clearCache() {
    _cachedFanPassStatus = null;
    _fanPassStatusCacheTime = null;
  }

  // ============================================================================
  // TRANSACTION HISTORY
  // ============================================================================

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get transaction history for current user
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

      // Sort all transactions by date descending
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

// ============================================================================
// DATA MODELS
// ============================================================================

/// Fan pass types
enum FanPassType {
  free('free'),
  fanPass('fan_pass'),
  superfanPass('superfan_pass');

  final String value;
  const FanPassType(this.value);

  static FanPassType fromString(String value) {
    switch (value) {
      case 'fan_pass':
        return FanPassType.fanPass;
      case 'superfan_pass':
        return FanPassType.superfanPass;
      default:
        return FanPassType.free;
    }
  }

  String get displayName {
    switch (this) {
      case FanPassType.free:
        return 'Free';
      case FanPassType.fanPass:
        return 'Fan Pass';
      case FanPassType.superfanPass:
        return 'Superfan Pass';
    }
  }

  String get price {
    switch (this) {
      case FanPassType.free:
        return 'Free';
      case FanPassType.fanPass:
        return '\$14.99';
      case FanPassType.superfanPass:
        return '\$29.99';
    }
  }
}

/// Fan pass status
class FanPassStatus {
  final bool hasPass;
  final FanPassType passType;
  final DateTime? purchasedAt;
  final Map<String, bool> features;

  FanPassStatus({
    required this.hasPass,
    required this.passType,
    this.purchasedAt,
    this.features = const {},
  });

  factory FanPassStatus.free() => FanPassStatus(
    hasPass: false,
    passType: FanPassType.free,
    features: _defaultFreeFeatures,
  );

  bool get hasAdFree => features['adFree'] ?? false;
  bool get hasAdvancedStats => features['advancedStats'] ?? false;
  bool get hasCustomAlerts => features['customAlerts'] ?? false;
  bool get hasAdvancedSocialFeatures => features['advancedSocialFeatures'] ?? false;
  bool get hasExclusiveContent => features['exclusiveContent'] ?? false;
  bool get hasPriorityFeatures => features['priorityFeatures'] ?? false;
  bool get hasAiMatchInsights => features['aiMatchInsights'] ?? false;

  static const Map<String, bool> _defaultFreeFeatures = {
    'basicSchedules': true,
    'venueDiscovery': true,
    'matchNotifications': true,
    'basicTeamFollowing': true,
    'communityAccess': true,
    'adFree': false,
    'advancedStats': false,
    'customAlerts': false,
    'advancedSocialFeatures': false,
    'exclusiveContent': false,
    'priorityFeatures': false,
    'aiMatchInsights': false,
    'downloadableContent': false,
  };
}

/// Venue premium status
class VenuePremiumStatus {
  final bool isPremium;
  final String tier;
  final DateTime? purchasedAt;
  final Map<String, bool> features;

  VenuePremiumStatus({
    required this.isPremium,
    required this.tier,
    this.purchasedAt,
    this.features = const {},
  });

  factory VenuePremiumStatus.free() => VenuePremiumStatus(
    isPremium: false,
    tier: 'free',
    features: _defaultFreeFeatures,
  );

  bool get canManageSchedule => features['matchScheduling'] ?? false;
  bool get canSetupTvs => features['tvSetup'] ?? false;
  bool get canAddSpecials => features['gameSpecials'] ?? false;
  bool get canSetAtmosphere => features['atmosphereSettings'] ?? false;
  bool get canUpdateCapacity => features['liveCapacity'] ?? false;
  bool get hasFeaturedListing => features['featuredListing'] ?? false;
  bool get hasAnalytics => features['analytics'] ?? false;

  static const Map<String, bool> _defaultFreeFeatures = {
    'showsMatches': true,
    'matchScheduling': false,
    'tvSetup': false,
    'gameSpecials': false,
    'atmosphereSettings': false,
    'liveCapacity': false,
    'featuredListing': false,
    'analytics': false,
  };
}

/// World Cup pricing info
class WorldCupPricing {
  final PriceInfo fanPass;
  final PriceInfo superfanPass;
  final PriceInfo venuePremium;
  final DateTime tournamentStart;
  final DateTime tournamentEnd;

  WorldCupPricing({
    required this.fanPass,
    required this.superfanPass,
    required this.venuePremium,
    required this.tournamentStart,
    required this.tournamentEnd,
  });

  factory WorldCupPricing.fromMap(Map<String, dynamic> map) {
    return WorldCupPricing(
      fanPass: PriceInfo.fromMap(map['fanPass'] ?? {}),
      superfanPass: PriceInfo.fromMap(map['superfanPass'] ?? {}),
      venuePremium: PriceInfo.fromMap(map['venuePremium'] ?? {}),
      tournamentStart: DateTime.parse(
        map['tournamentDates']?['start'] ?? '2026-06-11T00:00:00Z',
      ),
      tournamentEnd: DateTime.parse(
        map['tournamentDates']?['end'] ?? '2026-07-20T23:59:59Z',
      ),
    );
  }

  factory WorldCupPricing.defaults() => WorldCupPricing(
    fanPass: PriceInfo(
      amount: 1499,
      displayPrice: '\$14.99',
      name: 'Fan Pass',
      description: 'Ad-free experience, advanced stats, custom alerts, social features',
    ),
    superfanPass: PriceInfo(
      amount: 2999,
      displayPrice: '\$29.99',
      name: 'Superfan Pass',
      description: 'Everything in Fan Pass + exclusive content, AI insights, priority features',
    ),
    venuePremium: PriceInfo(
      amount: 9900,
      displayPrice: '\$99.00',
      name: 'Venue Premium',
      description: 'Full portal access: TV setup, specials, atmosphere, featured listing',
    ),
    tournamentStart: DateTime(2026, 6, 11),
    tournamentEnd: DateTime(2026, 7, 20),
  );
}

/// Price info for a product
class PriceInfo {
  final int amount; // in cents
  final String displayPrice;
  final String name;
  final String description;

  PriceInfo({
    required this.amount,
    required this.displayPrice,
    required this.name,
    required this.description,
  });

  factory PriceInfo.fromMap(Map<String, dynamic> map) => PriceInfo(
    amount: map['amount'] ?? 0,
    displayPrice: map['displayPrice'] ?? '',
    name: map['name'] ?? '',
    description: map['description'] ?? '',
  );
}

// ============================================================================
// TRANSACTION HISTORY MODELS
// ============================================================================

/// Transaction types
enum TransactionType {
  fanPass,
  venuePremium,
  virtualAttendance,
  tip,
  ticket;

  String get displayName {
    switch (this) {
      case TransactionType.fanPass:
        return 'Fan Pass';
      case TransactionType.venuePremium:
        return 'Venue Premium';
      case TransactionType.virtualAttendance:
        return 'Virtual Attendance';
      case TransactionType.tip:
        return 'Tip';
      case TransactionType.ticket:
        return 'Ticket';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.fanPass:
        return Icons.star;
      case TransactionType.venuePremium:
        return Icons.store;
      case TransactionType.virtualAttendance:
        return Icons.videocam;
      case TransactionType.tip:
        return Icons.favorite;
      case TransactionType.ticket:
        return Icons.confirmation_number;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.fanPass:
        return const Color(0xFFFFB300); // Gold
      case TransactionType.venuePremium:
        return const Color(0xFF7C4DFF); // Purple
      case TransactionType.virtualAttendance:
        return const Color(0xFF00BCD4); // Cyan
      case TransactionType.tip:
        return const Color(0xFFE91E63); // Pink
      case TransactionType.ticket:
        return const Color(0xFF4CAF50); // Green
    }
  }
}

/// Transaction status
enum TransactionStatus {
  pending,
  completed,
  failed,
  refunded;

  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.refunded:
        return 'Refunded';
    }
  }

  Color get color {
    switch (this) {
      case TransactionStatus.pending:
        return const Color(0xFFFFA000); // Amber
      case TransactionStatus.completed:
        return const Color(0xFF4CAF50); // Green
      case TransactionStatus.failed:
        return const Color(0xFFF44336); // Red
      case TransactionStatus.refunded:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}

/// Payment transaction record
class PaymentTransaction {
  final String id;
  final TransactionType type;
  final String productName;
  final int amount; // in cents
  final String currency;
  final TransactionStatus status;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  PaymentTransaction({
    required this.id,
    required this.type,
    required this.productName,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.metadata = const {},
  });

  /// Format amount for display (e.g., "$14.99")
  String get displayAmount {
    final dollars = amount / 100;
    final symbol = currency.toUpperCase() == 'USD' ? '\$' : currency;
    return '$symbol${dollars.toStringAsFixed(2)}';
  }

  /// Get a subtitle based on metadata
  String? get subtitle {
    if (type == TransactionType.virtualAttendance) {
      return metadata['watchPartyName'] as String?;
    }
    if (type == TransactionType.venuePremium) {
      return metadata['venueName'] as String?;
    }
    if (type == TransactionType.fanPass) {
      final passType = metadata['passType'] as String?;
      if (passType == 'superfan_pass') return 'World Cup 2026';
      return 'World Cup 2026';
    }
    return null;
  }
}
