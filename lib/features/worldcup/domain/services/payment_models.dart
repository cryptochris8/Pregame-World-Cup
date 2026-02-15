import 'package:flutter/material.dart';

// ============================================================================
// DATA MODELS  (extracted from world_cup_payment_service.dart)
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

  /// Format amount for display (e.g., "\$14.99")
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

// ============================================================================
// NATIVE IAP RESULT MODELS
// ============================================================================

/// Result of a fan pass purchase attempt
class FanPassPurchaseResult {
  final bool success;
  final String? errorMessage;
  final bool userCancelled;
  final bool usedFallback;

  FanPassPurchaseResult({
    required this.success,
    this.errorMessage,
    this.userCancelled = false,
    this.usedFallback = false,
  });
}

/// Result of a restore purchases attempt
class RestorePurchasesResult {
  final bool success;
  final bool hasRestoredPurchases;
  final FanPassType restoredPassType;
  final String? errorMessage;

  RestorePurchasesResult({
    required this.success,
    this.hasRestoredPurchases = false,
    this.restoredPassType = FanPassType.free,
    this.errorMessage,
  });
}
