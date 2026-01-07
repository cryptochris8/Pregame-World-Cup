import 'package:equatable/equatable.dart';

class VenueFilterCriteria extends Equatable {
  final String? showsMatchId;
  final bool? hasTvs;
  final bool? hasSpecials;
  final List<String> atmosphereTags;
  final bool? hasCapacityInfo;
  final String? teamAffinity;

  const VenueFilterCriteria({
    this.showsMatchId,
    this.hasTvs,
    this.hasSpecials,
    this.atmosphereTags = const [],
    this.hasCapacityInfo,
    this.teamAffinity,
  });

  factory VenueFilterCriteria.empty() => const VenueFilterCriteria();

  VenueFilterCriteria copyWith({
    String? showsMatchId,
    bool? hasTvs,
    bool? hasSpecials,
    List<String>? atmosphereTags,
    bool? hasCapacityInfo,
    String? teamAffinity,
  }) {
    return VenueFilterCriteria(
      showsMatchId: showsMatchId ?? this.showsMatchId,
      hasTvs: hasTvs ?? this.hasTvs,
      hasSpecials: hasSpecials ?? this.hasSpecials,
      atmosphereTags: atmosphereTags ?? this.atmosphereTags,
      hasCapacityInfo: hasCapacityInfo ?? this.hasCapacityInfo,
      teamAffinity: teamAffinity ?? this.teamAffinity,
    );
  }

  VenueFilterCriteria clearShowsMatch() {
    return VenueFilterCriteria(
      showsMatchId: null,
      hasTvs: hasTvs,
      hasSpecials: hasSpecials,
      atmosphereTags: atmosphereTags,
      hasCapacityInfo: hasCapacityInfo,
      teamAffinity: teamAffinity,
    );
  }

  VenueFilterCriteria clearHasTvs() {
    return VenueFilterCriteria(
      showsMatchId: showsMatchId,
      hasTvs: null,
      hasSpecials: hasSpecials,
      atmosphereTags: atmosphereTags,
      hasCapacityInfo: hasCapacityInfo,
      teamAffinity: teamAffinity,
    );
  }

  VenueFilterCriteria clearHasSpecials() {
    return VenueFilterCriteria(
      showsMatchId: showsMatchId,
      hasTvs: hasTvs,
      hasSpecials: null,
      atmosphereTags: atmosphereTags,
      hasCapacityInfo: hasCapacityInfo,
      teamAffinity: teamAffinity,
    );
  }

  bool get hasActiveFilters =>
      showsMatchId != null ||
      hasTvs == true ||
      hasSpecials == true ||
      atmosphereTags.isNotEmpty ||
      hasCapacityInfo == true ||
      teamAffinity != null;

  int get activeFilterCount {
    int count = 0;
    if (showsMatchId != null) count++;
    if (hasTvs == true) count++;
    if (hasSpecials == true) count++;
    if (atmosphereTags.isNotEmpty) count += atmosphereTags.length;
    if (hasCapacityInfo == true) count++;
    if (teamAffinity != null) count++;
    return count;
  }

  Map<String, dynamic> toJson() {
    return {
      'showsMatchId': showsMatchId,
      'hasTvs': hasTvs,
      'hasSpecials': hasSpecials,
      'atmosphereTags': atmosphereTags,
      'hasCapacityInfo': hasCapacityInfo,
      'teamAffinity': teamAffinity,
    };
  }

  factory VenueFilterCriteria.fromJson(Map<String, dynamic> json) {
    return VenueFilterCriteria(
      showsMatchId: json['showsMatchId'] as String?,
      hasTvs: json['hasTvs'] as bool?,
      hasSpecials: json['hasSpecials'] as bool?,
      atmosphereTags: List<String>.from(json['atmosphereTags'] ?? []),
      hasCapacityInfo: json['hasCapacityInfo'] as bool?,
      teamAffinity: json['teamAffinity'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        showsMatchId,
        hasTvs,
        hasSpecials,
        atmosphereTags,
        hasCapacityInfo,
        teamAffinity,
      ];
}
