import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/presentation/screens/edit_profile_screen.dart';
import 'package:pregame_world_cup/features/social/domain/entities/user_profile.dart';

void main() {
  group('EditProfileScreen', () {
    late UserProfile testProfile;

    setUp(() {
      testProfile = UserProfile(
        userId: 'test-user-id',
        displayName: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        socialStats: const SocialStats(
          friendsCount: 0,
          gamesAttended: 0,
          venuesVisited: 0,
          reviewsCount: 0,
          photosShared: 0,
          likesReceived: 0,
          checkInsCount: 0,
          helpfulVotes: 0,
        ),
        preferences: const UserPreferences(
          showLocation: true,
          allowFriendRequests: true,
          receiveNotifications: true,
          preferredVenueTypes: [],
          maxTravelDistance: 50,
          dietaryRestrictions: [],
          preferredPriceRange: 'medium',
        ),
        privacySettings: const UserPrivacySettings(
          profileVisible: true,
          showRealName: true,
          showOnlineStatus: true,
          showLocation: true,
        ),
        favoriteTeams: const [],
      );
    });

    test('is a StatefulWidget', () {
      final widget = EditProfileScreen(profile: testProfile);
      expect(widget, isA<StatefulWidget>());
    });

    test('can be constructed', () {
      final widget = EditProfileScreen(profile: testProfile);
      expect(widget, isNotNull);
    });

    test('has correct runtimeType', () {
      final widget = EditProfileScreen(profile: testProfile);
      expect(widget.runtimeType.toString(), 'EditProfileScreen');
    });

    test('creates multiple instances', () {
      final w1 = EditProfileScreen(profile: testProfile);
      final w2 = EditProfileScreen(profile: testProfile);
      expect(w1, isNotNull);
      expect(w2, isNotNull);
    });

    test('stores profile parameter correctly', () {
      final widget = EditProfileScreen(profile: testProfile);
      expect(widget.profile, equals(testProfile));
      expect(widget.profile.userId, equals('test-user-id'));
      expect(widget.profile.displayName, equals('Test User'));
    });
  });
}
