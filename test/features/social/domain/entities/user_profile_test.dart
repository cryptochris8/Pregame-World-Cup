import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/domain/entities/user_profile.dart';

/// Tests for UserProfile and related classes
void main() {
  group('UserProfile', () {
    group('create factory', () {
      test('creates profile with required fields', () {
        final profile = UserProfile.create(
          userId: 'user_001',
          displayName: 'John Doe',
          email: 'john@example.com',
        );

        expect(profile.userId, equals('user_001'));
        expect(profile.displayName, equals('John Doe'));
        expect(profile.email, equals('john@example.com'));
        expect(profile.level, equals(1));
        expect(profile.experiencePoints, equals(0));
      });

      test('creates profile with default preferences', () {
        final profile = UserProfile.create(
          userId: 'user_002',
          displayName: 'Jane Doe',
        );

        expect(profile.preferences, isNotNull);
        expect(profile.privacySettings, isNotNull);
        expect(profile.socialStats, isNotNull);
      });

      test('creates profile with favorite teams', () {
        final profile = UserProfile.create(
          userId: 'user_003',
          displayName: 'Fan',
          favoriteTeams: const ['Brazil', 'Argentina'],
        );

        expect(profile.favoriteTeams, contains('Brazil'));
        expect(profile.favoriteTeams, contains('Argentina'));
      });
    });

    group('computed properties', () {
      test('isVerified returns true when badges contain verified', () {
        final profile = _createProfile(badges: ['verified', 'super_fan']);
        expect(profile.isVerified, isTrue);
      });

      test('isVerified returns false when badges do not contain verified', () {
        final profile = _createProfile(badges: ['super_fan']);
        expect(profile.isVerified, isFalse);
      });

      test('isSuperFan returns true when badges contain super_fan', () {
        final profile = _createProfile(badges: ['super_fan']);
        expect(profile.isSuperFan, isTrue);
      });

      test('isSuperFan returns false when badges do not contain super_fan', () {
        final profile = _createProfile(badges: ['verified']);
        expect(profile.isSuperFan, isFalse);
      });

      test('hasCompletedProfile returns true when all fields present', () {
        final profile = _createProfile(
          profileImageUrl: 'https://example.com/photo.jpg',
          bio: 'I love the World Cup!',
          favoriteTeams: ['Brazil'],
          homeLocation: 'Miami, FL',
        );
        expect(profile.hasCompletedProfile, isTrue);
      });

      test('hasCompletedProfile returns false when missing profileImageUrl', () {
        final profile = _createProfile(
          bio: 'I love the World Cup!',
          favoriteTeams: ['Brazil'],
          homeLocation: 'Miami, FL',
        );
        expect(profile.hasCompletedProfile, isFalse);
      });

      test('hasCompletedProfile returns false when missing bio', () {
        final profile = _createProfile(
          profileImageUrl: 'https://example.com/photo.jpg',
          favoriteTeams: ['Brazil'],
          homeLocation: 'Miami, FL',
        );
        expect(profile.hasCompletedProfile, isFalse);
      });

      test('hasCompletedProfile returns false when missing favorite teams', () {
        final profile = _createProfile(
          profileImageUrl: 'https://example.com/photo.jpg',
          bio: 'I love the World Cup!',
          homeLocation: 'Miami, FL',
        );
        expect(profile.hasCompletedProfile, isFalse);
      });

      test('hasCompletedProfile returns false when missing homeLocation', () {
        final profile = _createProfile(
          profileImageUrl: 'https://example.com/photo.jpg',
          bio: 'I love the World Cup!',
          favoriteTeams: ['Brazil'],
        );
        expect(profile.hasCompletedProfile, isFalse);
      });
    });

    group('levelTitle', () {
      test('returns Rookie for level < 5', () {
        expect(_createProfile(level: 1).levelTitle, equals('Rookie'));
        expect(_createProfile(level: 4).levelTitle, equals('Rookie'));
      });

      test('returns Rising Star for level 5-9', () {
        expect(_createProfile(level: 5).levelTitle, equals('Rising Star'));
        expect(_createProfile(level: 9).levelTitle, equals('Rising Star'));
      });

      test('returns Regular for level 10-19', () {
        expect(_createProfile(level: 10).levelTitle, equals('Regular'));
        expect(_createProfile(level: 19).levelTitle, equals('Regular'));
      });

      test('returns Veteran for level 20-29', () {
        expect(_createProfile(level: 20).levelTitle, equals('Veteran'));
        expect(_createProfile(level: 29).levelTitle, equals('Veteran'));
      });

      test('returns Super Fan for level 30-49', () {
        expect(_createProfile(level: 30).levelTitle, equals('Super Fan'));
        expect(_createProfile(level: 49).levelTitle, equals('Super Fan'));
      });

      test('returns Legend for level >= 50', () {
        expect(_createProfile(level: 50).levelTitle, equals('Legend'));
        expect(_createProfile(level: 100).levelTitle, equals('Legend'));
      });
    });

    group('online status', () {
      test('shouldShowOnlineStatus returns privacy setting value', () {
        final profile = _createProfile(
          privacySettings: const UserPrivacySettings(showOnlineStatus: true),
        );
        expect(profile.shouldShowOnlineStatus, isTrue);

        final profileHidden = _createProfile(
          privacySettings: const UserPrivacySettings(showOnlineStatus: false),
        );
        expect(profileHidden.shouldShowOnlineStatus, isFalse);
      });

      test('isRecentlyActive returns false when lastSeenAt is null', () {
        final profile = _createProfile(lastSeenAt: null);
        expect(profile.isRecentlyActive, isFalse);
      });

      test('isRecentlyActive returns true when seen within 15 minutes', () {
        final profile = _createProfile(
          lastSeenAt: DateTime.now().subtract(const Duration(minutes: 10)),
        );
        expect(profile.isRecentlyActive, isTrue);
      });

      test('isRecentlyActive returns false when seen over 15 minutes ago', () {
        final profile = _createProfile(
          lastSeenAt: DateTime.now().subtract(const Duration(minutes: 20)),
        );
        expect(profile.isRecentlyActive, isFalse);
      });

      test('lastSeenText returns Online when isOnline', () {
        final profile = _createProfile(isOnline: true);
        expect(profile.lastSeenText, equals('Online'));
      });

      test('lastSeenText returns Last seen unknown when null', () {
        final profile = _createProfile(lastSeenAt: null, isOnline: false);
        expect(profile.lastSeenText, equals('Last seen unknown'));
      });

      test('lastSeenText returns Just now for recent', () {
        final profile = _createProfile(
          isOnline: false,
          lastSeenAt: DateTime.now().subtract(const Duration(seconds: 30)),
        );
        expect(profile.lastSeenText, equals('Just now'));
      });

      test('lastSeenText returns minutes ago', () {
        final profile = _createProfile(
          isOnline: false,
          lastSeenAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );
        expect(profile.lastSeenText, equals('30m ago'));
      });

      test('lastSeenText returns hours ago', () {
        final profile = _createProfile(
          isOnline: false,
          lastSeenAt: DateTime.now().subtract(const Duration(hours: 5)),
        );
        expect(profile.lastSeenText, equals('5h ago'));
      });

      test('lastSeenText returns days ago for recent days', () {
        final profile = _createProfile(
          isOnline: false,
          lastSeenAt: DateTime.now().subtract(const Duration(days: 3)),
        );
        expect(profile.lastSeenText, equals('3d ago'));
      });

      test('lastSeenText returns Last seen Xd ago for over a week', () {
        final profile = _createProfile(
          isOnline: false,
          lastSeenAt: DateTime.now().subtract(const Duration(days: 10)),
        );
        expect(profile.lastSeenText, equals('Last seen 10d ago'));
      });
    });

    group('copyWith', () {
      test('copies with changed display name', () {
        final original = _createProfile();
        final copied = original.copyWith(displayName: 'New Name');

        expect(copied.displayName, equals('New Name'));
        expect(copied.userId, equals(original.userId));
      });

      test('copies with changed level', () {
        final original = _createProfile(level: 5);
        final copied = original.copyWith(level: 10);

        expect(copied.level, equals(10));
      });

      test('preserves createdAt when copying', () {
        final original = _createProfile();
        final copied = original.copyWith(displayName: 'New');

        expect(copied.createdAt, equals(original.createdAt));
      });
    });

    group('JSON serialization', () {
      test('toJson includes all fields', () {
        final profile = _createFullProfile();
        final json = profile.toJson();

        expect(json['userId'], equals('user_full'));
        expect(json['displayName'], equals('Full User'));
        expect(json['email'], equals('full@example.com'));
        expect(json['level'], equals(25));
        expect(json['experiencePoints'], equals(5000));
      });

      test('fromJson parses correctly', () {
        final json = <String, dynamic>{
          'userId': 'parsed_user',
          'displayName': 'Parsed User',
          'email': 'parsed@example.com',
          'favoriteTeams': <dynamic>['Germany', 'France'],
          'preferences': <String, dynamic>{},
          'socialStats': <String, dynamic>{},
          'privacySettings': <String, dynamic>{},
          'createdAt': '2024-01-01T00:00:00.000',
          'updatedAt': '2024-06-01T00:00:00.000',
          'level': 15,
          'experiencePoints': 2500,
          'badges': <dynamic>['verified'],
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.userId, equals('parsed_user'));
        expect(profile.displayName, equals('Parsed User'));
        expect(profile.level, equals(15));
        expect(profile.badges, contains('verified'));
      });
    });
  });

  group('UserPreferences', () {
    test('default constructor has correct defaults', () {
      const prefs = UserPreferences();

      expect(prefs.showLocation, isTrue);
      expect(prefs.allowFriendRequests, isTrue);
      expect(prefs.shareGameDayPlans, isTrue);
      expect(prefs.receiveNotifications, isTrue);
      expect(prefs.maxTravelDistance, equals(5));
      expect(prefs.autoShareCheckIns, isFalse);
      expect(prefs.joinGroupsAutomatically, isFalse);
    });

    test('defaultPreferences factory includes venue types', () {
      final prefs = UserPreferences.defaultPreferences();
      expect(prefs.preferredVenueTypes, contains('sports_bar'));
      expect(prefs.preferredVenueTypes, contains('restaurant'));
    });

    test('copyWith changes specified fields', () {
      const original = UserPreferences();
      final copied = original.copyWith(
        maxTravelDistance: 10,
        autoShareCheckIns: true,
      );

      expect(copied.maxTravelDistance, equals(10));
      expect(copied.autoShareCheckIns, isTrue);
      expect(copied.showLocation, isTrue); // unchanged
    });

    test('fromJson parses correctly', () {
      final json = {
        'showLocation': false,
        'maxTravelDistance': 15,
        'dietaryRestrictions': ['vegetarian', 'gluten-free'],
        'preferredPriceRange': '\$\$\$',
      };

      final prefs = UserPreferences.fromJson(json);

      expect(prefs.showLocation, isFalse);
      expect(prefs.maxTravelDistance, equals(15));
      expect(prefs.dietaryRestrictions, contains('vegetarian'));
      expect(prefs.preferredPriceRange, equals('\$\$\$'));
    });

    test('toJson serializes correctly', () {
      const prefs = UserPreferences(
        showLocation: false,
        maxTravelDistance: 20,
      );

      final json = prefs.toJson();

      expect(json['showLocation'], isFalse);
      expect(json['maxTravelDistance'], equals(20));
    });
  });

  group('SocialStats', () {
    test('empty factory creates all zeros', () {
      final stats = SocialStats.empty();

      expect(stats.friendsCount, equals(0));
      expect(stats.checkInsCount, equals(0));
      expect(stats.reviewsCount, equals(0));
      expect(stats.gamesAttended, equals(0));
      expect(stats.venuesVisited, equals(0));
      expect(stats.photosShared, equals(0));
      expect(stats.likesReceived, equals(0));
      expect(stats.helpfulVotes, equals(0));
      expect(stats.lastActivity, isNull);
    });

    test('totalActivity calculates sum correctly', () {
      const stats = SocialStats(
        checkInsCount: 10,
        reviewsCount: 5,
        photosShared: 20,
        gamesAttended: 15,
      );

      expect(stats.totalActivity, equals(50));
    });

    test('copyWith changes specified fields', () {
      final stats = SocialStats.empty();
      final updated = stats.copyWith(
        friendsCount: 100,
        checkInsCount: 50,
      );

      expect(updated.friendsCount, equals(100));
      expect(updated.checkInsCount, equals(50));
      expect(updated.reviewsCount, equals(0)); // unchanged
    });

    test('fromJson parses correctly', () {
      final json = {
        'friendsCount': 250,
        'checkInsCount': 75,
        'gamesAttended': 30,
        'lastActivity': '2024-12-01T12:00:00.000',
      };

      final stats = SocialStats.fromJson(json);

      expect(stats.friendsCount, equals(250));
      expect(stats.checkInsCount, equals(75));
      expect(stats.gamesAttended, equals(30));
      expect(stats.lastActivity, isNotNull);
    });

    test('toJson serializes correctly', () {
      const stats = SocialStats(
        friendsCount: 100,
        likesReceived: 500,
      );

      final json = stats.toJson();

      expect(json['friendsCount'], equals(100));
      expect(json['likesReceived'], equals(500));
    });
  });

  group('UserPrivacySettings', () {
    test('default constructor has correct defaults', () {
      const settings = UserPrivacySettings();

      expect(settings.profileVisible, isTrue);
      expect(settings.showRealName, isTrue);
      expect(settings.showLocation, isTrue);
      expect(settings.showFavoriteTeams, isTrue);
      expect(settings.allowMessaging, isTrue);
      expect(settings.showOnlineStatus, isTrue);
      expect(settings.checkInVisibility, equals('friends'));
      expect(settings.friendListVisibility, equals('friends'));
    });

    test('defaultSettings factory returns defaults', () {
      final settings = UserPrivacySettings.defaultSettings();
      expect(settings.profileVisible, isTrue);
    });

    test('copyWith changes specified fields', () {
      const original = UserPrivacySettings();
      final copied = original.copyWith(
        profileVisible: false,
        checkInVisibility: 'private',
      );

      expect(copied.profileVisible, isFalse);
      expect(copied.checkInVisibility, equals('private'));
      expect(copied.showRealName, isTrue); // unchanged
    });

    test('fromJson parses correctly', () {
      final json = {
        'profileVisible': false,
        'showOnlineStatus': false,
        'checkInVisibility': 'public',
      };

      final settings = UserPrivacySettings.fromJson(json);

      expect(settings.profileVisible, isFalse);
      expect(settings.showOnlineStatus, isFalse);
      expect(settings.checkInVisibility, equals('public'));
    });

    test('toJson serializes correctly', () {
      const settings = UserPrivacySettings(
        profileVisible: false,
        friendListVisibility: 'private',
      );

      final json = settings.toJson();

      expect(json['profileVisible'], isFalse);
      expect(json['friendListVisibility'], equals('private'));
    });
  });
}

