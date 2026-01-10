import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/subscription_tier.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/tv_setup.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/live_capacity.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/game_day_special.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/atmosphere_settings.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/broadcasting_schedule.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/venue_enhancement.dart';

void main() {
  group('SubscriptionTier', () {
    test('has expected values', () {
      expect(SubscriptionTier.values, hasLength(2));
      expect(SubscriptionTier.values, contains(SubscriptionTier.free));
      expect(SubscriptionTier.values, contains(SubscriptionTier.premium));
    });

    test('displayName returns correct strings', () {
      expect(SubscriptionTier.free.displayName, equals('Free'));
      expect(SubscriptionTier.premium.displayName, equals('Premium'));
    });

    test('fromString parses values correctly', () {
      expect(SubscriptionTier.fromString('premium'), equals(SubscriptionTier.premium));
      expect(SubscriptionTier.fromString('PREMIUM'), equals(SubscriptionTier.premium));
      expect(SubscriptionTier.fromString('free'), equals(SubscriptionTier.free));
      expect(SubscriptionTier.fromString(null), equals(SubscriptionTier.free));
      expect(SubscriptionTier.fromString('invalid'), equals(SubscriptionTier.free));
    });

    test('toJson returns correct string', () {
      expect(SubscriptionTier.free.toJson(), equals('free'));
      expect(SubscriptionTier.premium.toJson(), equals('premium'));
    });
  });

  group('AudioSetup', () {
    test('has expected values', () {
      expect(AudioSetup.values, hasLength(3));
      expect(AudioSetup.values, contains(AudioSetup.dedicated));
      expect(AudioSetup.values, contains(AudioSetup.shared));
      expect(AudioSetup.values, contains(AudioSetup.headphonesAvailable));
    });

    test('displayName returns correct strings', () {
      expect(AudioSetup.dedicated.displayName, equals('Dedicated Audio'));
      expect(AudioSetup.shared.displayName, equals('Shared Audio'));
      expect(AudioSetup.headphonesAvailable.displayName, equals('Headphones Available'));
    });

    test('fromString parses values correctly', () {
      expect(AudioSetup.fromString('dedicated'), equals(AudioSetup.dedicated));
      expect(AudioSetup.fromString('shared'), equals(AudioSetup.shared));
      expect(AudioSetup.fromString('headphones_available'), equals(AudioSetup.headphonesAvailable));
      expect(AudioSetup.fromString('headphonesavailable'), equals(AudioSetup.headphonesAvailable));
      expect(AudioSetup.fromString(null), equals(AudioSetup.shared));
      expect(AudioSetup.fromString('invalid'), equals(AudioSetup.shared));
    });

    test('toJson returns correct strings', () {
      expect(AudioSetup.dedicated.toJson(), equals('dedicated'));
      expect(AudioSetup.shared.toJson(), equals('shared'));
      expect(AudioSetup.headphonesAvailable.toJson(), equals('headphones_available'));
    });
  });

  group('ScreenDetail', () {
    test('creates screen detail with required fields', () {
      const screen = ScreenDetail(
        id: 'screen_1',
        size: '55"',
        location: 'main bar',
      );

      expect(screen.id, equals('screen_1'));
      expect(screen.size, equals('55"'));
      expect(screen.location, equals('main bar'));
      expect(screen.hasAudio, isFalse);
      expect(screen.isPrimary, isFalse);
    });

    test('creates screen detail with optional fields', () {
      const screen = ScreenDetail(
        id: 'screen_1',
        size: '75"',
        location: 'patio',
        hasAudio: true,
        isPrimary: true,
      );

      expect(screen.hasAudio, isTrue);
      expect(screen.isPrimary, isTrue);
    });

    test('copyWith updates fields correctly', () {
      const original = ScreenDetail(
        id: 'screen_1',
        size: '55"',
        location: 'main bar',
      );
      final updated = original.copyWith(
        size: '65"',
        hasAudio: true,
      );

      expect(updated.id, equals('screen_1'));
      expect(updated.size, equals('65"'));
      expect(updated.location, equals('main bar'));
      expect(updated.hasAudio, isTrue);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'screen_1',
        'size': '75"',
        'location': 'private room',
        'hasAudio': true,
        'isPrimary': true,
      };

      final screen = ScreenDetail.fromJson(json);

      expect(screen.id, equals('screen_1'));
      expect(screen.size, equals('75"'));
      expect(screen.location, equals('private room'));
      expect(screen.hasAudio, isTrue);
      expect(screen.isPrimary, isTrue);
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};
      final screen = ScreenDetail.fromJson(json);

      expect(screen.size, isEmpty);
      expect(screen.location, isEmpty);
      expect(screen.hasAudio, isFalse);
      expect(screen.isPrimary, isFalse);
    });

    test('toJson serializes correctly', () {
      const screen = ScreenDetail(
        id: 'screen_1',
        size: '55"',
        location: 'bar',
        hasAudio: true,
        isPrimary: false,
      );
      final json = screen.toJson();

      expect(json['id'], equals('screen_1'));
      expect(json['size'], equals('55"'));
      expect(json['location'], equals('bar'));
      expect(json['hasAudio'], isTrue);
      expect(json['isPrimary'], isFalse);
    });

    test('roundtrip serialization preserves data', () {
      const original = ScreenDetail(
        id: 'screen_test',
        size: '85"',
        location: 'VIP area',
        hasAudio: true,
        isPrimary: true,
      );
      final json = original.toJson();
      final restored = ScreenDetail.fromJson(json);

      expect(restored, equals(original));
    });

    test('Equatable compares correctly', () {
      const screen1 = ScreenDetail(
        id: 'screen_1',
        size: '55"',
        location: 'bar',
      );
      const screen2 = ScreenDetail(
        id: 'screen_1',
        size: '55"',
        location: 'bar',
      );
      const screen3 = ScreenDetail(
        id: 'screen_2',
        size: '55"',
        location: 'bar',
      );

      expect(screen1, equals(screen2));
      expect(screen1, isNot(equals(screen3)));
    });
  });

  group('TvSetup', () {
    test('creates tv setup with default values', () {
      const setup = TvSetup();

      expect(setup.totalScreens, equals(0));
      expect(setup.screenDetails, isEmpty);
      expect(setup.audioSetup, equals(AudioSetup.shared));
    });

    test('creates tv setup with custom values', () {
      const setup = TvSetup(
        totalScreens: 5,
        screenDetails: [
          ScreenDetail(id: 's1', size: '55"', location: 'bar'),
        ],
        audioSetup: AudioSetup.dedicated,
      );

      expect(setup.totalScreens, equals(5));
      expect(setup.screenDetails, hasLength(1));
      expect(setup.audioSetup, equals(AudioSetup.dedicated));
    });

    test('empty factory creates empty setup', () {
      final setup = TvSetup.empty();

      expect(setup.totalScreens, equals(0));
      expect(setup.hasScreens, isFalse);
    });

    test('hasScreens returns correct value', () {
      const hasScreens = TvSetup(totalScreens: 3);
      const noScreens = TvSetup(totalScreens: 0);

      expect(hasScreens.hasScreens, isTrue);
      expect(noScreens.hasScreens, isFalse);
    });

    test('primaryScreen returns primary or first screen', () {
      const setupWithPrimary = TvSetup(
        totalScreens: 2,
        screenDetails: [
          ScreenDetail(id: 's1', size: '55"', location: 'bar'),
          ScreenDetail(id: 's2', size: '75"', location: 'patio', isPrimary: true),
        ],
      );
      const setupWithoutPrimary = TvSetup(
        totalScreens: 2,
        screenDetails: [
          ScreenDetail(id: 's1', size: '55"', location: 'bar'),
          ScreenDetail(id: 's2', size: '65"', location: 'patio'),
        ],
      );
      const emptySetup = TvSetup();

      expect(setupWithPrimary.primaryScreen?.id, equals('s2'));
      expect(setupWithoutPrimary.primaryScreen?.id, equals('s1'));
      expect(emptySetup.primaryScreen, isNull);
    });

    test('copyWith updates fields correctly', () {
      const original = TvSetup(
        totalScreens: 3,
        audioSetup: AudioSetup.shared,
      );
      final updated = original.copyWith(
        totalScreens: 5,
        audioSetup: AudioSetup.dedicated,
      );

      expect(updated.totalScreens, equals(5));
      expect(updated.audioSetup, equals(AudioSetup.dedicated));
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'totalScreens': 3,
        'screenDetails': [
          {'id': 's1', 'size': '55"', 'location': 'bar'},
        ],
        'audioSetup': 'dedicated',
      };

      final setup = TvSetup.fromJson(json);

      expect(setup.totalScreens, equals(3));
      expect(setup.screenDetails, hasLength(1));
      expect(setup.audioSetup, equals(AudioSetup.dedicated));
    });

    test('toJson serializes correctly', () {
      const setup = TvSetup(
        totalScreens: 2,
        screenDetails: [
          ScreenDetail(id: 's1', size: '55"', location: 'bar'),
        ],
        audioSetup: AudioSetup.headphonesAvailable,
      );
      final json = setup.toJson();

      expect(json['totalScreens'], equals(2));
      expect(json['screenDetails'], hasLength(1));
      expect(json['audioSetup'], equals('headphones_available'));
    });

    test('roundtrip serialization preserves data', () {
      const original = TvSetup(
        totalScreens: 4,
        screenDetails: [
          ScreenDetail(id: 's1', size: '55"', location: 'bar', hasAudio: true),
          ScreenDetail(id: 's2', size: '75"', location: 'patio', isPrimary: true),
        ],
        audioSetup: AudioSetup.dedicated,
      );
      final json = original.toJson();
      final restored = TvSetup.fromJson(json);

      expect(restored.totalScreens, equals(original.totalScreens));
      expect(restored.screenDetails.length, equals(original.screenDetails.length));
      expect(restored.audioSetup, equals(original.audioSetup));
    });
  });

  group('LiveCapacity', () {
    final now = DateTime(2024, 10, 15, 12, 0, 0);

    test('creates live capacity with required fields', () {
      final capacity = LiveCapacity(
        maxCapacity: 100,
        lastUpdated: now,
      );

      expect(capacity.currentOccupancy, equals(0));
      expect(capacity.maxCapacity, equals(100));
      expect(capacity.lastUpdated, equals(now));
      expect(capacity.reservationsAvailable, isTrue);
      expect(capacity.waitTimeMinutes, isNull);
    });

    test('creates live capacity with optional fields', () {
      final capacity = LiveCapacity(
        currentOccupancy: 75,
        maxCapacity: 100,
        lastUpdated: now,
        reservationsAvailable: false,
        waitTimeMinutes: 20,
      );

      expect(capacity.currentOccupancy, equals(75));
      expect(capacity.reservationsAvailable, isFalse);
      expect(capacity.waitTimeMinutes, equals(20));
    });

    test('empty factory creates default capacity', () {
      final capacity = LiveCapacity.empty(maxCapacity: 50);

      expect(capacity.currentOccupancy, equals(0));
      expect(capacity.maxCapacity, equals(50));
    });

    group('occupancyPercent', () {
      test('calculates correct percentage', () {
        final capacity = LiveCapacity(
          currentOccupancy: 50,
          maxCapacity: 100,
          lastUpdated: now,
        );

        expect(capacity.occupancyPercent, equals(50.0));
      });

      test('clamps to 100 when over capacity', () {
        final capacity = LiveCapacity(
          currentOccupancy: 150,
          maxCapacity: 100,
          lastUpdated: now,
        );

        expect(capacity.occupancyPercent, equals(100.0));
      });

      test('returns 0 when maxCapacity is 0', () {
        final capacity = LiveCapacity(
          currentOccupancy: 50,
          maxCapacity: 0,
          lastUpdated: now,
        );

        expect(capacity.occupancyPercent, equals(0.0));
      });
    });

    group('statusText', () {
      test('returns "At Capacity" for >= 95%', () {
        final capacity = LiveCapacity(
          currentOccupancy: 95,
          maxCapacity: 100,
          lastUpdated: now,
        );

        expect(capacity.statusText, equals('At Capacity'));
      });

      test('returns "Almost Full" for >= 80%', () {
        final capacity = LiveCapacity(
          currentOccupancy: 85,
          maxCapacity: 100,
          lastUpdated: now,
        );

        expect(capacity.statusText, equals('Almost Full'));
      });

      test('returns "Busy" for >= 50%', () {
        final capacity = LiveCapacity(
          currentOccupancy: 60,
          maxCapacity: 100,
          lastUpdated: now,
        );

        expect(capacity.statusText, equals('Busy'));
      });

      test('returns "Moderate" for >= 25%', () {
        final capacity = LiveCapacity(
          currentOccupancy: 30,
          maxCapacity: 100,
          lastUpdated: now,
        );

        expect(capacity.statusText, equals('Moderate'));
      });

      test('returns "Plenty of Room" for < 25%', () {
        final capacity = LiveCapacity(
          currentOccupancy: 10,
          maxCapacity: 100,
          lastUpdated: now,
        );

        expect(capacity.statusText, equals('Plenty of Room'));
      });
    });

    group('waitTimeText', () {
      test('returns "No Wait" when null or 0', () {
        final noWait = LiveCapacity(
          maxCapacity: 100,
          lastUpdated: now,
          waitTimeMinutes: null,
        );
        final zeroWait = LiveCapacity(
          maxCapacity: 100,
          lastUpdated: now,
          waitTimeMinutes: 0,
        );

        expect(noWait.waitTimeText, equals('No Wait'));
        expect(zeroWait.waitTimeText, equals('No Wait'));
      });

      test('returns short wait for < 15 minutes', () {
        final capacity = LiveCapacity(
          maxCapacity: 100,
          lastUpdated: now,
          waitTimeMinutes: 10,
        );

        expect(capacity.waitTimeText, equals('~10m wait'));
      });

      test('returns medium wait for 15-30 minutes', () {
        final capacity = LiveCapacity(
          maxCapacity: 100,
          lastUpdated: now,
          waitTimeMinutes: 20,
        );

        expect(capacity.waitTimeText, equals('~15-30m wait'));
      });

      test('returns long wait for 30-60 minutes', () {
        final capacity = LiveCapacity(
          maxCapacity: 100,
          lastUpdated: now,
          waitTimeMinutes: 45,
        );

        expect(capacity.waitTimeText, equals('~30-60m wait'));
      });

      test('returns "1hr+ wait" for >= 60 minutes', () {
        final capacity = LiveCapacity(
          maxCapacity: 100,
          lastUpdated: now,
          waitTimeMinutes: 90,
        );

        expect(capacity.waitTimeText, equals('1hr+ wait'));
      });
    });

    test('occupancyText formats correctly', () {
      final capacity = LiveCapacity(
        currentOccupancy: 75,
        maxCapacity: 100,
        lastUpdated: now,
      );

      expect(capacity.occupancyText, equals('75% Full'));
    });

    test('isStale returns true for old updates', () {
      final oldUpdate = DateTime.now().subtract(const Duration(minutes: 45));
      final capacity = LiveCapacity(
        maxCapacity: 100,
        lastUpdated: oldUpdate,
      );

      expect(capacity.isStale, isTrue);
    });

    test('isStale returns false for recent updates', () {
      final recentUpdate = DateTime.now().subtract(const Duration(minutes: 10));
      final capacity = LiveCapacity(
        maxCapacity: 100,
        lastUpdated: recentUpdate,
      );

      expect(capacity.isStale, isFalse);
    });

    test('copyWith updates fields correctly', () {
      final original = LiveCapacity(
        currentOccupancy: 50,
        maxCapacity: 100,
        lastUpdated: now,
      );
      final updated = original.copyWith(
        currentOccupancy: 75,
        waitTimeMinutes: 15,
      );

      expect(updated.currentOccupancy, equals(75));
      expect(updated.waitTimeMinutes, equals(15));
      expect(updated.maxCapacity, equals(100));
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'currentOccupancy': 60,
        'maxCapacity': 100,
        'lastUpdated': '2024-10-15T12:00:00.000',
        'reservationsAvailable': false,
        'waitTimeMinutes': 25,
      };

      final capacity = LiveCapacity.fromJson(json);

      expect(capacity.currentOccupancy, equals(60));
      expect(capacity.maxCapacity, equals(100));
      expect(capacity.reservationsAvailable, isFalse);
      expect(capacity.waitTimeMinutes, equals(25));
    });

    test('Equatable compares correctly', () {
      final cap1 = LiveCapacity(
        currentOccupancy: 50,
        maxCapacity: 100,
        lastUpdated: now,
      );
      final cap2 = LiveCapacity(
        currentOccupancy: 50,
        maxCapacity: 100,
        lastUpdated: now,
      );
      final cap3 = LiveCapacity(
        currentOccupancy: 75,
        maxCapacity: 100,
        lastUpdated: now,
      );

      expect(cap1, equals(cap2));
      expect(cap1, isNot(equals(cap3)));
    });
  });

  group('SpecialValidFor', () {
    test('has expected values', () {
      expect(SpecialValidFor.values, hasLength(2));
      expect(SpecialValidFor.values, contains(SpecialValidFor.allMatches));
      expect(SpecialValidFor.values, contains(SpecialValidFor.specificMatches));
    });

    test('displayName returns correct strings', () {
      expect(SpecialValidFor.allMatches.displayName, equals('All Matches'));
      expect(SpecialValidFor.specificMatches.displayName, equals('Specific Matches'));
    });

    test('fromString parses correctly', () {
      expect(SpecialValidFor.fromString('specific_matches'), equals(SpecialValidFor.specificMatches));
      expect(SpecialValidFor.fromString('specificmatches'), equals(SpecialValidFor.specificMatches));
      expect(SpecialValidFor.fromString('all_matches'), equals(SpecialValidFor.allMatches));
      expect(SpecialValidFor.fromString(null), equals(SpecialValidFor.allMatches));
      expect(SpecialValidFor.fromString('invalid'), equals(SpecialValidFor.allMatches));
    });

    test('toJson returns correct strings', () {
      expect(SpecialValidFor.allMatches.toJson(), equals('all_matches'));
      expect(SpecialValidFor.specificMatches.toJson(), equals('specific_matches'));
    });
  });

  group('GameDaySpecial', () {
    final now = DateTime(2024, 10, 15, 12, 0, 0);

    test('creates special with required fields', () {
      final special = GameDaySpecial(
        id: 'special_1',
        title: 'Happy Hour',
        description: 'Half price appetizers',
        createdAt: now,
      );

      expect(special.id, equals('special_1'));
      expect(special.title, equals('Happy Hour'));
      expect(special.description, equals('Half price appetizers'));
      expect(special.price, isNull);
      expect(special.discountPercent, isNull);
      expect(special.validFor, equals(SpecialValidFor.allMatches));
      expect(special.matchIds, isEmpty);
      expect(special.isActive, isTrue);
    });

    test('creates special with optional fields', () {
      final expires = DateTime(2024, 12, 31);
      final special = GameDaySpecial(
        id: 'special_1',
        title: 'Game Day Deal',
        description: 'Special pricing',
        price: 9.99,
        discountPercent: 20,
        validFor: SpecialValidFor.specificMatches,
        matchIds: ['match_1', 'match_2'],
        validDays: ['saturday', 'sunday'],
        validTimeStart: '11:00',
        validTimeEnd: '23:00',
        isActive: true,
        expiresAt: expires,
        createdAt: now,
      );

      expect(special.price, equals(9.99));
      expect(special.discountPercent, equals(20));
      expect(special.validFor, equals(SpecialValidFor.specificMatches));
      expect(special.matchIds, hasLength(2));
      expect(special.validDays, hasLength(2));
      expect(special.validTimeStart, equals('11:00'));
      expect(special.validTimeEnd, equals('23:00'));
      expect(special.expiresAt, equals(expires));
    });

    group('computed getters', () {
      test('isExpired returns correct value', () {
        final expired = GameDaySpecial(
          id: 'exp_1',
          title: 'Expired',
          description: 'desc',
          expiresAt: DateTime(2020, 1, 1),
          createdAt: now,
        );
        final notExpired = GameDaySpecial(
          id: 'exp_2',
          title: 'Not Expired',
          description: 'desc',
          expiresAt: DateTime(2030, 12, 31),
          createdAt: now,
        );
        final noExpiry = GameDaySpecial(
          id: 'exp_3',
          title: 'No Expiry',
          description: 'desc',
          createdAt: now,
        );

        expect(expired.isExpired, isTrue);
        expect(notExpired.isExpired, isFalse);
        expect(noExpiry.isExpired, isFalse);
      });

      test('isCurrentlyValid checks active and expiry', () {
        final validActive = GameDaySpecial(
          id: 'v1',
          title: 'Valid',
          description: 'desc',
          isActive: true,
          expiresAt: DateTime(2030, 12, 31),
          createdAt: now,
        );
        final inactiveNotExpired = GameDaySpecial(
          id: 'v2',
          title: 'Inactive',
          description: 'desc',
          isActive: false,
          expiresAt: DateTime(2030, 12, 31),
          createdAt: now,
        );
        final activeExpired = GameDaySpecial(
          id: 'v3',
          title: 'Expired',
          description: 'desc',
          isActive: true,
          expiresAt: DateTime(2020, 1, 1),
          createdAt: now,
        );

        expect(validActive.isCurrentlyValid, isTrue);
        expect(inactiveNotExpired.isCurrentlyValid, isFalse);
        expect(activeExpired.isCurrentlyValid, isFalse);
      });

      test('displayPrice formats correctly', () {
        final withPrice = GameDaySpecial(
          id: 'p1',
          title: 'Price',
          description: 'desc',
          price: 12.50,
          createdAt: now,
        );
        final withDiscount = GameDaySpecial(
          id: 'p2',
          title: 'Discount',
          description: 'desc',
          discountPercent: 25,
          createdAt: now,
        );
        final noValue = GameDaySpecial(
          id: 'p3',
          title: 'Special',
          description: 'desc',
          createdAt: now,
        );

        expect(withPrice.displayPrice, equals('\$12.50'));
        expect(withDiscount.displayPrice, equals('25% off'));
        expect(noValue.displayPrice, equals('Special'));
      });
    });

    test('copyWith updates fields correctly', () {
      final original = GameDaySpecial(
        id: 'orig_1',
        title: 'Original',
        description: 'Original desc',
        createdAt: now,
      );
      final updated = original.copyWith(
        title: 'Updated',
        price: 5.99,
        isActive: false,
      );

      expect(updated.id, equals('orig_1'));
      expect(updated.title, equals('Updated'));
      expect(updated.price, equals(5.99));
      expect(updated.isActive, isFalse);
      expect(updated.description, equals('Original desc'));
    });

    test('factory create generates ID', () {
      final special = GameDaySpecial.create(
        title: 'New Special',
        description: 'New desc',
        price: 7.99,
      );

      expect(special.id, isNotEmpty);
      expect(special.title, equals('New Special'));
      expect(special.price, equals(7.99));
      expect(special.isActive, isTrue);
    });

    test('Equatable compares correctly', () {
      final special1 = GameDaySpecial(
        id: 'same_id',
        title: 'Same',
        description: 'desc',
        createdAt: now,
      );
      final special2 = GameDaySpecial(
        id: 'same_id',
        title: 'Same',
        description: 'desc',
        createdAt: now,
      );
      final special3 = GameDaySpecial(
        id: 'diff_id',
        title: 'Same',
        description: 'desc',
        createdAt: now,
      );

      expect(special1, equals(special2));
      expect(special1, isNot(equals(special3)));
    });
  });

  group('NoiseLevel', () {
    test('has expected values', () {
      expect(NoiseLevel.values, hasLength(4));
      expect(NoiseLevel.values, contains(NoiseLevel.quiet));
      expect(NoiseLevel.values, contains(NoiseLevel.moderate));
      expect(NoiseLevel.values, contains(NoiseLevel.loud));
      expect(NoiseLevel.values, contains(NoiseLevel.veryLoud));
    });

    test('displayName returns correct strings', () {
      expect(NoiseLevel.quiet.displayName, equals('Quiet'));
      expect(NoiseLevel.moderate.displayName, equals('Moderate'));
      expect(NoiseLevel.loud.displayName, equals('Loud'));
      expect(NoiseLevel.veryLoud.displayName, equals('Very Loud'));
    });

    test('fromString parses correctly', () {
      expect(NoiseLevel.fromString('quiet'), equals(NoiseLevel.quiet));
      expect(NoiseLevel.fromString('loud'), equals(NoiseLevel.loud));
      expect(NoiseLevel.fromString('very_loud'), equals(NoiseLevel.veryLoud));
      expect(NoiseLevel.fromString('veryloud'), equals(NoiseLevel.veryLoud));
      expect(NoiseLevel.fromString(null), equals(NoiseLevel.moderate));
      expect(NoiseLevel.fromString('invalid'), equals(NoiseLevel.moderate));
    });

    test('toJson returns correct strings', () {
      expect(NoiseLevel.quiet.toJson(), equals('quiet'));
      expect(NoiseLevel.moderate.toJson(), equals('moderate'));
      expect(NoiseLevel.loud.toJson(), equals('loud'));
      expect(NoiseLevel.veryLoud.toJson(), equals('very_loud'));
    });
  });

  group('CrowdDensity', () {
    test('has expected values', () {
      expect(CrowdDensity.values, hasLength(4));
      expect(CrowdDensity.values, contains(CrowdDensity.spacious));
      expect(CrowdDensity.values, contains(CrowdDensity.comfortable));
      expect(CrowdDensity.values, contains(CrowdDensity.cozy));
      expect(CrowdDensity.values, contains(CrowdDensity.packed));
    });

    test('displayName returns correct strings', () {
      expect(CrowdDensity.spacious.displayName, equals('Spacious'));
      expect(CrowdDensity.comfortable.displayName, equals('Comfortable'));
      expect(CrowdDensity.cozy.displayName, equals('Cozy'));
      expect(CrowdDensity.packed.displayName, equals('Packed'));
    });

    test('fromString parses correctly', () {
      expect(CrowdDensity.fromString('spacious'), equals(CrowdDensity.spacious));
      expect(CrowdDensity.fromString('packed'), equals(CrowdDensity.packed));
      expect(CrowdDensity.fromString(null), equals(CrowdDensity.comfortable));
      expect(CrowdDensity.fromString('invalid'), equals(CrowdDensity.comfortable));
    });

    test('toJson returns correct strings', () {
      expect(CrowdDensity.spacious.toJson(), equals('spacious'));
      expect(CrowdDensity.cozy.toJson(), equals('cozy'));
    });
  });

  group('AtmosphereSettings', () {
    test('creates settings with default values', () {
      const settings = AtmosphereSettings();

      expect(settings.tags, isEmpty);
      expect(settings.fanBaseAffinity, isEmpty);
      expect(settings.noiseLevel, equals(NoiseLevel.moderate));
      expect(settings.crowdDensity, equals(CrowdDensity.comfortable));
    });

    test('creates settings with custom values', () {
      const settings = AtmosphereSettings(
        tags: ['family-friendly', '21+'],
        fanBaseAffinity: ['USA', 'MEX'],
        noiseLevel: NoiseLevel.loud,
        crowdDensity: CrowdDensity.packed,
      );

      expect(settings.tags, hasLength(2));
      expect(settings.fanBaseAffinity, hasLength(2));
      expect(settings.noiseLevel, equals(NoiseLevel.loud));
      expect(settings.crowdDensity, equals(CrowdDensity.packed));
    });

    test('empty factory creates default settings', () {
      final settings = AtmosphereSettings.empty();

      expect(settings.tags, isEmpty);
      expect(settings.noiseLevel, equals(NoiseLevel.moderate));
    });

    test('hasTag checks tags correctly', () {
      const settings = AtmosphereSettings(tags: ['family-friendly', 'outdoor-seating']);

      expect(settings.hasTag('family-friendly'), isTrue);
      expect(settings.hasTag('outdoor-seating'), isTrue);
      expect(settings.hasTag('21+'), isFalse);
    });

    test('supportsTeam checks affinity correctly', () {
      const withAffinity = AtmosphereSettings(fanBaseAffinity: ['USA', 'MEX']);
      const withoutAffinity = AtmosphereSettings();

      expect(withAffinity.supportsTeam('USA'), isTrue);
      expect(withAffinity.supportsTeam('usa'), isTrue);
      expect(withAffinity.supportsTeam('BRA'), isFalse);
      expect(withoutAffinity.supportsTeam('ANY'), isTrue); // Empty means all teams
    });

    test('copyWith updates fields correctly', () {
      const original = AtmosphereSettings(
        tags: ['tag1'],
        noiseLevel: NoiseLevel.quiet,
      );
      final updated = original.copyWith(
        noiseLevel: NoiseLevel.loud,
        crowdDensity: CrowdDensity.packed,
      );

      expect(updated.tags, equals(['tag1']));
      expect(updated.noiseLevel, equals(NoiseLevel.loud));
      expect(updated.crowdDensity, equals(CrowdDensity.packed));
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'tags': ['family-friendly'],
        'fanBaseAffinity': ['USA'],
        'noiseLevel': 'loud',
        'crowdDensity': 'cozy',
      };

      final settings = AtmosphereSettings.fromJson(json);

      expect(settings.tags, equals(['family-friendly']));
      expect(settings.fanBaseAffinity, equals(['USA']));
      expect(settings.noiseLevel, equals(NoiseLevel.loud));
      expect(settings.crowdDensity, equals(CrowdDensity.cozy));
    });

    test('toJson serializes correctly', () {
      const settings = AtmosphereSettings(
        tags: ['21+'],
        fanBaseAffinity: ['GER'],
        noiseLevel: NoiseLevel.veryLoud,
        crowdDensity: CrowdDensity.spacious,
      );
      final json = settings.toJson();

      expect(json['tags'], equals(['21+']));
      expect(json['fanBaseAffinity'], equals(['GER']));
      expect(json['noiseLevel'], equals('very_loud'));
      expect(json['crowdDensity'], equals('spacious'));
    });

    test('roundtrip serialization preserves data', () {
      const original = AtmosphereSettings(
        tags: ['rowdy', 'casual'],
        fanBaseAffinity: ['BRA', 'ARG'],
        noiseLevel: NoiseLevel.loud,
        crowdDensity: CrowdDensity.packed,
      );
      final json = original.toJson();
      final restored = AtmosphereSettings.fromJson(json);

      expect(restored, equals(original));
    });

    test('availableTags contains expected tags', () {
      expect(AtmosphereSettings.availableTags, contains('family-friendly'));
      expect(AtmosphereSettings.availableTags, contains('21+'));
      expect(AtmosphereSettings.availableTags, contains('rowdy'));
      expect(AtmosphereSettings.availableTags, contains('outdoor-seating'));
    });

    test('Equatable compares correctly', () {
      const settings1 = AtmosphereSettings(
        tags: ['tag1'],
        noiseLevel: NoiseLevel.quiet,
      );
      const settings2 = AtmosphereSettings(
        tags: ['tag1'],
        noiseLevel: NoiseLevel.quiet,
      );
      const settings3 = AtmosphereSettings(
        tags: ['tag2'],
        noiseLevel: NoiseLevel.loud,
      );

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });
  });

  group('BroadcastingSchedule', () {
    final now = DateTime(2024, 10, 15, 12, 0, 0);

    test('creates schedule with default empty collections', () {
      final schedule = BroadcastingSchedule(lastUpdated: now);
      expect(schedule.matchIds, equals(const []));
      expect(schedule.autoSelectByTeam, equals(const []));
    });

    test('creates schedule with required fields', () {
      final schedule = BroadcastingSchedule(
        lastUpdated: now,
      );

      expect(schedule.matchIds, isEmpty);
      expect(schedule.lastUpdated, equals(now));
      expect(schedule.autoSelectByTeam, isEmpty);
    });

    test('creates schedule with all fields', () {
      final schedule = BroadcastingSchedule(
        matchIds: ['match_1', 'match_2'],
        lastUpdated: now,
        autoSelectByTeam: ['USA', 'MEX'],
      );

      expect(schedule.matchIds, hasLength(2));
      expect(schedule.autoSelectByTeam, hasLength(2));
    });

    test('empty factory creates empty schedule', () {
      final schedule = BroadcastingSchedule.empty();

      expect(schedule.matchIds, isEmpty);
      expect(schedule.autoSelectByTeam, isEmpty);
    });

    test('isBroadcastingMatch checks matchIds', () {
      final schedule = BroadcastingSchedule(
        matchIds: ['match_1', 'match_2'],
        lastUpdated: now,
      );

      expect(schedule.isBroadcastingMatch('match_1'), isTrue);
      expect(schedule.isBroadcastingMatch('match_2'), isTrue);
      expect(schedule.isBroadcastingMatch('match_3'), isFalse);
    });

    test('copyWith updates fields correctly', () {
      final original = BroadcastingSchedule(
        matchIds: ['match_1'],
        lastUpdated: now,
      );
      final updated = original.copyWith(
        matchIds: ['match_1', 'match_2', 'match_3'],
        autoSelectByTeam: ['BRA'],
      );

      expect(updated.matchIds, hasLength(3));
      expect(updated.autoSelectByTeam, hasLength(1));
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'matchIds': ['m1', 'm2'],
        'lastUpdated': '2024-10-15T12:00:00.000',
        'autoSelectByTeam': ['USA'],
      };

      final schedule = BroadcastingSchedule.fromJson(json);

      expect(schedule.matchIds, equals(['m1', 'm2']));
      expect(schedule.autoSelectByTeam, equals(['USA']));
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};
      final schedule = BroadcastingSchedule.fromJson(json);

      expect(schedule.matchIds, isEmpty);
      expect(schedule.autoSelectByTeam, isEmpty);
    });

    test('Equatable compares correctly', () {
      final schedule1 = BroadcastingSchedule(
        matchIds: ['m1'],
        lastUpdated: now,
      );
      final schedule2 = BroadcastingSchedule(
        matchIds: ['m1'],
        lastUpdated: now,
      );
      final schedule3 = BroadcastingSchedule(
        matchIds: ['m2'],
        lastUpdated: now,
      );

      expect(schedule1, equals(schedule2));
      expect(schedule1, isNot(equals(schedule3)));
    });
  });

  group('VenueEnhancement', () {
    final now = DateTime(2024, 10, 15, 12, 0, 0);

    test('creates enhancement with required fields', () {
      final enhancement = VenueEnhancement(
        venueId: 'venue_1',
        ownerId: 'owner_1',
        createdAt: now,
        updatedAt: now,
      );

      expect(enhancement.venueId, equals('venue_1'));
      expect(enhancement.ownerId, equals('owner_1'));
      expect(enhancement.subscriptionTier, equals(SubscriptionTier.free));
      expect(enhancement.showsMatches, isFalse);
      expect(enhancement.isVerified, isFalse);
    });

    test('isPremium and isFree getters work correctly', () {
      final freeEnhancement = VenueEnhancement(
        venueId: 'venue_1',
        ownerId: 'owner_1',
        subscriptionTier: SubscriptionTier.free,
        createdAt: now,
        updatedAt: now,
      );
      final premiumEnhancement = VenueEnhancement(
        venueId: 'venue_2',
        ownerId: 'owner_2',
        subscriptionTier: SubscriptionTier.premium,
        createdAt: now,
        updatedAt: now,
      );

      expect(freeEnhancement.isFree, isTrue);
      expect(freeEnhancement.isPremium, isFalse);
      expect(premiumEnhancement.isFree, isFalse);
      expect(premiumEnhancement.isPremium, isTrue);
    });

    test('hasTvInfo getter works correctly', () {
      final withTv = VenueEnhancement(
        venueId: 'venue_1',
        ownerId: 'owner_1',
        tvSetup: const TvSetup(totalScreens: 3),
        createdAt: now,
        updatedAt: now,
      );
      final withoutTv = VenueEnhancement(
        venueId: 'venue_2',
        ownerId: 'owner_2',
        createdAt: now,
        updatedAt: now,
      );

      expect(withTv.hasTvInfo, isTrue);
      expect(withTv.tvCount, equals(3));
      expect(withoutTv.hasTvInfo, isFalse);
      expect(withoutTv.tvCount, equals(0));
    });

    test('factory create generates enhancement', () {
      final enhancement = VenueEnhancement.create(
        venueId: 'venue_new',
        ownerId: 'owner_new',
        tier: SubscriptionTier.premium,
      );

      expect(enhancement.venueId, equals('venue_new'));
      expect(enhancement.subscriptionTier, equals(SubscriptionTier.premium));
    });

    test('copyWith updates fields correctly', () {
      final original = VenueEnhancement(
        venueId: 'venue_1',
        ownerId: 'owner_1',
        showsMatches: false,
        createdAt: now,
        updatedAt: now,
      );
      final updated = original.copyWith(
        showsMatches: true,
        isVerified: true,
      );

      expect(updated.showsMatches, isTrue);
      expect(updated.isVerified, isTrue);
      expect(updated.venueId, equals('venue_1'));
    });
  });
}
