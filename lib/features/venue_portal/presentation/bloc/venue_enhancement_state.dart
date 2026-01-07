import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';

enum VenueEnhancementStatus {
  initial,
  loading,
  loaded,
  saving,
  saved,
  error,
}

class VenueEnhancementState extends Equatable {
  final VenueEnhancementStatus status;
  final VenueEnhancement? enhancement;
  final String? venueId;
  final String? venueName;
  final String? errorMessage;
  final bool isSaving;

  const VenueEnhancementState({
    this.status = VenueEnhancementStatus.initial,
    this.enhancement,
    this.venueId,
    this.venueName,
    this.errorMessage,
    this.isSaving = false,
  });

  @override
  List<Object?> get props => [
        status,
        enhancement,
        venueId,
        venueName,
        errorMessage,
        isSaving,
      ];

  VenueEnhancementState copyWith({
    VenueEnhancementStatus? status,
    VenueEnhancement? enhancement,
    String? venueId,
    String? venueName,
    String? errorMessage,
    bool clearError = false,
    bool? isSaving,
  }) {
    return VenueEnhancementState(
      status: status ?? this.status,
      enhancement: enhancement ?? this.enhancement,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSaving: isSaving ?? this.isSaving,
    );
  }

  // Computed properties
  bool get isLoading => status == VenueEnhancementStatus.loading;
  bool get isLoaded => status == VenueEnhancementStatus.loaded;
  bool get hasError => status == VenueEnhancementStatus.error;
  bool get hasEnhancement => enhancement != null;

  bool get isPremium => enhancement?.isPremium ?? false;
  bool get isFree => enhancement?.isFree ?? true;

  SubscriptionTier get tier =>
      enhancement?.subscriptionTier ?? SubscriptionTier.free;

  bool get showsMatches => enhancement?.showsMatches ?? false;
  BroadcastingSchedule? get broadcastingSchedule =>
      enhancement?.broadcastingSchedule;
  TvSetup? get tvSetup => enhancement?.tvSetup;
  List<GameDaySpecial> get gameSpecials => enhancement?.gameSpecials ?? [];
  List<GameDaySpecial> get activeSpecials => enhancement?.activeSpecials ?? [];
  AtmosphereSettings? get atmosphere => enhancement?.atmosphere;
  LiveCapacity? get liveCapacity => enhancement?.liveCapacity;

  bool get hasTvInfo => enhancement?.hasTvInfo ?? false;
  bool get hasActiveSpecials => enhancement?.hasActiveSpecials ?? false;
  bool get hasCapacityInfo => enhancement?.hasCapacityInfo ?? false;
  bool get hasAtmosphereInfo => enhancement?.hasAtmosphereInfo ?? false;
}
