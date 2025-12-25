// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_geocoding_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedGeocodingDataAdapter extends TypeAdapter<CachedGeocodingData> {
  @override
  final int typeId = 1;

  @override
  CachedGeocodingData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedGeocodingData(
      key: fields[0] as String,
      address: fields[1] as String,
      latitude: fields[2] as double,
      longitude: fields[3] as double,
      cachedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CachedGeocodingData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedGeocodingDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
