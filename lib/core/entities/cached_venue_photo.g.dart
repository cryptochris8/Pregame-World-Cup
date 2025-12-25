// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_venue_photo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedVenuePhotosAdapter extends TypeAdapter<CachedVenuePhotos> {
  @override
  final int typeId = 3;

  @override
  CachedVenuePhotos read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedVenuePhotos(
      placeId: fields[0] as String,
      photoUrls: (fields[1] as List).cast<String>(),
      timestamp: fields[2] as DateTime,
      metadata: (fields[3] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, CachedVenuePhotos obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.placeId)
      ..writeByte(1)
      ..write(obj.photoUrls)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedVenuePhotosAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
