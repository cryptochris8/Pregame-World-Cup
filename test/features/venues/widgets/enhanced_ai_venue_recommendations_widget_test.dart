import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/enhanced_ai_venue_recommendations_widget.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';

void main() {
  group('EnhancedAIVenueRecommendationsWidget construction and type tests', () {
    test('can be constructed with required nearbyVenues parameter', () {
      final widget = EnhancedAIVenueRecommendationsWidget(
        nearbyVenues: [],
      );

      expect(widget, isNotNull);
      expect(widget, isA<EnhancedAIVenueRecommendationsWidget>());
      expect(widget.nearbyVenues, isEmpty);
    });

    test('can be constructed with all parameters', () {
      final venues = <Place>[];
      final game = GameSchedule(
        gameId: 'game_123',
        homeTeamName: 'USA',
        awayTeamName: 'Mexico',
        dateTimeUTC: DateTime.now(),
      );

      final widget = EnhancedAIVenueRecommendationsWidget(
        nearbyVenues: venues,
        currentGame: game,
        customContext: 'pre_game',
      );

      expect(widget, isNotNull);
      expect(widget.nearbyVenues, equals(venues));
      expect(widget.currentGame, equals(game));
      expect(widget.customContext, equals('pre_game'));
    });

    test('is a StatefulWidget', () {
      final widget = EnhancedAIVenueRecommendationsWidget(
        nearbyVenues: [],
      );

      expect(widget, isA<StatefulWidget>());
    });

    test('stores nearbyVenues correctly', () {
      final venues = <Place>[];
      final widget = EnhancedAIVenueRecommendationsWidget(
        nearbyVenues: venues,
      );

      expect(widget.nearbyVenues, equals(venues));
    });

    test('currentGame is optional and defaults to null', () {
      final widget = EnhancedAIVenueRecommendationsWidget(
        nearbyVenues: [],
      );

      expect(widget.currentGame, isNull);
    });

    test('customContext is optional and defaults to null', () {
      final widget = EnhancedAIVenueRecommendationsWidget(
        nearbyVenues: [],
      );

      expect(widget.customContext, isNull);
    });

    test('multiple instances are independent', () {
      final venues1 = <Place>[];
      final venues2 = <Place>[];

      final widget1 = EnhancedAIVenueRecommendationsWidget(
        nearbyVenues: venues1,
        customContext: 'watch_party',
      );

      final widget2 = EnhancedAIVenueRecommendationsWidget(
        nearbyVenues: venues2,
        customContext: 'post_game',
      );

      expect(widget1.customContext, equals('watch_party'));
      expect(widget2.customContext, equals('post_game'));
    });

    test('widget key is optional', () {
      final widgetWithoutKey = EnhancedAIVenueRecommendationsWidget(
        nearbyVenues: [],
      );

      final widgetWithKey = EnhancedAIVenueRecommendationsWidget(
        key: const Key('ai_recommendations'),
        nearbyVenues: [],
      );

      expect(widgetWithoutKey.key, isNull);
      expect(widgetWithKey.key, isNotNull);
    });

    test('widget type is correct', () {
      final widget = EnhancedAIVenueRecommendationsWidget(
        nearbyVenues: [],
      );

      expect(widget.runtimeType.toString(), equals('EnhancedAIVenueRecommendationsWidget'));
    });

    test('can handle empty nearbyVenues list', () {
      final widget = EnhancedAIVenueRecommendationsWidget(
        nearbyVenues: [],
      );

      expect(widget.nearbyVenues, isEmpty);
      expect(widget.nearbyVenues.length, equals(0));
    });

    test('supports different custom context values', () {
      final contexts = [
        'pre_game',
        'watch_party',
        'post_game',
        'general',
      ];

      for (final context in contexts) {
        final widget = EnhancedAIVenueRecommendationsWidget(
          nearbyVenues: [],
          customContext: context,
        );
        expect(widget.customContext, equals(context));
      }
    });
  });
}
