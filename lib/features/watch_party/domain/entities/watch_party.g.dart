// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_party.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchPartyAdapter extends TypeAdapter<WatchParty> {
  @override
  final int typeId = 30;

  @override
  WatchParty read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchParty(
      watchPartyId: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      hostId: fields[3] as String,
      hostName: fields[4] as String,
      hostImageUrl: fields[5] as String?,
      visibility: fields[6] as WatchPartyVisibility,
      gameId: fields[7] as String,
      gameName: fields[8] as String,
      gameDateTime: fields[9] as DateTime,
      venueId: fields[10] as String,
      venueName: fields[11] as String,
      venueAddress: fields[12] as String?,
      venueLatitude: fields[13] as double?,
      venueLongitude: fields[14] as double?,
      maxAttendees: fields[15] as int,
      currentAttendeesCount: fields[16] as int,
      virtualAttendeesCount: fields[17] as int,
      allowVirtualAttendance: fields[18] as bool,
      virtualAttendanceFee: fields[19] as double,
      status: fields[20] as WatchPartyStatus,
      createdAt: fields[21] as DateTime,
      updatedAt: fields[22] as DateTime,
      imageUrl: fields[23] as String?,
      tags: (fields[24] as List).cast<String>(),
      settings: (fields[25] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, WatchParty obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.watchPartyId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.hostId)
      ..writeByte(4)
      ..write(obj.hostName)
      ..writeByte(5)
      ..write(obj.hostImageUrl)
      ..writeByte(6)
      ..write(obj.visibility)
      ..writeByte(7)
      ..write(obj.gameId)
      ..writeByte(8)
      ..write(obj.gameName)
      ..writeByte(9)
      ..write(obj.gameDateTime)
      ..writeByte(10)
      ..write(obj.venueId)
      ..writeByte(11)
      ..write(obj.venueName)
      ..writeByte(12)
      ..write(obj.venueAddress)
      ..writeByte(13)
      ..write(obj.venueLatitude)
      ..writeByte(14)
      ..write(obj.venueLongitude)
      ..writeByte(15)
      ..write(obj.maxAttendees)
      ..writeByte(16)
      ..write(obj.currentAttendeesCount)
      ..writeByte(17)
      ..write(obj.virtualAttendeesCount)
      ..writeByte(18)
      ..write(obj.allowVirtualAttendance)
      ..writeByte(19)
      ..write(obj.virtualAttendanceFee)
      ..writeByte(20)
      ..write(obj.status)
      ..writeByte(21)
      ..write(obj.createdAt)
      ..writeByte(22)
      ..write(obj.updatedAt)
      ..writeByte(23)
      ..write(obj.imageUrl)
      ..writeByte(24)
      ..write(obj.tags)
      ..writeByte(25)
      ..write(obj.settings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchPartyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WatchPartyVisibilityAdapter extends TypeAdapter<WatchPartyVisibility> {
  @override
  final int typeId = 31;

  @override
  WatchPartyVisibility read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WatchPartyVisibility.public;
      case 1:
        return WatchPartyVisibility.private;
      default:
        return WatchPartyVisibility.public;
    }
  }

  @override
  void write(BinaryWriter writer, WatchPartyVisibility obj) {
    switch (obj) {
      case WatchPartyVisibility.public:
        writer.writeByte(0);
        break;
      case WatchPartyVisibility.private:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchPartyVisibilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WatchPartyStatusAdapter extends TypeAdapter<WatchPartyStatus> {
  @override
  final int typeId = 32;

  @override
  WatchPartyStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WatchPartyStatus.upcoming;
      case 1:
        return WatchPartyStatus.live;
      case 2:
        return WatchPartyStatus.ended;
      case 3:
        return WatchPartyStatus.cancelled;
      default:
        return WatchPartyStatus.upcoming;
    }
  }

  @override
  void write(BinaryWriter writer, WatchPartyStatus obj) {
    switch (obj) {
      case WatchPartyStatus.upcoming:
        writer.writeByte(0);
        break;
      case WatchPartyStatus.live:
        writer.writeByte(1);
        break;
      case WatchPartyStatus.ended:
        writer.writeByte(2);
        break;
      case WatchPartyStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchPartyStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
