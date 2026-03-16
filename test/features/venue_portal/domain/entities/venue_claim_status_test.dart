import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/venue_enhancement.dart';

void main() {
  group('VenueClaimStatus', () {
    test('has exactly 4 values', () {
      expect(VenueClaimStatus.values, hasLength(4));
      expect(VenueClaimStatus.values,
          contains(VenueClaimStatus.pendingVerification));
      expect(
          VenueClaimStatus.values, contains(VenueClaimStatus.pendingReview));
      expect(VenueClaimStatus.values, contains(VenueClaimStatus.approved));
      expect(VenueClaimStatus.values, contains(VenueClaimStatus.rejected));
    });

    group('toJson', () {
      test('returns correct string for each value', () {
        expect(VenueClaimStatus.pendingVerification.toJson(),
            equals('pendingVerification'));
        expect(
            VenueClaimStatus.pendingReview.toJson(), equals('pendingReview'));
        expect(VenueClaimStatus.approved.toJson(), equals('approved'));
        expect(VenueClaimStatus.rejected.toJson(), equals('rejected'));
      });
    });

    group('fromJson', () {
      test('parses pendingVerification correctly', () {
        expect(VenueClaimStatus.fromJson('pendingVerification'),
            equals(VenueClaimStatus.pendingVerification));
      });

      test('parses pendingReview correctly', () {
        expect(VenueClaimStatus.fromJson('pendingReview'),
            equals(VenueClaimStatus.pendingReview));
      });

      test('parses approved correctly', () {
        expect(VenueClaimStatus.fromJson('approved'),
            equals(VenueClaimStatus.approved));
      });

      test('parses rejected correctly', () {
        expect(VenueClaimStatus.fromJson('rejected'),
            equals(VenueClaimStatus.rejected));
      });

      test('defaults to pendingVerification for null value (safe default)', () {
        expect(VenueClaimStatus.fromJson(null),
            equals(VenueClaimStatus.pendingVerification));
      });

      test('defaults to pendingVerification for unknown string (safe default)',
          () {
        expect(VenueClaimStatus.fromJson('unknown'),
            equals(VenueClaimStatus.pendingVerification));
      });

      test('defaults to pendingVerification for empty string (safe default)',
          () {
        expect(
            VenueClaimStatus.fromJson(''), equals(VenueClaimStatus.pendingVerification));
      });
    });

    group('roundtrip serialization', () {
      test('all values survive toJson/fromJson roundtrip', () {
        for (final status in VenueClaimStatus.values) {
          final json = status.toJson();
          final restored = VenueClaimStatus.fromJson(json);
          expect(restored, equals(status),
              reason: 'Roundtrip failed for $status');
        }
      });
    });
  });
}
