// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoMessageAdapter extends TypeAdapter<VideoMessage> {
  @override
  final int typeId = 22;

  @override
  VideoMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoMessage(
      messageId: fields[0] as String,
      videoUrl: fields[1] as String,
      thumbnailUrl: fields[2] as String?,
      durationSeconds: fields[3] as int,
      width: fields[4] as int?,
      height: fields[5] as int?,
      fileSizeBytes: fields[6] as int,
      isPlaying: fields[7] as bool,
      currentPosition: fields[8] as int?,
      isLoaded: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, VideoMessage obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.messageId)
      ..writeByte(1)
      ..write(obj.videoUrl)
      ..writeByte(2)
      ..write(obj.thumbnailUrl)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.width)
      ..writeByte(5)
      ..write(obj.height)
      ..writeByte(6)
      ..write(obj.fileSizeBytes)
      ..writeByte(7)
      ..write(obj.isPlaying)
      ..writeByte(8)
      ..write(obj.currentPosition)
      ..writeByte(9)
      ..write(obj.isLoaded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
