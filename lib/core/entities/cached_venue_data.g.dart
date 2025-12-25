// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_venue_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedVenueDataAdapter extends TypeAdapter<CachedVenueData> {
  @override
  final int typeId = 0;

  @override
  CachedVenueData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedVenueData(
      key: fields[0] as String,
      venuesJson: fields[1] as String,
      cachedAt: fields[2] as DateTime,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      radius: fields[5] as double,
      types: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, CachedVenueData obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.venuesJson)
      ..writeByte(2)
      ..write(obj.cachedAt)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.radius)
      ..writeByte(6)
      ..write(obj.types);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedVenueDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
