import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/venue_enhancement_service.dart';
import 'venue_onboarding_state.dart';

class VenueOnboardingCubit extends Cubit<VenueOnboardingState> {
  final VenueEnhancementService _service;

  VenueOnboardingCubit({required VenueEnhancementService service})
      : _service = service,
        super(const VenueOnboardingState());

  /// Check if the venue is available to claim
  Future<void> checkVenueAvailability(String venueId) async {
    emit(state.copyWith(
      status: VenueOnboardingStatus.checkingAvailability,
      clearError: true,
    ));

    try {
      final isClaimed = await _service.isVenueClaimed(venueId);

      if (isClaimed) {
        emit(state.copyWith(
          status: VenueOnboardingStatus.alreadyClaimed,
        ));
      } else {
        emit(state.copyWith(
          status: VenueOnboardingStatus.available,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: VenueOnboardingStatus.error,
        errorMessage: 'Failed to check venue availability: $e',
      ));
    }
  }

  /// Update the claim info
  void updateClaimInfo(VenueClaimInfo info) {
    emit(state.copyWith(claimInfo: info));
  }

  /// Go to next step
  void nextStep() {
    if (state.currentStep < 2) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  /// Go to previous step
  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  /// Claim the venue (final step)
  Future<void> claimVenue(String venueId, String venueName) async {
    emit(state.copyWith(
      status: VenueOnboardingStatus.submitting,
      clearError: true,
    ));

    try {
      final enhancement = await _service.claimVenue(
        venueId: venueId,
        venueName: venueName,
        businessName: state.claimInfo.businessName,
        contactEmail: state.claimInfo.contactEmail,
        contactPhone: state.claimInfo.contactPhone,
        ownerRole: state.claimInfo.role.toJson(),
        venueType: state.claimInfo.venueType.toJson(),
      );

      if (enhancement != null) {
        emit(state.copyWith(
          status: VenueOnboardingStatus.success,
          enhancement: enhancement,
        ));
      } else {
        emit(state.copyWith(
          status: VenueOnboardingStatus.error,
          errorMessage: 'Failed to claim venue. It may already be claimed.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: VenueOnboardingStatus.error,
        errorMessage: 'Error claiming venue: $e',
      ));
    }
  }
}
