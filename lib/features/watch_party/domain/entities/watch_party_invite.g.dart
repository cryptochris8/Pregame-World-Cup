// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_party_invite.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchPartyInviteAdapter extends TypeAdapter<WatchPartyInvite> {
  @override
  final int typeId = 39;

  @override
  WatchPartyInvite read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchPartyInvite(
      inviteId: fields[0] as String,
      watchPartyId: fields[1] as String,
      watchPartyName: fields[2] as String,
      inviterId: fields[3] as String,
      inviterName: fields[4] as String,
      inviterImageUrl: fields[5] as String?,
      inviteeId: fields[6] as String,
      status: fields[7] as WatchPartyInviteStatus,
      createdAt: fields[8] as DateTime,
      expiresAt: fields[9] as DateTime,
      message: fields[10] as String?,
      gameName: fields[11] as String?,
      gameDateTime: fields[12] as DateTime?,
      venueName: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WatchPartyInvite obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.inviteId)
      ..writeByte(1)
      ..write(obj.watchPartyId)
      ..writeByte(2)
      ..write(obj.watchPartyName)
      ..writeByte(3)
      ..write(obj.inviterId)
      ..writeByte(4)
      ..write(obj.inviterName)
      ..writeByte(5)
      ..write(obj.inviterImageUrl)
      ..writeByte(6)
      ..write(obj.inviteeId)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.expiresAt)
      ..writeByte(10)
      ..write(obj.message)
      ..writeByte(11)
      ..write(obj.gameName)
      ..writeByte(12)
      ..write(obj.gameDateTime)
      ..writeByte(13)
      ..write(obj.venueName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchPartyInviteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WatchPartyInviteStatusAdapter
    extends TypeAdapter<WatchPartyInviteStatus> {
  @override
  final int typeId = 40;

  @override
  WatchPartyInviteStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WatchPartyInviteStatus.pending;
      case 1:
        return WatchPartyInviteStatus.accepted;
      case 2:
        return WatchPartyInviteStatus.declined;
      case 3:
        return WatchPartyInviteStatus.expired;
      default:
        return WatchPartyInviteStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, WatchPartyInviteStatus obj) {
    switch (obj) {
      case WatchPartyInviteStatus.pending:
        writer.writeByte(0);
        break;
      case WatchPartyInviteStatus.accepted:
        writer.writeByte(1);
        break;
      case WatchPartyInviteStatus.declined:
        writer.writeByte(2);
        break;
      case WatchPartyInviteStatus.expired:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchPartyInviteStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
