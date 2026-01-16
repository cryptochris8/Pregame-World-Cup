// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 4;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      userId: fields[0] as String,
      displayName: fields[1] as String,
      email: fields[2] as String?,
      profileImageUrl: fields[3] as String?,
      bio: fields[4] as String?,
      favoriteTeams: (fields[5] as List).cast<String>(),
      homeLocation: fields[6] as String?,
      preferences: fields[7] as UserPreferences,
      socialStats: fields[8] as SocialStats,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      privacySettings: fields[11] as UserPrivacySettings,
      badges: (fields[12] as List).cast<String>(),
      level: fields[13] as int,
      experiencePoints: fields[14] as int,
      isOnline: fields[15] as bool,
      lastSeenAt: fields[16] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.profileImageUrl)
      ..writeByte(4)
      ..write(obj.bio)
      ..writeByte(5)
      ..write(obj.favoriteTeams)
      ..writeByte(6)
      ..write(obj.homeLocation)
      ..writeByte(7)
      ..write(obj.preferences)
      ..writeByte(8)
      ..write(obj.socialStats)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.privacySettings)
      ..writeByte(12)
      ..write(obj.badges)
      ..writeByte(13)
      ..write(obj.level)
      ..writeByte(14)
      ..write(obj.experiencePoints)
      ..writeByte(15)
      ..write(obj.isOnline)
      ..writeByte(16)
      ..write(obj.lastSeenAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 5;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      showLocation: fields[0] as bool,
      allowFriendRequests: fields[1] as bool,
      shareGameDayPlans: fields[2] as bool,
      receiveNotifications: fields[3] as bool,
      preferredVenueTypes: (fields[4] as List).cast<String>(),
      maxTravelDistance: fields[5] as int,
      dietaryRestrictions: (fields[6] as List).cast<String>(),
      preferredPriceRange: fields[7] as String,
      autoShareCheckIns: fields[8] as bool,
      joinGroupsAutomatically: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.showLocation)
      ..writeByte(1)
      ..write(obj.allowFriendRequests)
      ..writeByte(2)
      ..write(obj.shareGameDayPlans)
      ..writeByte(3)
      ..write(obj.receiveNotifications)
      ..writeByte(4)
      ..write(obj.preferredVenueTypes)
      ..writeByte(5)
      ..write(obj.maxTravelDistance)
      ..writeByte(6)
      ..write(obj.dietaryRestrictions)
      ..writeByte(7)
      ..write(obj.preferredPriceRange)
      ..writeByte(8)
      ..write(obj.autoShareCheckIns)
      ..writeByte(9)
      ..write(obj.joinGroupsAutomatically);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SocialStatsAdapter extends TypeAdapter<SocialStats> {
  @override
  final int typeId = 6;

  @override
  SocialStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocialStats(
      friendsCount: fields[0] as int,
      checkInsCount: fields[1] as int,
      reviewsCount: fields[2] as int,
      gamesAttended: fields[3] as int,
      venuesVisited: fields[4] as int,
      photosShared: fields[5] as int,
      likesReceived: fields[6] as int,
      helpfulVotes: fields[7] as int,
      lastActivity: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SocialStats obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.friendsCount)
      ..writeByte(1)
      ..write(obj.checkInsCount)
      ..writeByte(2)
      ..write(obj.reviewsCount)
      ..writeByte(3)
      ..write(obj.gamesAttended)
      ..writeByte(4)
      ..write(obj.venuesVisited)
      ..writeByte(5)
      ..write(obj.photosShared)
      ..writeByte(6)
      ..write(obj.likesReceived)
      ..writeByte(7)
      ..write(obj.helpfulVotes)
      ..writeByte(8)
      ..write(obj.lastActivity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserPrivacySettingsAdapter extends TypeAdapter<UserPrivacySettings> {
  @override
  final int typeId = 7;

  @override
  UserPrivacySettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPrivacySettings(
      profileVisible: fields[0] as bool,
      showRealName: fields[1] as bool,
      showLocation: fields[2] as bool,
      showFavoriteTeams: fields[3] as bool,
      allowMessaging: fields[4] as bool,
      showOnlineStatus: fields[5] as bool,
      checkInVisibility: fields[6] as String,
      friendListVisibility: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserPrivacySettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.profileVisible)
      ..writeByte(1)
      ..write(obj.showRealName)
      ..writeByte(2)
      ..write(obj.showLocation)
      ..writeByte(3)
      ..write(obj.showFavoriteTeams)
      ..writeByte(4)
      ..write(obj.allowMessaging)
      ..writeByte(5)
      ..write(obj.showOnlineStatus)
      ..writeByte(6)
      ..write(obj.checkInVisibility)
      ..writeByte(7)
      ..write(obj.friendListVisibility);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPrivacySettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
