import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 4)
class UserProfile extends Equatable {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final String displayName;
  
  @HiveField(2)
  final String? email;
  
  @HiveField(3)
  final String? profileImageUrl;
  
  @HiveField(4)
  final String? bio;
  
  @HiveField(5)
  final List<String> favoriteTeams;
  
  @HiveField(6)
  final String? homeLocation;
  
  @HiveField(7)
  final UserPreferences preferences;
  
  @HiveField(8)
  final SocialStats socialStats;
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  final DateTime updatedAt;
  
  @HiveField(11)
  final UserPrivacySettings privacySettings;
  
  @HiveField(12)
  final List<String> badges;
  
  @HiveField(13)
  final int level;
  
  @HiveField(14)
  final int experiencePoints;
  
  @HiveField(15)
  final bool isOnline;
  
  @HiveField(16)
  final DateTime? lastSeenAt;

  const UserProfile({
    required this.userId,
    required this.displayName,
    this.email,
    this.profileImageUrl,
    this.bio,
    this.favoriteTeams = const [],
    this.homeLocation,
    required this.preferences,
    required this.socialStats,
    required this.createdAt,
    required this.updatedAt,
    required this.privacySettings,
    this.badges = const [],
    this.level = 1,
    this.experiencePoints = 0,
    this.isOnline = false,
    this.lastSeenAt,
  });

  factory UserProfile.create({
    required String userId,
    required String displayName,
    String? email,
    List<String>? favoriteTeams,
  }) {
    final now = DateTime.now();
    return UserProfile(
      userId: userId,
      displayName: displayName,
      email: email,
      favoriteTeams: favoriteTeams ?? [],
      preferences: UserPreferences.defaultPreferences(),
      socialStats: SocialStats.empty(),
      createdAt: now,
      updatedAt: now,
      privacySettings: UserPrivacySettings.defaultSettings(),
    );
  }

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? profileImageUrl,
    String? bio,
    List<String>? favoriteTeams,
    String? homeLocation,
    UserPreferences? preferences,
    SocialStats? socialStats,
    DateTime? updatedAt,
    UserPrivacySettings? privacySettings,
    List<String>? badges,
    int? level,
    int? experiencePoints,
    bool? isOnline,
    DateTime? lastSeenAt,
  }) {
    return UserProfile(
      userId: userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      favoriteTeams: favoriteTeams ?? this.favoriteTeams,
      homeLocation: homeLocation ?? this.homeLocation,
      preferences: preferences ?? this.preferences,
      socialStats: socialStats ?? this.socialStats,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      privacySettings: privacySettings ?? this.privacySettings,
      badges: badges ?? this.badges,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  // Getters for computed properties
  bool get isVerified => badges.contains('verified');
  bool get isSuperFan => badges.contains('super_fan');
  bool get hasCompletedProfile => 
      profileImageUrl != null && 
      bio != null && 
      favoriteTeams.isNotEmpty &&
      homeLocation != null;

  String get levelTitle {
    if (level >= 50) return 'Legend';
    if (level >= 30) return 'Super Fan';
    if (level >= 20) return 'Veteran';
    if (level >= 10) return 'Regular';
    if (level >= 5) return 'Rising Star';
    return 'Rookie';
  }

  // Online status helpers
  bool get shouldShowOnlineStatus => privacySettings.showOnlineStatus;
  
  bool get isRecentlyActive {
    if (lastSeenAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastSeenAt!);
    return difference.inMinutes <= 15; // Consider active if seen within 15 minutes
  }
  
  String get lastSeenText {
    if (isOnline) return 'Online';
    if (lastSeenAt == null) return 'Last seen unknown';
    
    final now = DateTime.now();
    final difference = now.difference(lastSeenAt!);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return 'Last seen ${difference.inDays}d ago';
  }

  // JSON serialization
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      profileImageUrl: json['imageUrl'] as String?,
      bio: json['bio'] as String?,
      favoriteTeams: List<String>.from(json['favoriteTeams'] ?? []),
      homeLocation: json['location'] as String?,
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      socialStats: SocialStats.fromJson(json['socialStats'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.parse(json['createdAt'] as String),
      privacySettings: UserPrivacySettings.fromJson(json['privacySettings'] ?? {}),
      badges: List<String>.from(json['badges'] ?? []),
      level: json['level'] as int? ?? 1,
      experiencePoints: json['experiencePoints'] as int? ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeenAt: json['lastSeenAt'] != null 
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'imageUrl': profileImageUrl,
      'bio': bio,
      'location': homeLocation,
      'favoriteTeams': favoriteTeams,
      'preferences': preferences.toJson(),
      'socialStats': socialStats.toJson(),
      'badges': badges,
      'level': level,
      'experiencePoints': experiencePoints,
      'isOnline': isOnline,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'privacySettings': privacySettings.toJson(),
    };
  }

  /// Create UserProfile from Firestore document
  factory UserProfile.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserProfile(
      userId: documentId, // Use document ID as user ID
      displayName: data['displayName'] as String? ?? 'Anonymous User',
      email: data['email'] as String?,
      profileImageUrl: data['imageUrl'] as String?,
      bio: data['bio'] as String?,
      favoriteTeams: List<String>.from(data['favoriteTeams'] ?? []),
      homeLocation: data['location'] as String?,
      preferences: UserPreferences.fromJson(data['preferences'] ?? {}),
      socialStats: SocialStats.fromJson(data['socialStats'] ?? {}),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] is String 
              ? DateTime.parse(data['createdAt'])
              : (data['createdAt'] as Timestamp).toDate())
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] is String 
              ? DateTime.parse(data['updatedAt'])
              : (data['updatedAt'] as Timestamp).toDate())
          : DateTime.now(),
      privacySettings: UserPrivacySettings.fromJson(data['privacySettings'] ?? {}),
      badges: List<String>.from(data['badges'] ?? []),
      level: data['level'] as int? ?? 1,
      experiencePoints: data['experiencePoints'] as int? ?? 0,
      isOnline: data['isOnline'] as bool? ?? false,
      lastSeenAt: data['lastSeenAt'] != null 
          ? (data['lastSeenAt'] is String 
              ? DateTime.parse(data['lastSeenAt'])
              : (data['lastSeenAt'] as Timestamp).toDate())
          : null,
    );
  }

  /// Convert UserProfile to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'imageUrl': profileImageUrl,
      'bio': bio,
      'location': homeLocation,
      'favoriteTeams': favoriteTeams,
      'preferences': preferences.toJson(),
      'socialStats': socialStats.toJson(),
      'badges': badges,
      'level': level,
      'experiencePoints': experiencePoints,
      'isOnline': isOnline,
      'lastSeenAt': lastSeenAt != null ? Timestamp.fromDate(lastSeenAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'privacySettings': privacySettings.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        userId,
        displayName,
        email,
        profileImageUrl,
        bio,
        favoriteTeams,
        homeLocation,
        preferences,
        socialStats,
        createdAt,
        updatedAt,
        privacySettings,
        badges,
        level,
        experiencePoints,
        isOnline,
        lastSeenAt,
      ];
}

