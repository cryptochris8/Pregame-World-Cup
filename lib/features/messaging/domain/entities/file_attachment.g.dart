// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_attachment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FileAttachmentAdapter extends TypeAdapter<FileAttachment> {
  @override
  final int typeId = 21;

  @override
  FileAttachment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileAttachment(
      fileName: fields[0] as String,
      fileUrl: fields[1] as String,
      fileType: fields[2] as String,
      fileSizeBytes: fields[3] as int,
      mimeType: fields[4] as String?,
      thumbnailUrl: fields[5] as String?,
      uploadedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FileAttachment obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.fileName)
      ..writeByte(1)
      ..write(obj.fileUrl)
      ..writeByte(2)
      ..write(obj.fileType)
      ..writeByte(3)
      ..write(obj.fileSizeBytes)
      ..writeByte(4)
      ..write(obj.mimeType)
      ..writeByte(5)
      ..write(obj.thumbnailUrl)
      ..writeByte(6)
      ..write(obj.uploadedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileAttachmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
