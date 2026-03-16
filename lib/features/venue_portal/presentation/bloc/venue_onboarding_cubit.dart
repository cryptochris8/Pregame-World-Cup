import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/venue_enhancement_service.dart';
import 'venue_onboarding_state.dart';

class VenueOnboardingCubit extends Cubit<VenueOnboardingState> {
  final VenueEnhancementService _service;

  VenueOnboardingCubit({required VenueEnhancementService service})
      : _service = service,
        super(const VenueOnboardingState());

  /// Extract a user-friendly message from exceptions.
  String _friendlyError(Object e, String fallback) {
    if (e is FirebaseFunctionsException) {
      return e.message ?? fallback;
    }
    return fallback;
  }

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
        errorMessage: _friendlyError(e, 'Unable to check venue availability. Please check your connection and try again.'),
      ));
    }
  }

  /// Update the claim info
  void updateClaimInfo(VenueClaimInfo info) {
    emit(state.copyWith(claimInfo: info));
  }

  /// Go to next step
  void nextStep() {
    if (state.currentStep < 3) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  /// Go to previous step
  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  /// Claim the venue via Cloud Function (creates claim in pendingVerification status)
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
        venuePhoneNumber: state.claimInfo.contactPhone,
      );

      if (enhancement != null) {
        emit(state.copyWith(
          status: VenueOnboardingStatus.pendingVerification,
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
        errorMessage: _friendlyError(e, 'Unable to claim venue. Please try again.'),
      ));
    }
  }

  /// Send verification code to the venue's phone
  Future<void> sendVerificationCode(String venueId) async {
    emit(state.copyWith(
      status: VenueOnboardingStatus.sendingCode,
      clearError: true,
    ));

    try {
      final success = await _service.sendVerificationCode(venueId);
      if (success) {
        emit(state.copyWith(
          status: VenueOnboardingStatus.pendingVerification,
        ));
      } else {
        emit(state.copyWith(
          status: VenueOnboardingStatus.error,
          errorMessage: 'Failed to send verification code.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: VenueOnboardingStatus.error,
        errorMessage: _friendlyError(e, 'Unable to send verification code. Please try again.'),
      ));
    }
  }

  /// Verify the SMS code
  Future<void> verifyCode(String venueId, String code) async {
    emit(state.copyWith(
      status: VenueOnboardingStatus.verifying,
      clearError: true,
    ));

    try {
      final success = await _service.verifyCode(venueId, code);
      if (success) {
        emit(state.copyWith(
          status: VenueOnboardingStatus.pendingReview,
        ));
      } else {
        emit(state.copyWith(
          status: VenueOnboardingStatus.error,
          errorMessage: 'Verification failed.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: VenueOnboardingStatus.error,
        errorMessage: _friendlyError(e, 'Unable to verify code. Please try again.'),
      ));
    }
  }
}
