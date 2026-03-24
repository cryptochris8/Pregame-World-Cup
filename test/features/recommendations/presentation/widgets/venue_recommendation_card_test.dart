import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/recommendations/presentation/widgets/venue_recommendation_card.dart';
import 'package:pregame_world_cup/core/services/smart_venue_recommendation_service.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';

void main() {
  group('VenueRecommendationCard', () {
    final testPlace = Place(
      placeId: 'test_place_1',
      name: 'Test Bar',
      vicinity: '123 Main St',
      latitude: 40.7128,
      longitude: -74.0060,
      rating: 4.5,
      userRatingsTotal: 100,
    );

    final testRecommendation = SmartVenueRecommendation(
      venue: testPlace,
      smartScore: 0.85,
      aiScore: 0.9,
      behaviorScore: 0.8,
      contextScore: 0.85,
      predictionScore: 0.8,
      reasoning: 'Great sports bar with excellent atmosphere',
      tags: ['Sports Bar', 'Lively', 'Popular'],
      confidence: 0.9,
      personalizationLevel: 0.7,
    );

    test('is a StatelessWidget', () {
      final widget = VenueRecommendationCard(
        recommendation: testRecommendation,
        index: 0,
      );

      expect(widget, isA<VenueRecommendationCard>());
    });

    test('stores recommendation', () {
      final widget = VenueRecommendationCard(
        recommendation: testRecommendation,
        index: 0,
      );

      expect(widget.recommendation, equals(testRecommendation));
    });

    test('stores index', () {
      final widget = VenueRecommendationCard(
        recommendation: testRecommendation,
        index: 2,
      );

      expect(widget.index, equals(2));
    });

    test('stores optional onVenueSelected callback', () {
      void testCallback(Place place) {}

      final widget = VenueRecommendationCard(
        recommendation: testRecommendation,
        index: 0,
        onVenueSelected: testCallback,
      );

      expect(widget.onVenueSelected, equals(testCallback));
    });

    test('stores optional onVenueFavorited callback', () {
      void testCallback(Place place) {}

      final widget = VenueRecommendationCard(
        recommendation: testRecommendation,
        index: 0,
        onVenueFavorited: testCallback,
      );

      expect(widget.onVenueFavorited, equals(testCallback));
    });

    test('defaults to null for callbacks', () {
      final widget = VenueRecommendationCard(
        recommendation: testRecommendation,
        index: 0,
      );

      expect(widget.onVenueSelected, isNull);
      expect(widget.onVenueFavorited, isNull);
    });

    test('can be constructed with all parameters', () {
      void selectCallback(Place place) {}
      void favoriteCallback(Place place) {}

      final widget = VenueRecommendationCard(
        recommendation: testRecommendation,
        index: 1,
        onVenueSelected: selectCallback,
        onVenueFavorited: favoriteCallback,
      );

      expect(widget.recommendation, equals(testRecommendation));
      expect(widget.index, equals(1));
      expect(widget.onVenueSelected, equals(selectCallback));
      expect(widget.onVenueFavorited, equals(favoriteCallback));
    });

    test('can be constructed with different index values', () {
      final widget1 = VenueRecommendationCard(
        recommendation: testRecommendation,
        index: 0,
      );
      final widget2 = VenueRecommendationCard(
        recommendation: testRecommendation,
        index: 5,
      );

      expect(widget1.index, equals(0));
      expect(widget2.index, equals(5));
    });

    test('stores different recommendations', () {
      final place2 = Place(
        placeId: 'test_place_2',
        name: 'Another Bar',
        vicinity: '456 Oak Ave',
        latitude: 40.7580,
        longitude: -73.9855,
      );

      final recommendation2 = SmartVenueRecommendation(
        venue: place2,
        smartScore: 0.75,
        aiScore: 0.8,
        behaviorScore: 0.7,
        contextScore: 0.75,
        predictionScore: 0.7,
        reasoning: 'Cozy neighborhood spot',
        tags: ['Quiet', 'Local'],
        confidence: 0.85,
        personalizationLevel: 0.6,
      );

      final widget = VenueRecommendationCard(
        recommendation: recommendation2,
        index: 0,
      );

      expect(widget.recommendation.venue.name, equals('Another Bar'));
      expect(widget.recommendation.smartScore, equals(0.75));
    });
  });
}
