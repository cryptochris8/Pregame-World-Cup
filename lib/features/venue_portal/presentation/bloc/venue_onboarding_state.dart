import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';

enum VenueOnboardingStatus {
  initial,
  checkingAvailability,
  available,
  alreadyClaimed,
  submitting,
  success,
  error,
}

class VenueOnboardingState extends Equatable {
  final VenueOnboardingStatus status;
  final int currentStep;
  final VenueClaimInfo claimInfo;
  final String? errorMessage;
  final VenueEnhancement? enhancement;

  const VenueOnboardingState({
    this.status = VenueOnboardingStatus.initial,
    this.currentStep = 0,
    this.claimInfo = const VenueClaimInfo(),
    this.errorMessage,
    this.enhancement,
  });

  VenueOnboardingState copyWith({
    VenueOnboardingStatus? status,
    int? currentStep,
    VenueClaimInfo? claimInfo,
    String? errorMessage,
    bool clearError = false,
    VenueEnhancement? enhancement,
  }) {
    return VenueOnboardingState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      claimInfo: claimInfo ?? this.claimInfo,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      enhancement: enhancement ?? this.enhancement,
    );
  }

  bool get isChecking => status == VenueOnboardingStatus.checkingAvailability;
  bool get isAvailable => status == VenueOnboardingStatus.available;
  bool get isClaimed => status == VenueOnboardingStatus.alreadyClaimed;
  bool get isSubmitting => status == VenueOnboardingStatus.submitting;
  bool get isSuccess => status == VenueOnboardingStatus.success;
  bool get hasError => status == VenueOnboardingStatus.error;

  bool get canProceedFromStep1 => claimInfo.isStep1Valid;
  bool get canProceedFromStep2 => claimInfo.isStep2Valid;

  @override
  List<Object?> get props => [
        status,
        currentStep,
        claimInfo,
        errorMessage,
        enhancement,
      ];
}
