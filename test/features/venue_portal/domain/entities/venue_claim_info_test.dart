import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/venue_claim_info.dart';

void main() {
  group('VenueClaimInfo', () {
    group('Constructor', () {
      test('creates with default values', () {
        const info = VenueClaimInfo();

        expect(info.businessName, isEmpty);
        expect(info.contactEmail, isEmpty);
        expect(info.contactPhone, isEmpty);
        expect(info.role, equals(VenueOwnerRole.owner));
        expect(info.venueType, equals(VenueType.bar));
        expect(info.authorizedConfirmed, isFalse);
      });

      test('creates with custom values', () {
        const info = VenueClaimInfo(
          businessName: 'Sports Bar Grill',
          contactEmail: 'owner@sportsbar.com',
          contactPhone: '555-1234',
          role: VenueOwnerRole.manager,
          venueType: VenueType.sportsBar,
          authorizedConfirmed: true,
        );

        expect(info.businessName, equals('Sports Bar Grill'));
        expect(info.contactEmail, equals('owner@sportsbar.com'));
        expect(info.contactPhone, equals('555-1234'));
        expect(info.role, equals(VenueOwnerRole.manager));
        expect(info.venueType, equals(VenueType.sportsBar));
        expect(info.authorizedConfirmed, isTrue);
      });
    });

    group('isStep1Valid', () {
      test('returns true when businessName and valid email provided', () {
        const info = VenueClaimInfo(
          businessName: 'My Bar',
          contactEmail: 'test@example.com',
        );
        expect(info.isStep1Valid, isTrue);
      });

      test('returns false when businessName is empty', () {
        const info = VenueClaimInfo(
          businessName: '',
          contactEmail: 'test@example.com',
        );
        expect(info.isStep1Valid, isFalse);
      });

      test('returns false when contactEmail is empty', () {
        const info = VenueClaimInfo(
          businessName: 'My Bar',
          contactEmail: '',
        );
        expect(info.isStep1Valid, isFalse);
      });

      test('returns false when contactEmail has no @', () {
        const info = VenueClaimInfo(
          businessName: 'My Bar',
          contactEmail: 'notanemail',
        );
        expect(info.isStep1Valid, isFalse);
      });

      test('returns true when both businessName and email with @ are provided', () {
        const info = VenueClaimInfo(
          businessName: 'Venue Name',
          contactEmail: 'user@domain',
        );
        expect(info.isStep1Valid, isTrue);
      });
    });

    group('isStep2Valid', () {
      test('returns true when authorizedConfirmed is true', () {
        const info = VenueClaimInfo(authorizedConfirmed: true);
        expect(info.isStep2Valid, isTrue);
      });

      test('returns false when authorizedConfirmed is false', () {
        const info = VenueClaimInfo(authorizedConfirmed: false);
        expect(info.isStep2Valid, isFalse);
      });
    });

    group('copyWith', () {
      test('updates single field', () {
        const original = VenueClaimInfo(businessName: 'Original');
        final updated = original.copyWith(businessName: 'Updated');

        expect(updated.businessName, equals('Updated'));
        expect(updated.contactEmail, equals(original.contactEmail));
        expect(updated.role, equals(original.role));
      });

      test('updates multiple fields', () {
        const original = VenueClaimInfo();
        final updated = original.copyWith(
          businessName: 'New Bar',
          contactEmail: 'new@bar.com',
          contactPhone: '555-9999',
          role: VenueOwnerRole.staff,
          venueType: VenueType.restaurant,
          authorizedConfirmed: true,
        );

        expect(updated.businessName, equals('New Bar'));
        expect(updated.contactEmail, equals('new@bar.com'));
        expect(updated.contactPhone, equals('555-9999'));
        expect(updated.role, equals(VenueOwnerRole.staff));
        expect(updated.venueType, equals(VenueType.restaurant));
        expect(updated.authorizedConfirmed, isTrue);
      });

      test('preserves unchanged fields', () {
        const original = VenueClaimInfo(
          businessName: 'My Bar',
          contactEmail: 'test@test.com',
          role: VenueOwnerRole.manager,
          venueType: VenueType.hotelBar,
        );
        final updated = original.copyWith(authorizedConfirmed: true);

        expect(updated.businessName, equals('My Bar'));
        expect(updated.contactEmail, equals('test@test.com'));
        expect(updated.role, equals(VenueOwnerRole.manager));
        expect(updated.venueType, equals(VenueType.hotelBar));
      });
    });

    group('Equatable', () {
      test('equal instances are equal', () {
        const info1 = VenueClaimInfo(
          businessName: 'Bar A',
          contactEmail: 'a@a.com',
        );
        const info2 = VenueClaimInfo(
          businessName: 'Bar A',
          contactEmail: 'a@a.com',
        );
        expect(info1, equals(info2));
      });

      test('different instances are not equal', () {
        const info1 = VenueClaimInfo(businessName: 'Bar A');
        const info2 = VenueClaimInfo(businessName: 'Bar B');
        expect(info1, isNot(equals(info2)));
      });
    });
  });

  group('VenueOwnerRoleExtension', () {
    group('displayName', () {
      test('returns correct display names', () {
        expect(VenueOwnerRole.owner.displayName, equals('Owner'));
        expect(VenueOwnerRole.manager.displayName, equals('Manager'));
        expect(VenueOwnerRole.staff.displayName, equals('Staff'));
      });
    });

    group('toJson', () {
      test('returns enum name', () {
        expect(VenueOwnerRole.owner.toJson(), equals('owner'));
        expect(VenueOwnerRole.manager.toJson(), equals('manager'));
        expect(VenueOwnerRole.staff.toJson(), equals('staff'));
      });
    });

    group('fromJson', () {
      test('parses valid values', () {
        expect(VenueOwnerRoleExtension.fromJson('owner'), equals(VenueOwnerRole.owner));
        expect(VenueOwnerRoleExtension.fromJson('manager'), equals(VenueOwnerRole.manager));
        expect(VenueOwnerRoleExtension.fromJson('staff'), equals(VenueOwnerRole.staff));
      });

      test('returns owner for null', () {
        expect(VenueOwnerRoleExtension.fromJson(null), equals(VenueOwnerRole.owner));
      });

      test('returns owner for unknown value', () {
        expect(VenueOwnerRoleExtension.fromJson('unknown'), equals(VenueOwnerRole.owner));
      });
    });
  });

  group('VenueTypeExtension', () {
    group('displayName', () {
      test('returns correct display names', () {
        expect(VenueType.bar.displayName, equals('Bar'));
        expect(VenueType.restaurant.displayName, equals('Restaurant'));
        expect(VenueType.sportsBar.displayName, equals('Sports Bar'));
        expect(VenueType.hotelBar.displayName, equals('Hotel Bar'));
        expect(VenueType.other.displayName, equals('Other'));
      });
    });

    group('toJson', () {
      test('returns enum name', () {
        expect(VenueType.bar.toJson(), equals('bar'));
        expect(VenueType.restaurant.toJson(), equals('restaurant'));
        expect(VenueType.sportsBar.toJson(), equals('sportsBar'));
        expect(VenueType.hotelBar.toJson(), equals('hotelBar'));
        expect(VenueType.other.toJson(), equals('other'));
      });
    });

    group('fromJson', () {
      test('parses valid values', () {
        expect(VenueTypeExtension.fromJson('bar'), equals(VenueType.bar));
        expect(VenueTypeExtension.fromJson('restaurant'), equals(VenueType.restaurant));
        expect(VenueTypeExtension.fromJson('sportsBar'), equals(VenueType.sportsBar));
        expect(VenueTypeExtension.fromJson('hotelBar'), equals(VenueType.hotelBar));
        expect(VenueTypeExtension.fromJson('other'), equals(VenueType.other));
      });

      test('returns bar for null', () {
        expect(VenueTypeExtension.fromJson(null), equals(VenueType.bar));
      });

      test('returns bar for unknown value', () {
        expect(VenueTypeExtension.fromJson('unknown'), equals(VenueType.bar));
      });
    });

    group('roundtrip', () {
      test('toJson/fromJson roundtrip for all roles', () {
        for (final role in VenueOwnerRole.values) {
          final json = role.toJson();
          final restored = VenueOwnerRoleExtension.fromJson(json);
          expect(restored, equals(role));
        }
      });

      test('toJson/fromJson roundtrip for all venue types', () {
        for (final type in VenueType.values) {
          final json = type.toJson();
          final restored = VenueTypeExtension.fromJson(json);
          expect(restored, equals(type));
        }
      });
    });
  });
}
