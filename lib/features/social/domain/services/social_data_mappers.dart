import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/user_profile.dart';
import '../../../../core/services/logging_service.dart';

/// Handles serialization and deserialization of social domain entities.
/// Converts between Firestore documents and domain objects for
/// UserPreferences, SocialStats, UserPrivacySettings, and UserProfile.
class SocialDataMappers {
  static const String _logTag = 'SocialDataMappers';

  // -- Parsing from Firestore --

  UserPreferences parsePreferences(Map<String, dynamic>? data) {
    if (data == null) return UserPreferences.defaultPreferences();

    return UserPreferences(
      showLocation: data['showLocation'] ?? true,
      allowFriendRequests: data['allowFriendRequests'] ?? true,
      shareGameDayPlans: data['shareGameDayPlans'] ?? true,
      receiveNotifications: data['receiveNotifications'] ?? true,
      preferredVenueTypes: List<String>.from(data['preferredVenueTypes'] ?? []),
      maxTravelDistance: data['maxTravelDistance'] ?? 5,
      dietaryRestrictions: List<String>.from(data['dietaryRestrictions'] ?? []),
      preferredPriceRange: data['preferredPriceRange'] ?? '\$\$',
      autoShareCheckIns: data['autoShareCheckIns'] ?? false,
      joinGroupsAutomatically: data['joinGroupsAutomatically'] ?? false,
    );
  }

  SocialStats parseSocialStats(Map<String, dynamic>? data) {
    if (data == null) return SocialStats.empty();

    return SocialStats(
      friendsCount: data['friendsCount'] ?? 0,
      checkInsCount: data['checkInsCount'] ?? 0,
      reviewsCount: data['reviewsCount'] ?? 0,
      gamesAttended: data['gamesAttended'] ?? 0,
      venuesVisited: data['venuesVisited'] ?? 0,
      photosShared: data['photosShared'] ?? 0,
      likesReceived: data['likesReceived'] ?? 0,
      helpfulVotes: data['helpfulVotes'] ?? 0,
      lastActivity: data['lastActivity'] != null
          ? (data['lastActivity'] as Timestamp).toDate()
          : null,
    );
  }

  UserPrivacySettings parsePrivacySettings(Map<String, dynamic>? data) {
    if (data == null) return UserPrivacySettings.defaultSettings();

    return UserPrivacySettings(
      profileVisible: data['profileVisible'] ?? true,
      showRealName: data['showRealName'] ?? true,
      showLocation: data['showLocation'] ?? true,
      showFavoriteTeams: data['showFavoriteTeams'] ?? true,
      allowMessaging: data['allowMessaging'] ?? true,
      showOnlineStatus: data['showOnlineStatus'] ?? true,
      checkInVisibility: data['checkInVisibility'] ?? 'friends',
      friendListVisibility: data['friendListVisibility'] ?? 'friends',
    );
  }

  UserProfile? parseProfileFromData(String userId, Map<String, dynamic> data) {
    try {
      return UserProfile(
        userId: userId,
        displayName: data['displayName'] ?? 'Unknown User',
        email: data['email'],
        profileImageUrl: data['profileImageUrl'],
        bio: data['bio'],
        favoriteTeams: List<String>.from(data['favoriteTeams'] ?? []),
        homeLocation: data['homeLocation'],
        preferences: parsePreferences(data['preferences']),
        socialStats: parseSocialStats(data['socialStats']),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        privacySettings: parsePrivacySettings(data['privacySettings']),
        badges: List<String>.from(data['badges'] ?? []),
        level: data['level'] ?? 1,
        experiencePoints: data['experiencePoints'] ?? 0,
      );
    } catch (e) {
      LoggingService.error('Error parsing profile: $e', tag: _logTag);
      return null;
    }
  }

  UserProfile? parseProfileFromDoc(DocumentSnapshot doc) {
    try {
      if (!doc.exists || doc.data() == null) return null;

      final data = Map<String, dynamic>.from(doc.data()! as Map);
      return parseProfileFromData(doc.id, data);
    } catch (e) {
      LoggingService.error('Error parsing profile from doc: $e', tag: _logTag);
      return null;
    }
  }

  // -- Serialization to Firestore --

  Map<String, dynamic> preferencesToMap(UserPreferences preferences) {
    return {
      'showLocation': preferences.showLocation,
      'allowFriendRequests': preferences.allowFriendRequests,
      'shareGameDayPlans': preferences.shareGameDayPlans,
      'receiveNotifications': preferences.receiveNotifications,
      'preferredVenueTypes': preferences.preferredVenueTypes,
      'maxTravelDistance': preferences.maxTravelDistance,
      'dietaryRestrictions': preferences.dietaryRestrictions,
      'preferredPriceRange': preferences.preferredPriceRange,
      'autoShareCheckIns': preferences.autoShareCheckIns,
      'joinGroupsAutomatically': preferences.joinGroupsAutomatically,
    };
  }

  Map<String, dynamic> socialStatsToMap(SocialStats stats) {
    return {
      'friendsCount': stats.friendsCount,
      'checkInsCount': stats.checkInsCount,
      'reviewsCount': stats.reviewsCount,
      'gamesAttended': stats.gamesAttended,
      'venuesVisited': stats.venuesVisited,
      'photosShared': stats.photosShared,
      'likesReceived': stats.likesReceived,
      'helpfulVotes': stats.helpfulVotes,
      'lastActivity': stats.lastActivity != null
          ? Timestamp.fromDate(stats.lastActivity!)
          : null,
    };
  }

  Map<String, dynamic> privacySettingsToMap(UserPrivacySettings settings) {
    return {
      'profileVisible': settings.profileVisible,
      'showRealName': settings.showRealName,
      'showLocation': settings.showLocation,
      'showFavoriteTeams': settings.showFavoriteTeams,
      'allowMessaging': settings.allowMessaging,
      'showOnlineStatus': settings.showOnlineStatus,
      'checkInVisibility': settings.checkInVisibility,
      'friendListVisibility': settings.friendListVisibility,
    };
  }

  Map<String, dynamic> profileToMap(UserProfile profile) {
    return {
      'displayName': profile.displayName,
      'displayNameLowercase': profile.displayName.toLowerCase(),
      'email': profile.email,
      'profileImageUrl': profile.profileImageUrl,
      'bio': profile.bio,
      'favoriteTeams': profile.favoriteTeams,
      'homeLocation': profile.homeLocation,
      'preferences': preferencesToMap(profile.preferences),
      'socialStats': socialStatsToMap(profile.socialStats),
      'createdAt': Timestamp.fromDate(profile.createdAt),
      'updatedAt': Timestamp.fromDate(profile.updatedAt),
      'privacySettings': privacySettingsToMap(profile.privacySettings),
      'badges': profile.badges,
      'level': profile.level,
      'experiencePoints': profile.experiencePoints,
    };
  }
}
