import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'subscription_tier.dart';
import 'broadcasting_schedule.dart';
import 'tv_setup.dart';
import 'game_day_special.dart';
import 'atmosphere_settings.dart';
import 'live_capacity.dart';

class VenueEnhancement extends Equatable {
  final String venueId;
  final String ownerId;
  final SubscriptionTier subscriptionTier;

  // FREE TIER - Basic toggle
  final bool showsMatches;

  // PREMIUM TIER features
  final BroadcastingSchedule? broadcastingSchedule;
  final TvSetup? tvSetup;
  final List<GameDaySpecial> gameSpecials;
  final AtmosphereSettings? atmosphere;
  final LiveCapacity? liveCapacity;

  // Business info (from onboarding)
  final String? businessName;
  final String? contactEmail;
  final String? contactPhone;
  final String? ownerRole;
  final String? venueType;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final DateTime? featuredUntil;

  const VenueEnhancement({
    required this.venueId,
    required this.ownerId,
    this.subscriptionTier = SubscriptionTier.free,
    this.showsMatches = false,
    this.broadcastingSchedule,
    this.tvSetup,
    this.gameSpecials = const [],
    this.atmosphere,
    this.liveCapacity,
    this.businessName,
    this.contactEmail,
    this.contactPhone,
    this.ownerRole,
    this.venueType,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.featuredUntil,
  });

  factory VenueEnhancement.create({
    required String venueId,
    required String ownerId,
    SubscriptionTier tier = SubscriptionTier.free,
  }) {
    final now = DateTime.now();
    return VenueEnhancement(
      venueId: venueId,
      ownerId: ownerId,
      subscriptionTier: tier,
      createdAt: now,
      updatedAt: now,
    );
  }

  VenueEnhancement copyWith({
    SubscriptionTier? subscriptionTier,
    bool? showsMatches,
    BroadcastingSchedule? broadcastingSchedule,
    TvSetup? tvSetup,
    List<GameDaySpecial>? gameSpecials,
    AtmosphereSettings? atmosphere,
    LiveCapacity? liveCapacity,
    String? businessName,
    String? contactEmail,
    String? contactPhone,
    String? ownerRole,
    String? venueType,
    DateTime? updatedAt,
    bool? isVerified,
    DateTime? featuredUntil,
  }) {
    return VenueEnhancement(
      venueId: venueId,
      ownerId: ownerId,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      showsMatches: showsMatches ?? this.showsMatches,
      broadcastingSchedule: broadcastingSchedule ?? this.broadcastingSchedule,
      tvSetup: tvSetup ?? this.tvSetup,
      gameSpecials: gameSpecials ?? this.gameSpecials,
      atmosphere: atmosphere ?? this.atmosphere,
      liveCapacity: liveCapacity ?? this.liveCapacity,
      businessName: businessName ?? this.businessName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      ownerRole: ownerRole ?? this.ownerRole,
      venueType: venueType ?? this.venueType,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isVerified: isVerified ?? this.isVerified,
      featuredUntil: featuredUntil ?? this.featuredUntil,
    );
  }

  // Computed properties
  bool get isPremium => subscriptionTier == SubscriptionTier.premium;
  bool get isFree => subscriptionTier == SubscriptionTier.free;

  bool get hasTvInfo => tvSetup != null && tvSetup!.hasScreens;
  int get tvCount => tvSetup?.totalScreens ?? 0;

  bool get hasActiveSpecials =>
      gameSpecials.any((s) => s.isCurrentlyValid);
  List<GameDaySpecial> get activeSpecials =>
      gameSpecials.where((s) => s.isCurrentlyValid).toList();

  bool get hasCapacityInfo => liveCapacity != null;
  bool get hasAtmosphereInfo => atmosphere != null;

  bool get isFeatured =>
      featuredUntil != null && DateTime.now().isBefore(featuredUntil!);

  /// Check if this venue is broadcasting a specific match
  /// Free tier: uses showsMatches toggle
  /// Premium tier: checks specific match IDs
  bool isBroadcastingMatch(String matchId) {
    if (isPremium && broadcastingSchedule != null) {
      return broadcastingSchedule!.isBroadcastingMatch(matchId);
    }
    return showsMatches;
  }

  /// Get a summary for display in venue cards
  String get enhancementSummary {
    final parts = <String>[];
    if (hasTvInfo) parts.add('$tvCount TVs');
    if (hasActiveSpecials) parts.add('${activeSpecials.length} Special${activeSpecials.length == 1 ? '' : 's'}');
    if (hasCapacityInfo) parts.add(liveCapacity!.statusText);
    return parts.isEmpty ? '' : parts.join(' · ');
  }

  // Firestore serialization
  factory VenueEnhancement.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return VenueEnhancement(
      venueId: documentId,
      ownerId: data['ownerId'] as String? ?? '',
      subscriptionTier: SubscriptionTier.fromString(data['subscriptionTier'] as String?),
      showsMatches: data['showsMatches'] as bool? ?? false,
      broadcastingSchedule: data['broadcastingSchedule'] != null
          ? BroadcastingSchedule.fromJson(
              data['broadcastingSchedule'] as Map<String, dynamic>)
          : null,
      tvSetup: data['tvSetup'] != null
          ? TvSetup.fromJson(data['tvSetup'] as Map<String, dynamic>)
          : null,
      gameSpecials: (data['gameSpecials'] as List<dynamic>?)
              ?.map((e) => GameDaySpecial.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      atmosphere: data['atmosphere'] != null
          ? AtmosphereSettings.fromJson(data['atmosphere'] as Map<String, dynamic>)
          : null,
      liveCapacity: data['liveCapacity'] != null
          ? LiveCapacity.fromJson(data['liveCapacity'] as Map<String, dynamic>)
          : null,
      businessName: data['businessName'] as String?,
      contactEmail: data['contactEmail'] as String?,
      contactPhone: data['contactPhone'] as String?,
      ownerRole: data['ownerRole'] as String?,
      venueType: data['venueType'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.parse(data['createdAt'] as String))
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is Timestamp
              ? (data['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(data['updatedAt'] as String))
          : DateTime.now(),
      isVerified: data['isVerified'] as bool? ?? false,
      featuredUntil: data['featuredUntil'] != null
          ? (data['featuredUntil'] is Timestamp
              ? (data['featuredUntil'] as Timestamp).toDate()
              : DateTime.parse(data['featuredUntil'] as String))
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'subscriptionTier': subscriptionTier.toJson(),
      'showsMatches': showsMatches,
      'broadcastingSchedule': broadcastingSchedule?.toJson(),
      'tvSetup': tvSetup?.toJson(),
      'gameSpecials': gameSpecials.map((s) => s.toJson()).toList(),
      'atmosphere': atmosphere?.toJson(),
      'liveCapacity': liveCapacity?.toJson(),
      if (businessName != null) 'businessName': businessName,
      if (contactEmail != null) 'contactEmail': contactEmail,
      if (contactPhone != null) 'contactPhone': contactPhone,
      if (ownerRole != null) 'ownerRole': ownerRole,
      if (venueType != null) 'venueType': venueType,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isVerified': isVerified,
      'featuredUntil': featuredUntil != null ? Timestamp.fromDate(featuredUntil!) : null,
    };
  }

  @override
  List<Object?> get props => [
        venueId,
        ownerId,
        subscriptionTier,
        showsMatches,
        broadcastingSchedule,
        tvSetup,
        gameSpecials,
        atmosphere,
        liveCapacity,
        businessName,
        contactEmail,
        contactPhone,
        ownerRole,
        venueType,
        createdAt,
        updatedAt,
        isVerified,
        featuredUntil,
      ];
}
