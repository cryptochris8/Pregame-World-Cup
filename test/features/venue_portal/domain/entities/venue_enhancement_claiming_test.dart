import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/venue_enhancement.dart';

void main() {
  final now = DateTime(2026, 6, 15, 12, 0, 0);

  /// Helper to create a VenueEnhancement with claim-related fields
  VenueEnhancement createEnhancementWithClaim({
    String venueId = 'venue_1',
    String ownerId = 'owner_1',
    VenueClaimStatus claimStatus = VenueClaimStatus.approved,
    DateTime? claimedAt,
    String? venuePhoneNumber,
  }) {
    return VenueEnhancement(
      venueId: venueId,
      ownerId: ownerId,
      claimStatus: claimStatus,
      claimedAt: claimedAt,
      venuePhoneNumber: venuePhoneNumber,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('VenueEnhancement - Claim Fields', () {
    // =========================================================================
    // 1. Default claim status
    // =========================================================================
    test('default claimStatus is approved', () {
      final enhancement = VenueEnhancement(
        venueId: 'venue_1',
        ownerId: 'owner_1',
        createdAt: now,
        updatedAt: now,
      );

      expect(enhancement.claimStatus, equals(VenueClaimStatus.approved));
      expect(enhancement.claimedAt, isNull);
      expect(enhancement.venuePhoneNumber, isNull);
    });

    // =========================================================================
    // 2. Constructor with all claim fields
    // =========================================================================
    test('constructor accepts all claim fields', () {
      final claimedAt = DateTime(2026, 6, 10);
      final enhancement = createEnhancementWithClaim(
        claimStatus: VenueClaimStatus.pendingVerification,
        claimedAt: claimedAt,
        venuePhoneNumber: '+15551234567',
      );

      expect(enhancement.claimStatus,
          equals(VenueClaimStatus.pendingVerification));
      expect(enhancement.claimedAt, equals(claimedAt));
      expect(enhancement.venuePhoneNumber, equals('+15551234567'));
    });

    // =========================================================================
    // 3. isClaimApproved computed property
    // =========================================================================
    group('isClaimApproved', () {
      test('returns true when status is approved', () {
        final enhancement = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.approved,
        );
        expect(enhancement.isClaimApproved, isTrue);
      });

      test('returns false when status is pendingVerification', () {
        final enhancement = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.pendingVerification,
        );
        expect(enhancement.isClaimApproved, isFalse);
      });

      test('returns false when status is pendingReview', () {
        final enhancement = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.pendingReview,
        );
        expect(enhancement.isClaimApproved, isFalse);
      });

      test('returns false when status is rejected', () {
        final enhancement = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.rejected,
        );
        expect(enhancement.isClaimApproved, isFalse);
      });
    });

    // =========================================================================
    // 4. isClaimPending computed property
    // =========================================================================
    group('isClaimPending', () {
      test('returns true when status is pendingVerification', () {
        final enhancement = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.pendingVerification,
        );
        expect(enhancement.isClaimPending, isTrue);
      });

      test('returns true when status is pendingReview', () {
        final enhancement = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.pendingReview,
        );
        expect(enhancement.isClaimPending, isTrue);
      });

      test('returns false when status is approved', () {
        final enhancement = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.approved,
        );
        expect(enhancement.isClaimPending, isFalse);
      });

      test('returns false when status is rejected', () {
        final enhancement = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.rejected,
        );
        expect(enhancement.isClaimPending, isFalse);
      });
    });

    // =========================================================================
    // 5. copyWith for claim fields
    // =========================================================================
    group('copyWith claim fields', () {
      test('copies claimStatus', () {
        final original = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.pendingVerification,
        );
        final updated = original.copyWith(
          claimStatus: VenueClaimStatus.approved,
        );

        expect(updated.claimStatus, equals(VenueClaimStatus.approved));
        expect(updated.venueId, equals(original.venueId));
        expect(updated.ownerId, equals(original.ownerId));
      });

      test('copies claimedAt', () {
        final original = createEnhancementWithClaim();
        final claimedAt = DateTime(2026, 6, 12);
        final updated = original.copyWith(claimedAt: claimedAt);

        expect(updated.claimedAt, equals(claimedAt));
      });

      test('copies venuePhoneNumber', () {
        final original = createEnhancementWithClaim();
        final updated =
            original.copyWith(venuePhoneNumber: '+15559876543');

        expect(updated.venuePhoneNumber, equals('+15559876543'));
      });

      test('preserves existing claim fields when not specified', () {
        final original = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.pendingReview,
          claimedAt: DateTime(2026, 6, 10),
          venuePhoneNumber: '+15551111111',
        );
        final updated = original.copyWith(showsMatches: true);

        expect(updated.claimStatus, equals(VenueClaimStatus.pendingReview));
        expect(updated.claimedAt, equals(DateTime(2026, 6, 10)));
        expect(updated.venuePhoneNumber, equals('+15551111111'));
        expect(updated.showsMatches, isTrue);
      });
    });

    // =========================================================================
    // 6. fromFirestore with claim fields
    // =========================================================================
    group('fromFirestore claim fields', () {
      test('parses claimStatus from Firestore data', () {
        final data = {
          'ownerId': 'owner_1',
          'subscriptionTier': 'free',
          'showsMatches': false,
          'gameSpecials': <dynamic>[],
          'claimStatus': 'pendingVerification',
          'isVerified': false,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        };

        final enhancement = VenueEnhancement.fromFirestore(data, 'venue_1');

        expect(enhancement.claimStatus,
            equals(VenueClaimStatus.pendingVerification));
      });

      test('parses claimedAt from Firestore Timestamp', () {
        final claimedAt = DateTime(2026, 6, 10, 14, 30);
        final data = {
          'ownerId': 'owner_1',
          'subscriptionTier': 'free',
          'showsMatches': false,
          'gameSpecials': <dynamic>[],
          'claimStatus': 'approved',
          'claimedAt': Timestamp.fromDate(claimedAt),
          'isVerified': false,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        };

        final enhancement = VenueEnhancement.fromFirestore(data, 'venue_1');

        expect(enhancement.claimedAt, equals(claimedAt));
      });

      test('parses claimedAt from ISO string', () {
        final data = {
          'ownerId': 'owner_1',
          'subscriptionTier': 'free',
          'showsMatches': false,
          'gameSpecials': <dynamic>[],
          'claimStatus': 'approved',
          'claimedAt': '2026-06-10T14:30:00.000',
          'isVerified': false,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        };

        final enhancement = VenueEnhancement.fromFirestore(data, 'venue_1');

        expect(enhancement.claimedAt, isNotNull);
        expect(enhancement.claimedAt!.year, equals(2026));
        expect(enhancement.claimedAt!.month, equals(6));
        expect(enhancement.claimedAt!.day, equals(10));
      });

      test('parses venuePhoneNumber from Firestore data', () {
        final data = {
          'ownerId': 'owner_1',
          'subscriptionTier': 'free',
          'showsMatches': false,
          'gameSpecials': <dynamic>[],
          'claimStatus': 'approved',
          'venuePhoneNumber': '+15551234567',
          'isVerified': false,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        };

        final enhancement = VenueEnhancement.fromFirestore(data, 'venue_1');

        expect(enhancement.venuePhoneNumber, equals('+15551234567'));
      });

      test('defaults claimStatus to approved when missing from Firestore', () {
        final data = {
          'ownerId': 'owner_1',
          'subscriptionTier': 'free',
          'showsMatches': false,
          'gameSpecials': <dynamic>[],
          'isVerified': false,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        };

        final enhancement = VenueEnhancement.fromFirestore(data, 'venue_1');

        expect(enhancement.claimStatus, equals(VenueClaimStatus.approved));
      });

      test('handles null claimedAt and venuePhoneNumber', () {
        final data = {
          'ownerId': 'owner_1',
          'subscriptionTier': 'free',
          'showsMatches': false,
          'gameSpecials': <dynamic>[],
          'claimStatus': 'approved',
          'isVerified': false,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        };

        final enhancement = VenueEnhancement.fromFirestore(data, 'venue_1');

        expect(enhancement.claimedAt, isNull);
        expect(enhancement.venuePhoneNumber, isNull);
      });
    });

    // =========================================================================
    // 7. toFirestore with claim fields
    // =========================================================================
    group('toFirestore claim fields', () {
      test('serializes claimStatus to Firestore', () {
        final enhancement = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.pendingReview,
        );
        final data = enhancement.toFirestore();

        expect(data['claimStatus'], equals('pendingReview'));
      });

      test('serializes claimedAt as Timestamp when present', () {
        final claimedAt = DateTime(2026, 6, 10, 14, 30);
        final enhancement = createEnhancementWithClaim(
          claimedAt: claimedAt,
        );
        final data = enhancement.toFirestore();

        expect(data['claimedAt'], isA<Timestamp>());
        expect((data['claimedAt'] as Timestamp).toDate(), equals(claimedAt));
      });

      test('omits claimedAt when null', () {
        final enhancement = createEnhancementWithClaim(claimedAt: null);
        final data = enhancement.toFirestore();

        expect(data.containsKey('claimedAt'), isFalse);
      });

      test('serializes venuePhoneNumber when present', () {
        final enhancement = createEnhancementWithClaim(
          venuePhoneNumber: '+15551234567',
        );
        final data = enhancement.toFirestore();

        expect(data['venuePhoneNumber'], equals('+15551234567'));
      });

      test('omits venuePhoneNumber when null', () {
        final enhancement =
            createEnhancementWithClaim(venuePhoneNumber: null);
        final data = enhancement.toFirestore();

        expect(data.containsKey('venuePhoneNumber'), isFalse);
      });
    });

    // =========================================================================
    // 8. Firestore roundtrip
    // =========================================================================
    group('Firestore roundtrip for claim fields', () {
      test('pendingVerification survives roundtrip', () {
        final claimedAt = DateTime(2026, 6, 10, 14, 30);
        final original = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.pendingVerification,
          claimedAt: claimedAt,
          venuePhoneNumber: '+15551234567',
        );
        final data = original.toFirestore();

        // Simulate reading back from Firestore
        final restored =
            VenueEnhancement.fromFirestore(data, original.venueId);

        expect(restored.claimStatus,
            equals(VenueClaimStatus.pendingVerification));
        expect(restored.claimedAt, equals(claimedAt));
        expect(restored.venuePhoneNumber, equals('+15551234567'));
      });

      test('all claim statuses survive roundtrip', () {
        for (final status in VenueClaimStatus.values) {
          final original = createEnhancementWithClaim(
            claimStatus: status,
            claimedAt: now,
            venuePhoneNumber: '+15550000000',
          );
          final data = original.toFirestore();
          final restored =
              VenueEnhancement.fromFirestore(data, original.venueId);

          expect(restored.claimStatus, equals(status),
              reason: 'Roundtrip failed for $status');
        }
      });
    });

    // =========================================================================
    // 9. Equatable includes claim fields
    // =========================================================================
    group('Equatable with claim fields', () {
      test('two enhancements with same claim fields are equal', () {
        final claimedAt = DateTime(2026, 6, 10);
        final a = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.pendingReview,
          claimedAt: claimedAt,
          venuePhoneNumber: '+15551234567',
        );
        final b = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.pendingReview,
          claimedAt: claimedAt,
          venuePhoneNumber: '+15551234567',
        );

        expect(a, equals(b));
      });

      test('different claimStatus makes enhancements unequal', () {
        final a = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.approved,
        );
        final b = createEnhancementWithClaim(
          claimStatus: VenueClaimStatus.rejected,
        );

        expect(a, isNot(equals(b)));
      });

      test('different venuePhoneNumber makes enhancements unequal', () {
        final a = createEnhancementWithClaim(
          venuePhoneNumber: '+15551111111',
        );
        final b = createEnhancementWithClaim(
          venuePhoneNumber: '+15552222222',
        );

        expect(a, isNot(equals(b)));
      });
    });

    // =========================================================================
    // 10. VenueEnhancement.create factory
    // =========================================================================
    test('create factory sets default approved status', () {
      final enhancement = VenueEnhancement.create(
        venueId: 'venue_new',
        ownerId: 'owner_new',
      );

      expect(enhancement.claimStatus, equals(VenueClaimStatus.approved));
      expect(enhancement.claimedAt, isNull);
      expect(enhancement.venuePhoneNumber, isNull);
    });
  });
}
