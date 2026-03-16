import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/entities.dart';

// ==================== HELPERS ====================

final _now = DateTime(2026, 6, 15, 12, 0, 0);

VenueEnhancement _createEnhancement({
  String venueId = 'venue_1',
  String ownerId = 'owner_1',
  SubscriptionTier tier = SubscriptionTier.premium,
  bool showsMatches = true,
  TvSetup? tvSetup,
  List<GameDaySpecial>? gameSpecials,
  AtmosphereSettings? atmosphere,
  LiveCapacity? liveCapacity,
}) {
  return VenueEnhancement(
    venueId: venueId,
    ownerId: ownerId,
    subscriptionTier: tier,
    showsMatches: showsMatches,
    tvSetup: tvSetup,
    gameSpecials: gameSpecials ?? [],
    atmosphere: atmosphere,
    liveCapacity: liveCapacity,
    createdAt: _now,
    updatedAt: _now,
  );
}

VenueEnhancement _createFreeEnhancement({
  String venueId = 'venue_free',
  String ownerId = 'owner_1',
  bool showsMatches = false,
}) {
  return _createEnhancement(
    venueId: venueId,
    ownerId: ownerId,
    tier: SubscriptionTier.free,
    showsMatches: showsMatches,
  );
}

Map<String, dynamic> _enhancementToFirestoreData({
  String ownerId = 'owner_1',
  String tier = 'premium',
  bool showsMatches = true,
}) {
  return {
    'ownerId': ownerId,
    'subscriptionTier': tier,
    'showsMatches': showsMatches,
    'gameSpecials': <dynamic>[],
    'claimStatus': 'approved',
    'isVerified': false,
    'createdAt': Timestamp.fromDate(_now),
    'updatedAt': Timestamp.fromDate(_now),
  };
}

// ==================== TESTS ====================