@HiveType(typeId: 5)
class UserPreferences extends Equatable {
  @HiveField(0)
  final bool showLocation;
  
  @HiveField(1)
  final bool allowFriendRequests;
  
  @HiveField(2)
  final bool shareGameDayPlans;
  
  @HiveField(3)
  final bool receiveNotifications;
  
  @HiveField(4)
  final List<String> preferredVenueTypes;
  
  @HiveField(5)
  final int maxTravelDistance; // km
  
  @HiveField(6)
  final List<String> dietaryRestrictions;
  
  @HiveField(7)
  final String preferredPriceRange; // $, $$, $$$, $$$$
  
  @HiveField(8)
  final bool autoShareCheckIns;
  
  @HiveField(9)
  final bool joinGroupsAutomatically;

  const UserPreferences({
    this.showLocation = true,
    this.allowFriendRequests = true,
    this.shareGameDayPlans = true,
    this.receiveNotifications = true,
    this.preferredVenueTypes = const [],
    this.maxTravelDistance = 5,
    this.dietaryRestrictions = const [],
    this.preferredPriceRange = '\$\$',
    this.autoShareCheckIns = false,
    this.joinGroupsAutomatically = false,
  });

  factory UserPreferences.defaultPreferences() {
    return const UserPreferences(
      preferredVenueTypes: ['sports_bar', 'restaurant'],
    );
  }

