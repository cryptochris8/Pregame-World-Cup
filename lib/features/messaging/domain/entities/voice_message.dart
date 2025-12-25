import 'package:equatable/equatable.dart';

class VoiceMessage extends Equatable {
  final String messageId;
  final String audioUrl;
  final int durationSeconds;
  final List<double> waveformData;
  final bool isPlaying;
  final int? currentPosition;

  const VoiceMessage({
    required this.messageId,
    required this.audioUrl,
    required this.durationSeconds,
    this.waveformData = const [],
    this.isPlaying = false,
    this.currentPosition,
  });

  factory VoiceMessage.fromJson(Map<String, dynamic> json) {
    return VoiceMessage(
      messageId: json['messageId'] as String,
      audioUrl: json['audioUrl'] as String,
      durationSeconds: json['durationSeconds'] as int,
      waveformData: (json['waveformData'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ?? [],
      isPlaying: json['isPlaying'] as bool? ?? false,
      currentPosition: json['currentPosition'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'audioUrl': audioUrl,
      'durationSeconds': durationSeconds,
      'waveformData': waveformData,
      'isPlaying': isPlaying,
      'currentPosition': currentPosition,
    };
  }

  VoiceMessage copyWith({
    String? messageId,
    String? audioUrl,
    int? durationSeconds,
    List<double>? waveformData,
    bool? isPlaying,
    int? currentPosition,
  }) {
    return VoiceMessage(
      messageId: messageId ?? this.messageId,
      audioUrl: audioUrl ?? this.audioUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      waveformData: waveformData ?? this.waveformData,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (currentPosition == null || durationSeconds == 0) return 0.0;
    return (currentPosition! / durationSeconds).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        messageId,
        audioUrl,
        durationSeconds,
        waveformData,
        isPlaying,
        currentPosition,
      ];
} 