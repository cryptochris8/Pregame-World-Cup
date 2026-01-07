import 'package:equatable/equatable.dart';

enum AudioSetup {
  dedicated,
  shared,
  headphonesAvailable;

  String get displayName {
    switch (this) {
      case AudioSetup.dedicated:
        return 'Dedicated Audio';
      case AudioSetup.shared:
        return 'Shared Audio';
      case AudioSetup.headphonesAvailable:
        return 'Headphones Available';
    }
  }

  static AudioSetup fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'dedicated':
        return AudioSetup.dedicated;
      case 'shared':
        return AudioSetup.shared;
      case 'headphones_available':
      case 'headphonesavailable':
        return AudioSetup.headphonesAvailable;
      default:
        return AudioSetup.shared;
    }
  }

  String toJson() {
    switch (this) {
      case AudioSetup.dedicated:
        return 'dedicated';
      case AudioSetup.shared:
        return 'shared';
      case AudioSetup.headphonesAvailable:
        return 'headphones_available';
    }
  }
}

class ScreenDetail extends Equatable {
  final String id;
  final String size; // e.g., '55"', '75"', '85"', 'projector'
  final String location; // e.g., 'main bar', 'patio', 'private room'
  final bool hasAudio;
  final bool isPrimary;

  const ScreenDetail({
    required this.id,
    required this.size,
    required this.location,
    this.hasAudio = false,
    this.isPrimary = false,
  });

  ScreenDetail copyWith({
    String? size,
    String? location,
    bool? hasAudio,
    bool? isPrimary,
  }) {
    return ScreenDetail(
      id: id,
      size: size ?? this.size,
      location: location ?? this.location,
      hasAudio: hasAudio ?? this.hasAudio,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  factory ScreenDetail.fromJson(Map<String, dynamic> json) {
    return ScreenDetail(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      size: json['size'] as String? ?? '',
      location: json['location'] as String? ?? '',
      hasAudio: json['hasAudio'] as bool? ?? false,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size': size,
      'location': location,
      'hasAudio': hasAudio,
      'isPrimary': isPrimary,
    };
  }

  @override
  List<Object?> get props => [id, size, location, hasAudio, isPrimary];
}

class TvSetup extends Equatable {
  final int totalScreens;
  final List<ScreenDetail> screenDetails;
  final AudioSetup audioSetup;

  const TvSetup({
    this.totalScreens = 0,
    this.screenDetails = const [],
    this.audioSetup = AudioSetup.shared,
  });

  factory TvSetup.empty() => const TvSetup();

  TvSetup copyWith({
    int? totalScreens,
    List<ScreenDetail>? screenDetails,
    AudioSetup? audioSetup,
  }) {
    return TvSetup(
      totalScreens: totalScreens ?? this.totalScreens,
      screenDetails: screenDetails ?? this.screenDetails,
      audioSetup: audioSetup ?? this.audioSetup,
    );
  }

  bool get hasScreens => totalScreens > 0;

  ScreenDetail? get primaryScreen =>
      screenDetails.isEmpty ? null : screenDetails.firstWhere(
        (s) => s.isPrimary,
        orElse: () => screenDetails.first,
      );

  factory TvSetup.fromJson(Map<String, dynamic> json) {
    return TvSetup(
      totalScreens: json['totalScreens'] as int? ?? 0,
      screenDetails: (json['screenDetails'] as List<dynamic>?)
              ?.map((e) => ScreenDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      audioSetup: AudioSetup.fromString(json['audioSetup'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalScreens': totalScreens,
      'screenDetails': screenDetails.map((s) => s.toJson()).toList(),
      'audioSetup': audioSetup.toJson(),
    };
  }

  @override
  List<Object?> get props => [totalScreens, screenDetails, audioSetup];
}
