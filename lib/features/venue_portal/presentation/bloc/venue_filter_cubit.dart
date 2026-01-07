import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/venue_enhancement_service.dart';

/// State for venue filtering
class VenueFilterState extends Equatable {
  final VenueFilterCriteria criteria;
  final Map<String, VenueEnhancement> enhancements;
  final bool isLoading;
  final String? errorMessage;

  const VenueFilterState({
    this.criteria = const VenueFilterCriteria(),
    this.enhancements = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [criteria, enhancements, isLoading, errorMessage];

  VenueFilterState copyWith({
    VenueFilterCriteria? criteria,
    Map<String, VenueEnhancement>? enhancements,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VenueFilterState(
      criteria: criteria ?? this.criteria,
      enhancements: enhancements ?? this.enhancements,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get hasActiveFilters => criteria.hasActiveFilters;
  int get activeFilterCount => criteria.activeFilterCount;

  /// Get enhancement for a venue
  VenueEnhancement? getEnhancement(String venueId) => enhancements[venueId];

  /// Check if venue passes current filters
  bool venuePassesFilters(String venueId) {
    if (!hasActiveFilters) return true;

    final enhancement = enhancements[venueId];
    if (enhancement == null) {
      // If no enhancement data, only pass if no specific filters are active
      return !hasActiveFilters;
    }

    // Check match filter
    if (criteria.showsMatchId != null) {
      if (!enhancement.isBroadcastingMatch(criteria.showsMatchId!)) {
        return false;
      }
    }

    // Check TV filter
    if (criteria.hasTvs == true) {
      if (!enhancement.hasTvInfo) return false;
    }

    // Check specials filter
    if (criteria.hasSpecials == true) {
      if (!enhancement.hasActiveSpecials) return false;
    }

    // Check atmosphere tags
    if (criteria.atmosphereTags.isNotEmpty) {
      if (enhancement.atmosphere == null) return false;
      final hasMatchingTag = criteria.atmosphereTags
          .any((tag) => enhancement.atmosphere!.hasTag(tag));
      if (!hasMatchingTag) return false;
    }

    // Check capacity info
    if (criteria.hasCapacityInfo == true) {
      if (!enhancement.hasCapacityInfo) return false;
    }

    // Check team affinity
    if (criteria.teamAffinity != null) {
      if (enhancement.atmosphere == null ||
          !enhancement.atmosphere!.supportsTeam(criteria.teamAffinity!)) {
        return false;
      }
    }

    return true;
  }
}

/// Cubit for managing venue filters
class VenueFilterCubit extends Cubit<VenueFilterState> {
  final VenueEnhancementService _service;

  VenueFilterCubit({required VenueEnhancementService service})
      : _service = service,
        super(const VenueFilterState());

  /// Load enhancements for a list of venue IDs
  Future<void> loadEnhancementsForVenues(List<String> venueIds) async {
    if (venueIds.isEmpty) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final enhancements = await _service.getEnhancementsForVenues(venueIds);

      emit(state.copyWith(
        enhancements: {...state.enhancements, ...enhancements},
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load venue data: $e',
      ));
    }
  }

  /// Set filter for showing a specific match
  void setShowsMatchFilter(String? matchId) {
    final newCriteria = matchId != null
        ? state.criteria.copyWith(showsMatchId: matchId)
        : state.criteria.clearShowsMatch();
    emit(state.copyWith(criteria: newCriteria));
  }

  /// Set TV filter
  void setHasTvsFilter(bool? hasTvs) {
    final newCriteria = hasTvs != null
        ? state.criteria.copyWith(hasTvs: hasTvs)
        : state.criteria.clearHasTvs();
    emit(state.copyWith(criteria: newCriteria));
  }

  /// Toggle TV filter
  void toggleHasTvsFilter() {
    final currentValue = state.criteria.hasTvs;
    setHasTvsFilter(currentValue == true ? null : true);
  }

  /// Set specials filter
  void setHasSpecialsFilter(bool? hasSpecials) {
    final newCriteria = hasSpecials != null
        ? state.criteria.copyWith(hasSpecials: hasSpecials)
        : state.criteria.clearHasSpecials();
    emit(state.copyWith(criteria: newCriteria));
  }

  /// Toggle specials filter
  void toggleHasSpecialsFilter() {
    final currentValue = state.criteria.hasSpecials;
    setHasSpecialsFilter(currentValue == true ? null : true);
  }

  /// Set atmosphere tags filter
  void setAtmosphereTagsFilter(List<String> tags) {
    final newCriteria = state.criteria.copyWith(atmosphereTags: tags);
    emit(state.copyWith(criteria: newCriteria));
  }

  /// Add atmosphere tag to filter
  void addAtmosphereTag(String tag) {
    if (!state.criteria.atmosphereTags.contains(tag)) {
      final tags = [...state.criteria.atmosphereTags, tag];
      setAtmosphereTagsFilter(tags);
    }
  }

  /// Remove atmosphere tag from filter
  void removeAtmosphereTag(String tag) {
    final tags = state.criteria.atmosphereTags.where((t) => t != tag).toList();
    setAtmosphereTagsFilter(tags);
  }

  /// Set capacity info filter
  void setHasCapacityFilter(bool? hasCapacity) {
    final newCriteria = state.criteria.copyWith(hasCapacityInfo: hasCapacity);
    emit(state.copyWith(criteria: newCriteria));
  }

  /// Set team affinity filter
  void setTeamAffinityFilter(String? teamCode) {
    final newCriteria = state.criteria.copyWith(teamAffinity: teamCode);
    emit(state.copyWith(criteria: newCriteria));
  }

  /// Clear all filters
  void clearAllFilters() {
    emit(state.copyWith(criteria: const VenueFilterCriteria()));
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Filter a list of venue IDs based on current criteria
  List<String> filterVenueIds(List<String> venueIds) {
    if (!state.hasActiveFilters) return venueIds;
    return venueIds.where((id) => state.venuePassesFilters(id)).toList();
  }
}
