import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/ai/entities/ai_recommendation.dart';

void main() {
  group('AIRecommendation', () {
    group('Constructor', () {
      test('creates recommendation with required fields', () {
        final now = DateTime.now();
        final recommendation = AIRecommendation(
          id: 'rec_1',
          title: 'Best Venue for Game Day',
          description: 'This sports bar has the best atmosphere for watching the game',
          confidence: 0.92,
          metadata: {'venueId': 'venue_123'},
          reasons: ['Great TVs', 'Team-friendly staff', 'Game day specials'],
          timestamp: now,
          category: 'venue',
        );

        expect(recommendation.id, equals('rec_1'));
        expect(recommendation.title, equals('Best Venue for Game Day'));
        expect(recommendation.description, contains('best atmosphere'));
        expect(recommendation.confidence, equals(0.92));
        expect(recommendation.metadata['venueId'], equals('venue_123'));
        expect(recommendation.reasons, hasLength(3));
        expect(recommendation.timestamp, equals(now));
        expect(recommendation.category, equals('venue'));
      });

      test('creates recommendation with empty metadata and reasons', () {
        final now = DateTime.now();
        final recommendation = AIRecommendation(
          id: 'rec_2',
          title: 'General Recommendation',
          description: 'A basic recommendation',
          confidence: 0.75,
          metadata: {},
          reasons: [],
          timestamp: now,
          category: 'general',
        );

        expect(recommendation.metadata, isEmpty);
        expect(recommendation.reasons, isEmpty);
      });
    });

    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'id': 'rec_1',
          'title': 'Top Pick',
          'description': 'Highly recommended venue',
          'confidence': 0.88,
          'metadata': {'rating': 4.5, 'priceLevel': 2},
          'reasons': ['Great atmosphere', 'Good prices'],
          'timestamp': '2024-10-15T12:00:00.000',
          'category': 'venue',
        };

        final recommendation = AIRecommendation.fromJson(json);

        expect(recommendation.id, equals('rec_1'));
        expect(recommendation.title, equals('Top Pick'));
        expect(recommendation.description, equals('Highly recommended venue'));
        expect(recommendation.confidence, equals(0.88));
        expect(recommendation.metadata['rating'], equals(4.5));
        expect(recommendation.reasons, hasLength(2));
        expect(recommendation.timestamp, equals(DateTime(2024, 10, 15, 12, 0, 0)));
        expect(recommendation.category, equals('venue'));
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{};

        final recommendation = AIRecommendation.fromJson(json);

        expect(recommendation.id, isEmpty);
        expect(recommendation.title, isEmpty);
        expect(recommendation.description, isEmpty);
        expect(recommendation.confidence, equals(0.0));
        expect(recommendation.metadata, isEmpty);
        expect(recommendation.reasons, isEmpty);
        expect(recommendation.category, isEmpty);
      });

      test('handles null values gracefully', () {
        final json = {
          'id': null,
          'title': null,
          'description': null,
          'confidence': null,
          'metadata': null,
          'reasons': null,
          'timestamp': null,
          'category': null,
        };

        final recommendation = AIRecommendation.fromJson(json);

        expect(recommendation.id, isEmpty);
        expect(recommendation.title, isEmpty);
        expect(recommendation.confidence, equals(0.0));
        expect(recommendation.metadata, isEmpty);
        expect(recommendation.reasons, isEmpty);
      });

      test('parses integer confidence as double', () {
        final json = {
          'id': 'rec_1',
          'title': 'Test',
          'description': 'Description',
          'confidence': 1, // Integer instead of double
          'metadata': {},
          'reasons': [],
          'timestamp': '2024-10-15T12:00:00.000',
          'category': 'test',
        };

        final recommendation = AIRecommendation.fromJson(json);

        expect(recommendation.confidence, equals(1.0));
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final timestamp = DateTime(2024, 10, 15, 14, 30, 0);
        final recommendation = AIRecommendation(
          id: 'rec_1',
          title: 'Best Sports Bar',
          description: 'Great for watching games',
          confidence: 0.95,
          metadata: {'venueType': 'bar', 'distance': 2.5},
          reasons: ['Multiple screens', 'Craft beer selection'],
          timestamp: timestamp,
          category: 'venue',
        );

        final json = recommendation.toJson();

        expect(json['id'], equals('rec_1'));
        expect(json['title'], equals('Best Sports Bar'));
        expect(json['description'], equals('Great for watching games'));
        expect(json['confidence'], equals(0.95));
        expect(json['metadata']['venueType'], equals('bar'));
        expect(json['metadata']['distance'], equals(2.5));
        expect(json['reasons'], equals(['Multiple screens', 'Craft beer selection']));
        expect(json['timestamp'], equals('2024-10-15T14:30:00.000'));
        expect(json['category'], equals('venue'));
      });
    });

    group('Roundtrip serialization', () {
      test('preserves all data through toJson and fromJson', () {
        final timestamp = DateTime(2024, 11, 20, 18, 45, 0);
        final original = AIRecommendation(
          id: 'rec_original',
          title: 'Game Day Recommendation',
          description: 'Perfect spot for the big game',
          confidence: 0.89,
          metadata: {
            'venueId': 'venue_456',
            'teamAffiliation': 'Georgia',
            'matchScore': 95,
          },
          reasons: [
            'Team-friendly atmosphere',
            'Game day specials',
            'Large screen TVs',
            'Convenient location',
          ],
          timestamp: timestamp,
          category: 'game_day_venue',
        );

        final json = original.toJson();
        final restored = AIRecommendation.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.title, equals(original.title));
        expect(restored.description, equals(original.description));
        expect(restored.confidence, equals(original.confidence));
        expect(restored.metadata['venueId'], equals(original.metadata['venueId']));
        expect(restored.metadata['teamAffiliation'], equals(original.metadata['teamAffiliation']));
        expect(restored.reasons.length, equals(original.reasons.length));
        expect(restored.timestamp, equals(original.timestamp));
        expect(restored.category, equals(original.category));
      });
    });

    group('Equatable', () {
      test('two recommendations with same props are equal', () {
        final timestamp = DateTime(2024, 10, 15, 12, 0, 0);
        final rec1 = AIRecommendation(
          id: 'rec_1',
          title: 'Title',
          description: 'Description',
          confidence: 0.85,
          metadata: {'key': 'value'},
          reasons: ['reason1'],
          timestamp: timestamp,
          category: 'test',
        );

        final rec2 = AIRecommendation(
          id: 'rec_1',
          title: 'Title',
          description: 'Description',
          confidence: 0.85,
          metadata: {'key': 'value'},
          reasons: ['reason1'],
          timestamp: timestamp,
          category: 'test',
        );

        expect(rec1, equals(rec2));
      });

      test('two recommendations with different props are not equal', () {
        final timestamp = DateTime.now();
        final rec1 = AIRecommendation(
          id: 'rec_1',
          title: 'Title 1',
          description: 'Description 1',
          confidence: 0.85,
          metadata: {},
          reasons: [],
          timestamp: timestamp,
          category: 'test',
        );

        final rec2 = AIRecommendation(
          id: 'rec_2',
          title: 'Title 2',
          description: 'Description 2',
          confidence: 0.90,
          metadata: {},
          reasons: [],
          timestamp: timestamp,
          category: 'test',
        );

        expect(rec1, isNot(equals(rec2)));
      });

      test('recommendations with different confidence are not equal', () {
        final timestamp = DateTime.now();
        final rec1 = AIRecommendation(
          id: 'rec_1',
          title: 'Title',
          description: 'Description',
          confidence: 0.85,
          metadata: {},
          reasons: [],
          timestamp: timestamp,
          category: 'test',
        );

        final rec2 = AIRecommendation(
          id: 'rec_1',
          title: 'Title',
          description: 'Description',
          confidence: 0.95,
          metadata: {},
          reasons: [],
          timestamp: timestamp,
          category: 'test',
        );

        expect(rec1, isNot(equals(rec2)));
      });

      test('recommendations with different reasons are not equal', () {
        final timestamp = DateTime.now();
        final rec1 = AIRecommendation(
          id: 'rec_1',
          title: 'Title',
          description: 'Description',
          confidence: 0.85,
          metadata: {},
          reasons: ['reason1'],
          timestamp: timestamp,
          category: 'test',
        );

        final rec2 = AIRecommendation(
          id: 'rec_1',
          title: 'Title',
          description: 'Description',
          confidence: 0.85,
          metadata: {},
          reasons: ['reason1', 'reason2'],
          timestamp: timestamp,
          category: 'test',
        );

        expect(rec1, isNot(equals(rec2)));
      });
    });

    group('toString', () {
      test('returns formatted string representation', () {
        final recommendation = AIRecommendation(
          id: 'rec_1',
          title: 'Best Venue',
          description: 'Description here',
          confidence: 0.85,
          metadata: {},
          reasons: [],
          timestamp: DateTime.now(),
          category: 'venue',
        );

        final str = recommendation.toString();

        expect(str, contains('AIRecommendation'));
      });
    });

    group('Confidence levels', () {
      test('handles zero confidence', () {
        final recommendation = AIRecommendation(
          id: 'rec_1',
          title: 'Low confidence rec',
          description: 'Not very confident',
          confidence: 0.0,
          metadata: {},
          reasons: [],
          timestamp: DateTime.now(),
          category: 'test',
        );

        expect(recommendation.confidence, equals(0.0));
      });

      test('handles max confidence', () {
        final recommendation = AIRecommendation(
          id: 'rec_1',
          title: 'High confidence rec',
          description: 'Very confident',
          confidence: 1.0,
          metadata: {},
          reasons: [],
          timestamp: DateTime.now(),
          category: 'test',
        );

        expect(recommendation.confidence, equals(1.0));
      });
    });

    group('Category variations', () {
      test('handles venue category', () {
        final recommendation = AIRecommendation(
          id: 'rec_1',
          title: 'Venue Recommendation',
          description: 'Great venue',
          confidence: 0.88,
          metadata: {'venueId': '123'},
          reasons: ['Good food'],
          timestamp: DateTime.now(),
          category: 'venue',
        );

        expect(recommendation.category, equals('venue'));
      });

      test('handles activity category', () {
        final recommendation = AIRecommendation(
          id: 'rec_2',
          title: 'Activity Recommendation',
          description: 'Fun activity',
          confidence: 0.75,
          metadata: {'activityType': 'tailgate'},
          reasons: ['Fun for fans'],
          timestamp: DateTime.now(),
          category: 'activity',
        );

        expect(recommendation.category, equals('activity'));
      });

      test('handles game category', () {
        final recommendation = AIRecommendation(
          id: 'rec_3',
          title: 'Game Recommendation',
          description: 'Must-watch game',
          confidence: 0.92,
          metadata: {'gameId': 'game_456'},
          reasons: ['Rivalry game', 'Playoff implications'],
          timestamp: DateTime.now(),
          category: 'game',
        );

        expect(recommendation.category, equals('game'));
      });
    });

    group('Metadata variations', () {
      test('handles nested metadata', () {
        final recommendation = AIRecommendation(
          id: 'rec_1',
          title: 'Complex Recommendation',
          description: 'Has nested data',
          confidence: 0.80,
          metadata: {
            'venue': {
              'id': 'venue_123',
              'name': 'Sports Bar',
              'location': {'lat': 33.75, 'lng': -84.39},
            },
            'scores': [85, 90, 88],
          },
          reasons: ['Reason'],
          timestamp: DateTime.now(),
          category: 'complex',
        );

        expect(recommendation.metadata['venue'], isA<Map>());
        expect(recommendation.metadata['scores'], isA<List>());
      });

      test('handles various metadata value types', () {
        final recommendation = AIRecommendation(
          id: 'rec_1',
          title: 'Type Test',
          description: 'Testing types',
          confidence: 0.80,
          metadata: {
            'stringValue': 'hello',
            'intValue': 42,
            'doubleValue': 3.14,
            'boolValue': true,
            'nullValue': null,
            'listValue': [1, 2, 3],
          },
          reasons: [],
          timestamp: DateTime.now(),
          category: 'test',
        );

        expect(recommendation.metadata['stringValue'], equals('hello'));
        expect(recommendation.metadata['intValue'], equals(42));
        expect(recommendation.metadata['doubleValue'], equals(3.14));
        expect(recommendation.metadata['boolValue'], isTrue);
        expect(recommendation.metadata['nullValue'], isNull);
        expect(recommendation.metadata['listValue'], equals([1, 2, 3]));
      });
    });
  });
}
