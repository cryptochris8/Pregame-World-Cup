// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_connection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SocialConnectionAdapter extends TypeAdapter<SocialConnection> {
  @override
  final int typeId = 8;

  @override
  SocialConnection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocialConnection(
      connectionId: fields[0] as String,
      fromUserId: fields[1] as String,
      toUserId: fields[2] as String,
      type: fields[3] as ConnectionType,
      status: fields[4] as ConnectionStatus,
      createdAt: fields[5] as DateTime,
      acceptedAt: fields[6] as DateTime?,
      connectionSource: fields[7] as String?,
      metadata: (fields[8] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SocialConnection obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.connectionId)
      ..writeByte(1)
      ..write(obj.fromUserId)
      ..writeByte(2)
      ..write(obj.toUserId)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.acceptedAt)
      ..writeByte(7)
      ..write(obj.connectionSource)
      ..writeByte(8)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialConnectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FriendSuggestionAdapter extends TypeAdapter<FriendSuggestion> {
  @override
  final int typeId = 11;

  @override
  FriendSuggestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FriendSuggestion(
      userId: fields[0] as String,
      displayName: fields[1] as String,
      profileImageUrl: fields[2] as String?,
      mutualFriends: (fields[3] as List).cast<String>(),
      sharedTeams: (fields[4] as List).cast<String>(),
      connectionReason: fields[5] as String?,
      relevanceScore: fields[6] as double,
      suggestedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FriendSuggestion obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.profileImageUrl)
      ..writeByte(3)
      ..write(obj.mutualFriends)
      ..writeByte(4)
      ..write(obj.sharedTeams)
      ..writeByte(5)
      ..write(obj.connectionReason)
      ..writeByte(6)
      ..write(obj.relevanceScore)
      ..writeByte(7)
      ..write(obj.suggestedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendSuggestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConnectionTypeAdapter extends TypeAdapter<ConnectionType> {
  @override
  final int typeId = 9;

  @override
  ConnectionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConnectionType.friend;
      case 1:
        return ConnectionType.follow;
      case 2:
        return ConnectionType.block;
      default:
        return ConnectionType.friend;
    }
  }

  @override
  void write(BinaryWriter writer, ConnectionType obj) {
    switch (obj) {
      case ConnectionType.friend:
        writer.writeByte(0);
        break;
      case ConnectionType.follow:
        writer.writeByte(1);
        break;
      case ConnectionType.block:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConnectionStatusAdapter extends TypeAdapter<ConnectionStatus> {
  @override
  final int typeId = 10;

  @override
  ConnectionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConnectionStatus.pending;
      case 1:
        return ConnectionStatus.accepted;
      case 2:
        return ConnectionStatus.declined;
      case 3:
        return ConnectionStatus.blocked;
      default:
        return ConnectionStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, ConnectionStatus obj) {
    switch (obj) {
      case ConnectionStatus.pending:
        writer.writeByte(0);
        break;
      case ConnectionStatus.accepted:
        writer.writeByte(1);
        break;
      case ConnectionStatus.declined:
        writer.writeByte(2);
        break;
      case ConnectionStatus.blocked:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
