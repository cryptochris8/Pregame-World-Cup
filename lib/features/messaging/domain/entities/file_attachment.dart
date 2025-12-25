import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'file_attachment.g.dart';

@HiveType(typeId: 21)
class FileAttachment extends Equatable {
  @HiveField(0)
  final String fileName;
  
  @HiveField(1)
  final String fileUrl;
  
  @HiveField(2)
  final String fileType;
  
  @HiveField(3)
  final int fileSizeBytes;
  
  @HiveField(4)
  final String? mimeType;
  
  @HiveField(5)
  final String? thumbnailUrl;
  
  @HiveField(6)
  final DateTime uploadedAt;

  const FileAttachment({
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSizeBytes,
    this.mimeType,
    this.thumbnailUrl,
    required this.uploadedAt,
  });

  factory FileAttachment.fromJson(Map<String, dynamic> json) {
    return FileAttachment(
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      fileType: json['fileType'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int,
      mimeType: json['mimeType'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSizeBytes': fileSizeBytes,
      'mimeType': mimeType,
      'thumbnailUrl': thumbnailUrl,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  String get formattedFileSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (fileSizeBytes < 1024 * 1024 * 1024) {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : '';
  }

  bool get isImage => ['JPG', 'JPEG', 'PNG', 'GIF', 'WEBP'].contains(fileExtension);
  bool get isVideo => ['MP4', 'MOV', 'AVI', 'MKV', 'WEBM'].contains(fileExtension);
  bool get isAudio => ['MP3', 'WAV', 'AAC', 'M4A', 'OGG'].contains(fileExtension);
  bool get isDocument => ['PDF', 'DOC', 'DOCX', 'TXT', 'RTF'].contains(fileExtension);

  @override
  List<Object?> get props => [
        fileName,
        fileUrl,
        fileType,
        fileSizeBytes,
        mimeType,
        thumbnailUrl,
        uploadedAt,
      ];
} 