  UserPreferences copyWith({
    bool? showLocation,
    bool? allowFriendRequests,
    bool? shareGameDayPlans,
    bool? receiveNotifications,
    List<String>? preferredVenueTypes,
    int? maxTravelDistance,
    List<String>? dietaryRestrictions,
    String? preferredPriceRange,
    bool? autoShareCheckIns,
    bool? joinGroupsAutomatically,
  }) {
    return UserPreferences(
      showLocation: showLocation ?? this.showLocation,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      shareGameDayPlans: shareGameDayPlans ?? this.shareGameDayPlans,
      receiveNotifications: receiveNotifications ?? this.receiveNotifications,
      preferredVenueTypes: preferredVenueTypes ?? this.preferredVenueTypes,
      maxTravelDistance: maxTravelDistance ?? this.maxTravelDistance,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      preferredPriceRange: preferredPriceRange ?? this.preferredPriceRange,
      autoShareCheckIns: autoShareCheckIns ?? this.autoShareCheckIns,
      joinGroupsAutomatically: joinGroupsAutomatically ?? this.joinGroupsAutomatically,
    );
  }

  // JSON serialization
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      showLocation: json['showLocation'] as bool? ?? true,
      allowFriendRequests: json['allowFriendRequests'] as bool? ?? true,
      shareGameDayPlans: json['shareGameDayPlans'] as bool? ?? true,
      receiveNotifications: json['receiveNotifications'] as bool? ?? true,
      preferredVenueTypes: List<String>.from(json['preferredVenueTypes'] ?? []),
      maxTravelDistance: json['maxTravelDistance'] as int? ?? 5,
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions'] ?? []),
      preferredPriceRange: json['preferredPriceRange'] as String? ?? '\$\$',
      autoShareCheckIns: json['autoShareCheckIns'] as bool? ?? false,
      joinGroupsAutomatically: json['joinGroupsAutomatically'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showLocation': showLocation,
      'allowFriendRequests': allowFriendRequests,
      'shareGameDayPlans': shareGameDayPlans,
      'receiveNotifications': receiveNotifications,
      'preferredVenueTypes': preferredVenueTypes,
      'maxTravelDistance': maxTravelDistance,
      'dietaryRestrictions': dietaryRestrictions,
      'preferredPriceRange': preferredPriceRange,
      'autoShareCheckIns': autoShareCheckIns,
      'joinGroupsAutomatically': joinGroupsAutomatically,
    };
  }

  @override
  List<Object?> get props => [
        showLocation,
        allowFriendRequests,
        shareGameDayPlans,
        receiveNotifications,
        preferredVenueTypes,
        maxTravelDistance,
        dietaryRestrictions,
        preferredPriceRange,
        autoShareCheckIns,
        joinGroupsAutomatically,
      ];
}

@HiveType(typeId: 6)
class SocialStats extends Equatable {
  @HiveField(0)
  final int friendsCount;
  
  @HiveField(1)
  final int checkInsCount;
  
  @HiveField(2)
  final int reviewsCount;
  
  @HiveField(3)
  final int gamesAttended;
  
  @HiveField(4)
  final int venuesVisited;
  
  @HiveField(5)
  final int photosShared;
  
  @HiveField(6)
  final int likesReceived;
  
  @HiveField(7)
  final int helpfulVotes;
  
  @HiveField(8)
  final DateTime? lastActivity;

  const SocialStats({
    this.friendsCount = 0,
    this.checkInsCount = 0,
    this.reviewsCount = 0,
    this.gamesAttended = 0,
    this.venuesVisited = 0,
    this.photosShared = 0,
    this.likesReceived = 0,
    this.helpfulVotes = 0,
    this.lastActivity,
  });

  factory SocialStats.empty() => const SocialStats();

