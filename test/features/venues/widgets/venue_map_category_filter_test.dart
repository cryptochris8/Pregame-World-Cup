import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/venue_recommendation_service.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_map_category_filter.dart';
import '../../venues/venue_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Suppress overflow errors during tests
    FlutterError.onError = (details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().startsWith("A RenderFlex overflowed by"),
          );
      if (isOverflowError) {
        // Ignore overflow errors
      } else {
        FlutterError.presentError(details);
      }
    };
  });

  group('VenueMapCategoryFilter', () {
    test('can be constructed with required parameters', () {
      final allVenues = <Place>[
        VenueTestFactory.createPlace(),
      ];
      final filteredVenues = <Place>[
        VenueTestFactory.createPlace(),
      ];
      VenueCategory? selectedCategory;
      var callbackInvoked = false;

      final widget = VenueMapCategoryFilter(
        allVenues: allVenues,
        filteredVenues: filteredVenues,
        selectedCategory: selectedCategory,
        onCategorySelected: (category) {
          callbackInvoked = true;
        },
      );

      expect(widget, isA<VenueMapCategoryFilter>());
      expect(widget.allVenues, equals(allVenues));
      expect(widget.filteredVenues, equals(filteredVenues));
      expect(widget.selectedCategory, isNull);
      expect(callbackInvoked, isFalse);
    });

    test('can be constructed with selected category', () {
      final allVenues = <Place>[
        VenueTestFactory.createRestaurant(),
      ];
      final filteredVenues = <Place>[
        VenueTestFactory.createRestaurant(),
      ];
      const selectedCategory = VenueCategory.restaurant;

      final widget = VenueMapCategoryFilter(
        allVenues: allVenues,
        filteredVenues: filteredVenues,
        selectedCategory: selectedCategory,
        onCategorySelected: (_) {},
      );

      expect(widget.selectedCategory, equals(VenueCategory.restaurant));
    });

    test('accepts empty venue lists', () {
      final widget = VenueMapCategoryFilter(
        allVenues: const [],
        filteredVenues: const [],
        selectedCategory: null,
        onCategorySelected: (_) {},
      );

      expect(widget.allVenues, isEmpty);
      expect(widget.filteredVenues, isEmpty);
    });

    test('stores callback function', () {
      VenueCategory? capturedCategory;

      final widget = VenueMapCategoryFilter(
        allVenues: [VenueTestFactory.createPlace()],
        filteredVenues: [VenueTestFactory.createPlace()],
        selectedCategory: null,
        onCategorySelected: (category) {
          capturedCategory = category;
        },
      );

      // Simulate callback invocation
      widget.onCategorySelected(VenueCategory.sportsBar);

      expect(capturedCategory, equals(VenueCategory.sportsBar));
    });

    test('accepts multiple venue types', () {
      final allVenues = [
        VenueTestFactory.createRestaurant(),
        VenueTestFactory.createCafe(),
        VenueTestFactory.createPlace(types: ['bar']),
      ];

      final widget = VenueMapCategoryFilter(
        allVenues: allVenues,
        filteredVenues: allVenues,
        selectedCategory: null,
        onCategorySelected: (_) {},
      );

      expect(widget.allVenues.length, equals(3));
    });

    test('is a StatelessWidget', () {
      final widget = VenueMapCategoryFilter(
        allVenues: [VenueTestFactory.createPlace()],
        filteredVenues: [VenueTestFactory.createPlace()],
        selectedCategory: null,
        onCategorySelected: (_) {},
      );

      expect(widget, isA<StatelessWidget>());
    });

    test('different lists for allVenues and filteredVenues', () {
      final allVenues = [
        VenueTestFactory.createRestaurant(),
        VenueTestFactory.createCafe(),
        VenueTestFactory.createPlace(types: ['bar']),
      ];
      final filteredVenues = [
        VenueTestFactory.createRestaurant(),
      ];

      final widget = VenueMapCategoryFilter(
        allVenues: allVenues,
        filteredVenues: filteredVenues,
        selectedCategory: VenueCategory.restaurant,
        onCategorySelected: (_) {},
      );

      expect(widget.allVenues.length, equals(3));
      expect(widget.filteredVenues.length, equals(1));
    });
  });
}
