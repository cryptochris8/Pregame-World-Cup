import 'package:pregame_world_cup/features/venue_portal/domain/entities/venue_enhancement.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/subscription_tier.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/tv_setup.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/game_day_special.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/atmosphere_settings.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/live_capacity.dart';

/// Test data factories for venue portal entities
class VenuePortalTestFactory {
  static TvSetup createTvSetup({
    int totalScreens = 8,
    AudioSetup audioSetup = AudioSetup.dedicated,
    List<ScreenDetail>? screenDetails,
  }) {
    return TvSetup(
      totalScreens: totalScreens,
      audioSetup: audioSetup,
      screenDetails: screenDetails ?? [
        const ScreenDetail(
          id: 'screen_1',
          size: '75"',
          location: 'main bar',
          hasAudio: true,
          isPrimary: true,
        ),
        const ScreenDetail(
          id: 'screen_2',
          size: '55"',
          location: 'patio',
          hasAudio: false,
          isPrimary: false,
        ),
      ],
    );
  }

  static GameDaySpecial createGameDaySpecial({
    String id = 'special_123',
    String title = 'Game Day Wings',
    String description = 'Half price wings during all World Cup matches',
    double? price = 9.99,
    int? discountPercent,
    bool isActive = true,
    DateTime? expiresAt,
  }) {
    return GameDaySpecial(
      id: id,
      title: title,
      description: description,
      price: price,
      discountPercent: discountPercent,
      isActive: isActive,
      expiresAt: expiresAt,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    );
  }

  static AtmosphereSettings createAtmosphereSettings({
    List<String> tags = const ['family-friendly', 'casual', 'outdoor-seating'],
    List<String> fanBaseAffinity = const ['USA', 'MEX'],
    NoiseLevel noiseLevel = NoiseLevel.moderate,
    CrowdDensity crowdDensity = CrowdDensity.comfortable,
  }) {
    return AtmosphereSettings(
      tags: tags,
      fanBaseAffinity: fanBaseAffinity,
      noiseLevel: noiseLevel,
      crowdDensity: crowdDensity,
    );
  }

  static LiveCapacity createLiveCapacity({
    int currentOccupancy = 45,
    int maxCapacity = 100,
    bool reservationsAvailable = true,
    int? waitTimeMinutes,
  }) {
    return LiveCapacity(
      currentOccupancy: currentOccupancy,
      maxCapacity: maxCapacity,
      lastUpdated: DateTime.now(),
      reservationsAvailable: reservationsAvailable,
      waitTimeMinutes: waitTimeMinutes,
    );
  }

  static VenueEnhancement createVenueEnhancement({
    String venueId = 'venue_123',
    String ownerId = 'owner_123',
    SubscriptionTier subscriptionTier = SubscriptionTier.premium,
    bool showsMatches = true,
    TvSetup? tvSetup,
    List<GameDaySpecial>? gameSpecials,
    AtmosphereSettings? atmosphere,
    LiveCapacity? liveCapacity,
    bool isVerified = false,
    DateTime? featuredUntil,
  }) {
    final now = DateTime.now();
    return VenueEnhancement(
      venueId: venueId,
      ownerId: ownerId,
      subscriptionTier: subscriptionTier,
      showsMatches: showsMatches,
      tvSetup: tvSetup,
      gameSpecials: gameSpecials ?? [],
      atmosphere: atmosphere,
      liveCapacity: liveCapacity,
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now,
      isVerified: isVerified,
      featuredUntil: featuredUntil,
    );
  }

  /// Creates a fully enhanced venue with all features
  static VenueEnhancement createFullyEnhancedVenue({
    String venueId = 'venue_full',
    int tvCount = 12,
    int currentOccupancy = 65,
    int maxCapacity = 100,
    bool hasActiveSpecials = true,
  }) {
    return createVenueEnhancement(
      venueId: venueId,
      subscriptionTier: SubscriptionTier.premium,
      tvSetup: createTvSetup(totalScreens: tvCount),
      gameSpecials: hasActiveSpecials ? [createGameDaySpecial()] : [],
      atmosphere: createAtmosphereSettings(),
      liveCapacity: createLiveCapacity(
        currentOccupancy: currentOccupancy,
        maxCapacity: maxCapacity,
      ),
      isVerified: true,
    );
  }

  /// Creates a basic free tier venue
  static VenueEnhancement createFreeVenue({
    String venueId = 'venue_free',
    bool showsMatches = true,
  }) {
    return createVenueEnhancement(
      venueId: venueId,
      subscriptionTier: SubscriptionTier.free,
      showsMatches: showsMatches,
    );
  }
}
