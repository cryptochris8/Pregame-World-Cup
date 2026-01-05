// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_party_member.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchPartyMemberAdapter extends TypeAdapter<WatchPartyMember> {
  @override
  final int typeId = 33;

  @override
  WatchPartyMember read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchPartyMember(
      memberId: fields[0] as String,
      watchPartyId: fields[1] as String,
      userId: fields[2] as String,
      displayName: fields[3] as String,
      profileImageUrl: fields[4] as String?,
      role: fields[5] as WatchPartyMemberRole,
      attendanceType: fields[6] as WatchPartyAttendanceType,
      rsvpStatus: fields[7] as MemberRsvpStatus,
      joinedAt: fields[8] as DateTime,
      paymentIntentId: fields[9] as String?,
      hasPaid: fields[10] as bool,
      checkedInAt: fields[11] as DateTime?,
      isMuted: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WatchPartyMember obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.memberId)
      ..writeByte(1)
      ..write(obj.watchPartyId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.displayName)
      ..writeByte(4)
      ..write(obj.profileImageUrl)
      ..writeByte(5)
      ..write(obj.role)
      ..writeByte(6)
      ..write(obj.attendanceType)
      ..writeByte(7)
      ..write(obj.rsvpStatus)
      ..writeByte(8)
      ..write(obj.joinedAt)
      ..writeByte(9)
      ..write(obj.paymentIntentId)
      ..writeByte(10)
      ..write(obj.hasPaid)
      ..writeByte(11)
      ..write(obj.checkedInAt)
      ..writeByte(12)
      ..write(obj.isMuted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchPartyMemberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WatchPartyMemberRoleAdapter extends TypeAdapter<WatchPartyMemberRole> {
  @override
  final int typeId = 34;

  @override
  WatchPartyMemberRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WatchPartyMemberRole.host;
      case 1:
        return WatchPartyMemberRole.coHost;
      case 2:
        return WatchPartyMemberRole.member;
      default:
        return WatchPartyMemberRole.host;
    }
  }

  @override
  void write(BinaryWriter writer, WatchPartyMemberRole obj) {
    switch (obj) {
      case WatchPartyMemberRole.host:
        writer.writeByte(0);
        break;
      case WatchPartyMemberRole.coHost:
        writer.writeByte(1);
        break;
      case WatchPartyMemberRole.member:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchPartyMemberRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WatchPartyAttendanceTypeAdapter
    extends TypeAdapter<WatchPartyAttendanceType> {
  @override
  final int typeId = 35;

  @override
  WatchPartyAttendanceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WatchPartyAttendanceType.inPerson;
      case 1:
        return WatchPartyAttendanceType.virtual;
      default:
        return WatchPartyAttendanceType.inPerson;
    }
  }

  @override
  void write(BinaryWriter writer, WatchPartyAttendanceType obj) {
    switch (obj) {
      case WatchPartyAttendanceType.inPerson:
        writer.writeByte(0);
        break;
      case WatchPartyAttendanceType.virtual:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchPartyAttendanceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MemberRsvpStatusAdapter extends TypeAdapter<MemberRsvpStatus> {
  @override
  final int typeId = 36;

  @override
  MemberRsvpStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MemberRsvpStatus.going;
      case 1:
        return MemberRsvpStatus.maybe;
      case 2:
        return MemberRsvpStatus.notGoing;
      default:
        return MemberRsvpStatus.going;
    }
  }

  @override
  void write(BinaryWriter writer, MemberRsvpStatus obj) {
    switch (obj) {
      case MemberRsvpStatus.going:
        writer.writeByte(0);
        break;
      case MemberRsvpStatus.maybe:
        writer.writeByte(1);
        break;
      case MemberRsvpStatus.notGoing:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberRsvpStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
