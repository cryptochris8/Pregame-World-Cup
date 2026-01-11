import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/ai/entities/ai_recommendation.dart';
import 'package:pregame_world_cup/core/ai/entities/user_interaction.dart';
import 'package:pregame_world_cup/core/ai/entities/learned_preference.dart';

void main() {
  group('AIRecommendation', () {
    final testTimestamp = DateTime(2024, 10, 15, 12, 0, 0);

    AIRecommendation createTestRecommendation({
      String id = 'rec_1',
      String title = 'Recommended Venue',
      String description = 'Great atmosphere for watching games',
      double confidence = 0.85,
      Map<String, dynamic> metadata = const {'venueId': 'v1'},
      List<String> reasons = const ['Close to you', 'Good reviews'],
      DateTime? timestamp,
      String category = 'venue',
    }) {
      return AIRecommendation(
        id: id,
        title: title,
        description: description,
        confidence: confidence,
        metadata: metadata,
        reasons: reasons,
        timestamp: timestamp ?? testTimestamp,
        category: category,
      );
    }

    group('Constructor', () {
      test('creates recommendation with required fields', () {
        final rec = createTestRecommendation();

        expect(rec.id, equals('rec_1'));
        expect(rec.title, equals('Recommended Venue'));
        expect(rec.description, equals('Great atmosphere for watching games'));
        expect(rec.confidence, equals(0.85));
        expect(rec.category, equals('venue'));
        expect(rec.reasons, hasLength(2));
      });

      test('creates recommendation with custom metadata', () {
        final rec = createTestRecommendation(
          metadata: {
            'venueId': 'venue_123',
            'distance': 2.5,
            'rating': 4.8,
          },
        );

        expect(rec.metadata['venueId'], equals('venue_123'));
        expect(rec.metadata['distance'], equals(2.5));
        expect(rec.metadata['rating'], equals(4.8));
      });

      test('creates recommendation with multiple reasons', () {
        final rec = createTestRecommendation(
          reasons: [
            'Highly rated',
            'Close to your location',
            'Has great drink specials',
            'Many screens available',
          ],
        );

        expect(rec.reasons, hasLength(4));
        expect(rec.reasons, contains('Highly rated'));
        expect(rec.reasons, contains('Many screens available'));
      });
    });

    group('JSON serialization', () {
      test('toJson serializes all fields', () {
        final rec = createTestRecommendation();
        final json = rec.toJson();

        expect(json['id'], equals('rec_1'));
        expect(json['title'], equals('Recommended Venue'));
        expect(json['description'], equals('Great atmosphere for watching games'));
        expect(json['confidence'], equals(0.85));
        expect(json['metadata'], equals({'venueId': 'v1'}));
        expect(json['reasons'], equals(['Close to you', 'Good reviews']));
        expect(json['category'], equals('venue'));
        expect(json['timestamp'], equals('2024-10-15T12:00:00.000'));
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'id': 'rec_test',
          'title': 'Test Recommendation',
          'description': 'Test description',
          'confidence': 0.75,
          'metadata': {'key': 'value'},
          'reasons': ['Reason 1', 'Reason 2'],
          'timestamp': '2024-10-15T14:30:00.000',
          'category': 'match',
        };

        final rec = AIRecommendation.fromJson(json);

        expect(rec.id, equals('rec_test'));
        expect(rec.title, equals('Test Recommendation'));
        expect(rec.description, equals('Test description'));
        expect(rec.confidence, equals(0.75));
        expect(rec.metadata, equals({'key': 'value'}));
        expect(rec.reasons, equals(['Reason 1', 'Reason 2']));
        expect(rec.category, equals('match'));
        expect(rec.timestamp, equals(DateTime(2024, 10, 15, 14, 30, 0)));
      });

      test('fromJson handles missing fields with defaults', () {
        final json = <String, dynamic>{};

        final rec = AIRecommendation.fromJson(json);

        expect(rec.id, equals(''));
        expect(rec.title, equals(''));
        expect(rec.description, equals(''));
        expect(rec.confidence, equals(0.0));
        expect(rec.metadata, isEmpty);
        expect(rec.reasons, isEmpty);
        expect(rec.category, equals(''));
      });

      test('fromJson handles null values', () {
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

        final rec = AIRecommendation.fromJson(json);

        expect(rec.id, equals(''));
        expect(rec.title, equals(''));
        expect(rec.confidence, equals(0.0));
        expect(rec.metadata, isEmpty);
        expect(rec.reasons, isEmpty);
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestRecommendation(
          metadata: {'venueId': 'v1', 'score': 95},
          reasons: ['Reason A', 'Reason B', 'Reason C'],
        );
        final json = original.toJson();
        final restored = AIRecommendation.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.title, equals(original.title));
        expect(restored.description, equals(original.description));
        expect(restored.confidence, equals(original.confidence));
        expect(restored.category, equals(original.category));
        expect(restored.reasons, equals(original.reasons));
        expect(restored.timestamp, equals(original.timestamp));
      });
    });

    group('Equatable', () {
      test('two recommendations with same props are equal', () {
        final rec1 = createTestRecommendation();
        final rec2 = createTestRecommendation();

        expect(rec1, equals(rec2));
      });

      test('two recommendations with different props are not equal', () {
        final rec1 = createTestRecommendation(id: 'rec_1');
        final rec2 = createTestRecommendation(id: 'rec_2');

        expect(rec1, isNot(equals(rec2)));
      });

      test('props contains all fields', () {
        final rec = createTestRecommendation();
        expect(rec.props, hasLength(8));
        expect(rec.props, contains(rec.id));
        expect(rec.props, contains(rec.title));
        expect(rec.props, contains(rec.confidence));
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        final rec = createTestRecommendation();
        final str = rec.toString();

        expect(str, contains('AIRecommendation'));
      });
    });
  });

  group('UserInteractionType', () {
    test('has expected values', () {
      expect(UserInteractionType.values, hasLength(5));
      expect(UserInteractionType.values, contains(UserInteractionType.venueSelection));
      expect(UserInteractionType.values, contains(UserInteractionType.venueRating));
      expect(UserInteractionType.values, contains(UserInteractionType.recommendationFeedback));
      expect(UserInteractionType.values, contains(UserInteractionType.gameView));
      expect(UserInteractionType.values, contains(UserInteractionType.socialShare));
    });
  });

  group('UserInteraction', () {
    final testTimestamp = DateTime(2024, 10, 15, 12, 0, 0);

    UserInteraction createTestInteraction({
      String interactionId = 'int_1',
      String userId = 'user_123',
      UserInteractionType type = UserInteractionType.venueSelection,
      DateTime? timestamp,
      Map<String, dynamic> data = const {'venueId': 'venue_1'},
    }) {
      return UserInteraction(
        interactionId: interactionId,
        userId: userId,
        type: type,
        timestamp: timestamp ?? testTimestamp,
        data: data,
      );
    }

    group('Constructor', () {
      test('creates interaction with required fields', () {
        final interaction = createTestInteraction();

        expect(interaction.interactionId, equals('int_1'));
        expect(interaction.userId, equals('user_123'));
        expect(interaction.type, equals(UserInteractionType.venueSelection));
        expect(interaction.timestamp, equals(testTimestamp));
        expect(interaction.data, equals({'venueId': 'venue_1'}));
      });

      test('creates interaction with different types', () {
        final venueRating = createTestInteraction(
          type: UserInteractionType.venueRating,
          data: {'venueId': 'v1', 'rating': 5},
        );
        final gameView = createTestInteraction(
          type: UserInteractionType.gameView,
          data: {'gameId': 'g1', 'duration': 120},
        );
        final socialShare = createTestInteraction(
          type: UserInteractionType.socialShare,
          data: {'platform': 'twitter', 'contentId': 'c1'},
        );
        final feedback = createTestInteraction(
          type: UserInteractionType.recommendationFeedback,
          data: {'recommendationId': 'r1', 'accepted': true},
        );

        expect(venueRating.type, equals(UserInteractionType.venueRating));
        expect(gameView.type, equals(UserInteractionType.gameView));
        expect(socialShare.type, equals(UserInteractionType.socialShare));
        expect(feedback.type, equals(UserInteractionType.recommendationFeedback));
      });

      test('handles complex data maps', () {
        final interaction = createTestInteraction(
          data: {
            'venueId': 'venue_123',
            'rating': 4.5,
            'tags': ['sports', 'bar'],
            'nested': {'key': 'value'},
          },
        );

        expect(interaction.data['venueId'], equals('venue_123'));
        expect(interaction.data['rating'], equals(4.5));
        expect(interaction.data['tags'], equals(['sports', 'bar']));
        expect(interaction.data['nested'], equals({'key': 'value'}));
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final original = createTestInteraction();
        final newTime = DateTime(2024, 10, 16, 14, 0, 0);
        final updated = original.copyWith(
          type: UserInteractionType.venueRating,
          timestamp: newTime,
          data: {'rating': 5},
        );

        expect(updated.type, equals(UserInteractionType.venueRating));
        expect(updated.timestamp, equals(newTime));
        expect(updated.data, equals({'rating': 5}));
        expect(updated.interactionId, equals(original.interactionId));
        expect(updated.userId, equals(original.userId));
      });

      test('preserves unchanged fields', () {
        final original = createTestInteraction(
          data: {'venueId': 'v1', 'action': 'select'},
        );
        final updated = original.copyWith(
          type: UserInteractionType.gameView,
        );

        expect(updated.interactionId, equals(original.interactionId));
        expect(updated.userId, equals(original.userId));
        expect(updated.data, equals(original.data));
      });
    });

    group('toString', () {
      test('returns formatted string with key fields', () {
        final interaction = createTestInteraction();
        final str = interaction.toString();

        expect(str, contains('UserInteraction'));
        expect(str, contains('int_1'));
        expect(str, contains('venueSelection'));
        expect(str, contains('user_123'));
      });
    });
  });

  group('LearnedPreference', () {
    final testCreatedAt = DateTime(2024, 10, 1, 10, 0, 0);
    final testUpdatedAt = DateTime(2024, 10, 15, 12, 0, 0);

    LearnedPreference createTestPreference({
      String preferenceId = 'pref_1',
      String userId = 'user_123',
      String category = 'venue_type',
      String description = 'Prefers sports bars over restaurants',
      double confidence = 0.85,
      DateTime? createdAt,
      DateTime? updatedAt,
    }) {
      return LearnedPreference(
        preferenceId: preferenceId,
        userId: userId,
        category: category,
        description: description,
        confidence: confidence,
        createdAt: createdAt ?? testCreatedAt,
        updatedAt: updatedAt ?? testUpdatedAt,
      );
    }

    group('Constructor', () {
      test('creates preference with required fields', () {
        final pref = createTestPreference();

        expect(pref.preferenceId, equals('pref_1'));
        expect(pref.userId, equals('user_123'));
        expect(pref.category, equals('venue_type'));
        expect(pref.description, equals('Prefers sports bars over restaurants'));
        expect(pref.confidence, equals(0.85));
        expect(pref.createdAt, equals(testCreatedAt));
        expect(pref.updatedAt, equals(testUpdatedAt));
      });

      test('creates preferences with different categories', () {
        final venueType = createTestPreference(category: 'venue_type');
        final location = createTestPreference(category: 'location');
        final timing = createTestPreference(category: 'timing');
        final team = createTestPreference(category: 'favorite_team');

        expect(venueType.category, equals('venue_type'));
        expect(location.category, equals('location'));
        expect(timing.category, equals('timing'));
        expect(team.category, equals('favorite_team'));
      });

      test('handles various confidence levels', () {
        final high = createTestPreference(confidence: 0.95);
        final medium = createTestPreference(confidence: 0.65);
        final low = createTestPreference(confidence: 0.35);

        expect(high.confidence, equals(0.95));
        expect(medium.confidence, equals(0.65));
        expect(low.confidence, equals(0.35));
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final original = createTestPreference();
        final newUpdatedAt = DateTime(2024, 10, 20, 15, 0, 0);
        final updated = original.copyWith(
          description: 'Updated preference description',
          confidence: 0.92,
          updatedAt: newUpdatedAt,
        );

        expect(updated.description, equals('Updated preference description'));
        expect(updated.confidence, equals(0.92));
        expect(updated.updatedAt, equals(newUpdatedAt));
        expect(updated.preferenceId, equals(original.preferenceId));
        expect(updated.userId, equals(original.userId));
        expect(updated.category, equals(original.category));
        expect(updated.createdAt, equals(original.createdAt));
      });

      test('preserves unchanged fields', () {
        final original = createTestPreference(
          category: 'venue_type',
          description: 'Original description',
        );
        final updated = original.copyWith(confidence: 0.99);

        expect(updated.category, equals('venue_type'));
        expect(updated.description, equals('Original description'));
        expect(updated.preferenceId, equals(original.preferenceId));
        expect(updated.userId, equals(original.userId));
      });

      test('can update all fields', () {
        final original = createTestPreference();
        final newCreatedAt = DateTime(2024, 9, 1);
        final newUpdatedAt = DateTime(2024, 10, 25);
        final updated = original.copyWith(
          preferenceId: 'pref_new',
          userId: 'user_new',
          category: 'new_category',
          description: 'New description',
          confidence: 0.50,
          createdAt: newCreatedAt,
          updatedAt: newUpdatedAt,
        );

        expect(updated.preferenceId, equals('pref_new'));
        expect(updated.userId, equals('user_new'));
        expect(updated.category, equals('new_category'));
        expect(updated.description, equals('New description'));
        expect(updated.confidence, equals(0.50));
        expect(updated.createdAt, equals(newCreatedAt));
        expect(updated.updatedAt, equals(newUpdatedAt));
      });
    });

    group('toString', () {
      test('returns formatted string with percentage', () {
        final pref = createTestPreference(
          category: 'venue_type',
          description: 'Prefers bars',
          confidence: 0.85,
        );
        final str = pref.toString();

        expect(str, contains('LearnedPreference'));
        expect(str, contains('venue_type'));
        expect(str, contains('Prefers bars'));
        expect(str, contains('85%'));
      });

      test('rounds confidence percentage correctly', () {
        final pref1 = createTestPreference(confidence: 0.754);
        final pref2 = createTestPreference(confidence: 0.756);

        expect(pref1.toString(), contains('75%'));
        expect(pref2.toString(), contains('76%'));
      });

      test('handles edge confidence values', () {
        final zero = createTestPreference(confidence: 0.0);
        final full = createTestPreference(confidence: 1.0);

        expect(zero.toString(), contains('0%'));
        expect(full.toString(), contains('100%'));
      });
    });
  });
}
