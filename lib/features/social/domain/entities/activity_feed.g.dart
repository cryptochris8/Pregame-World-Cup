// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_feed.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityFeedItemAdapter extends TypeAdapter<ActivityFeedItem> {
  @override
  final int typeId = 12;

  @override
  ActivityFeedItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityFeedItem(
      activityId: fields[0] as String,
      userId: fields[1] as String,
      userName: fields[2] as String,
      userProfileImage: fields[3] as String?,
      type: fields[4] as ActivityType,
      content: fields[5] as String,
      createdAt: fields[6] as DateTime,
      metadata: (fields[7] as Map).cast<String, dynamic>(),
      mentionedUsers: (fields[8] as List).cast<String>(),
      tags: (fields[9] as List).cast<String>(),
      relatedGameId: fields[10] as String?,
      relatedVenueId: fields[11] as String?,
      likesCount: fields[12] as int,
      commentsCount: fields[13] as int,
      isPublic: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityFeedItem obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.activityId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.userProfileImage)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.content)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.metadata)
      ..writeByte(8)
      ..write(obj.mentionedUsers)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.relatedGameId)
      ..writeByte(11)
      ..write(obj.relatedVenueId)
      ..writeByte(12)
      ..write(obj.likesCount)
      ..writeByte(13)
      ..write(obj.commentsCount)
      ..writeByte(14)
      ..write(obj.isPublic);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityFeedItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityCommentAdapter extends TypeAdapter<ActivityComment> {
  @override
  final int typeId = 14;

  @override
  ActivityComment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityComment(
      commentId: fields[0] as String,
      activityId: fields[1] as String,
      userId: fields[2] as String,
      userName: fields[3] as String,
      userProfileImage: fields[4] as String?,
      comment: fields[5] as String,
      createdAt: fields[6] as DateTime,
      mentionedUsers: (fields[7] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ActivityComment obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.commentId)
      ..writeByte(1)
      ..write(obj.activityId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.userName)
      ..writeByte(4)
      ..write(obj.userProfileImage)
      ..writeByte(5)
      ..write(obj.comment)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.mentionedUsers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityCommentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityLikeAdapter extends TypeAdapter<ActivityLike> {
  @override
  final int typeId = 15;

  @override
  ActivityLike read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityLike(
      likeId: fields[0] as String,
      activityId: fields[1] as String,
      userId: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityLike obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.likeId)
      ..writeByte(1)
      ..write(obj.activityId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLikeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityTypeAdapter extends TypeAdapter<ActivityType> {
  @override
  final int typeId = 13;

  @override
  ActivityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityType.checkIn;
      case 1:
        return ActivityType.friendConnection;
      case 2:
        return ActivityType.gameAttendance;
      case 3:
        return ActivityType.venueReview;
      case 4:
        return ActivityType.photoShare;
      case 5:
        return ActivityType.gameComment;
      case 6:
        return ActivityType.teamFollow;
      case 7:
        return ActivityType.achievement;
      case 8:
        return ActivityType.groupJoin;
      default:
        return ActivityType.checkIn;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityType obj) {
    switch (obj) {
      case ActivityType.checkIn:
        writer.writeByte(0);
        break;
      case ActivityType.friendConnection:
        writer.writeByte(1);
        break;
      case ActivityType.gameAttendance:
        writer.writeByte(2);
        break;
      case ActivityType.venueReview:
        writer.writeByte(3);
        break;
      case ActivityType.photoShare:
        writer.writeByte(4);
        break;
      case ActivityType.gameComment:
        writer.writeByte(5);
        break;
      case ActivityType.teamFollow:
        writer.writeByte(6);
        break;
      case ActivityType.achievement:
        writer.writeByte(7);
        break;
      case ActivityType.groupJoin:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
