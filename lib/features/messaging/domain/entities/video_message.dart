import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'video_message.g.dart';

@HiveType(typeId: 22)
class VideoMessage extends Equatable {
  @HiveField(0)
  final String messageId;
  
  @HiveField(1)
  final String videoUrl;
  
  @HiveField(2)
  final String? thumbnailUrl;
  
  @HiveField(3)
  final int durationSeconds;
  
  @HiveField(4)
  final int? width;
  
  @HiveField(5)
  final int? height;
  
  @HiveField(6)
  final int fileSizeBytes;
  
  @HiveField(7)
  final bool isPlaying;
  
  @HiveField(8)
  final int? currentPosition;
  
  @HiveField(9)
  final bool isLoaded;

  const VideoMessage({
    required this.messageId,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.durationSeconds,
    this.width,
    this.height,
    required this.fileSizeBytes,
    this.isPlaying = false,
    this.currentPosition,
    this.isLoaded = false,
  });

  factory VideoMessage.fromJson(Map<String, dynamic> json) {
    return VideoMessage(
      messageId: json['messageId'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int,
      width: json['width'] as int?,
      height: json['height'] as int?,
      fileSizeBytes: json['fileSizeBytes'] as int,
      isPlaying: json['isPlaying'] as bool? ?? false,
      currentPosition: json['currentPosition'] as int?,
      isLoaded: json['isLoaded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'durationSeconds': durationSeconds,
      'width': width,
      'height': height,
      'fileSizeBytes': fileSizeBytes,
      'isPlaying': isPlaying,
      'currentPosition': currentPosition,
      'isLoaded': isLoaded,
    };
  }

  VideoMessage copyWith({
    String? messageId,
    String? videoUrl,
    String? thumbnailUrl,
    int? durationSeconds,
    int? width,
    int? height,
    int? fileSizeBytes,
    bool? isPlaying,
    int? currentPosition,
    bool? isLoaded,
  }) {
    return VideoMessage(
      messageId: messageId ?? this.messageId,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      width: width ?? this.width,
      height: height ?? this.height,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedFileSize {
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (fileSizeBytes < 1024 * 1024 * 1024) {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  double get progress {
    if (currentPosition == null || durationSeconds == 0) return 0.0;
    return (currentPosition! / durationSeconds).clamp(0.0, 1.0);
  }

  double get aspectRatio {
    if (width == null || height == null || width == 0 || height == 0) {
      return 16 / 9; // Default aspect ratio
    }
    return width! / height!;
  }

  String get resolution {
    if (width == null || height == null) return 'Unknown';
    return '${width}x$height';
  }

  @override
  List<Object?> get props => [
        messageId,
        videoUrl,
        thumbnailUrl,
        durationSeconds,
        width,
        height,
        fileSizeBytes,
        isPlaying,
        currentPosition,
        isLoaded,
      ];
} 