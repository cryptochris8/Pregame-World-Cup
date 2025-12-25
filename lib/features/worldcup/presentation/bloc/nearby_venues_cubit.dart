import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/services/nearby_venues_service.dart';
import '../../domain/entities/world_cup_venue.dart';

/// State for nearby venues
class NearbyVenuesState extends Equatable {
  final List<NearbyVenueResult> venues;
  final WorldCupVenue? stadium;
  final bool isLoading;
  final String? errorMessage;
  final double radiusMeters;
  final String selectedType; // 'all', 'bar', 'restaurant', 'cafe'

  const NearbyVenuesState({
    this.venues = const [],
    this.stadium,
    this.isLoading = false,
    this.errorMessage,
    this.radiusMeters = 2000,
    this.selectedType = 'all',
  });

  @override
  List<Object?> get props => [
        venues,
        stadium,
        isLoading,
        errorMessage,
        radiusMeters,
        selectedType,
      ];

  NearbyVenuesState copyWith({
    List<NearbyVenueResult>? venues,
    WorldCupVenue? stadium,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    double? radiusMeters,
    String? selectedType,
  }) {
    return NearbyVenuesState(
      venues: venues ?? this.venues,
      stadium: stadium ?? this.stadium,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      radiusMeters: radiusMeters ?? this.radiusMeters,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  /// Get filtered venues based on selected type
  List<NearbyVenueResult> get filteredVenues {
    if (selectedType == 'all') return venues;

    return venues.where((v) {
      final types = v.place.types ?? [];
      switch (selectedType) {
        case 'bar':
          return types.contains('bar');
        case 'restaurant':
          return types.contains('restaurant');
        case 'cafe':
          return types.contains('cafe');
        default:
          return true;
      }
    }).toList();
  }

  /// Count of venues by type
  int get barCount =>
      venues.where((v) => (v.place.types ?? []).contains('bar')).length;
  int get restaurantCount =>
      venues.where((v) => (v.place.types ?? []).contains('restaurant')).length;
  int get cafeCount =>
      venues.where((v) => (v.place.types ?? []).contains('cafe')).length;
}

/// Cubit for managing nearby venues state
class NearbyVenuesCubit extends Cubit<NearbyVenuesState> {
  final NearbyVenuesService _service;

  NearbyVenuesCubit({required NearbyVenuesService service})
      : _service = service,
        super(const NearbyVenuesState());

  /// Load nearby venues for a stadium
  Future<void> loadNearbyVenues(WorldCupVenue stadium) async {
    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      stadium: stadium,
    ));

    try {
      final venues = await _service.getNearbyVenues(
        stadium: stadium,
        radiusMeters: state.radiusMeters,
      );

      emit(state.copyWith(
        venues: venues,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load nearby venues: $e',
      ));
    }
  }

  /// Load nearby venues by stadium ID
  Future<void> loadNearbyVenuesByStadiumId(String stadiumId) async {
    final stadium = WorldCupVenues.getById(stadiumId);
    if (stadium == null) {
      emit(state.copyWith(
        errorMessage: 'Stadium not found',
      ));
      return;
    }

    await loadNearbyVenues(stadium);
  }

  /// Change search radius and reload
  Future<void> setRadius(double radiusMeters) async {
    emit(state.copyWith(radiusMeters: radiusMeters));

    if (state.stadium != null) {
      await loadNearbyVenues(state.stadium!);
    }
  }

  /// Filter by venue type
  void setTypeFilter(String type) {
    emit(state.copyWith(selectedType: type));
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Refresh venues
  Future<void> refresh() async {
    if (state.stadium != null) {
      await loadNearbyVenues(state.stadium!);
    }
  }
}
