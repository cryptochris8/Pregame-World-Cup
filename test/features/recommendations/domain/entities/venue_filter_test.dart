import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/venue_filter.dart';

/// Tests for VenueFilter entity and related enums
void main() {
  group('VenueFilter', () {
    group('Constructor and defaults', () {
      test('default constructor has correct default values', () {
        const filter = VenueFilter();

        expect(filter.venueTypes, containsAll([VenueType.bar, VenueType.restaurant]));
        expect(filter.maxDistance, equals(2.0));
        expect(filter.minRating, isNull);
        expect(filter.priceLevel, isNull);
        expect(filter.openNow, isFalse);
        expect(filter.keyword, isNull);
      });

      test('constructor accepts custom values', () {
        const filter = VenueFilter(
          venueTypes: [VenueType.cafe],
          maxDistance: 5.0,
          minRating: 4.0,
          priceLevel: PriceLevel.moderate,
          openNow: true,
          keyword: 'coffee',
        );

        expect(filter.venueTypes, contains(VenueType.cafe));
        expect(filter.maxDistance, equals(5.0));
        expect(filter.minRating, equals(4.0));
        expect(filter.priceLevel, equals(PriceLevel.moderate));
        expect(filter.openNow, isTrue);
        expect(filter.keyword, equals('coffee'));
      });
    });

    group('copyWith', () {
      test('copyWith changes specified fields', () {
        const original = VenueFilter(
          venueTypes: [VenueType.bar],
          maxDistance: 2.0,
        );

        final modified = original.copyWith(
          maxDistance: 5.0,
          openNow: true,
        );

        expect(modified.venueTypes, contains(VenueType.bar));
        expect(modified.maxDistance, equals(5.0));
        expect(modified.openNow, isTrue);
      });

      test('copyWith preserves unspecified fields', () {
        const original = VenueFilter(
          venueTypes: [VenueType.restaurant],
          maxDistance: 3.0,
          minRating: 4.5,
          keyword: 'wings',
        );

        final modified = original.copyWith(openNow: true);

        expect(modified.venueTypes, contains(VenueType.restaurant));
        expect(modified.maxDistance, equals(3.0));
        expect(modified.minRating, equals(4.5));
        expect(modified.keyword, equals('wings'));
        expect(modified.openNow, isTrue);
      });

      test('copyWith can change all fields', () {
        const original = VenueFilter();

        final modified = original.copyWith(
          venueTypes: [VenueType.nightclub],
          maxDistance: 10.0,
          minRating: 3.0,
          priceLevel: PriceLevel.expensive,
          openNow: true,
          keyword: 'dance',
        );

        expect(modified.venueTypes, contains(VenueType.nightclub));
        expect(modified.maxDistance, equals(10.0));
        expect(modified.minRating, equals(3.0));
        expect(modified.priceLevel, equals(PriceLevel.expensive));
        expect(modified.openNow, isTrue);
        expect(modified.keyword, equals('dance'));
      });
    });

    group('Factory constructors', () {
      test('all() returns filter with all venue types and 5km distance', () {
        final filter = VenueFilter.all();

        expect(filter.venueTypes, contains(VenueType.bar));
        expect(filter.venueTypes, contains(VenueType.restaurant));
        expect(filter.venueTypes, contains(VenueType.cafe));
        expect(filter.venueTypes, contains(VenueType.nightclub));
        expect(filter.venueTypes.length, equals(4));
        expect(filter.maxDistance, equals(5.0));
      });

      test('barsOnly() returns filter for bars and nightclubs', () {
        final filter = VenueFilter.barsOnly();

        expect(filter.venueTypes, contains(VenueType.bar));
        expect(filter.venueTypes, contains(VenueType.nightclub));
        expect(filter.venueTypes.length, equals(2));
        expect(filter.maxDistance, equals(2.0));
      });

      test('restaurantsOnly() returns filter for restaurants and cafes', () {
        final filter = VenueFilter.restaurantsOnly();

        expect(filter.venueTypes, contains(VenueType.restaurant));
        expect(filter.venueTypes, contains(VenueType.cafe));
        expect(filter.venueTypes.length, equals(2));
        expect(filter.maxDistance, equals(2.0));
      });
    });

    group('venueTypesToApi', () {
      test('converts venue types to API strings', () {
        const filter = VenueFilter(
          venueTypes: [VenueType.bar, VenueType.restaurant, VenueType.nightclub],
        );

        final apiValues = filter.venueTypesToApi;

        expect(apiValues, contains('bar'));
        expect(apiValues, contains('restaurant'));
        expect(apiValues, contains('night_club'));
      });

      test('converts all venue types correctly', () {
        const filter = VenueFilter(
          venueTypes: [
            VenueType.bar,
            VenueType.restaurant,
            VenueType.cafe,
            VenueType.nightclub,
            VenueType.bakery,
            VenueType.liquorStore,
          ],
        );

        final apiValues = filter.venueTypesToApi;

        expect(apiValues, contains('bar'));
        expect(apiValues, contains('restaurant'));
        expect(apiValues, contains('cafe'));
        expect(apiValues, contains('night_club'));
        expect(apiValues, contains('bakery'));
        expect(apiValues, contains('liquor_store'));
      });

      test('returns empty list for empty venue types', () {
        const filter = VenueFilter(venueTypes: []);
        expect(filter.venueTypesToApi, isEmpty);
      });
    });

    group('Equatable props', () {
      test('filters with same values are equal', () {
        const filter1 = VenueFilter(
          venueTypes: [VenueType.bar],
          maxDistance: 2.0,
          openNow: true,
        );
        const filter2 = VenueFilter(
          venueTypes: [VenueType.bar],
          maxDistance: 2.0,
          openNow: true,
        );

        expect(filter1, equals(filter2));
      });

      test('filters with different values are not equal', () {
        const filter1 = VenueFilter(
          venueTypes: [VenueType.bar],
          maxDistance: 2.0,
        );
        const filter2 = VenueFilter(
          venueTypes: [VenueType.restaurant],
          maxDistance: 2.0,
        );

        expect(filter1, isNot(equals(filter2)));
      });
    });
  });

  group('VenueType enum', () {
    test('bar has correct apiValue', () {
      expect(VenueType.bar.apiValue, equals('bar'));
    });

    test('restaurant has correct apiValue', () {
      expect(VenueType.restaurant.apiValue, equals('restaurant'));
    });

    test('cafe has correct apiValue', () {
      expect(VenueType.cafe.apiValue, equals('cafe'));
    });

    test('nightclub has correct apiValue', () {
      expect(VenueType.nightclub.apiValue, equals('night_club'));
    });

    test('bakery has correct apiValue', () {
      expect(VenueType.bakery.apiValue, equals('bakery'));
    });

    test('liquorStore has correct apiValue', () {
      expect(VenueType.liquorStore.apiValue, equals('liquor_store'));
    });

    test('all enum values have apiValue', () {
      for (final type in VenueType.values) {
        expect(type.apiValue, isNotEmpty);
      }
    });
  });

  group('PriceLevel enum', () {
    test('inexpensive has value 1', () {
      expect(PriceLevel.inexpensive.value, equals(1));
    });

    test('moderate has value 2', () {
      expect(PriceLevel.moderate.value, equals(2));
    });

    test('expensive has value 3', () {
      expect(PriceLevel.expensive.value, equals(3));
    });

    test('veryExpensive has value 4', () {
      expect(PriceLevel.veryExpensive.value, equals(4));
    });

    test('all price levels have sequential values', () {
      expect(PriceLevel.inexpensive.value, equals(1));
      expect(PriceLevel.moderate.value, equals(2));
      expect(PriceLevel.expensive.value, equals(3));
      expect(PriceLevel.veryExpensive.value, equals(4));
    });
  });
}
