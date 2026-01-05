// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_party_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageReactionAdapter extends TypeAdapter<MessageReaction> {
  @override
  final int typeId = 41;

  @override
  MessageReaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageReaction(
      emoji: fields[0] as String,
      userId: fields[1] as String,
      userName: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MessageReaction obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.emoji)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageReactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WatchPartyMessageAdapter extends TypeAdapter<WatchPartyMessage> {
  @override
  final int typeId = 37;

  @override
  WatchPartyMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchPartyMessage(
      messageId: fields[0] as String,
      watchPartyId: fields[1] as String,
      senderId: fields[2] as String,
      senderName: fields[3] as String,
      senderImageUrl: fields[4] as String?,
      senderRole: fields[5] as WatchPartyMemberRole,
      content: fields[6] as String,
      type: fields[7] as WatchPartyMessageType,
      createdAt: fields[8] as DateTime,
      isDeleted: fields[9] as bool,
      reactions: (fields[10] as List).cast<MessageReaction>(),
      replyToMessageId: fields[11] as String?,
      metadata: (fields[12] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, WatchPartyMessage obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.messageId)
      ..writeByte(1)
      ..write(obj.watchPartyId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.senderName)
      ..writeByte(4)
      ..write(obj.senderImageUrl)
      ..writeByte(5)
      ..write(obj.senderRole)
      ..writeByte(6)
      ..write(obj.content)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.isDeleted)
      ..writeByte(10)
      ..write(obj.reactions)
      ..writeByte(11)
      ..write(obj.replyToMessageId)
      ..writeByte(12)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchPartyMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WatchPartyMessageTypeAdapter extends TypeAdapter<WatchPartyMessageType> {
  @override
  final int typeId = 38;

  @override
  WatchPartyMessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WatchPartyMessageType.text;
      case 1:
        return WatchPartyMessageType.image;
      case 2:
        return WatchPartyMessageType.gif;
      case 3:
        return WatchPartyMessageType.system;
      case 4:
        return WatchPartyMessageType.poll;
      default:
        return WatchPartyMessageType.text;
    }
  }

  @override
  void write(BinaryWriter writer, WatchPartyMessageType obj) {
    switch (obj) {
      case WatchPartyMessageType.text:
        writer.writeByte(0);
        break;
      case WatchPartyMessageType.image:
        writer.writeByte(1);
        break;
      case WatchPartyMessageType.gif:
        writer.writeByte(2);
        break;
      case WatchPartyMessageType.system:
        writer.writeByte(3);
        break;
      case WatchPartyMessageType.poll:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchPartyMessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