  SocialStats copyWith({
    int? friendsCount,
    int? checkInsCount,
    int? reviewsCount,
    int? gamesAttended,
    int? venuesVisited,
    int? photosShared,
    int? likesReceived,
    int? helpfulVotes,
    DateTime? lastActivity,
  }) {
    return SocialStats(
      friendsCount: friendsCount ?? this.friendsCount,
      checkInsCount: checkInsCount ?? this.checkInsCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      gamesAttended: gamesAttended ?? this.gamesAttended,
      venuesVisited: venuesVisited ?? this.venuesVisited,
      photosShared: photosShared ?? this.photosShared,
      likesReceived: likesReceived ?? this.likesReceived,
      helpfulVotes: helpfulVotes ?? this.helpfulVotes,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  int get totalActivity => 
      checkInsCount + reviewsCount + photosShared + gamesAttended;

  // JSON serialization
  factory SocialStats.fromJson(Map<String, dynamic> json) {
    return SocialStats(
      friendsCount: json['friendsCount'] as int? ?? 0,
      checkInsCount: json['checkInsCount'] as int? ?? 0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      gamesAttended: json['gamesAttended'] as int? ?? 0,
      venuesVisited: json['venuesVisited'] as int? ?? 0,
      photosShared: json['photosShared'] as int? ?? 0,
      likesReceived: json['likesReceived'] as int? ?? 0,
      helpfulVotes: json['helpfulVotes'] as int? ?? 0,
      lastActivity: json['lastActivity'] != null 
          ? DateTime.parse(json['lastActivity'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'friendsCount': friendsCount,
      'checkInsCount': checkInsCount,
      'reviewsCount': reviewsCount,
      'gamesAttended': gamesAttended,
      'venuesVisited': venuesVisited,
      'photosShared': photosShared,
      'likesReceived': likesReceived,
      'helpfulVotes': helpfulVotes,
      'lastActivity': lastActivity?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        friendsCount,
        checkInsCount,
        reviewsCount,
        gamesAttended,
        venuesVisited,
        photosShared,
        likesReceived,
        helpfulVotes,
        lastActivity,
      ];
}

@HiveType(typeId: 7)
class UserPrivacySettings extends Equatable {
  @HiveField(0)
  final bool profileVisible;
  
  @HiveField(1)
  final bool showRealName;
  
  @HiveField(2)
  final bool showLocation;
  
  @HiveField(3)
  final bool showFavoriteTeams;
  
  @HiveField(4)
  final bool allowMessaging;
  
  @HiveField(5)
  final bool showOnlineStatus;
  
  @HiveField(6)
  final String checkInVisibility; // public, friends, private
  
  @HiveField(7)
  final String friendListVisibility; // public, friends, private

  const UserPrivacySettings({
    this.profileVisible = true,
    this.showRealName = true,
    this.showLocation = true,
    this.showFavoriteTeams = true,
    this.allowMessaging = true,
    this.showOnlineStatus = true,
    this.checkInVisibility = 'friends',
    this.friendListVisibility = 'friends',
  });

  factory UserPrivacySettings.defaultSettings() {
    return const UserPrivacySettings();
  }

  UserPrivacySettings copyWith({
    bool? profileVisible,
    bool? showRealName,
    bool? showLocation,
    bool? showFavoriteTeams,
    bool? allowMessaging,
    bool? showOnlineStatus,
    String? checkInVisibility,
    String? friendListVisibility,
  }) {
    return UserPrivacySettings(
      profileVisible: profileVisible ?? this.profileVisible,
      showRealName: showRealName ?? this.showRealName,
      showLocation: showLocation ?? this.showLocation,
      showFavoriteTeams: showFavoriteTeams ?? this.showFavoriteTeams,
      allowMessaging: allowMessaging ?? this.allowMessaging,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      checkInVisibility: checkInVisibility ?? this.checkInVisibility,
      friendListVisibility: friendListVisibility ?? this.friendListVisibility,
    );
  }

  // JSON serialization
  factory UserPrivacySettings.fromJson(Map<String, dynamic> json) {
    return UserPrivacySettings(
      profileVisible: json['profileVisible'] as bool? ?? true,
      showRealName: json['showRealName'] as bool? ?? true,
      showLocation: json['showLocation'] as bool? ?? true,
      showFavoriteTeams: json['showFavoriteTeams'] as bool? ?? true,
      allowMessaging: json['allowMessaging'] as bool? ?? true,
      showOnlineStatus: json['showOnlineStatus'] as bool? ?? true,
      checkInVisibility: json['checkInVisibility'] as String? ?? 'friends',
      friendListVisibility: json['friendListVisibility'] as String? ?? 'friends',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileVisible': profileVisible,
      'showRealName': showRealName,
      'showLocation': showLocation,
      'showFavoriteTeams': showFavoriteTeams,
      'allowMessaging': allowMessaging,
      'showOnlineStatus': showOnlineStatus,
      'checkInVisibility': checkInVisibility,
      'friendListVisibility': friendListVisibility,
    };
  }

  @override
  List<Object?> get props => [
        profileVisible,
        showRealName,
        showLocation,
        showFavoriteTeams,
        allowMessaging,
        showOnlineStatus,
        checkInVisibility,
        friendListVisibility,
      ];
} 