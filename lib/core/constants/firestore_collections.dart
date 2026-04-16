/// Centralized Firestore collection name constants.
///
/// Use these constants instead of hardcoded strings when referencing
/// Firestore collections. This prevents typos and makes renames easy.
class FirestoreCollections {
  FirestoreCollections._(); // Prevent instantiation

  // ── User & Auth ──────────────────────────────────────────────
  static const String users = 'users';
  static const String userProfiles = 'user_profiles';
  static const String userFavorites = 'userFavorites';
  static const String socialProfiles = 'social_profiles';

  // ── Social ───────────────────────────────────────────────────
  static const String socialConnections = 'social_connections';
  static const String friendships = 'friendships';
  static const String friendRequestNotifications = 'friend_request_notifications';

  // ── Activity Feed ────────────────────────────────────────────
  static const String activities = 'activities';
  static const String activityLikes = 'activity_likes';
  static const String activityComments = 'activity_comments';

  // ── Messaging ────────────────────────────────────────────────
  static const String chats = 'chats';
  static const String messages = 'messages';
  static const String messageNotifications = 'message_notifications';
  static const String typingIndicators = 'typing_indicators';
  static const String userChatSettings = 'user_chat_settings';

  // ── Notifications ────────────────────────────────────────────
  static const String notifications = 'notifications';
  static const String notificationPreferences = 'notification_preferences';
  static const String broadcastNotifications = 'broadcast_notifications';

  // ── Watch Party ──────────────────────────────────────────────
  static const String watchParties = 'watch_parties';
  static const String members = 'members';
  static const String watchPartyInvites = 'watch_party_invites';
  static const String watchPartyVirtualPayments = 'watch_party_virtual_payments';

  // ── Predictions & Matches ────────────────────────────────────
  static const String predictions = 'predictions';
  static const String userPredictions = 'user_predictions';
  static const String worldcupMatches = 'worldcup_matches';
  static const String comments = 'comments';

  // ── Moderation & Reports ─────────────────────────────────────
  static const String reports = 'reports';
  static const String userSanctions = 'user_sanctions';
  static const String userModerationStatus = 'user_moderation_status';

  // ── Payments & Venues ────────────────────────────────────────
  static const String worldCupFanPasses = 'world_cup_fan_passes';
  static const String worldCupVenuePurchases = 'world_cup_venue_purchases';
  static const String venueEnhancements = 'venue_enhancements';
  static const String venueDisputes = 'venue_disputes';

  // ── User Learning / Behavior ─────────────────────────────────
  static const String userInteractions = 'user_interactions';
  static const String venueInteractions = 'venue_interactions';
  static const String teamPreferences = 'team_preferences';
  static const String userBehaviorSummary = 'user_behavior_summary';

  /// All collection names used in this app, for validation purposes.
  static const List<String> allCollections = [
    users,
    userProfiles,
    userFavorites,
    socialProfiles,
    socialConnections,
    friendships,
    friendRequestNotifications,
    activities,
    activityLikes,
    activityComments,
    chats,
    messages,
    messageNotifications,
    typingIndicators,
    userChatSettings,
    notifications,
    notificationPreferences,
    broadcastNotifications,
    watchParties,
    members,
    watchPartyInvites,
    watchPartyVirtualPayments,
    predictions,
    userPredictions,
    worldcupMatches,
    comments,
    reports,
    userSanctions,
    userModerationStatus,
    worldCupFanPasses,
    worldCupVenuePurchases,
    venueEnhancements,
    venueDisputes,
    userInteractions,
    venueInteractions,
    teamPreferences,
    userBehaviorSummary,
  ];
}
