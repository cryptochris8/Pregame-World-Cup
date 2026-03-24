import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/venue_recommendation_service.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_map_top_controls.dart';
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

  group('VenueMapTopControls', () {
    test('can be constructed with required parameters', () {
      final allVenues = <Place>[
        VenueTestFactory.createPlace(),
      ];
      final filteredVenues = <Place>[
        VenueTestFactory.createPlace(),
      ];
      VenueCategory? selectedCategory;
      var callbackInvoked = false;

      final widget = VenueMapTopControls(
        allVenues: allVenues,
        filteredVenues: filteredVenues,
        selectedCategory: selectedCategory,
        onCategorySelected: (category) {
          callbackInvoked = true;
        },
      );

      expect(widget, isA<VenueMapTopControls>());
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

      final widget = VenueMapTopControls(
        allVenues: allVenues,
        filteredVenues: filteredVenues,
        selectedCategory: selectedCategory,
        onCategorySelected: (_) {},
      );

      expect(widget.selectedCategory, equals(VenueCategory.restaurant));
    });

    test('accepts empty venue lists', () {
      final widget = VenueMapTopControls(
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

      final widget = VenueMapTopControls(
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

      final widget = VenueMapTopControls(
        allVenues: allVenues,
        filteredVenues: allVenues,
        selectedCategory: null,
        onCategorySelected: (_) {},
      );

      expect(widget.allVenues.length, equals(3));
    });

    test('is a StatelessWidget', () {
      final widget = VenueMapTopControls(
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

      final widget = VenueMapTopControls(
        allVenues: allVenues,
        filteredVenues: filteredVenues,
        selectedCategory: VenueCategory.restaurant,
        onCategorySelected: (_) {},
      );

      expect(widget.allVenues.length, equals(3));
      expect(widget.filteredVenues.length, equals(1));
    });

    test('handles null selected category', () {
      final widget = VenueMapTopControls(
        allVenues: [VenueTestFactory.createPlace()],
        filteredVenues: [VenueTestFactory.createPlace()],
        selectedCategory: null,
        onCategorySelected: (_) {},
      );

      expect(widget.selectedCategory, isNull);
    });

    test('all VenueCategory values are valid', () {
      for (final category in VenueCategory.values) {
        final widget = VenueMapTopControls(
          allVenues: [VenueTestFactory.createPlace()],
          filteredVenues: [VenueTestFactory.createPlace()],
          selectedCategory: category,
          onCategorySelected: (_) {},
        );

        expect(widget.selectedCategory, equals(category));
      }
    });
  });
}
