import 'package:pregame_world_cup/features/social/domain/entities/user_profile.dart';
import 'package:pregame_world_cup/features/social/domain/entities/social_connection.dart';

/// Test data factories for social entities
class SocialTestFactory {
  static SocialStats createSocialStats({
    int friendsCount = 42,
    int checkInsCount = 15,
    int reviewsCount = 8,
    int gamesAttended = 12,
    int venuesVisited = 25,
    int photosShared = 30,
    int likesReceived = 150,
    int helpfulVotes = 20,
  }) {
    return SocialStats(
      friendsCount: friendsCount,
      checkInsCount: checkInsCount,
      reviewsCount: reviewsCount,
      gamesAttended: gamesAttended,
      venuesVisited: venuesVisited,
      photosShared: photosShared,
      likesReceived: likesReceived,
      helpfulVotes: helpfulVotes,
    );
  }

  static UserPreferences createUserPreferences({
    bool showLocation = true,
    bool allowFriendRequests = true,
    bool shareGameDayPlans = true,
    bool receiveNotifications = true,
    List<String> preferredVenueTypes = const ['sports_bar', 'restaurant'],
    int maxTravelDistance = 5,
  }) {
    return UserPreferences(
      showLocation: showLocation,
      allowFriendRequests: allowFriendRequests,
      shareGameDayPlans: shareGameDayPlans,
      receiveNotifications: receiveNotifications,
      preferredVenueTypes: preferredVenueTypes,
      maxTravelDistance: maxTravelDistance,
    );
  }

  static UserPrivacySettings createPrivacySettings({
    bool profileVisible = true,
    bool showRealName = true,
    bool showLocation = true,
    bool showFavoriteTeams = true,
    bool allowMessaging = true,
    bool showOnlineStatus = true,
    String checkInVisibility = 'friends',
    String friendListVisibility = 'friends',
  }) {
    return UserPrivacySettings(
      profileVisible: profileVisible,
      showRealName: showRealName,
      showLocation: showLocation,
      showFavoriteTeams: showFavoriteTeams,
      allowMessaging: allowMessaging,
      showOnlineStatus: showOnlineStatus,
      checkInVisibility: checkInVisibility,
      friendListVisibility: friendListVisibility,
    );
  }

  static UserProfile createUserProfile({
    String userId = 'user_123',
    String displayName = 'John Doe',
    String? email = 'john@example.com',
    String? profileImageUrl,
    String? bio = 'Soccer fan from NYC',
    List<String> favoriteTeams = const ['USA', 'Manchester United'],
    String? homeLocation = 'New York, NY',
    SocialStats? socialStats,
    UserPreferences? preferences,
    UserPrivacySettings? privacySettings,
    List<String> badges = const [],
    int level = 5,
    int experiencePoints = 500,
    bool isOnline = false,
    DateTime? lastSeenAt,
  }) {
    final now = DateTime.now();
    return UserProfile(
      userId: userId,
      displayName: displayName,
      email: email,
      profileImageUrl: profileImageUrl,
      bio: bio,
      favoriteTeams: favoriteTeams,
      homeLocation: homeLocation,
      socialStats: socialStats ?? createSocialStats(),
      preferences: preferences ?? createUserPreferences(),
      privacySettings: privacySettings ?? createPrivacySettings(),
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now,
      badges: badges,
      level: level,
      experiencePoints: experiencePoints,
      isOnline: isOnline,
      lastSeenAt: lastSeenAt,
    );
  }

  static SocialConnection createSocialConnection({
    String connectionId = 'conn_123',
    String fromUserId = 'user_456',
    String toUserId = 'user_123',
    ConnectionType type = ConnectionType.friend,
    ConnectionStatus status = ConnectionStatus.pending,
    DateTime? createdAt,
    DateTime? acceptedAt,
    String? connectionSource,
    String? connectedUserName = 'Jane Smith',
  }) {
    final now = DateTime.now();
    return SocialConnection(
      connectionId: connectionId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      type: type,
      status: status,
      createdAt: createdAt ?? now.subtract(const Duration(hours: 2)),
      acceptedAt: acceptedAt,
      connectionSource: connectionSource,
      metadata: connectedUserName != null
          ? {'connectedUserName': connectedUserName}
          : {},
    );
  }

  static FriendSuggestion createFriendSuggestion({
    String userId = 'suggested_user_123',
    String displayName = 'Suggested User',
    String? profileImageUrl,
    List<String> mutualFriends = const ['friend_1', 'friend_2'],
    List<String> sharedTeams = const ['USA'],
    String? connectionReason,
    double relevanceScore = 0.85,
  }) {
    return FriendSuggestion(
      userId: userId,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      mutualFriends: mutualFriends,
      sharedTeams: sharedTeams,
      connectionReason: connectionReason,
      relevanceScore: relevanceScore,
      suggestedAt: DateTime.now(),
    );
  }
}
