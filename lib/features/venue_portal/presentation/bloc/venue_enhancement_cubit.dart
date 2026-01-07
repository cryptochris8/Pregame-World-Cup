import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/venue_enhancement_service.dart';
import 'venue_enhancement_state.dart';

class VenueEnhancementCubit extends Cubit<VenueEnhancementState> {
  final VenueEnhancementService _service;

  VenueEnhancementCubit({required VenueEnhancementService service})
      : _service = service,
        super(const VenueEnhancementState());

  /// Load venue enhancement data
  Future<void> loadEnhancement(String venueId, {String? venueName}) async {
    emit(state.copyWith(
      status: VenueEnhancementStatus.loading,
      venueId: venueId,
      venueName: venueName,
      clearError: true,
    ));

    try {
      var enhancement = await _service.getVenueEnhancement(venueId);

      // Create new enhancement if none exists
      if (enhancement == null) {
        enhancement = await _service.createVenueEnhancement(venueId: venueId);
      }

      emit(state.copyWith(
        status: VenueEnhancementStatus.loaded,
        enhancement: enhancement,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VenueEnhancementStatus.error,
        errorMessage: 'Failed to load venue data: $e',
      ));
    }
  }

  /// Update shows matches toggle (FREE tier)
  Future<void> updateShowsMatches(bool showsMatches) async {
    if (state.venueId == null || state.enhancement == null) return;

    emit(state.copyWith(isSaving: true));

    try {
      final success =
          await _service.updateShowsMatches(state.venueId!, showsMatches);

      if (success) {
        final updated = state.enhancement!.copyWith(showsMatches: showsMatches);
        emit(state.copyWith(
          enhancement: updated,
          isSaving: false,
          status: VenueEnhancementStatus.saved,
        ));
      } else {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to update setting',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Error: $e',
      ));
    }
  }

  /// Update broadcasting schedule (PREMIUM tier)
  Future<void> updateBroadcastingSchedule(List<String> matchIds) async {
    if (state.venueId == null || !state.isPremium) return;

    emit(state.copyWith(isSaving: true));

    try {
      final success =
          await _service.updateBroadcastingSchedule(state.venueId!, matchIds);

      if (success) {
        final schedule = BroadcastingSchedule(
          matchIds: matchIds,
          lastUpdated: DateTime.now(),
          autoSelectByTeam:
              state.broadcastingSchedule?.autoSelectByTeam ?? [],
        );
        final updated =
            state.enhancement!.copyWith(broadcastingSchedule: schedule);
        emit(state.copyWith(
          enhancement: updated,
          isSaving: false,
          status: VenueEnhancementStatus.saved,
        ));
      } else {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to update broadcasting schedule',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Error: $e',
      ));
    }
  }

  /// Add match to broadcasting schedule
  Future<void> addMatchToBroadcast(String matchId) async {
    final currentMatchIds =
        state.broadcastingSchedule?.matchIds.toList() ?? [];
    if (!currentMatchIds.contains(matchId)) {
      currentMatchIds.add(matchId);
      await updateBroadcastingSchedule(currentMatchIds);
    }
  }

  /// Remove match from broadcasting schedule
  Future<void> removeMatchFromBroadcast(String matchId) async {
    final currentMatchIds =
        state.broadcastingSchedule?.matchIds.toList() ?? [];
    currentMatchIds.remove(matchId);
    await updateBroadcastingSchedule(currentMatchIds);
  }

  /// Update TV setup (PREMIUM tier)
  Future<void> updateTvSetup(TvSetup tvSetup) async {
    if (state.venueId == null || !state.isPremium) return;

    emit(state.copyWith(isSaving: true));

    try {
      final success = await _service.updateTvSetup(state.venueId!, tvSetup);

      if (success) {
        final updated = state.enhancement!.copyWith(tvSetup: tvSetup);
        emit(state.copyWith(
          enhancement: updated,
          isSaving: false,
          status: VenueEnhancementStatus.saved,
        ));
      } else {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to update TV setup',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Error: $e',
      ));
    }
  }

  /// Add game day special (PREMIUM tier)
  Future<void> addGameSpecial(GameDaySpecial special) async {
    if (state.venueId == null || !state.isPremium) return;

    emit(state.copyWith(isSaving: true));

    try {
      final success = await _service.addGameSpecial(state.venueId!, special);

      if (success) {
        final specials = [...state.gameSpecials, special];
        final updated = state.enhancement!.copyWith(gameSpecials: specials);
        emit(state.copyWith(
          enhancement: updated,
          isSaving: false,
          status: VenueEnhancementStatus.saved,
        ));
      } else {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to add special',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Error: $e',
      ));
    }
  }

  /// Update game day special
  Future<void> updateGameSpecial(GameDaySpecial special) async {
    if (state.venueId == null || !state.isPremium) return;

    emit(state.copyWith(isSaving: true));

    try {
      final success = await _service.updateGameSpecial(state.venueId!, special);

      if (success) {
        final specials =
            state.gameSpecials.map((s) => s.id == special.id ? special : s).toList();
        final updated = state.enhancement!.copyWith(gameSpecials: specials);
        emit(state.copyWith(
          enhancement: updated,
          isSaving: false,
          status: VenueEnhancementStatus.saved,
        ));
      } else {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to update special',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Error: $e',
      ));
    }
  }

  /// Delete game day special
  Future<void> deleteGameSpecial(String specialId) async {
    if (state.venueId == null || !state.isPremium) return;

    emit(state.copyWith(isSaving: true));

    try {
      final success =
          await _service.deleteGameSpecial(state.venueId!, specialId);

      if (success) {
        final specials =
            state.gameSpecials.where((s) => s.id != specialId).toList();
        final updated = state.enhancement!.copyWith(gameSpecials: specials);
        emit(state.copyWith(
          enhancement: updated,
          isSaving: false,
          status: VenueEnhancementStatus.saved,
        ));
      } else {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to delete special',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Error: $e',
      ));
    }
  }

  /// Update atmosphere settings (PREMIUM tier)
  Future<void> updateAtmosphere(AtmosphereSettings atmosphere) async {
    if (state.venueId == null || !state.isPremium) return;

    emit(state.copyWith(isSaving: true));

    try {
      final success =
          await _service.updateAtmosphere(state.venueId!, atmosphere);

      if (success) {
        final updated = state.enhancement!.copyWith(atmosphere: atmosphere);
        emit(state.copyWith(
          enhancement: updated,
          isSaving: false,
          status: VenueEnhancementStatus.saved,
        ));
      } else {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to update atmosphere',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Error: $e',
      ));
    }
  }

  /// Update live capacity (PREMIUM tier)
  Future<void> updateLiveCapacity({
    required int currentOccupancy,
    int? waitTimeMinutes,
    bool? reservationsAvailable,
  }) async {
    if (state.venueId == null || !state.isPremium) return;

    emit(state.copyWith(isSaving: true));

    try {
      final success = await _service.updateLiveCapacity(
        state.venueId!,
        currentOccupancy: currentOccupancy,
        waitTimeMinutes: waitTimeMinutes,
        reservationsAvailable: reservationsAvailable,
      );

      if (success) {
        final capacity = (state.liveCapacity ?? LiveCapacity.empty()).copyWith(
          currentOccupancy: currentOccupancy,
          waitTimeMinutes: waitTimeMinutes,
          reservationsAvailable: reservationsAvailable,
        );
        final updated = state.enhancement!.copyWith(liveCapacity: capacity);
        emit(state.copyWith(
          enhancement: updated,
          isSaving: false,
          status: VenueEnhancementStatus.saved,
        ));
      } else {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to update capacity',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Error: $e',
      ));
    }
  }

  /// Set max capacity
  Future<void> setMaxCapacity(int maxCapacity) async {
    if (state.venueId == null || !state.isPremium) return;

    emit(state.copyWith(isSaving: true));

    try {
      final success = await _service.setMaxCapacity(state.venueId!, maxCapacity);

      if (success) {
        final capacity = (state.liveCapacity ?? LiveCapacity.empty())
            .copyWith(maxCapacity: maxCapacity);
        final updated = state.enhancement!.copyWith(liveCapacity: capacity);
        emit(state.copyWith(
          enhancement: updated,
          isSaving: false,
          status: VenueEnhancementStatus.saved,
        ));
      } else {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to set max capacity',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Error: $e',
      ));
    }
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Refresh enhancement data
  Future<void> refresh() async {
    if (state.venueId != null) {
      await loadEnhancement(state.venueId!, venueName: state.venueName);
    }
  }
}
