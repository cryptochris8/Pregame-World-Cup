import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/constants/firestore_collections.dart';

void main() {
  group('FirestoreCollections', () {
    test('all constants have non-empty values with valid characters', () {
      for (final name in FirestoreCollections.allCollections) {
        expect(name, isNotEmpty, reason: 'Collection name must not be empty');
        expect(
          name,
          matches(RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$')),
          reason: '"$name" should contain only letters, digits, and underscores',
        );
      }
    });

    test('allCollections list has no duplicates', () {
      final unique = FirestoreCollections.allCollections.toSet();
      expect(
        unique.length,
        FirestoreCollections.allCollections.length,
        reason: 'allCollections should not contain duplicate entries',
      );
    });

    test('allCollections contains all expected collection names', () {
      const expectedCollections = [
        'users',
        'user_profiles',
        'userFavorites',
        'social_profiles',
        'social_connections',
        'friendships',
        'friend_request_notifications',
        'activities',
        'activity_likes',
        'activity_comments',
        'chats',
        'messages',
        'message_notifications',
        'typing_indicators',
        'user_chat_settings',
        'notifications',
        'notification_preferences',
        'broadcast_notifications',
        'watch_parties',
        'members',
        'watch_party_invites',
        'watch_party_virtual_payments',
        'predictions',
        'user_predictions',
        'worldcup_matches',
        'comments',
        'reports',
        'user_sanctions',
        'user_moderation_status',
        'world_cup_fan_passes',
        'world_cup_venue_purchases',
        'venue_enhancements',
        'venue_disputes',
        'user_interactions',
        'venue_interactions',
        'team_preferences',
        'user_behavior_summary',
      ];

      for (final expected in expectedCollections) {
        expect(
          FirestoreCollections.allCollections.contains(expected),
          isTrue,
          reason: '"$expected" should be in allCollections',
        );
      }

      // Ensure allCollections is exhaustive — no extras
      expect(
        FirestoreCollections.allCollections.length,
        expectedCollections.length,
        reason: 'allCollections should have exactly ${expectedCollections.length} entries',
      );
    });

    test('individual constants match their string values', () {
      expect(FirestoreCollections.users, 'users');
      expect(FirestoreCollections.userProfiles, 'user_profiles');
      expect(FirestoreCollections.userFavorites, 'userFavorites');
      expect(FirestoreCollections.socialProfiles, 'social_profiles');
      expect(FirestoreCollections.socialConnections, 'social_connections');
      expect(FirestoreCollections.friendships, 'friendships');
      expect(FirestoreCollections.friendRequestNotifications, 'friend_request_notifications');
      expect(FirestoreCollections.activities, 'activities');
      expect(FirestoreCollections.activityLikes, 'activity_likes');
      expect(FirestoreCollections.activityComments, 'activity_comments');
      expect(FirestoreCollections.chats, 'chats');
      expect(FirestoreCollections.messages, 'messages');
      expect(FirestoreCollections.messageNotifications, 'message_notifications');
      expect(FirestoreCollections.typingIndicators, 'typing_indicators');
      expect(FirestoreCollections.userChatSettings, 'user_chat_settings');
      expect(FirestoreCollections.notifications, 'notifications');
      expect(FirestoreCollections.notificationPreferences, 'notification_preferences');
      expect(FirestoreCollections.broadcastNotifications, 'broadcast_notifications');
      expect(FirestoreCollections.watchParties, 'watch_parties');
      expect(FirestoreCollections.members, 'members');
      expect(FirestoreCollections.watchPartyInvites, 'watch_party_invites');
      expect(FirestoreCollections.watchPartyVirtualPayments, 'watch_party_virtual_payments');
      expect(FirestoreCollections.predictions, 'predictions');
      expect(FirestoreCollections.userPredictions, 'user_predictions');
      expect(FirestoreCollections.worldcupMatches, 'worldcup_matches');
      expect(FirestoreCollections.comments, 'comments');
      expect(FirestoreCollections.reports, 'reports');
      expect(FirestoreCollections.userSanctions, 'user_sanctions');
      expect(FirestoreCollections.userModerationStatus, 'user_moderation_status');
      expect(FirestoreCollections.worldCupFanPasses, 'world_cup_fan_passes');
      expect(FirestoreCollections.worldCupVenuePurchases, 'world_cup_venue_purchases');
      expect(FirestoreCollections.venueEnhancements, 'venue_enhancements');
      expect(FirestoreCollections.venueDisputes, 'venue_disputes');
      expect(FirestoreCollections.userInteractions, 'user_interactions');
      expect(FirestoreCollections.venueInteractions, 'venue_interactions');
      expect(FirestoreCollections.teamPreferences, 'team_preferences');
      expect(FirestoreCollections.userBehaviorSummary, 'user_behavior_summary');
    });

    test('no collection name contains prohibited terms', () {
      for (final name in FirestoreCollections.allCollections) {
        expect(
          name.toLowerCase().contains('fifa'),
          isFalse,
          reason: '"$name" must not contain "fifa" — Apple IP violation',
        );
      }
    });
  });
}
