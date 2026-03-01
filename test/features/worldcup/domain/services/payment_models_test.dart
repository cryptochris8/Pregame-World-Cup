import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/services/payment_models.dart';

void main() {
  // ============================================================================
  // FanPassType enum
  // ============================================================================
  group('FanPassType', () {
    group('values', () {
      test('has three enum values', () {
        expect(FanPassType.values.length, 3);
      });

      test('value property returns correct string for each type', () {
        expect(FanPassType.free.value, 'free');
        expect(FanPassType.fanPass.value, 'fan_pass');
        expect(FanPassType.superfanPass.value, 'superfan_pass');
      });
    });

    group('fromString', () {
      test('returns fanPass for "fan_pass"', () {
        expect(FanPassType.fromString('fan_pass'), FanPassType.fanPass);
      });

      test('returns superfanPass for "superfan_pass"', () {
        expect(
            FanPassType.fromString('superfan_pass'), FanPassType.superfanPass);
      });

      test('returns free for "free"', () {
        expect(FanPassType.fromString('free'), FanPassType.free);
      });

      test('returns free for unknown string', () {
        expect(FanPassType.fromString(''), FanPassType.free);
        expect(FanPassType.fromString('unknown'), FanPassType.free);
        expect(FanPassType.fromString('premium'), FanPassType.free);
        expect(FanPassType.fromString('FAN_PASS'), FanPassType.free);
      });

      test('returns free for null-like edge cases', () {
        expect(FanPassType.fromString('null'), FanPassType.free);
        expect(FanPassType.fromString(' '), FanPassType.free);
      });
    });

    group('displayName', () {
      test('returns human-readable names', () {
        expect(FanPassType.free.displayName, 'Free');
        expect(FanPassType.fanPass.displayName, 'Fan Pass');
        expect(FanPassType.superfanPass.displayName, 'Superfan Pass');
      });
    });

    group('price', () {
      test('free returns "Free"', () {
        expect(FanPassType.free.price, 'Free');
      });

      test('fanPass returns \$14.99', () {
        expect(FanPassType.fanPass.price, '\$14.99');
      });

      test('superfanPass returns \$29.99', () {
        expect(FanPassType.superfanPass.price, '\$29.99');
      });
    });
  });

  // ============================================================================
  // FanPassStatus
  // ============================================================================
  group('FanPassStatus', () {
    group('constructor', () {
      test('creates with required fields and empty features', () {
        final status = FanPassStatus(
          hasPass: true,
          passType: FanPassType.fanPass,
        );
        expect(status.hasPass, true);
        expect(status.passType, FanPassType.fanPass);
        expect(status.purchasedAt, isNull);
        expect(status.features, isEmpty);
      });

      test('creates with all fields', () {
        final now = DateTime.now();
        final features = {'adFree': true, 'advancedStats': true};
        final status = FanPassStatus(
          hasPass: true,
          passType: FanPassType.superfanPass,
          purchasedAt: now,
          features: features,
        );
        expect(status.hasPass, true);
        expect(status.passType, FanPassType.superfanPass);
        expect(status.purchasedAt, now);
        expect(status.features, features);
      });
    });

    group('free factory', () {
      test('returns status with hasPass false', () {
        final status = FanPassStatus.free();
        expect(status.hasPass, false);
      });

      test('returns status with free pass type', () {
        final status = FanPassStatus.free();
        expect(status.passType, FanPassType.free);
      });

      test('has no purchasedAt date', () {
        final status = FanPassStatus.free();
        expect(status.purchasedAt, isNull);
      });

      test('has default free features with basic features enabled', () {
        final status = FanPassStatus.free();
        expect(status.features['basicSchedules'], true);
        expect(status.features['venueDiscovery'], true);
        expect(status.features['matchNotifications'], true);
        expect(status.features['basicTeamFollowing'], true);
        expect(status.features['communityAccess'], true);
      });

      test('has default free features with premium features disabled', () {
        final status = FanPassStatus.free();
        expect(status.features['adFree'], false);
        expect(status.features['advancedStats'], false);
        expect(status.features['customAlerts'], false);
        expect(status.features['advancedSocialFeatures'], false);
        expect(status.features['exclusiveContent'], false);
        expect(status.features['priorityFeatures'], false);
        expect(status.features['aiMatchInsights'], false);
        expect(status.features['downloadableContent'], false);
      });
    });

    group('feature accessors', () {
      test('return false when features map is empty', () {
        final status = FanPassStatus(
          hasPass: false,
          passType: FanPassType.free,
        );
        expect(status.hasAdFree, false);
        expect(status.hasAdvancedStats, false);
        expect(status.hasCustomAlerts, false);
        expect(status.hasAdvancedSocialFeatures, false);
        expect(status.hasExclusiveContent, false);
        expect(status.hasPriorityFeatures, false);
        expect(status.hasAiMatchInsights, false);
      });

      test('return true when corresponding feature is enabled', () {
        final status = FanPassStatus(
          hasPass: true,
          passType: FanPassType.superfanPass,
          features: {
            'adFree': true,
            'advancedStats': true,
            'customAlerts': true,
            'advancedSocialFeatures': true,
            'exclusiveContent': true,
            'priorityFeatures': true,
            'aiMatchInsights': true,
          },
        );
        expect(status.hasAdFree, true);
        expect(status.hasAdvancedStats, true);
        expect(status.hasCustomAlerts, true);
        expect(status.hasAdvancedSocialFeatures, true);
        expect(status.hasExclusiveContent, true);
        expect(status.hasPriorityFeatures, true);
        expect(status.hasAiMatchInsights, true);
      });

      test('return false for explicitly disabled features', () {
        final status = FanPassStatus(
          hasPass: true,
          passType: FanPassType.fanPass,
          features: {
            'adFree': true,
            'advancedStats': false,
            'exclusiveContent': false,
          },
        );
        expect(status.hasAdFree, true);
        expect(status.hasAdvancedStats, false);
        expect(status.hasExclusiveContent, false);
      });

      test('return false from free factory for premium accessors', () {
        final status = FanPassStatus.free();
        expect(status.hasAdFree, false);
        expect(status.hasAdvancedStats, false);
        expect(status.hasCustomAlerts, false);
        expect(status.hasAdvancedSocialFeatures, false);
        expect(status.hasExclusiveContent, false);
        expect(status.hasPriorityFeatures, false);
        expect(status.hasAiMatchInsights, false);
      });
    });
  });

  // ============================================================================
  // VenuePremiumStatus
  // ============================================================================
  group('VenuePremiumStatus', () {
    group('constructor', () {
      test('creates with required fields and empty features', () {
        final status = VenuePremiumStatus(
          isPremium: true,
          tier: 'premium',
        );
        expect(status.isPremium, true);
        expect(status.tier, 'premium');
        expect(status.purchasedAt, isNull);
        expect(status.features, isEmpty);
      });

      test('creates with all fields', () {
        final now = DateTime.now();
        final features = {'matchScheduling': true, 'tvSetup': true};
        final status = VenuePremiumStatus(
          isPremium: true,
          tier: 'premium',
          purchasedAt: now,
          features: features,
        );
        expect(status.isPremium, true);
        expect(status.tier, 'premium');
        expect(status.purchasedAt, now);
        expect(status.features, features);
      });
    });

    group('free factory', () {
      test('returns status with isPremium false', () {
        final status = VenuePremiumStatus.free();
        expect(status.isPremium, false);
      });

      test('returns status with "free" tier', () {
        final status = VenuePremiumStatus.free();
        expect(status.tier, 'free');
      });

      test('has no purchasedAt date', () {
        final status = VenuePremiumStatus.free();
        expect(status.purchasedAt, isNull);
      });

      test('has showsMatches enabled', () {
        final status = VenuePremiumStatus.free();
        expect(status.features['showsMatches'], true);
      });

      test('has all premium features disabled', () {
        final status = VenuePremiumStatus.free();
        expect(status.features['matchScheduling'], false);
        expect(status.features['tvSetup'], false);
        expect(status.features['gameSpecials'], false);
        expect(status.features['atmosphereSettings'], false);
        expect(status.features['liveCapacity'], false);
        expect(status.features['featuredListing'], false);
        expect(status.features['analytics'], false);
      });
    });

    group('feature accessors', () {
      test('return false when features map is empty', () {
        final status = VenuePremiumStatus(
          isPremium: false,
          tier: 'free',
        );
        expect(status.canManageSchedule, false);
        expect(status.canSetupTvs, false);
        expect(status.canAddSpecials, false);
        expect(status.canSetAtmosphere, false);
        expect(status.canUpdateCapacity, false);
        expect(status.hasFeaturedListing, false);
        expect(status.hasAnalytics, false);
      });

      test('return true when corresponding feature is enabled', () {
        final status = VenuePremiumStatus(
          isPremium: true,
          tier: 'premium',
          features: {
            'matchScheduling': true,
            'tvSetup': true,
            'gameSpecials': true,
            'atmosphereSettings': true,
            'liveCapacity': true,
            'featuredListing': true,
            'analytics': true,
          },
        );
        expect(status.canManageSchedule, true);
        expect(status.canSetupTvs, true);
        expect(status.canAddSpecials, true);
        expect(status.canSetAtmosphere, true);
        expect(status.canUpdateCapacity, true);
        expect(status.hasFeaturedListing, true);
        expect(status.hasAnalytics, true);
      });

      test('return correct values from free factory', () {
        final status = VenuePremiumStatus.free();
        expect(status.canManageSchedule, false);
        expect(status.canSetupTvs, false);
        expect(status.canAddSpecials, false);
        expect(status.canSetAtmosphere, false);
        expect(status.canUpdateCapacity, false);
        expect(status.hasFeaturedListing, false);
        expect(status.hasAnalytics, false);
      });
    });
  });

  // ============================================================================
  // PriceInfo
  // ============================================================================
  group('PriceInfo', () {
    group('constructor', () {
      test('creates with required fields', () {
        final info = PriceInfo(
          amount: 1499,
          displayPrice: '\$14.99',
          name: 'Fan Pass',
          description: 'Premium features',
        );
        expect(info.amount, 1499);
        expect(info.displayPrice, '\$14.99');
        expect(info.name, 'Fan Pass');
        expect(info.description, 'Premium features');
      });
    });

    group('fromMap', () {
      test('parses complete map', () {
        final info = PriceInfo.fromMap({
          'amount': 2999,
          'displayPrice': '\$29.99',
          'name': 'Superfan Pass',
          'description': 'All features included',
        });
        expect(info.amount, 2999);
        expect(info.displayPrice, '\$29.99');
        expect(info.name, 'Superfan Pass');
        expect(info.description, 'All features included');
      });

      test('uses defaults for missing fields', () {
        final info = PriceInfo.fromMap({});
        expect(info.amount, 0);
        expect(info.displayPrice, '');
        expect(info.name, '');
        expect(info.description, '');
      });

      test('handles partial map', () {
        final info = PriceInfo.fromMap({
          'amount': 500,
          'name': 'Test',
        });
        expect(info.amount, 500);
        expect(info.name, 'Test');
        expect(info.displayPrice, '');
        expect(info.description, '');
      });
    });
  });

  // ============================================================================
  // WorldCupPricing
  // ============================================================================
  group('WorldCupPricing', () {
    group('defaults factory', () {
      late WorldCupPricing pricing;

      setUp(() {
        pricing = WorldCupPricing.defaults();
      });

      test('has correct fan pass pricing', () {
        expect(pricing.fanPass.amount, 1499);
        expect(pricing.fanPass.displayPrice, '\$14.99');
        expect(pricing.fanPass.name, 'Fan Pass');
      });

      test('has correct superfan pass pricing', () {
        expect(pricing.superfanPass.amount, 2999);
        expect(pricing.superfanPass.displayPrice, '\$29.99');
        expect(pricing.superfanPass.name, 'Superfan Pass');
      });

      test('has correct venue premium pricing', () {
        expect(pricing.venuePremium.amount, 49900);
        expect(pricing.venuePremium.displayPrice, '\$499.00');
        expect(pricing.venuePremium.name, 'Venue Premium');
      });

      test('has correct tournament dates', () {
        expect(pricing.tournamentStart, DateTime(2026, 6, 11));
        expect(pricing.tournamentEnd, DateTime(2026, 7, 20));
      });

      test('fan pass description mentions key features', () {
        expect(pricing.fanPass.description, contains('Ad-free'));
        expect(pricing.fanPass.description, contains('advanced stats'));
      });

      test('superfan pass description mentions exclusive content', () {
        expect(pricing.superfanPass.description, contains('exclusive content'));
        expect(pricing.superfanPass.description, contains('AI insights'));
      });

      test('venue premium description mentions portal features', () {
        expect(pricing.venuePremium.description, contains('TV setup'));
        expect(pricing.venuePremium.description, contains('featured listing'));
      });
    });

    group('fromMap', () {
      test('parses complete map', () {
        final pricing = WorldCupPricing.fromMap({
          'fanPass': {
            'amount': 1499,
            'displayPrice': '\$14.99',
            'name': 'Fan Pass',
            'description': 'Basic premium',
          },
          'superfanPass': {
            'amount': 2999,
            'displayPrice': '\$29.99',
            'name': 'Superfan',
            'description': 'Full premium',
          },
          'venuePremium': {
            'amount': 49900,
            'displayPrice': '\$499.00',
            'name': 'Venue',
            'description': 'Venue premium',
          },
          'tournamentDates': {
            'start': '2026-06-11T00:00:00Z',
            'end': '2026-07-20T23:59:59Z',
          },
        });
        expect(pricing.fanPass.amount, 1499);
        expect(pricing.superfanPass.amount, 2999);
        expect(pricing.venuePremium.amount, 49900);
        expect(pricing.tournamentStart.year, 2026);
        expect(pricing.tournamentStart.month, 6);
        expect(pricing.tournamentStart.day, 11);
        expect(pricing.tournamentEnd.month, 7);
        expect(pricing.tournamentEnd.day, 20);
      });

      test('uses defaults for empty map', () {
        final pricing = WorldCupPricing.fromMap({});
        expect(pricing.fanPass.amount, 0);
        expect(pricing.superfanPass.amount, 0);
        expect(pricing.venuePremium.amount, 0);
        // Default dates from the code
        expect(pricing.tournamentStart.year, 2026);
        expect(pricing.tournamentStart.month, 6);
        expect(pricing.tournamentStart.day, 11);
        expect(pricing.tournamentEnd.year, 2026);
        expect(pricing.tournamentEnd.month, 7);
        expect(pricing.tournamentEnd.day, 20);
      });

      test('uses default dates when tournamentDates is null', () {
        final pricing = WorldCupPricing.fromMap({
          'fanPass': {'amount': 100},
        });
        expect(pricing.tournamentStart.year, 2026);
        expect(pricing.tournamentEnd.year, 2026);
      });

      test('handles partial tournamentDates', () {
        final pricing = WorldCupPricing.fromMap({
          'tournamentDates': {
            'start': '2026-06-15T12:00:00Z',
          },
        });
        expect(pricing.tournamentStart.month, 6);
        expect(pricing.tournamentStart.day, 15);
        // end should use default
        expect(pricing.tournamentEnd.month, 7);
        expect(pricing.tournamentEnd.day, 20);
      });
    });
  });

  // ============================================================================
  // TransactionType enum
  // ============================================================================
  group('TransactionType', () {
    test('has five enum values', () {
      expect(TransactionType.values.length, 5);
    });

    group('displayName', () {
      test('returns correct names', () {
        expect(TransactionType.fanPass.displayName, 'Fan Pass');
        expect(TransactionType.venuePremium.displayName, 'Venue Premium');
        expect(TransactionType.virtualAttendance.displayName,
            'Virtual Attendance');
        expect(TransactionType.tip.displayName, 'Tip');
        expect(TransactionType.ticket.displayName, 'Ticket');
      });
    });

    group('icon', () {
      test('returns an IconData for each type', () {
        for (final type in TransactionType.values) {
          expect(type.icon, isA<IconData>());
        }
      });

      test('returns specific icons', () {
        expect(TransactionType.fanPass.icon, Icons.star);
        expect(TransactionType.venuePremium.icon, Icons.store);
        expect(TransactionType.virtualAttendance.icon, Icons.videocam);
        expect(TransactionType.tip.icon, Icons.favorite);
        expect(TransactionType.ticket.icon, Icons.confirmation_number);
      });
    });

    group('color', () {
      test('returns a Color for each type', () {
        for (final type in TransactionType.values) {
          expect(type.color, isA<Color>());
        }
      });

      test('returns distinct colors', () {
        final colors = TransactionType.values.map((t) => t.color).toSet();
        expect(colors.length, TransactionType.values.length);
      });

      test('returns correct specific colors', () {
        expect(TransactionType.fanPass.color, const Color(0xFFFFB300));
        expect(TransactionType.venuePremium.color, const Color(0xFF7C4DFF));
        expect(
            TransactionType.virtualAttendance.color, const Color(0xFF00BCD4));
        expect(TransactionType.tip.color, const Color(0xFFE91E63));
        expect(TransactionType.ticket.color, const Color(0xFF4CAF50));
      });
    });
  });

  // ============================================================================
  // TransactionStatus enum
  // ============================================================================
  group('TransactionStatus', () {
    test('has four enum values', () {
      expect(TransactionStatus.values.length, 4);
    });

    group('displayName', () {
      test('returns correct names', () {
        expect(TransactionStatus.pending.displayName, 'Pending');
        expect(TransactionStatus.completed.displayName, 'Completed');
        expect(TransactionStatus.failed.displayName, 'Failed');
        expect(TransactionStatus.refunded.displayName, 'Refunded');
      });
    });

    group('color', () {
      test('returns a Color for each status', () {
        for (final status in TransactionStatus.values) {
          expect(status.color, isA<Color>());
        }
      });

      test('returns correct specific colors', () {
        expect(TransactionStatus.pending.color, const Color(0xFFFFA000));
        expect(TransactionStatus.completed.color, const Color(0xFF4CAF50));
        expect(TransactionStatus.failed.color, const Color(0xFFF44336));
        expect(TransactionStatus.refunded.color, const Color(0xFF9E9E9E));
      });

      test('uses semantic colors (green=success, red=failure, etc.)', () {
        // Completed should be greenish
        expect(TransactionStatus.completed.color.green, greaterThan(150));
        // Failed should be reddish
        expect(TransactionStatus.failed.color.red, greaterThan(200));
      });
    });
  });

  // ============================================================================
  // PaymentTransaction
  // ============================================================================
  group('PaymentTransaction', () {
    late PaymentTransaction transaction;

    setUp(() {
      transaction = PaymentTransaction(
        id: 'txn_001',
        type: TransactionType.fanPass,
        productName: 'Fan Pass',
        amount: 1499,
        currency: 'USD',
        status: TransactionStatus.completed,
        createdAt: DateTime(2026, 3, 1),
      );
    });

    group('constructor', () {
      test('creates with required fields', () {
        expect(transaction.id, 'txn_001');
        expect(transaction.type, TransactionType.fanPass);
        expect(transaction.productName, 'Fan Pass');
        expect(transaction.amount, 1499);
        expect(transaction.currency, 'USD');
        expect(transaction.status, TransactionStatus.completed);
        expect(transaction.createdAt, DateTime(2026, 3, 1));
        expect(transaction.metadata, isEmpty);
      });

      test('creates with metadata', () {
        final tx = PaymentTransaction(
          id: 'txn_002',
          type: TransactionType.venuePremium,
          productName: 'Venue Premium',
          amount: 49900,
          currency: 'USD',
          status: TransactionStatus.pending,
          createdAt: DateTime(2026, 3, 1),
          metadata: {'venueName': 'Sports Bar XYZ'},
        );
        expect(tx.metadata['venueName'], 'Sports Bar XYZ');
      });
    });

    group('displayAmount', () {
      test('formats USD amount correctly', () {
        expect(transaction.displayAmount, '\$14.99');
      });

      test('formats large amounts correctly', () {
        final tx = PaymentTransaction(
          id: 'txn_003',
          type: TransactionType.venuePremium,
          productName: 'Venue Premium',
          amount: 49900,
          currency: 'USD',
          status: TransactionStatus.completed,
          createdAt: DateTime(2026, 3, 1),
        );
        expect(tx.displayAmount, '\$499.00');
      });

      test('formats zero amount correctly', () {
        final tx = PaymentTransaction(
          id: 'txn_004',
          type: TransactionType.fanPass,
          productName: 'Free',
          amount: 0,
          currency: 'USD',
          status: TransactionStatus.completed,
          createdAt: DateTime(2026, 3, 1),
        );
        expect(tx.displayAmount, '\$0.00');
      });

      test('uses currency code for non-USD currencies', () {
        final tx = PaymentTransaction(
          id: 'txn_005',
          type: TransactionType.fanPass,
          productName: 'Fan Pass',
          amount: 1299,
          currency: 'EUR',
          status: TransactionStatus.completed,
          createdAt: DateTime(2026, 3, 1),
        );
        expect(tx.displayAmount, 'EUR12.99');
      });

      test('handles lowercase currency for USD', () {
        final tx = PaymentTransaction(
          id: 'txn_006',
          type: TransactionType.fanPass,
          productName: 'Fan Pass',
          amount: 1499,
          currency: 'usd',
          status: TransactionStatus.completed,
          createdAt: DateTime(2026, 3, 1),
        );
        expect(tx.displayAmount, '\$14.99');
      });

      test('formats single cent amounts', () {
        final tx = PaymentTransaction(
          id: 'txn_007',
          type: TransactionType.tip,
          productName: 'Tip',
          amount: 1,
          currency: 'USD',
          status: TransactionStatus.completed,
          createdAt: DateTime(2026, 3, 1),
        );
        expect(tx.displayAmount, '\$0.01');
      });
    });

    group('subtitle', () {
      test('returns watch party name for virtualAttendance', () {
        final tx = PaymentTransaction(
          id: 'txn_va',
          type: TransactionType.virtualAttendance,
          productName: 'Virtual Attendance',
          amount: 500,
          currency: 'USD',
          status: TransactionStatus.completed,
          createdAt: DateTime(2026, 3, 1),
          metadata: {'watchPartyName': 'Brazil vs Argentina Watch Party'},
        );
        expect(tx.subtitle, 'Brazil vs Argentina Watch Party');
      });

      test('returns venue name for venuePremium', () {
        final tx = PaymentTransaction(
          id: 'txn_vp',
          type: TransactionType.venuePremium,
          productName: 'Venue Premium',
          amount: 49900,
          currency: 'USD',
          status: TransactionStatus.completed,
          createdAt: DateTime(2026, 3, 1),
          metadata: {'venueName': 'The Sports Corner'},
        );
        expect(tx.subtitle, 'The Sports Corner');
      });

      test('returns "World Cup 2026" for fanPass', () {
        final tx = PaymentTransaction(
          id: 'txn_fp',
          type: TransactionType.fanPass,
          productName: 'Fan Pass',
          amount: 1499,
          currency: 'USD',
          status: TransactionStatus.completed,
          createdAt: DateTime(2026, 3, 1),
          metadata: {'passType': 'fan_pass'},
        );
        expect(tx.subtitle, 'World Cup 2026');
      });

      test('returns "World Cup 2026" for superfan fanPass', () {
        final tx = PaymentTransaction(
          id: 'txn_sfp',
          type: TransactionType.fanPass,
          productName: 'Superfan Pass',
          amount: 2999,
          currency: 'USD',
          status: TransactionStatus.completed,
          createdAt: DateTime(2026, 3, 1),
          metadata: {'passType': 'superfan_pass'},
        );
        expect(tx.subtitle, 'World Cup 2026');
      });

      test('returns null for tip type', () {
        final tx = PaymentTransaction(
          id: 'txn_tip',
          type: TransactionType.tip,
          productName: 'Tip',
          amount: 300,
          currency: 'USD',
          status: TransactionStatus.completed,
          createdAt: DateTime(2026, 3, 1),
        );
        expect(tx.subtitle, isNull);
      });

      test('returns null for ticket type', () {
        final tx = PaymentTransaction(
          id: 'txn_tkt',
          type: TransactionType.ticket,
          productName: 'Match Ticket',
          amount: 15000,
          currency: 'USD',
          status: TransactionStatus.completed,
          createdAt: DateTime(2026, 3, 1),
        );
        expect(tx.subtitle, isNull);
      });

      test('returns null when metadata is missing expected key', () {
        final tx = PaymentTransaction(
          id: 'txn_va2',
          type: TransactionType.virtualAttendance,
          productName: 'Virtual Attendance',
          amount: 500,
          currency: 'USD',
          status: TransactionStatus.completed,
          createdAt: DateTime(2026, 3, 1),
        );
        expect(tx.subtitle, isNull);
      });

      test(
          'returns "World Cup 2026" for fanPass even without passType in metadata',
          () {
        final tx = PaymentTransaction(
          id: 'txn_fp2',
          type: TransactionType.fanPass,
          productName: 'Fan Pass',
          amount: 1499,
          currency: 'USD',
          status: TransactionStatus.completed,
          createdAt: DateTime(2026, 3, 1),
        );
        // passType is null so the condition `passType == 'superfan_pass'` is false,
        // falls through to return 'World Cup 2026'
        expect(tx.subtitle, 'World Cup 2026');
      });
    });
  });

  // ============================================================================
  // FanPassPurchaseResult
  // ============================================================================
  group('FanPassPurchaseResult', () {
    test('creates successful result', () {
      final result = FanPassPurchaseResult(success: true);
      expect(result.success, true);
      expect(result.errorMessage, isNull);
      expect(result.userCancelled, false);
      expect(result.usedFallback, false);
    });

    test('creates failed result with error message', () {
      final result = FanPassPurchaseResult(
        success: false,
        errorMessage: 'Payment declined',
      );
      expect(result.success, false);
      expect(result.errorMessage, 'Payment declined');
    });

    test('creates user cancelled result', () {
      final result = FanPassPurchaseResult(
        success: false,
        userCancelled: true,
      );
      expect(result.success, false);
      expect(result.userCancelled, true);
    });

    test('creates fallback result', () {
      final result = FanPassPurchaseResult(
        success: true,
        usedFallback: true,
      );
      expect(result.success, true);
      expect(result.usedFallback, true);
    });
  });

  // ============================================================================
  // RestorePurchasesResult
  // ============================================================================
  group('RestorePurchasesResult', () {
    test('creates successful result with restored purchases', () {
      final result = RestorePurchasesResult(
        success: true,
        hasRestoredPurchases: true,
        restoredPassType: FanPassType.superfanPass,
      );
      expect(result.success, true);
      expect(result.hasRestoredPurchases, true);
      expect(result.restoredPassType, FanPassType.superfanPass);
      expect(result.errorMessage, isNull);
    });

    test('creates successful result with no restored purchases', () {
      final result = RestorePurchasesResult(
        success: true,
        hasRestoredPurchases: false,
      );
      expect(result.success, true);
      expect(result.hasRestoredPurchases, false);
      expect(result.restoredPassType, FanPassType.free);
    });

    test('defaults to no restored purchases and free pass type', () {
      final result = RestorePurchasesResult(success: true);
      expect(result.hasRestoredPurchases, false);
      expect(result.restoredPassType, FanPassType.free);
    });

    test('creates failed result with error message', () {
      final result = RestorePurchasesResult(
        success: false,
        errorMessage: 'Network error',
      );
      expect(result.success, false);
      expect(result.errorMessage, 'Network error');
    });
  });
}
