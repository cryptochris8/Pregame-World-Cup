import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/domain/entities/user_profile.dart';
import 'package:pregame_world_cup/features/social/domain/services/social_data_mappers.dart';

void main() {
  late SocialDataMappers mappers;

  setUp(() {
    mappers = SocialDataMappers();
  });

  // ===========================================================================
  // parsePreferences
  // ===========================================================================
  group('parsePreferences', () {
    test('returns default preferences when data is null', () {
      final result = mappers.parsePreferences(null);

      expect(result.showLocation, isTrue);
      expect(result.allowFriendRequests, isTrue);
      expect(result.shareGameDayPlans, isTrue);
      expect(result.receiveNotifications, isTrue);
      expect(result.maxTravelDistance, equals(5));
      expect(result.preferredPriceRange, equals('\$\$'));
      expect(result.autoShareCheckIns, isFalse);
      expect(result.joinGroupsAutomatically, isFalse);
    });

    test('parses all fields from complete data', () {
      final data = {
        'showLocation': false,
        'allowFriendRequests': false,
        'shareGameDayPlans': false,
        'receiveNotifications': false,
        'preferredVenueTypes': ['pub', 'bar'],
        'maxTravelDistance': 15,
        'dietaryRestrictions': ['vegan'],
        'preferredPriceRange': '\$\$\$',
        'autoShareCheckIns': true,
        'joinGroupsAutomatically': true,
      };

      final result = mappers.parsePreferences(data);

      expect(result.showLocation, isFalse);
      expect(result.allowFriendRequests, isFalse);
      expect(result.shareGameDayPlans, isFalse);
      expect(result.receiveNotifications, isFalse);
      expect(result.preferredVenueTypes, equals(['pub', 'bar']));
      expect(result.maxTravelDistance, equals(15));
      expect(result.dietaryRestrictions, equals(['vegan']));
      expect(result.preferredPriceRange, equals('\$\$\$'));
      expect(result.autoShareCheckIns, isTrue);
      expect(result.joinGroupsAutomatically, isTrue);
    });

    test('uses defaults for missing fields in partial data', () {
      final data = <String, dynamic>{
        'showLocation': false,
      };

      final result = mappers.parsePreferences(data);

      expect(result.showLocation, isFalse);
      expect(result.allowFriendRequests, isTrue);
      expect(result.maxTravelDistance, equals(5));
      expect(result.preferredVenueTypes, isEmpty);
    });

    test('handles empty map', () {
      final result = mappers.parsePreferences({});

      expect(result.showLocation, isTrue);
      expect(result.allowFriendRequests, isTrue);
      expect(result.preferredVenueTypes, isEmpty);
      expect(result.dietaryRestrictions, isEmpty);
    });
  });

  // ===========================================================================
  // parseSocialStats
  // ===========================================================================
  group('parseSocialStats', () {
    test('returns empty stats when data is null', () {
      final result = mappers.parseSocialStats(null);

      expect(result.friendsCount, equals(0));
      expect(result.checkInsCount, equals(0));
      expect(result.reviewsCount, equals(0));
      expect(result.gamesAttended, equals(0));
      expect(result.venuesVisited, equals(0));
      expect(result.photosShared, equals(0));
      expect(result.likesReceived, equals(0));
      expect(result.helpfulVotes, equals(0));
      expect(result.lastActivity, isNull);
    });

    test('parses all fields from complete data', () {
      final lastActivity = DateTime(2026, 6, 15, 12, 0);
      final data = {
        'friendsCount': 42,
        'checkInsCount': 10,
        'reviewsCount': 5,
        'gamesAttended': 20,
        'venuesVisited': 15,
        'photosShared': 50,
        'likesReceived': 100,
        'helpfulVotes': 30,
        'lastActivity': Timestamp.fromDate(lastActivity),
      };

      final result = mappers.parseSocialStats(data);

      expect(result.friendsCount, equals(42));
      expect(result.checkInsCount, equals(10));
      expect(result.reviewsCount, equals(5));
      expect(result.gamesAttended, equals(20));
      expect(result.venuesVisited, equals(15));
      expect(result.photosShared, equals(50));
      expect(result.likesReceived, equals(100));
      expect(result.helpfulVotes, equals(30));
      expect(result.lastActivity, equals(lastActivity));
    });

    test('defaults to 0 for missing numeric fields', () {
      final result = mappers.parseSocialStats({});

      expect(result.friendsCount, equals(0));
      expect(result.gamesAttended, equals(0));
      expect(result.lastActivity, isNull);
    });

    test('handles null lastActivity field', () {
      final data = {
        'friendsCount': 5,
        'lastActivity': null,
      };

      final result = mappers.parseSocialStats(data);

      expect(result.friendsCount, equals(5));
      expect(result.lastActivity, isNull);
    });
  });

  // ===========================================================================
  // parsePrivacySettings
  // ===========================================================================
  group('parsePrivacySettings', () {
    test('returns default settings when data is null', () {
      final result = mappers.parsePrivacySettings(null);

      expect(result.profileVisible, isTrue);
      expect(result.showRealName, isTrue);
      expect(result.showLocation, isTrue);
      expect(result.showFavoriteTeams, isTrue);
      expect(result.allowMessaging, isTrue);
      expect(result.showOnlineStatus, isTrue);
      expect(result.checkInVisibility, equals('friends'));
      expect(result.friendListVisibility, equals('friends'));
    });

    test('parses all fields from complete data', () {
      final data = {
        'profileVisible': false,
        'showRealName': false,
        'showLocation': false,
        'showFavoriteTeams': false,
        'allowMessaging': false,
        'showOnlineStatus': false,
        'checkInVisibility': 'private',
        'friendListVisibility': 'public',
      };

      final result = mappers.parsePrivacySettings(data);

      expect(result.profileVisible, isFalse);
      expect(result.showRealName, isFalse);
      expect(result.showLocation, isFalse);
      expect(result.showFavoriteTeams, isFalse);
      expect(result.allowMessaging, isFalse);
      expect(result.showOnlineStatus, isFalse);
      expect(result.checkInVisibility, equals('private'));
      expect(result.friendListVisibility, equals('public'));
    });

    test('defaults to true for missing boolean fields', () {
      final result = mappers.parsePrivacySettings({});

      expect(result.profileVisible, isTrue);
      expect(result.allowMessaging, isTrue);
    });
  });

  // ===========================================================================
  // parseProfileFromData
  // ===========================================================================
  group('parseProfileFromData', () {
    test('parses complete profile data', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final data = {
        'displayName': 'John Doe',
        'email': 'john@example.com',
        'profileImageUrl': 'https://example.com/photo.jpg',
        'bio': 'Soccer fan',
        'favoriteTeams': ['USA', 'Brazil'],
        'homeLocation': 'New York',
        'preferences': {
          'showLocation': true,
          'maxTravelDistance': 10,
        },
        'socialStats': {
          'friendsCount': 42,
        },
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'privacySettings': {
          'profileVisible': true,
        },
        'badges': ['verified'],
        'level': 15,
        'experiencePoints': 5000,
      };

      final result = mappers.parseProfileFromData('user_123', data);

      expect(result, isNotNull);
      expect(result!.userId, equals('user_123'));
      expect(result.displayName, equals('John Doe'));
      expect(result.email, equals('john@example.com'));
      expect(result.profileImageUrl, equals('https://example.com/photo.jpg'));
      expect(result.bio, equals('Soccer fan'));
      expect(result.favoriteTeams, equals(['USA', 'Brazil']));
      expect(result.homeLocation, equals('New York'));
      expect(result.badges, equals(['verified']));
      expect(result.level, equals(15));
      expect(result.experiencePoints, equals(5000));
      expect(result.socialStats.friendsCount, equals(42));
    });

    test('uses defaults for missing optional fields', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final data = {
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final result = mappers.parseProfileFromData('user_456', data);

      expect(result, isNotNull);
      expect(result!.userId, equals('user_456'));
      expect(result.displayName, equals('Unknown User'));
      expect(result.email, isNull);
      expect(result.favoriteTeams, isEmpty);
      expect(result.badges, isEmpty);
      expect(result.level, equals(1));
      expect(result.experiencePoints, equals(0));
    });

    test('returns null when data causes a parsing error', () {
      // Missing required createdAt timestamp will cause an error
      final data = <String, dynamic>{
        'displayName': 'Test',
        // createdAt is missing - will throw when trying to cast null as Timestamp
      };

      final result = mappers.parseProfileFromData('user_789', data);

      expect(result, isNull);
    });

    test('handles null preferences and socialStats gracefully', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final data = {
        'displayName': 'Simple User',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'preferences': null,
        'socialStats': null,
        'privacySettings': null,
      };

      final result = mappers.parseProfileFromData('user_simple', data);

      expect(result, isNotNull);
      expect(result!.preferences.showLocation, isTrue);
      expect(result.socialStats.friendsCount, equals(0));
      expect(result.privacySettings.profileVisible, isTrue);
    });
  });

  // ===========================================================================
  // parseProfileFromDoc
  // ===========================================================================
  group('parseProfileFromDoc', () {
    test('parses profile from Firestore document snapshot', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final now = DateTime(2026, 6, 15, 12, 0);

      await fakeFirestore.collection('user_profiles').doc('user_doc_1').set({
        'displayName': 'DocUser',
        'email': 'doc@example.com',
        'favoriteTeams': ['Mexico'],
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'level': 10,
        'experiencePoints': 2000,
      });

      final doc =
          await fakeFirestore.collection('user_profiles').doc('user_doc_1').get();

      final result = mappers.parseProfileFromDoc(doc);

      expect(result, isNotNull);
      expect(result!.userId, equals('user_doc_1'));
      expect(result.displayName, equals('DocUser'));
      expect(result.favoriteTeams, equals(['Mexico']));
      expect(result.level, equals(10));
    });

    test('returns null for non-existent document', () async {
      final fakeFirestore = FakeFirebaseFirestore();

      final doc = await fakeFirestore
          .collection('user_profiles')
          .doc('nonexistent')
          .get();

      final result = mappers.parseProfileFromDoc(doc);

      expect(result, isNull);
    });
  });

  // ===========================================================================
  // preferencesToMap
  // ===========================================================================
  group('preferencesToMap', () {
    test('serializes all preferences fields', () {
      const preferences = UserPreferences(
        showLocation: false,
        allowFriendRequests: false,
        shareGameDayPlans: true,
        receiveNotifications: true,
        preferredVenueTypes: ['sports_bar'],
        maxTravelDistance: 10,
        dietaryRestrictions: ['gluten_free'],
        preferredPriceRange: '\$\$\$',
        autoShareCheckIns: true,
        joinGroupsAutomatically: false,
      );

      final result = mappers.preferencesToMap(preferences);

      expect(result['showLocation'], isFalse);
      expect(result['allowFriendRequests'], isFalse);
      expect(result['shareGameDayPlans'], isTrue);
      expect(result['receiveNotifications'], isTrue);
      expect(result['preferredVenueTypes'], equals(['sports_bar']));
      expect(result['maxTravelDistance'], equals(10));
      expect(result['dietaryRestrictions'], equals(['gluten_free']));
      expect(result['preferredPriceRange'], equals('\$\$\$'));
      expect(result['autoShareCheckIns'], isTrue);
      expect(result['joinGroupsAutomatically'], isFalse);
    });

    test('roundtrip parse/serialize preserves all values', () {
      const original = UserPreferences(
        showLocation: false,
        allowFriendRequests: false,
        maxTravelDistance: 20,
        preferredPriceRange: '\$',
        autoShareCheckIns: true,
        dietaryRestrictions: ['vegan', 'nut-free'],
      );

      final map = mappers.preferencesToMap(original);
      final restored = mappers.parsePreferences(map);

      expect(restored.showLocation, equals(original.showLocation));
      expect(restored.allowFriendRequests, equals(original.allowFriendRequests));
      expect(restored.maxTravelDistance, equals(original.maxTravelDistance));
      expect(restored.preferredPriceRange, equals(original.preferredPriceRange));
      expect(restored.autoShareCheckIns, equals(original.autoShareCheckIns));
      expect(restored.dietaryRestrictions, equals(original.dietaryRestrictions));
    });
  });

  // ===========================================================================
  // socialStatsToMap
  // ===========================================================================
  group('socialStatsToMap', () {
    test('serializes all stats fields', () {
      final lastActivity = DateTime(2026, 6, 15, 12, 0);
      final stats = SocialStats(
        friendsCount: 42,
        checkInsCount: 10,
        reviewsCount: 5,
        gamesAttended: 20,
        venuesVisited: 15,
        photosShared: 50,
        likesReceived: 100,
        helpfulVotes: 30,
        lastActivity: lastActivity,
      );

      final result = mappers.socialStatsToMap(stats);

      expect(result['friendsCount'], equals(42));
      expect(result['checkInsCount'], equals(10));
      expect(result['reviewsCount'], equals(5));
      expect(result['gamesAttended'], equals(20));
      expect(result['venuesVisited'], equals(15));
      expect(result['photosShared'], equals(50));
      expect(result['likesReceived'], equals(100));
      expect(result['helpfulVotes'], equals(30));
      expect(result['lastActivity'], isA<Timestamp>());
    });

    test('handles null lastActivity', () {
      final stats = SocialStats.empty();

      final result = mappers.socialStatsToMap(stats);

      expect(result['lastActivity'], isNull);
      expect(result['friendsCount'], equals(0));
    });

    test('roundtrip serialize/parse preserves numeric values', () {
      const original = SocialStats(
        friendsCount: 100,
        gamesAttended: 25,
        photosShared: 75,
      );

      final map = mappers.socialStatsToMap(original);
      // lastActivity becomes a Timestamp in the map, so replace it for parse
      map['lastActivity'] = null;
      final restored = mappers.parseSocialStats(map);

      expect(restored.friendsCount, equals(original.friendsCount));
      expect(restored.gamesAttended, equals(original.gamesAttended));
      expect(restored.photosShared, equals(original.photosShared));
    });
  });

  // ===========================================================================
  // privacySettingsToMap
  // ===========================================================================
  group('privacySettingsToMap', () {
    test('serializes all privacy settings fields', () {
      const settings = UserPrivacySettings(
        profileVisible: false,
        showRealName: false,
        showLocation: false,
        showFavoriteTeams: true,
        allowMessaging: false,
        showOnlineStatus: true,
        checkInVisibility: 'private',
        friendListVisibility: 'public',
      );

      final result = mappers.privacySettingsToMap(settings);

      expect(result['profileVisible'], isFalse);
      expect(result['showRealName'], isFalse);
      expect(result['showLocation'], isFalse);
      expect(result['showFavoriteTeams'], isTrue);
      expect(result['allowMessaging'], isFalse);
      expect(result['showOnlineStatus'], isTrue);
      expect(result['checkInVisibility'], equals('private'));
      expect(result['friendListVisibility'], equals('public'));
    });

    test('roundtrip serialize/parse preserves all values', () {
      const original = UserPrivacySettings(
        profileVisible: false,
        showRealName: false,
        allowMessaging: false,
        checkInVisibility: 'private',
        friendListVisibility: 'public',
      );

      final map = mappers.privacySettingsToMap(original);
      final restored = mappers.parsePrivacySettings(map);

      expect(restored.profileVisible, equals(original.profileVisible));
      expect(restored.showRealName, equals(original.showRealName));
      expect(restored.allowMessaging, equals(original.allowMessaging));
      expect(restored.checkInVisibility, equals(original.checkInVisibility));
      expect(
        restored.friendListVisibility,
        equals(original.friendListVisibility),
      );
    });
  });

  // ===========================================================================
  // profileToMap
  // ===========================================================================
  group('profileToMap', () {
    test('serializes complete profile to map', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final profile = UserProfile(
        userId: 'user_123',
        displayName: 'John Doe',
        email: 'john@example.com',
        profileImageUrl: 'https://example.com/photo.jpg',
        bio: 'Soccer fan',
        favoriteTeams: const ['USA', 'Brazil'],
        homeLocation: 'New York',
        preferences: UserPreferences.defaultPreferences(),
        socialStats: SocialStats.empty(),
        createdAt: now,
        updatedAt: now,
        privacySettings: UserPrivacySettings.defaultSettings(),
        badges: const ['verified'],
        level: 15,
        experiencePoints: 5000,
      );

      final result = mappers.profileToMap(profile);

      expect(result['displayName'], equals('John Doe'));
      expect(result['displayNameLowercase'], equals('john doe'));
      expect(result['email'], equals('john@example.com'));
      expect(result['profileImageUrl'], equals('https://example.com/photo.jpg'));
      expect(result['bio'], equals('Soccer fan'));
      expect(result['favoriteTeams'], equals(['USA', 'Brazil']));
      expect(result['homeLocation'], equals('New York'));
      expect(result['badges'], equals(['verified']));
      expect(result['level'], equals(15));
      expect(result['experiencePoints'], equals(5000));
      expect(result['createdAt'], isA<Timestamp>());
      expect(result['updatedAt'], isA<Timestamp>());
      expect(result['preferences'], isA<Map<String, dynamic>>());
      expect(result['socialStats'], isA<Map<String, dynamic>>());
      expect(result['privacySettings'], isA<Map<String, dynamic>>());
    });

    test('adds displayNameLowercase for case-insensitive search', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final profile = UserProfile(
        userId: 'user_1',
        displayName: 'MiXeD CaSe UsEr',
        preferences: UserPreferences.defaultPreferences(),
        socialStats: SocialStats.empty(),
        createdAt: now,
        updatedAt: now,
        privacySettings: UserPrivacySettings.defaultSettings(),
      );

      final result = mappers.profileToMap(profile);

      expect(result['displayNameLowercase'], equals('mixed case user'));
    });

    test('handles profile with null optional fields', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final profile = UserProfile(
        userId: 'user_minimal',
        displayName: 'Minimal',
        preferences: UserPreferences.defaultPreferences(),
        socialStats: SocialStats.empty(),
        createdAt: now,
        updatedAt: now,
        privacySettings: UserPrivacySettings.defaultSettings(),
      );

      final result = mappers.profileToMap(profile);

      expect(result['displayName'], equals('Minimal'));
      expect(result['email'], isNull);
      expect(result['profileImageUrl'], isNull);
      expect(result['bio'], isNull);
      expect(result['homeLocation'], isNull);
      expect(result['favoriteTeams'], isEmpty);
      expect(result['badges'], isEmpty);
    });

    test('full roundtrip profileToMap then parseProfileFromData', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final original = UserProfile(
        userId: 'roundtrip_user',
        displayName: 'Roundtrip Test',
        email: 'roundtrip@test.com',
        profileImageUrl: 'https://example.com/rt.jpg',
        bio: 'Testing roundtrip',
        favoriteTeams: const ['ARG', 'GER'],
        homeLocation: 'Buenos Aires',
        preferences: const UserPreferences(
          showLocation: false,
          maxTravelDistance: 20,
        ),
        socialStats: const SocialStats(
          friendsCount: 50,
          gamesAttended: 10,
        ),
        createdAt: now,
        updatedAt: now,
        privacySettings: const UserPrivacySettings(
          profileVisible: false,
          checkInVisibility: 'private',
        ),
        badges: const ['super_fan'],
        level: 25,
        experiencePoints: 10000,
      );

      final map = mappers.profileToMap(original);
      final restored = mappers.parseProfileFromData('roundtrip_user', map);

      expect(restored, isNotNull);
      expect(restored!.userId, equals(original.userId));
      expect(restored.displayName, equals(original.displayName));
      expect(restored.email, equals(original.email));
      expect(restored.bio, equals(original.bio));
      expect(restored.favoriteTeams, equals(original.favoriteTeams));
      expect(restored.homeLocation, equals(original.homeLocation));
      expect(restored.level, equals(original.level));
      expect(restored.experiencePoints, equals(original.experiencePoints));
      expect(restored.badges, equals(original.badges));
      expect(
        restored.preferences.showLocation,
        equals(original.preferences.showLocation),
      );
      expect(
        restored.preferences.maxTravelDistance,
        equals(original.preferences.maxTravelDistance),
      );
      expect(
        restored.socialStats.friendsCount,
        equals(original.socialStats.friendsCount),
      );
      expect(
        restored.privacySettings.profileVisible,
        equals(original.privacySettings.profileVisible),
      );
    });
  });
}