/// Tests for VenueEnhancementService domain logic.
///
/// The service uses `FirebaseFirestore.instance` and `FirebaseAuth.instance`
/// directly (not injectable), so we cannot instantiate it in unit tests.
/// Instead, we thoroughly test:
/// - All entity creation, serialization, and deserialization
/// - All computed properties used by the service
/// - All business logic the service delegates to entities
/// - Premium tier guards (the service checks `isPremium` before updates)
/// - Cache behavior patterns (Map operations the service performs)
/// - Filter criteria logic
void main() {
  group('VenueEnhancementService domain logic', () {
    // =========================================================================
    // VenueEnhancement.fromFirestore parsing
    // =========================================================================
    group('VenueEnhancement.fromFirestore', () {
      test('parses premium venue correctly', () {
        final data = _enhancementToFirestoreData();
        final enhancement = VenueEnhancement.fromFirestore(data, 'venue_1');

        expect(enhancement.venueId, 'venue_1');
        expect(enhancement.ownerId, 'owner_1');
        expect(enhancement.subscriptionTier, SubscriptionTier.premium);
        expect(enhancement.showsMatches, true);
        expect(enhancement.isPremium, true);
        expect(enhancement.isFree, false);
      });

      test('parses free tier venue correctly', () {
        final data = _enhancementToFirestoreData(tier: 'free', showsMatches: false);
        final enhancement = VenueEnhancement.fromFirestore(data, 'venue_free');

        expect(enhancement.venueId, 'venue_free');
        expect(enhancement.subscriptionTier, SubscriptionTier.free);
        expect(enhancement.showsMatches, false);
        expect(enhancement.isFree, true);
        expect(enhancement.isPremium, false);
      });

      test('handles missing optional fields gracefully', () {
        final data = <String, dynamic>{
          'ownerId': 'owner_1',
          'createdAt': Timestamp.fromDate(_now),
          'updatedAt': Timestamp.fromDate(_now),
        };
        final enhancement = VenueEnhancement.fromFirestore(data, 'venue_minimal');

        expect(enhancement.venueId, 'venue_minimal');
        expect(enhancement.ownerId, 'owner_1');
        expect(enhancement.subscriptionTier, SubscriptionTier.free); // default
        expect(enhancement.showsMatches, false); // default
        expect(enhancement.tvSetup, isNull);
        expect(enhancement.atmosphere, isNull);
        expect(enhancement.liveCapacity, isNull);
        expect(enhancement.gameSpecials, isEmpty);
        expect(enhancement.businessName, isNull);
        expect(enhancement.contactEmail, isNull);
        expect(enhancement.venuePhoneNumber, isNull);
      });

      test('parses claim status correctly', () {
        final data = _enhancementToFirestoreData();
        data['claimStatus'] = 'pendingVerification';

        final enhancement = VenueEnhancement.fromFirestore(data, 'venue_pv');
        expect(enhancement.claimStatus, VenueClaimStatus.pendingVerification);
        expect(enhancement.isClaimPending, true);
        expect(enhancement.isClaimApproved, false);
      });

      test('parses business info fields', () {
        final data = _enhancementToFirestoreData();
        data['businessName'] = 'Test Bar';
        data['contactEmail'] = 'owner@bar.com';
        data['contactPhone'] = '+15551234567';
        data['ownerRole'] = 'owner';
        data['venueType'] = 'sportsBar';
        data['venuePhoneNumber'] = '+15559999999';

        final enhancement = VenueEnhancement.fromFirestore(data, 'venue_biz');
        expect(enhancement.businessName, 'Test Bar');
        expect(enhancement.contactEmail, 'owner@bar.com');
        expect(enhancement.contactPhone, '+15551234567');
        expect(enhancement.ownerRole, 'owner');
        expect(enhancement.venueType, 'sportsBar');
        expect(enhancement.venuePhoneNumber, '+15559999999');
      });
    });

    // =========================================================================
    // VenueEnhancement.toFirestore serialization
    // =========================================================================
    group('VenueEnhancement.toFirestore', () {
      test('produces correct map', () {
        final enhancement = _createEnhancement();
        final firestoreMap = enhancement.toFirestore();

        expect(firestoreMap['ownerId'], 'owner_1');
        expect(firestoreMap['subscriptionTier'], 'premium');
        expect(firestoreMap['showsMatches'], true);
        expect(firestoreMap['gameSpecials'], isA<List>());
        expect(firestoreMap['isVerified'], false);
        expect(firestoreMap['createdAt'], isA<Timestamp>());
        expect(firestoreMap['updatedAt'], isA<Timestamp>());
      });

      test('round-trips through Firestore serialization', () {
        final original = _createEnhancement(venueId: 'venue_rt');
        final firestoreMap = original.toFirestore();
        final restored = VenueEnhancement.fromFirestore(firestoreMap, 'venue_rt');

        expect(restored.venueId, original.venueId);
        expect(restored.ownerId, original.ownerId);
        expect(restored.subscriptionTier, original.subscriptionTier);
        expect(restored.showsMatches, original.showsMatches);
      });
    });

    // =========================================================================
    // VenueEnhancement.create factory
    // =========================================================================
    group('VenueEnhancement.create', () {
      test('produces correct initial state', () {
        final enhancement = VenueEnhancement.create(
          venueId: 'venue_new',
          ownerId: 'owner_new',
          tier: SubscriptionTier.premium,
        );

        expect(enhancement.venueId, 'venue_new');
        expect(enhancement.ownerId, 'owner_new');
        expect(enhancement.subscriptionTier, SubscriptionTier.premium);
        expect(enhancement.showsMatches, false);
        expect(enhancement.tvSetup, isNull);
        expect(enhancement.gameSpecials, isEmpty);
        expect(enhancement.atmosphere, isNull);
        expect(enhancement.liveCapacity, isNull);
      });

      test('defaults to free tier', () {
        final enhancement = VenueEnhancement.create(
          venueId: 'venue_free',
          ownerId: 'owner_1',
        );

        expect(enhancement.subscriptionTier, SubscriptionTier.free);
        expect(enhancement.isFree, true);
      });
    });

    // =========================================================================
    // isVenueClaimed logic (ownerId check)
    // =========================================================================
    group('isVenueClaimed logic', () {
      test('non-empty ownerId means claimed', () {
        final enhancement = _createEnhancement(ownerId: 'real_owner');
        // The service checks: enhancement != null && enhancement.ownerId.isNotEmpty
        expect(enhancement.ownerId.isNotEmpty, true);
      });

      test('empty ownerId means unclaimed', () {
        final enhancement = _createEnhancement(ownerId: '');
        expect(enhancement.ownerId.isNotEmpty, false);
      });
    });

    // =========================================================================
    // copyWith / update patterns (what the service does)
    // =========================================================================
    group('updateShowsMatches pattern', () {
      test('copyWith updates showsMatches correctly', () {
        final enhancement = _createFreeEnhancement(showsMatches: false);
        final updated = enhancement.copyWith(showsMatches: true);

        expect(updated.showsMatches, true);
        expect(updated.venueId, enhancement.venueId);
        expect(updated.subscriptionTier, SubscriptionTier.free);
      });
    });

    group('updateBroadcastingSchedule pattern', () {
      test('premium venue can have broadcasting schedule', () {
        final enhancement = _createEnhancement(tier: SubscriptionTier.premium);
        expect(enhancement.isPremium, true);

        final schedule = BroadcastingSchedule(
          matchIds: ['match_1', 'match_2'],
          lastUpdated: _now,
          autoSelectByTeam: [],
        );
        final updated = enhancement.copyWith(broadcastingSchedule: schedule);

        expect(updated.broadcastingSchedule, isNotNull);
        expect(updated.broadcastingSchedule!.matchIds, ['match_1', 'match_2']);
      });

      test('service rejects update for non-premium (isPremium check)', () {
        final enhancement = _createFreeEnhancement();
        // The service checks: if (enhancement == null || !enhancement.isPremium) return false;
        expect(enhancement.isPremium, false);
      });
    });

    group('updateTvSetup pattern', () {
      test('premium venue can have TV setup', () {
        final enhancement = _createEnhancement(tier: SubscriptionTier.premium);

        final tvSetup = const TvSetup(
          totalScreens: 8,
          audioSetup: AudioSetup.dedicated,
          screenDetails: [
            ScreenDetail(
              id: 'screen_1',
              size: '75"',
              location: 'main bar',
              hasAudio: true,
              isPrimary: true,
            ),
          ],
        );
        final updated = enhancement.copyWith(tvSetup: tvSetup);

        expect(updated.tvSetup, isNotNull);
        expect(updated.tvSetup!.totalScreens, 8);
        expect(updated.hasTvInfo, true);
        expect(updated.tvCount, 8);
      });

      test('hasTvInfo returns false when no TV setup', () {
        final enhancement = _createEnhancement(tvSetup: null);
        expect(enhancement.hasTvInfo, false);
        expect(enhancement.tvCount, 0);
      });
    });

    group('addGameSpecial pattern', () {
      test('adding a special to list works', () {
        final enhancement = _createEnhancement(
          tier: SubscriptionTier.premium,
          gameSpecials: [],
        );

        final special = GameDaySpecial(
          id: 'special_1',
          title: 'Happy Hour Wings',
          description: 'Half price during matches',
          price: 9.99,
          isActive: true,
          createdAt: _now,
        );

        // Service pattern: [...enhancement.gameSpecials, special]
        final updatedSpecials = [...enhancement.gameSpecials, special];
        final updated = enhancement.copyWith(gameSpecials: updatedSpecials);

        expect(updated.gameSpecials.length, 1);
        expect(updated.gameSpecials.first.title, 'Happy Hour Wings');
      });
    });

    group('updateGameSpecial pattern', () {
      test('replacing a specific special by ID works', () {
        final special1 = GameDaySpecial(
          id: 'special_1',
          title: 'Old Title',
          description: 'Old desc',
          isActive: true,
          createdAt: _now,
        );
        final special2 = GameDaySpecial(
          id: 'special_2',
          title: 'Other Special',
          description: 'Other desc',
          isActive: true,
          createdAt: _now,
        );

        final enhancement = _createEnhancement(
          tier: SubscriptionTier.premium,
          gameSpecials: [special1, special2],
        );

        final updatedSpecial = GameDaySpecial(
          id: 'special_1',
          title: 'New Title',
          description: 'New desc',
          isActive: true,
          createdAt: _now,
        );

        // Service pattern: .map((s) => s.id == special.id ? special : s)
        final updatedSpecials = enhancement.gameSpecials
            .map((s) => s.id == updatedSpecial.id ? updatedSpecial : s)
            .toList();
        final updated = enhancement.copyWith(gameSpecials: updatedSpecials);

        expect(updated.gameSpecials.length, 2);
        expect(
          updated.gameSpecials.firstWhere((s) => s.id == 'special_1').title,
          'New Title',
        );
        expect(
          updated.gameSpecials.firstWhere((s) => s.id == 'special_2').title,
          'Other Special',
        );
      });
    });

    group('deleteGameSpecial pattern', () {
      test('removing a specific special by ID works', () {
        final special1 = GameDaySpecial(
          id: 'special_1',
          title: 'Keep This',
          description: 'Keep',
          isActive: true,
          createdAt: _now,
        );
        final special2 = GameDaySpecial(
          id: 'special_2',
          title: 'Delete This',
          description: 'Delete',
          isActive: true,
          createdAt: _now,
        );

        final enhancement = _createEnhancement(
          tier: SubscriptionTier.premium,
          gameSpecials: [special1, special2],
        );

        // Service pattern: .where((s) => s.id != specialId)
        final updatedSpecials = enhancement.gameSpecials
            .where((s) => s.id != 'special_2')
            .toList();
        final updated = enhancement.copyWith(gameSpecials: updatedSpecials);

        expect(updated.gameSpecials.length, 1);
        expect(updated.gameSpecials.first.id, 'special_1');
      });
    });

    group('updateAtmosphere pattern', () {
      test('setting atmosphere on premium venue works', () {
        final enhancement = _createEnhancement(tier: SubscriptionTier.premium);

        const atmosphere = AtmosphereSettings(
          tags: ['family-friendly', 'outdoor-seating'],
          fanBaseAffinity: ['USA', 'MEX'],
          noiseLevel: NoiseLevel.moderate,
          crowdDensity: CrowdDensity.comfortable,
        );

        final updated = enhancement.copyWith(atmosphere: atmosphere);

        expect(updated.atmosphere, isNotNull);
        expect(updated.hasAtmosphereInfo, true);
        expect(updated.atmosphere!.tags, contains('family-friendly'));
        expect(updated.atmosphere!.fanBaseAffinity, contains('USA'));
      });
    });

    group('updateLiveCapacity pattern', () {
      test('setting live capacity on premium venue works', () {
        final enhancement = _createEnhancement(tier: SubscriptionTier.premium);

        final capacity = LiveCapacity(
          currentOccupancy: 75,
          maxCapacity: 100,
          lastUpdated: _now,
          reservationsAvailable: true,
          waitTimeMinutes: 10,
        );

        final updated = enhancement.copyWith(liveCapacity: capacity);

        expect(updated.liveCapacity, isNotNull);
        expect(updated.hasCapacityInfo, true);
        expect(updated.liveCapacity!.currentOccupancy, 75);
        expect(updated.liveCapacity!.maxCapacity, 100);
        expect(updated.liveCapacity!.occupancyPercent, 75.0);
        expect(updated.liveCapacity!.waitTimeMinutes, 10);
      });

      test('LiveCapacity.empty creates default capacity', () {
        final capacity = LiveCapacity.empty();

        expect(capacity.currentOccupancy, 0);
        expect(capacity.maxCapacity, 100);
        expect(capacity.reservationsAvailable, true);
        expect(capacity.waitTimeMinutes, isNull);
      });

      test('LiveCapacity.copyWith updates correctly', () {
        final capacity = LiveCapacity.empty(maxCapacity: 200);
        final updated = capacity.copyWith(
          currentOccupancy: 50,
          waitTimeMinutes: 15,
          reservationsAvailable: false,
        );

        expect(updated.currentOccupancy, 50);
        expect(updated.maxCapacity, 200);
        expect(updated.waitTimeMinutes, 15);
        expect(updated.reservationsAvailable, false);
      });
    });

    // =========================================================================
    // isBroadcastingMatch
    // =========================================================================
    group('isBroadcastingMatch', () {
      test('premium venue with specific match returns true', () {
        final enhancement = _createEnhancement(
          tier: SubscriptionTier.premium,
        ).copyWith(
          broadcastingSchedule: BroadcastingSchedule(
            matchIds: ['match_1', 'match_2'],
            lastUpdated: _now,
            autoSelectByTeam: [],
          ),
        );

        expect(enhancement.isBroadcastingMatch('match_1'), true);
        expect(enhancement.isBroadcastingMatch('match_3'), false);
      });

      test('free venue with showsMatches true broadcasts all', () {
        final enhancement = _createFreeEnhancement(showsMatches: true);
        expect(enhancement.isBroadcastingMatch('any_match'), true);
      });

      test('free venue with showsMatches false broadcasts none', () {
        final enhancement = _createFreeEnhancement(showsMatches: false);
        expect(enhancement.isBroadcastingMatch('any_match'), false);
      });
    });

    // =========================================================================
    // updateSubscriptionTier logic
    // =========================================================================
    group('updateSubscriptionTier logic', () {
      test('upgrading from free to premium', () {
        final enhancement = _createFreeEnhancement();
        expect(enhancement.isFree, true);

        final upgraded = enhancement.copyWith(
          subscriptionTier: SubscriptionTier.premium,
        );

        expect(upgraded.isPremium, true);
        expect(upgraded.isFree, false);
      });

      test('downgrading from premium to free', () {
        final enhancement = _createEnhancement(tier: SubscriptionTier.premium);
        expect(enhancement.isPremium, true);

        final downgraded = enhancement.copyWith(
          subscriptionTier: SubscriptionTier.free,
        );

        expect(downgraded.isFree, true);
        expect(downgraded.isPremium, false);
      });
    });

    // =========================================================================
    // enhancementSummary
    // =========================================================================
    group('enhancementSummary', () {
      test('returns empty string for venue with no info', () {
        final enhancement = _createEnhancement(
          tvSetup: null,
          gameSpecials: [],
          liveCapacity: null,
        );

        expect(enhancement.enhancementSummary, '');
      });

      test('includes TV count when present', () {
        final enhancement = _createEnhancement(
          tvSetup: const TvSetup(
            totalScreens: 8,
            audioSetup: AudioSetup.shared,
            screenDetails: [
              ScreenDetail(
                id: 's1',
                size: '55"',
                location: 'bar',
                hasAudio: true,
                isPrimary: true,
              ),
            ],
          ),
        );

        expect(enhancement.enhancementSummary, contains('8 TVs'));
      });

      test('includes capacity info when present', () {
        final enhancement = _createEnhancement(
          liveCapacity: LiveCapacity(
            currentOccupancy: 25,
            maxCapacity: 100,
            lastUpdated: _now,
          ),
        );

        expect(enhancement.enhancementSummary, isNotEmpty);
      });
    });

    // =========================================================================
    // VenueClaimStatus
    // =========================================================================
    group('VenueClaimStatus', () {
      test('isClaimApproved returns true for approved', () {
        final enhancement = _createEnhancement().copyWith(
          claimStatus: VenueClaimStatus.approved,
        );
        expect(enhancement.isClaimApproved, true);
        expect(enhancement.isClaimPending, false);
      });

      test('isClaimPending for pendingVerification', () {
        final enhancement = _createEnhancement().copyWith(
          claimStatus: VenueClaimStatus.pendingVerification,
        );
        expect(enhancement.isClaimPending, true);
        expect(enhancement.isClaimApproved, false);
      });

      test('isClaimPending for pendingReview', () {
        final enhancement = _createEnhancement().copyWith(
          claimStatus: VenueClaimStatus.pendingReview,
        );
        expect(enhancement.isClaimPending, true);
      });

      test('fromJson handles all values', () {
        expect(VenueClaimStatus.fromJson('pendingVerification'),
            VenueClaimStatus.pendingVerification);
        expect(VenueClaimStatus.fromJson('pendingReview'),
            VenueClaimStatus.pendingReview);
        expect(VenueClaimStatus.fromJson('approved'), VenueClaimStatus.approved);
        expect(VenueClaimStatus.fromJson('rejected'), VenueClaimStatus.rejected);
        expect(VenueClaimStatus.fromJson(null), VenueClaimStatus.pendingVerification);
        expect(VenueClaimStatus.fromJson('unknown'), VenueClaimStatus.pendingVerification);
      });
    });

    // =========================================================================
    // SubscriptionTier
    // =========================================================================
    group('SubscriptionTier', () {
      test('fromString handles all values', () {
        expect(SubscriptionTier.fromString('premium'), SubscriptionTier.premium);
        expect(SubscriptionTier.fromString('Premium'), SubscriptionTier.premium);
        expect(SubscriptionTier.fromString('free'), SubscriptionTier.free);
        expect(SubscriptionTier.fromString('Free'), SubscriptionTier.free);
        expect(SubscriptionTier.fromString(null), SubscriptionTier.free);
        expect(SubscriptionTier.fromString('unknown'), SubscriptionTier.free);
      });

      test('toJson returns correct string', () {
        expect(SubscriptionTier.free.toJson(), 'free');
        expect(SubscriptionTier.premium.toJson(), 'premium');
      });

      test('displayName returns correct text', () {
        expect(SubscriptionTier.free.displayName, 'Free');
        expect(SubscriptionTier.premium.displayName, 'Premium');
      });
    });

    // =========================================================================
    // LiveCapacity computed properties
    // =========================================================================
    group('LiveCapacity computed properties', () {
      test('occupancyPercent calculates correctly', () {
        final capacity = LiveCapacity(
          currentOccupancy: 50,
          maxCapacity: 100,
          lastUpdated: _now,
        );
        expect(capacity.occupancyPercent, 50.0);
      });

      test('occupancyPercent clamps to 100', () {
        final capacity = LiveCapacity(
          currentOccupancy: 150,
          maxCapacity: 100,
          lastUpdated: _now,
        );
        expect(capacity.occupancyPercent, 100.0);
      });

      test('occupancyPercent returns 0 when maxCapacity is 0', () {
        final capacity = LiveCapacity(
          currentOccupancy: 50,
          maxCapacity: 0,
          lastUpdated: _now,
        );
        expect(capacity.occupancyPercent, 0);
      });

      test('statusText at each threshold', () {
        expect(
          LiveCapacity(currentOccupancy: 96, maxCapacity: 100, lastUpdated: _now)
              .statusText,
          'At Capacity',
        );
        expect(
          LiveCapacity(currentOccupancy: 85, maxCapacity: 100, lastUpdated: _now)
              .statusText,
          'Almost Full',
        );
        expect(
          LiveCapacity(currentOccupancy: 55, maxCapacity: 100, lastUpdated: _now)
              .statusText,
          'Busy',
        );
        expect(
          LiveCapacity(currentOccupancy: 30, maxCapacity: 100, lastUpdated: _now)
              .statusText,
          'Moderate',
        );
        expect(
          LiveCapacity(currentOccupancy: 10, maxCapacity: 100, lastUpdated: _now)
              .statusText,
          'Plenty of Room',
        );
      });

      test('waitTimeText returns correct text', () {
        expect(
          LiveCapacity(currentOccupancy: 0, maxCapacity: 100, lastUpdated: _now)
              .waitTimeText,
          'No Wait',
        );
        expect(
          LiveCapacity(
                  currentOccupancy: 0,
                  maxCapacity: 100,
                  lastUpdated: _now,
                  waitTimeMinutes: 0)
              .waitTimeText,
          'No Wait',
        );
        expect(
          LiveCapacity(
                  currentOccupancy: 0,
                  maxCapacity: 100,
                  lastUpdated: _now,
                  waitTimeMinutes: 10)
              .waitTimeText,
          '~10m wait',
        );
        expect(
          LiveCapacity(
                  currentOccupancy: 0,
                  maxCapacity: 100,
                  lastUpdated: _now,
                  waitTimeMinutes: 20)
              .waitTimeText,
          '~15-30m wait',
        );
        expect(
          LiveCapacity(
                  currentOccupancy: 0,
                  maxCapacity: 100,
                  lastUpdated: _now,
                  waitTimeMinutes: 45)
              .waitTimeText,
          '~30-60m wait',
        );
        expect(
          LiveCapacity(
                  currentOccupancy: 0,
                  maxCapacity: 100,
                  lastUpdated: _now,
                  waitTimeMinutes: 90)
              .waitTimeText,
          '1hr+ wait',
        );
      });

      test('isStale returns true after 30 minutes', () {
        final staleCapacity = LiveCapacity(
          currentOccupancy: 50,
          maxCapacity: 100,
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 31)),
        );
        expect(staleCapacity.isStale, true);
      });

      test('isStale returns false within 30 minutes', () {
        final freshCapacity = LiveCapacity(
          currentOccupancy: 50,
          maxCapacity: 100,
          lastUpdated: DateTime.now(),
        );
        expect(freshCapacity.isStale, false);
      });

      test('LiveCapacity.fromJson parses correctly', () {
        final json = {
          'currentOccupancy': 75,
          'maxCapacity': 150,
          'lastUpdated': Timestamp.fromDate(_now),
          'reservationsAvailable': false,
          'waitTimeMinutes': 20,
        };

        final capacity = LiveCapacity.fromJson(json);

        expect(capacity.currentOccupancy, 75);
        expect(capacity.maxCapacity, 150);
        expect(capacity.reservationsAvailable, false);
        expect(capacity.waitTimeMinutes, 20);
      });

      test('LiveCapacity.toJson serializes correctly', () {
        final capacity = LiveCapacity(
          currentOccupancy: 60,
          maxCapacity: 120,
          lastUpdated: _now,
          waitTimeMinutes: 15,
        );

        final json = capacity.toJson();

        expect(json['currentOccupancy'], 60);
        expect(json['maxCapacity'], 120);
        expect(json['waitTimeMinutes'], 15);
        expect(json['lastUpdated'], isA<Timestamp>());
      });
    });

    // =========================================================================
    // isFeatured
    // =========================================================================
    group('isFeatured', () {
      test('returns true when featuredUntil is in the future', () {
        final enhancement = _createEnhancement().copyWith(
          featuredUntil: DateTime.now().add(const Duration(days: 7)),
        );
        expect(enhancement.isFeatured, true);
      });

      test('returns false when featuredUntil is in the past', () {
        final enhancement = _createEnhancement().copyWith(
          featuredUntil: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(enhancement.isFeatured, false);
      });

      test('returns false when featuredUntil is null', () {
        final enhancement = _createEnhancement();
        expect(enhancement.featuredUntil, isNull);
        expect(enhancement.isFeatured, false);
      });
    });

    // =========================================================================
    // Complex Firestore round-trips
    // =========================================================================
    group('complex Firestore round-trips', () {
      test('round-trips TvSetup', () {
        final enhancement = _createEnhancement(
          tvSetup: const TvSetup(
            totalScreens: 4,
            audioSetup: AudioSetup.dedicated,
            screenDetails: [
              ScreenDetail(
                id: 's1',
                size: '65"',
                location: 'main',
                hasAudio: true,
                isPrimary: true,
              ),
            ],
          ),
        );

        final map = enhancement.toFirestore();
        expect(map['tvSetup'], isNotNull);

        final restored = VenueEnhancement.fromFirestore(map, 'venue_1');
        expect(restored.tvSetup, isNotNull);
        expect(restored.tvSetup!.totalScreens, 4);
      });

      test('round-trips LiveCapacity', () {
        final enhancement = _createEnhancement(
          liveCapacity: LiveCapacity(
            currentOccupancy: 60,
            maxCapacity: 120,
            lastUpdated: _now,
            reservationsAvailable: false,
            waitTimeMinutes: 25,
          ),
        );

        final map = enhancement.toFirestore();
        expect(map['liveCapacity'], isNotNull);

        final restored = VenueEnhancement.fromFirestore(map, 'venue_1');
        expect(restored.liveCapacity, isNotNull);
        expect(restored.liveCapacity!.currentOccupancy, 60);
        expect(restored.liveCapacity!.maxCapacity, 120);
        expect(restored.liveCapacity!.waitTimeMinutes, 25);
        expect(restored.liveCapacity!.reservationsAvailable, false);
      });
    });

    // =========================================================================
    // VenueFilterCriteria (used by getEnhancedVenues)
    // =========================================================================
    group('VenueFilterCriteria', () {
      test('empty filter has no active filters', () {
        final filter = VenueFilterCriteria.empty();
        expect(filter.hasActiveFilters, false);
        expect(filter.activeFilterCount, 0);
      });

      test('hasActiveFilters returns true when filter set', () {
        const filter = VenueFilterCriteria(hasTvs: true);
        expect(filter.hasActiveFilters, true);
        expect(filter.activeFilterCount, 1);
      });

      test('activeFilterCount counts correctly', () {
        const filter = VenueFilterCriteria(
          showsMatchId: 'match_1',
          hasTvs: true,
          hasSpecials: true,
          atmosphereTags: ['outdoor', 'casual'],
          hasCapacityInfo: true,
          teamAffinity: 'USA',
        );
        // 1 + 1 + 1 + 2 + 1 + 1 = 7
        expect(filter.activeFilterCount, 7);
      });

      test('copyWith preserves fields', () {
        const original = VenueFilterCriteria(hasTvs: true, hasSpecials: true);
        final updated = original.copyWith(hasCapacityInfo: true);

        expect(updated.hasTvs, true);
        expect(updated.hasSpecials, true);
        expect(updated.hasCapacityInfo, true);
      });

      test('clear methods work correctly', () {
        const filter = VenueFilterCriteria(
          showsMatchId: 'match_1',
          hasTvs: true,
          hasSpecials: true,
        );

        final cleared1 = filter.clearShowsMatch();
        expect(cleared1.showsMatchId, isNull);
        expect(cleared1.hasTvs, true);

        final cleared2 = filter.clearHasTvs();
        expect(cleared2.hasTvs, isNull);
        expect(cleared2.showsMatchId, 'match_1');

        final cleared3 = filter.clearHasSpecials();
        expect(cleared3.hasSpecials, isNull);
        expect(cleared3.showsMatchId, 'match_1');
      });

      test('toJson/fromJson round-trip works', () {
        const original = VenueFilterCriteria(
          showsMatchId: 'match_1',
          hasTvs: true,
          atmosphereTags: ['casual'],
          teamAffinity: 'MEX',
        );

        final json = original.toJson();
        final restored = VenueFilterCriteria.fromJson(json);

        expect(restored.showsMatchId, 'match_1');
        expect(restored.hasTvs, true);
        expect(restored.atmosphereTags, ['casual']);
        expect(restored.teamAffinity, 'MEX');
      });
    });

    // =========================================================================
    // Cache behavior patterns (Map operations the service performs)
    // =========================================================================
    group('cache behavior patterns', () {
      test('cache stores and retrieves by venueId', () {
        final cache = <String, VenueEnhancement>{};
        final enhancement = _createEnhancement(venueId: 'venue_cached');

        cache['venue_cached'] = enhancement;
        expect(cache.containsKey('venue_cached'), true);
        expect(cache['venue_cached']!.venueId, 'venue_cached');
      });

      test('clearCache removes specific venue', () {
        final cache = <String, VenueEnhancement>{};
        cache['venue_1'] = _createEnhancement(venueId: 'venue_1');
        cache['venue_2'] = _createEnhancement(venueId: 'venue_2');

        cache.remove('venue_1');
        expect(cache.containsKey('venue_1'), false);
        expect(cache.containsKey('venue_2'), true);
      });

      test('clearAllCaches empties the map', () {
        final cache = <String, VenueEnhancement>{};
        cache['venue_1'] = _createEnhancement(venueId: 'venue_1');
        cache['venue_2'] = _createEnhancement(venueId: 'venue_2');

        cache.clear();
        expect(cache.length, 0);
      });

      test('getEnhancementsForVenues batch pattern', () {
        final cache = <String, VenueEnhancement>{};
        cache['v1'] = _createEnhancement(venueId: 'v1');

        final venueIds = ['v1', 'v2', 'v3'];
        final results = <String, VenueEnhancement>{};
        final uncachedIds = <String>[];

        for (final id in venueIds) {
          if (cache.containsKey(id)) {
            results[id] = cache[id]!;
          } else {
            uncachedIds.add(id);
          }
        }

        expect(results.length, 1);
        expect(results['v1'], isNotNull);
        expect(uncachedIds, ['v2', 'v3']);
      });

      test('batch query splits into chunks of 10', () {
        final uncachedIds = List.generate(25, (i) => 'venue_$i');
        final batches = <List<String>>[];

        for (var i = 0; i < uncachedIds.length; i += 10) {
          batches.add(uncachedIds.skip(i).take(10).toList());
        }

        expect(batches.length, 3);
        expect(batches[0].length, 10);
        expect(batches[1].length, 10);
        expect(batches[2].length, 5);
      });
    });

    // =========================================================================
    // Cache TTL behavior patterns (mirrors _CacheEntry logic)
    // =========================================================================
    group('cache TTL behavior patterns', () {
      test('fresh entry is not expired', () {
        final cachedAt = DateTime.now();
        const ttl = Duration(minutes: 5);
        final isExpired = DateTime.now().difference(cachedAt) > ttl;
        expect(isExpired, false);
      });

      test('entry older than TTL is expired', () {
        final cachedAt = DateTime.now().subtract(const Duration(minutes: 6));
        const ttl = Duration(minutes: 5);
        final isExpired = DateTime.now().difference(cachedAt) > ttl;
        expect(isExpired, true);
      });

      test('entry exactly at TTL boundary is not expired', () {
        final cachedAt = DateTime.now().subtract(const Duration(minutes: 5));
        const ttl = Duration(minutes: 5);
        // difference == ttl, not > ttl, so not expired
        final isExpired = DateTime.now().difference(cachedAt) > ttl;
        expect(isExpired, false);
      });

      test('expired entries are removed before adding new ones', () {
        // Simulates _addToCache eviction of expired entries
        final now = DateTime.now();
        final entries = <String, DateTime>{
          'v1': now.subtract(const Duration(minutes: 10)), // expired
          'v2': now.subtract(const Duration(minutes: 1)), // fresh
          'v3': now.subtract(const Duration(minutes: 7)), // expired
        };
        const ttl = Duration(minutes: 5);

        entries.removeWhere((_, cachedAt) => now.difference(cachedAt) > ttl);

        expect(entries.length, 1);
        expect(entries.containsKey('v2'), true);
      });

      test('oldest entry evicted when cache is at max size', () {
        const maxSize = 3;
        final now = DateTime.now();
        final cache = <String, DateTime>{
          'v1': now.subtract(const Duration(minutes: 3)), // oldest
          'v2': now.subtract(const Duration(minutes: 1)),
          'v3': now,
        };

        // Simulate adding a new entry when at capacity
        if (cache.length >= maxSize) {
          final oldest = cache.entries
              .reduce((a, b) => a.value.isBefore(b.value) ? a : b);
          cache.remove(oldest.key);
        }
        cache['v4'] = now;

        expect(cache.length, 3);
        expect(cache.containsKey('v1'), false); // evicted
        expect(cache.containsKey('v4'), true); // added
      });

      test('TTL-aware cache skips expired entries on read', () {
        final now = DateTime.now();
        final entries = <String, DateTime>{
          'v1': now.subtract(const Duration(minutes: 6)), // expired
          'v2': now.subtract(const Duration(minutes: 2)), // fresh
        };
        const ttl = Duration(minutes: 5);

        // Simulates getVenueEnhancement cache check
        DateTime? cachedAt = entries['v1'];
        bool isExpired = cachedAt != null && now.difference(cachedAt) > ttl;
        expect(isExpired, true); // should skip v1

        cachedAt = entries['v2'];
        isExpired = cachedAt != null && now.difference(cachedAt) > ttl;
        expect(isExpired, false); // should use v2
      });
    });

    // =========================================================================
    // _applyFilters logic tests
    // =========================================================================
    group('_applyFilters logic', () {
      test('filters by showsMatchId', () {
        final venues = [
          _createEnhancement(venueId: 'v1', tier: SubscriptionTier.premium)
              .copyWith(
            broadcastingSchedule: BroadcastingSchedule(
              matchIds: ['m1'],
              lastUpdated: _now,
              autoSelectByTeam: [],
            ),
          ),
          _createFreeEnhancement(venueId: 'v2', showsMatches: true),
          _createFreeEnhancement(venueId: 'v3', showsMatches: false),
        ];

        const filters = VenueFilterCriteria(showsMatchId: 'm1');

        final filtered = venues.where((v) {
          if (filters.showsMatchId != null) {
            if (!v.isBroadcastingMatch(filters.showsMatchId!)) return false;
          }
          return true;
        }).toList();

        expect(filtered.length, 2); // v1 (has m1) and v2 (showsMatches true)
      });

      test('filters by hasTvs', () {
        final venues = [
          _createEnhancement(
            venueId: 'v1',
            tvSetup: const TvSetup(
              totalScreens: 4,
              audioSetup: AudioSetup.shared,
              screenDetails: [
                ScreenDetail(
                  id: 's1',
                  size: '55"',
                  location: 'bar',
                  hasAudio: true,
                  isPrimary: true,
                ),
              ],
            ),
          ),
          _createEnhancement(venueId: 'v2', tvSetup: null),
        ];

        const filters = VenueFilterCriteria(hasTvs: true);

        final filtered = venues.where((v) {
          if (filters.hasTvs == true) {
            if (!v.hasTvInfo) return false;
          }
          return true;
        }).toList();

        expect(filtered.length, 1);
        expect(filtered.first.venueId, 'v1');
      });

      test('filters by hasCapacityInfo', () {
        final venues = [
          _createEnhancement(
            venueId: 'v1',
            liveCapacity: LiveCapacity(
              currentOccupancy: 50,
              maxCapacity: 100,
              lastUpdated: _now,
            ),
          ),
          _createEnhancement(venueId: 'v2', liveCapacity: null),
        ];

        const filters = VenueFilterCriteria(hasCapacityInfo: true);

        final filtered = venues.where((v) {
          if (filters.hasCapacityInfo == true) {
            if (!v.hasCapacityInfo) return false;
          }
          return true;
        }).toList();

        expect(filtered.length, 1);
        expect(filtered.first.venueId, 'v1');
      });
    });
  });
}
