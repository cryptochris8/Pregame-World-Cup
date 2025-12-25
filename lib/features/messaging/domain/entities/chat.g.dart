// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatAdapter extends TypeAdapter<Chat> {
  @override
  final int typeId = 21;

  @override
  Chat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chat(
      chatId: fields[0] as String,
      type: fields[1] as ChatType,
      participantIds: (fields[2] as List).cast<String>(),
      adminIds: (fields[3] as List).cast<String>(),
      name: fields[4] as String?,
      description: fields[5] as String?,
      imageUrl: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime?,
      lastMessageId: fields[9] as String?,
      lastMessageContent: fields[10] as String?,
      lastMessageTime: fields[11] as DateTime?,
      lastMessageSenderId: fields[12] as String?,
      unreadCounts: (fields[13] as Map).cast<String, int>(),
      settings: (fields[14] as Map).cast<String, dynamic>(),
      isActive: fields[15] as bool,
      createdBy: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Chat obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.chatId)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.participantIds)
      ..writeByte(3)
      ..write(obj.adminIds)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.lastMessageId)
      ..writeByte(10)
      ..write(obj.lastMessageContent)
      ..writeByte(11)
      ..write(obj.lastMessageTime)
      ..writeByte(12)
      ..write(obj.lastMessageSenderId)
      ..writeByte(13)
      ..write(obj.unreadCounts)
      ..writeByte(14)
      ..write(obj.settings)
      ..writeByte(15)
      ..write(obj.isActive)
      ..writeByte(16)
      ..write(obj.createdBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatMemberAdapter extends TypeAdapter<ChatMember> {
  @override
  final int typeId = 23;

  @override
  ChatMember read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMember(
      userId: fields[0] as String,
      displayName: fields[1] as String,
      imageUrl: fields[2] as String?,
      role: fields[3] as ChatMemberRole,
      joinedAt: fields[4] as DateTime,
      lastSeenAt: fields[5] as DateTime?,
      isOnline: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMember obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.joinedAt)
      ..writeByte(5)
      ..write(obj.lastSeenAt)
      ..writeByte(6)
      ..write(obj.isOnline);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMemberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatTypeAdapter extends TypeAdapter<ChatType> {
  @override
  final int typeId = 22;

  @override
  ChatType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChatType.direct;
      case 1:
        return ChatType.group;
      case 2:
        return ChatType.team;
      case 3:
        return ChatType.event;
      default:
        return ChatType.direct;
    }
  }

  @override
  void write(BinaryWriter writer, ChatType obj) {
    switch (obj) {
      case ChatType.direct:
        writer.writeByte(0);
        break;
      case ChatType.group:
        writer.writeByte(1);
        break;
      case ChatType.team:
        writer.writeByte(2);
        break;
      case ChatType.event:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatMemberRoleAdapter extends TypeAdapter<ChatMemberRole> {
  @override
  final int typeId = 24;

  @override
  ChatMemberRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChatMemberRole.member;
      case 1:
        return ChatMemberRole.admin;
      case 2:
        return ChatMemberRole.owner;
      default:
        return ChatMemberRole.member;
    }
  }

  @override
  void write(BinaryWriter writer, ChatMemberRole obj) {
    switch (obj) {
      case ChatMemberRole.member:
        writer.writeByte(0);
        break;
      case ChatMemberRole.admin:
        writer.writeByte(1);
        break;
      case ChatMemberRole.owner:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMemberRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
