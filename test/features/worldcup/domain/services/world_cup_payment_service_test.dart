import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/services/world_cup_payment_service.dart';

/// Tests for the WorldCupPaymentService data models and observable behavior.
///
/// The service itself is a singleton with hardcoded Firebase dependencies,
/// so we focus on testing the data models and types that are publicly exposed.
/// The critical business logic around pass status, features, and pricing
/// is encoded in these models.
void main() {
  group('FanPassType', () {
    test('fromString returns correct type for fan_pass', () {
      expect(FanPassType.fromString('fan_pass'), equals(FanPassType.fanPass));
    });

    test('fromString returns correct type for superfan_pass', () {
      expect(
        FanPassType.fromString('superfan_pass'),
        equals(FanPassType.superfanPass),
      );
    });

    test('fromString returns free for unknown values', () {
      expect(FanPassType.fromString('unknown'), equals(FanPassType.free));
      expect(FanPassType.fromString(''), equals(FanPassType.free));
      expect(FanPassType.fromString('premium'), equals(FanPassType.free));
    });

    test('value returns correct string representation', () {
      expect(FanPassType.free.value, equals('free'));
      expect(FanPassType.fanPass.value, equals('fan_pass'));
      expect(FanPassType.superfanPass.value, equals('superfan_pass'));
    });

    test('displayName returns human-readable name', () {
      expect(FanPassType.free.displayName, equals('Free'));
      expect(FanPassType.fanPass.displayName, equals('Fan Pass'));
      expect(FanPassType.superfanPass.displayName, equals('Superfan Pass'));
    });

    test('price returns correct price string', () {
      expect(FanPassType.free.price, equals('Free'));
      expect(FanPassType.fanPass.price, equals('\$14.99'));
      expect(FanPassType.superfanPass.price, equals('\$29.99'));
    });

    test('roundtrip fromString(value) preserves all types', () {
      for (final type in FanPassType.values) {
        expect(FanPassType.fromString(type.value), equals(type));
      }
    });
  });

  group('FanPassStatus', () {
    test('free() factory creates status with no pass', () {
      final status = FanPassStatus.free();

      expect(status.hasPass, isFalse);
      expect(status.passType, equals(FanPassType.free));
      expect(status.purchasedAt, isNull);
    });

    test('free() factory includes default free features', () {
      final status = FanPassStatus.free();

      // Free users get basic features
      expect(status.features['basicSchedules'], isTrue);
      expect(status.features['venueDiscovery'], isTrue);
      expect(status.features['matchNotifications'], isTrue);
      expect(status.features['basicTeamFollowing'], isTrue);
      expect(status.features['communityAccess'], isTrue);

      // Premium features are disabled for free users
      expect(status.hasAdFree, isFalse);
      expect(status.hasAdvancedStats, isFalse);
      expect(status.hasCustomAlerts, isFalse);
      expect(status.hasAdvancedSocialFeatures, isFalse);
      expect(status.hasExclusiveContent, isFalse);
      expect(status.hasPriorityFeatures, isFalse);
      expect(status.hasAiMatchInsights, isFalse);
    });

    test('constructing FanPassStatus with superfan pass enables all features', () {
      final status = FanPassStatus(
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

      expect(status.hasPass, isTrue);
      expect(status.passType, equals(FanPassType.superfanPass));
      expect(status.hasAdFree, isTrue);
      expect(status.hasAdvancedStats, isTrue);
      expect(status.hasCustomAlerts, isTrue);
      expect(status.hasAdvancedSocialFeatures, isTrue);
      expect(status.hasExclusiveContent, isTrue);
      expect(status.hasPriorityFeatures, isTrue);
      expect(status.hasAiMatchInsights, isTrue);
    });

    test('constructing FanPassStatus with fan pass enables mid-tier features', () {
      final status = FanPassStatus(
        hasPass: true,
        passType: FanPassType.fanPass,
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
          'exclusiveContent': false,
          'priorityFeatures': false,
          'aiMatchInsights': false,
          'downloadableContent': false,
        },
      );

      expect(status.hasPass, isTrue);
      expect(status.hasAdFree, isTrue);
      expect(status.hasAdvancedStats, isTrue);
      expect(status.hasCustomAlerts, isTrue);
      expect(status.hasAdvancedSocialFeatures, isTrue);

      // Superfan-only features are not included
      expect(status.hasExclusiveContent, isFalse);
      expect(status.hasPriorityFeatures, isFalse);
      expect(status.hasAiMatchInsights, isFalse);
    });

    test('feature getters default to false when feature key is missing', () {
      final status = FanPassStatus(
        hasPass: false,
        passType: FanPassType.free,
        features: const {},
      );

      expect(status.hasAdFree, isFalse);
      expect(status.hasAdvancedStats, isFalse);
      expect(status.hasCustomAlerts, isFalse);
      expect(status.hasAdvancedSocialFeatures, isFalse);
      expect(status.hasExclusiveContent, isFalse);
      expect(status.hasPriorityFeatures, isFalse);
      expect(status.hasAiMatchInsights, isFalse);
    });
  });

  group('VenuePremiumStatus', () {
    test('free() factory creates non-premium status', () {
      final status = VenuePremiumStatus.free();

      expect(status.isPremium, isFalse);
      expect(status.tier, equals('free'));
      expect(status.purchasedAt, isNull);
    });

    test('free() factory has correct default features', () {
      final status = VenuePremiumStatus.free();

      expect(status.features['showsMatches'], isTrue);
      expect(status.canManageSchedule, isFalse);
      expect(status.canSetupTvs, isFalse);
      expect(status.canAddSpecials, isFalse);
      expect(status.canSetAtmosphere, isFalse);
      expect(status.canUpdateCapacity, isFalse);
      expect(status.hasFeaturedListing, isFalse);
      expect(status.hasAnalytics, isFalse);
    });

    test('premium status enables all venue features', () {
      final status = VenuePremiumStatus(
        isPremium: true,
        tier: 'premium',
        purchasedAt: DateTime.now(),
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

      expect(status.isPremium, isTrue);
      expect(status.canManageSchedule, isTrue);
      expect(status.canSetupTvs, isTrue);
      expect(status.canAddSpecials, isTrue);
      expect(status.canSetAtmosphere, isTrue);
      expect(status.canUpdateCapacity, isTrue);
      expect(status.hasFeaturedListing, isTrue);
      expect(status.hasAnalytics, isTrue);
    });

    test('feature getters default to false when feature key is missing', () {
      final status = VenuePremiumStatus(
        isPremium: false,
        tier: 'free',
        features: const {},
      );

      expect(status.canManageSchedule, isFalse);
      expect(status.canSetupTvs, isFalse);
      expect(status.canAddSpecials, isFalse);
      expect(status.canSetAtmosphere, isFalse);
      expect(status.canUpdateCapacity, isFalse);
      expect(status.hasFeaturedListing, isFalse);
      expect(status.hasAnalytics, isFalse);
    });
  });

  group('WorldCupPricing', () {
    test('defaults() factory returns correct default pricing', () {
      final pricing = WorldCupPricing.defaults();

      expect(pricing.fanPass.amount, equals(1499));
      expect(pricing.fanPass.displayPrice, equals('\$14.99'));
      expect(pricing.fanPass.name, equals('Fan Pass'));

      expect(pricing.superfanPass.amount, equals(2999));
      expect(pricing.superfanPass.displayPrice, equals('\$29.99'));
      expect(pricing.superfanPass.name, equals('Superfan Pass'));

      expect(pricing.venuePremium.amount, equals(49900));
      expect(pricing.venuePremium.displayPrice, equals('\$499.00'));
      expect(pricing.venuePremium.name, equals('Venue Premium'));

      expect(pricing.tournamentStart, equals(DateTime(2026, 6, 11)));
      expect(pricing.tournamentEnd, equals(DateTime(2026, 7, 20)));
    });

    test('fromMap() parses valid data correctly', () {
      final data = {
        'fanPass': {
          'amount': 1499,
          'displayPrice': '\$14.99',
          'name': 'Fan Pass',
          'description': 'Basic premium features',
        },
        'superfanPass': {
          'amount': 2999,
          'displayPrice': '\$29.99',
          'name': 'Superfan Pass',
          'description': 'All premium features',
        },
        'venuePremium': {
          'amount': 9900,
          'displayPrice': '\$99.00',
          'name': 'Venue Premium',
          'description': 'Full portal access',
        },
        'tournamentDates': {
          'start': '2026-06-11T00:00:00Z',
          'end': '2026-07-20T23:59:59Z',
        },
      };

      final pricing = WorldCupPricing.fromMap(data);

      expect(pricing.fanPass.amount, equals(1499));
      expect(pricing.superfanPass.amount, equals(2999));
      expect(pricing.venuePremium.amount, equals(9900));
      expect(pricing.tournamentStart.year, equals(2026));
      expect(pricing.tournamentStart.month, equals(6));
      expect(pricing.tournamentStart.day, equals(11));
    });

    test('fromMap() handles missing data with defaults', () {
      final pricing = WorldCupPricing.fromMap({});

      expect(pricing.fanPass.amount, equals(0));
      expect(pricing.fanPass.displayPrice, equals(''));
      expect(pricing.tournamentStart.year, equals(2026));
      expect(pricing.tournamentStart.month, equals(6));
      expect(pricing.tournamentStart.day, equals(11));
    });
  });

  group('PriceInfo', () {
    test('fromMap() parses correctly', () {
      final info = PriceInfo.fromMap({
        'amount': 1499,
        'displayPrice': '\$14.99',
        'name': 'Fan Pass',
        'description': 'Ad-free and more',
      });

      expect(info.amount, equals(1499));
      expect(info.displayPrice, equals('\$14.99'));
      expect(info.name, equals('Fan Pass'));
      expect(info.description, equals('Ad-free and more'));
    });

    test('fromMap() handles missing fields with defaults', () {
      final info = PriceInfo.fromMap({});

      expect(info.amount, equals(0));
      expect(info.displayPrice, equals(''));
      expect(info.name, equals(''));
      expect(info.description, equals(''));
    });
  });

  group('PaymentTransaction', () {
    test('displayAmount formats USD correctly', () {
      final tx = PaymentTransaction(
        id: 'tx_1',
        type: TransactionType.fanPass,
        productName: 'Fan Pass',
        amount: 1499,
        currency: 'usd',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
      );

      expect(tx.displayAmount, equals('\$14.99'));
    });

    test('displayAmount formats zero amount', () {
      final tx = PaymentTransaction(
        id: 'tx_1',
        type: TransactionType.virtualAttendance,
        productName: 'Free Event',
        amount: 0,
        currency: 'usd',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
      );

      expect(tx.displayAmount, equals('\$0.00'));
    });

    test('subtitle returns watchPartyName for virtual attendance', () {
      final tx = PaymentTransaction(
        id: 'tx_1',
        type: TransactionType.virtualAttendance,
        productName: 'Virtual Attendance',
        amount: 500,
        currency: 'usd',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
        metadata: {'watchPartyName': 'Game Day Party'},
      );

      expect(tx.subtitle, equals('Game Day Party'));
    });

    test('subtitle returns venueName for venue premium', () {
      final tx = PaymentTransaction(
        id: 'tx_1',
        type: TransactionType.venuePremium,
        productName: 'Venue Premium',
        amount: 9900,
        currency: 'usd',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
        metadata: {'venueName': 'Sports Bar NYC'},
      );

      expect(tx.subtitle, equals('Sports Bar NYC'));
    });

    test('subtitle returns World Cup 2026 for fan pass', () {
      final tx = PaymentTransaction(
        id: 'tx_1',
        type: TransactionType.fanPass,
        productName: 'Fan Pass',
        amount: 1499,
        currency: 'usd',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
        metadata: {'passType': 'fan_pass'},
      );

      expect(tx.subtitle, equals('World Cup 2026'));
    });

    test('subtitle returns null for tip type', () {
      final tx = PaymentTransaction(
        id: 'tx_1',
        type: TransactionType.tip,
        productName: 'Tip',
        amount: 200,
        currency: 'usd',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
      );

      expect(tx.subtitle, isNull);
    });
  });

  group('TransactionType', () {
    test('displayName returns correct names', () {
      expect(TransactionType.fanPass.displayName, equals('Fan Pass'));
      expect(TransactionType.venuePremium.displayName, equals('Venue Premium'));
      expect(
        TransactionType.virtualAttendance.displayName,
        equals('Virtual Attendance'),
      );
      expect(TransactionType.tip.displayName, equals('Tip'));
      expect(TransactionType.ticket.displayName, equals('Ticket'));
    });

    test('icon returns correct icon for each type', () {
      expect(TransactionType.fanPass.icon, equals(Icons.star));
      expect(TransactionType.venuePremium.icon, equals(Icons.store));
      expect(TransactionType.virtualAttendance.icon, equals(Icons.videocam));
      expect(TransactionType.tip.icon, equals(Icons.favorite));
      expect(
        TransactionType.ticket.icon,
        equals(Icons.confirmation_number),
      );
    });

    test('color returns non-null color for each type', () {
      for (final type in TransactionType.values) {
        expect(type.color, isNotNull);
        expect(type.color, isA<Color>());
      }
    });
  });

  group('TransactionStatus', () {
    test('displayName returns correct names', () {
      expect(TransactionStatus.pending.displayName, equals('Pending'));
      expect(TransactionStatus.completed.displayName, equals('Completed'));
      expect(TransactionStatus.failed.displayName, equals('Failed'));
      expect(TransactionStatus.refunded.displayName, equals('Refunded'));
    });

    test('color returns non-null color for each status', () {
      for (final status in TransactionStatus.values) {
        expect(status.color, isNotNull);
        expect(status.color, isA<Color>());
      }
    });
  });

  group('FanPassPurchaseResult', () {
    test('successful result has correct flags', () {
      final result = FanPassPurchaseResult(success: true);

      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.userCancelled, isFalse);
      expect(result.usedFallback, isFalse);
    });

    test('failed result with user cancellation', () {
      final result = FanPassPurchaseResult(
        success: false,
        errorMessage: 'Cancelled by user',
        userCancelled: true,
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Cancelled by user'));
      expect(result.userCancelled, isTrue);
    });

    test('fallback result has usedFallback flag', () {
      final result = FanPassPurchaseResult(
        success: true,
        usedFallback: true,
      );

      expect(result.success, isTrue);
      expect(result.usedFallback, isTrue);
    });
  });

  group('RestorePurchasesResult', () {
    test('successful restore with purchases', () {
      final result = RestorePurchasesResult(
        success: true,
        hasRestoredPurchases: true,
        restoredPassType: FanPassType.superfanPass,
      );

      expect(result.success, isTrue);
      expect(result.hasRestoredPurchases, isTrue);
      expect(result.restoredPassType, equals(FanPassType.superfanPass));
      expect(result.errorMessage, isNull);
    });

    test('successful restore with no purchases', () {
      final result = RestorePurchasesResult(
        success: true,
        hasRestoredPurchases: false,
      );

      expect(result.success, isTrue);
      expect(result.hasRestoredPurchases, isFalse);
      expect(result.restoredPassType, equals(FanPassType.free));
    });

    test('failed restore', () {
      final result = RestorePurchasesResult(
        success: false,
        errorMessage: 'Network error',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Network error'));
    });

    test('restore with fanPass type', () {
      final result = RestorePurchasesResult(
        success: true,
        hasRestoredPurchases: true,
        restoredPassType: FanPassType.fanPass,
      );

      expect(result.restoredPassType, equals(FanPassType.fanPass));
    });
  });

  // ==========================================================================
  // Edge cases and negative tests
  // ==========================================================================

  group('PaymentTransaction - edge cases', () {
    test('displayAmount formats large amounts correctly', () {
      final tx = PaymentTransaction(
        id: 'tx_large',
        type: TransactionType.venuePremium,
        productName: 'Venue Premium',
        amount: 49900,
        currency: 'usd',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
      );

      expect(tx.displayAmount, equals('\$499.00'));
    });

    test('displayAmount uses currency code for non-USD currencies', () {
      final tx = PaymentTransaction(
        id: 'tx_eur',
        type: TransactionType.fanPass,
        productName: 'Fan Pass',
        amount: 1299,
        currency: 'eur',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
      );

      // currency string is used as-is (lowercase) when not USD
      expect(tx.displayAmount, equals('eur12.99'));
    });

    test('displayAmount handles single-digit cent amounts', () {
      final tx = PaymentTransaction(
        id: 'tx_small',
        type: TransactionType.tip,
        productName: 'Tip',
        amount: 5,
        currency: 'usd',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
      );

      expect(tx.displayAmount, equals('\$0.05'));
    });

    test('subtitle returns null when metadata is empty', () {
      final tx = PaymentTransaction(
        id: 'tx_nometa',
        type: TransactionType.venuePremium,
        productName: 'Venue Premium',
        amount: 9900,
        currency: 'usd',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
      );

      expect(tx.subtitle, isNull);
    });

    test('subtitle returns null for ticket type', () {
      final tx = PaymentTransaction(
        id: 'tx_ticket',
        type: TransactionType.ticket,
        productName: 'Ticket',
        amount: 5000,
        currency: 'usd',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
      );

      expect(tx.subtitle, isNull);
    });

    test('metadata defaults to empty map', () {
      final tx = PaymentTransaction(
        id: 'tx_default',
        type: TransactionType.fanPass,
        productName: 'Fan Pass',
        amount: 1499,
        currency: 'usd',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
      );

      expect(tx.metadata, isEmpty);
    });
  });

  group('WorldCupPricing - edge cases', () {
    test('fromMap with partial fanPass data', () {
      final pricing = WorldCupPricing.fromMap({
        'fanPass': {'amount': 999},
      });

      expect(pricing.fanPass.amount, equals(999));
      expect(pricing.fanPass.displayPrice, equals(''));
      expect(pricing.fanPass.name, equals(''));
    });

    test('fromMap with null tournamentDates uses defaults', () {
      final pricing = WorldCupPricing.fromMap({
        'tournamentDates': null,
      });

      // fromMap parses ISO date strings as UTC
      expect(pricing.tournamentStart.year, equals(2026));
      expect(pricing.tournamentStart.month, equals(6));
      expect(pricing.tournamentStart.day, equals(11));
      expect(pricing.tournamentEnd.year, equals(2026));
      expect(pricing.tournamentEnd.month, equals(7));
    });

    test('defaults() venuePremium has correct description', () {
      final pricing = WorldCupPricing.defaults();

      expect(pricing.venuePremium.description, contains('portal'));
    });

    test('defaults() tournament dates span June 11 to July 20', () {
      final pricing = WorldCupPricing.defaults();

      expect(pricing.tournamentStart.month, equals(6));
      expect(pricing.tournamentStart.day, equals(11));
      expect(pricing.tournamentEnd.month, equals(7));
      expect(pricing.tournamentEnd.day, equals(20));
    });
  });

  group('FanPassType - edge cases', () {
    test('fromString handles null-like strings', () {
      expect(FanPassType.fromString('null'), equals(FanPassType.free));
      expect(FanPassType.fromString('undefined'), equals(FanPassType.free));
      expect(FanPassType.fromString('FREE'), equals(FanPassType.free));
    });

    test('values contains exactly 3 types', () {
      expect(FanPassType.values.length, equals(3));
    });

    test('each type has a non-empty displayName', () {
      for (final type in FanPassType.values) {
        expect(type.displayName.isNotEmpty, isTrue);
      }
    });

    test('each type has a non-empty price', () {
      for (final type in FanPassType.values) {
        expect(type.price.isNotEmpty, isTrue);
      }
    });
  });

  group('FanPassStatus - edge cases', () {
    test('hasPass true with free passType is a valid state', () {
      final status = FanPassStatus(
        hasPass: true,
        passType: FanPassType.free,
        features: const {},
      );

      expect(status.hasPass, isTrue);
      expect(status.passType, equals(FanPassType.free));
    });

    test('purchasedAt is preserved correctly', () {
      final purchaseDate = DateTime(2026, 5, 15, 10, 30);
      final status = FanPassStatus(
        hasPass: true,
        passType: FanPassType.fanPass,
        purchasedAt: purchaseDate,
        features: const {},
      );

      expect(status.purchasedAt, equals(purchaseDate));
    });
  });

  group('VenuePremiumStatus - edge cases', () {
    test('partial features map only enables listed features', () {
      final status = VenuePremiumStatus(
        isPremium: true,
        tier: 'premium',
        features: const {
          'matchScheduling': true,
          'analytics': true,
        },
      );

      expect(status.canManageSchedule, isTrue);
      expect(status.hasAnalytics, isTrue);
      expect(status.canSetupTvs, isFalse);
      expect(status.canAddSpecials, isFalse);
      expect(status.hasFeaturedListing, isFalse);
    });

    test('purchasedAt is preserved correctly', () {
      final purchaseDate = DateTime(2026, 4, 1);
      final status = VenuePremiumStatus(
        isPremium: true,
        tier: 'premium',
        purchasedAt: purchaseDate,
        features: const {},
      );

      expect(status.purchasedAt, equals(purchaseDate));
    });
  });

  group('PriceInfo - edge cases', () {
    test('fromMap with zero amount', () {
      final info = PriceInfo.fromMap({
        'amount': 0,
        'displayPrice': 'Free',
        'name': 'Trial',
        'description': 'Free trial',
      });

      expect(info.amount, equals(0));
      expect(info.displayPrice, equals('Free'));
    });

    test('fromMap with extra fields ignores them', () {
      final info = PriceInfo.fromMap({
        'amount': 1000,
        'displayPrice': '\$10.00',
        'name': 'Test',
        'description': 'Desc',
        'extraField': 'ignored',
        'anotherField': 42,
      });

      expect(info.amount, equals(1000));
      expect(info.name, equals('Test'));
    });
  });

  group('FanPassPurchaseResult - edge cases', () {
    test('all defaults are correct', () {
      final result = FanPassPurchaseResult(success: false);

      expect(result.success, isFalse);
      expect(result.errorMessage, isNull);
      expect(result.userCancelled, isFalse);
      expect(result.usedFallback, isFalse);
    });

    test('error with fallback used', () {
      final result = FanPassPurchaseResult(
        success: false,
        errorMessage: 'Primary payment failed',
        usedFallback: true,
      );

      expect(result.success, isFalse);
      expect(result.usedFallback, isTrue);
      expect(result.errorMessage, contains('Primary payment failed'));
    });

    test('success with all flags set', () {
      final result = FanPassPurchaseResult(
        success: true,
        errorMessage: null,
        userCancelled: false,
        usedFallback: true,
      );

      expect(result.success, isTrue);
      expect(result.usedFallback, isTrue);
      expect(result.userCancelled, isFalse);
    });
  });
}
