// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SocialNotificationAdapter extends TypeAdapter<SocialNotification> {
  @override
  final int typeId = 16;

  @override
  SocialNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocialNotification(
      notificationId: fields[0] as String,
      userId: fields[1] as String,
      fromUserId: fields[2] as String?,
      fromUserName: fields[3] as String?,
      fromUserImage: fields[4] as String?,
      type: fields[5] as NotificationType,
      title: fields[6] as String,
      message: fields[7] as String,
      createdAt: fields[8] as DateTime,
      isRead: fields[9] as bool,
      data: (fields[10] as Map).cast<String, dynamic>(),
      actionUrl: fields[11] as String?,
      priority: fields[12] as NotificationPriority,
    );
  }

  @override
  void write(BinaryWriter writer, SocialNotification obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.notificationId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.fromUserId)
      ..writeByte(3)
      ..write(obj.fromUserName)
      ..writeByte(4)
      ..write(obj.fromUserImage)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.message)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.isRead)
      ..writeByte(10)
      ..write(obj.data)
      ..writeByte(11)
      ..write(obj.actionUrl)
      ..writeByte(12)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationPreferencesAdapter
    extends TypeAdapter<NotificationPreferences> {
  @override
  final int typeId = 19;

  @override
  NotificationPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationPreferences(
      friendRequests: fields[0] as bool,
      activityLikes: fields[1] as bool,
      activityComments: fields[2] as bool,
      gameInvites: fields[3] as bool,
      venueRecommendations: fields[4] as bool,
      newFollowers: fields[5] as bool,
      groupActivity: fields[6] as bool,
      achievements: fields[7] as bool,
      systemUpdates: fields[8] as bool,
      pushNotifications: fields[9] as bool,
      emailNotifications: fields[10] as bool,
      quietHoursStart: fields[11] as String,
      quietHoursEnd: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationPreferences obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.friendRequests)
      ..writeByte(1)
      ..write(obj.activityLikes)
      ..writeByte(2)
      ..write(obj.activityComments)
      ..writeByte(3)
      ..write(obj.gameInvites)
      ..writeByte(4)
      ..write(obj.venueRecommendations)
      ..writeByte(5)
      ..write(obj.newFollowers)
      ..writeByte(6)
      ..write(obj.groupActivity)
      ..writeByte(7)
      ..write(obj.achievements)
      ..writeByte(8)
      ..write(obj.systemUpdates)
      ..writeByte(9)
      ..write(obj.pushNotifications)
      ..writeByte(10)
      ..write(obj.emailNotifications)
      ..writeByte(11)
      ..write(obj.quietHoursStart)
      ..writeByte(12)
      ..write(obj.quietHoursEnd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationTypeAdapter extends TypeAdapter<NotificationType> {
  @override
  final int typeId = 17;

  @override
  NotificationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationType.friendRequest;
      case 1:
        return NotificationType.friendRequestAccepted;
      case 2:
        return NotificationType.activityLike;
      case 3:
        return NotificationType.activityComment;
      case 4:
        return NotificationType.gameInvite;
      case 5:
        return NotificationType.venueRecommendation;
      case 6:
        return NotificationType.newFollower;
      case 7:
        return NotificationType.groupInvite;
      case 8:
        return NotificationType.achievement;
      case 9:
        return NotificationType.systemUpdate;
      default:
        return NotificationType.friendRequest;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationType obj) {
    switch (obj) {
      case NotificationType.friendRequest:
        writer.writeByte(0);
        break;
      case NotificationType.friendRequestAccepted:
        writer.writeByte(1);
        break;
      case NotificationType.activityLike:
        writer.writeByte(2);
        break;
      case NotificationType.activityComment:
        writer.writeByte(3);
        break;
      case NotificationType.gameInvite:
        writer.writeByte(4);
        break;
      case NotificationType.venueRecommendation:
        writer.writeByte(5);
        break;
      case NotificationType.newFollower:
        writer.writeByte(6);
        break;
      case NotificationType.groupInvite:
        writer.writeByte(7);
        break;
      case NotificationType.achievement:
        writer.writeByte(8);
        break;
      case NotificationType.systemUpdate:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationPriorityAdapter extends TypeAdapter<NotificationPriority> {
  @override
  final int typeId = 18;

  @override
  NotificationPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationPriority.low;
      case 1:
        return NotificationPriority.normal;
      case 2:
        return NotificationPriority.high;
      case 3:
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationPriority obj) {
    switch (obj) {
      case NotificationPriority.low:
        writer.writeByte(0);
        break;
      case NotificationPriority.normal:
        writer.writeByte(1);
        break;
      case NotificationPriority.high:
        writer.writeByte(2);
        break;
      case NotificationPriority.urgent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
