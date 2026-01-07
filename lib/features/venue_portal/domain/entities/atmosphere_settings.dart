import 'package:equatable/equatable.dart';

enum NoiseLevel {
  quiet,
  moderate,
  loud,
  veryLoud;

  String get displayName {
    switch (this) {
      case NoiseLevel.quiet:
        return 'Quiet';
      case NoiseLevel.moderate:
        return 'Moderate';
      case NoiseLevel.loud:
        return 'Loud';
      case NoiseLevel.veryLoud:
        return 'Very Loud';
    }
  }

  static NoiseLevel fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'quiet':
        return NoiseLevel.quiet;
      case 'moderate':
        return NoiseLevel.moderate;
      case 'loud':
        return NoiseLevel.loud;
      case 'very_loud':
      case 'veryloud':
        return NoiseLevel.veryLoud;
      default:
        return NoiseLevel.moderate;
    }
  }

  String toJson() {
    switch (this) {
      case NoiseLevel.quiet:
        return 'quiet';
      case NoiseLevel.moderate:
        return 'moderate';
      case NoiseLevel.loud:
        return 'loud';
      case NoiseLevel.veryLoud:
        return 'very_loud';
    }
  }
}

enum CrowdDensity {
  spacious,
  comfortable,
  cozy,
  packed;

  String get displayName {
    switch (this) {
      case CrowdDensity.spacious:
        return 'Spacious';
      case CrowdDensity.comfortable:
        return 'Comfortable';
      case CrowdDensity.cozy:
        return 'Cozy';
      case CrowdDensity.packed:
        return 'Packed';
    }
  }

  static CrowdDensity fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'spacious':
        return CrowdDensity.spacious;
      case 'comfortable':
        return CrowdDensity.comfortable;
      case 'cozy':
        return CrowdDensity.cozy;
      case 'packed':
        return CrowdDensity.packed;
      default:
        return CrowdDensity.comfortable;
    }
  }

  String toJson() => name;
}

class AtmosphereSettings extends Equatable {
  final List<String> tags; // e.g., 'family-friendly', 'rowdy', '21+'
  final List<String> fanBaseAffinity; // Team codes this venue supports
  final NoiseLevel noiseLevel;
  final CrowdDensity crowdDensity;

  const AtmosphereSettings({
    this.tags = const [],
    this.fanBaseAffinity = const [],
    this.noiseLevel = NoiseLevel.moderate,
    this.crowdDensity = CrowdDensity.comfortable,
  });

  factory AtmosphereSettings.empty() => const AtmosphereSettings();

  AtmosphereSettings copyWith({
    List<String>? tags,
    List<String>? fanBaseAffinity,
    NoiseLevel? noiseLevel,
    CrowdDensity? crowdDensity,
  }) {
    return AtmosphereSettings(
      tags: tags ?? this.tags,
      fanBaseAffinity: fanBaseAffinity ?? this.fanBaseAffinity,
      noiseLevel: noiseLevel ?? this.noiseLevel,
      crowdDensity: crowdDensity ?? this.crowdDensity,
    );
  }

  bool hasTag(String tag) => tags.contains(tag.toLowerCase());
  bool supportsTeam(String teamCode) =>
      fanBaseAffinity.isEmpty || fanBaseAffinity.contains(teamCode.toUpperCase());

  static const List<String> availableTags = [
    'family-friendly',
    '21+',
    'rowdy',
    'chill',
    'upscale',
    'casual',
    'outdoor-seating',
    'private-rooms',
    'standing-room',
    'reservations-required',
  ];

  factory AtmosphereSettings.fromJson(Map<String, dynamic> json) {
    return AtmosphereSettings(
      tags: List<String>.from(json['tags'] ?? []),
      fanBaseAffinity: List<String>.from(json['fanBaseAffinity'] ?? []),
      noiseLevel: NoiseLevel.fromString(json['noiseLevel'] as String?),
      crowdDensity: CrowdDensity.fromString(json['crowdDensity'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tags': tags,
      'fanBaseAffinity': fanBaseAffinity,
      'noiseLevel': noiseLevel.toJson(),
      'crowdDensity': crowdDensity.toJson(),
    };
  }

  @override
  List<Object?> get props => [tags, fanBaseAffinity, noiseLevel, crowdDensity];
}