/// Helper function to create a minimal UserProfile
UserProfile _createProfile({
  String userId = 'test_user',
  String displayName = 'Test User',
  List<String> badges = const [],
  int level = 1,
  String? profileImageUrl,
  String? bio,
  List<String> favoriteTeams = const [],
  String? homeLocation,
  UserPrivacySettings privacySettings = const UserPrivacySettings(),
  bool isOnline = false,
  DateTime? lastSeenAt,
}) {
  final now = DateTime.now();
  return UserProfile(
    userId: userId,
    displayName: displayName,
    badges: badges,
    level: level,
    profileImageUrl: profileImageUrl,
    bio: bio,
    favoriteTeams: favoriteTeams,
    homeLocation: homeLocation,
    preferences: const UserPreferences(),
    socialStats: const SocialStats(),
    createdAt: now,
    updatedAt: now,
    privacySettings: privacySettings,
    isOnline: isOnline,
    lastSeenAt: lastSeenAt,
  );
}

/// Helper function to create a full UserProfile
UserProfile _createFullProfile() {
  final now = DateTime.now();
  return UserProfile(
    userId: 'user_full',
    displayName: 'Full User',
    email: 'full@example.com',
    profileImageUrl: 'https://example.com/photo.jpg',
    bio: 'I am a huge World Cup fan!',
    favoriteTeams: const ['Brazil', 'Argentina', 'Germany'],
    homeLocation: 'Miami, FL',
    preferences: const UserPreferences(
      maxTravelDistance: 10,
      preferredVenueTypes: ['sports_bar'],
    ),
    socialStats: const SocialStats(
      friendsCount: 150,
      checkInsCount: 50,
      gamesAttended: 25,
    ),
    createdAt: now.subtract(const Duration(days: 365)),
    updatedAt: now,
    privacySettings: const UserPrivacySettings(),
    badges: const ['verified', 'super_fan'],
    level: 25,
    experiencePoints: 5000,
    isOnline: true,
    lastSeenAt: now,
  );
}
