import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'world_cup_venue_enums.dart';

// Re-export enums, extensions, parsing helper, and static venue data
// so existing imports of this file still work.
export 'world_cup_venue_enums.dart';
export 'world_cup_venues_data.dart';

/// WorldCupVenue entity representing a FIFA World Cup 2026 stadium
class WorldCupVenue extends Equatable {
  /// Unique venue ID
  final String venueId;

  /// Official stadium name
  final String name;

  /// Stadium name during World Cup (may differ due to FIFA naming rules)
  final String? worldCupName;

  /// Host city name
  final String city;

  /// State/Province (for USA/Canada)
  final String? state;

  /// Host country
  final HostCountry country;

  /// Stadium capacity
  final int capacity;

  /// Capacity during World Cup (may be adjusted)
  final int? worldCupCapacity;

  /// Year the stadium was opened
  final int? yearOpened;

  /// Latitude coordinate
  final double? latitude;

  /// Longitude coordinate
  final double? longitude;

  /// Stadium address
  final String? address;

  /// Time zone (e.g., "America/New_York", "America/Mexico_City")
  final String? timeZone;

  /// UTC offset in hours (e.g., -5 for EST, -6 for CST)
  final int? utcOffset;

  /// URL to stadium image
  final String? imageUrl;

  /// URL to stadium thumbnail
  final String? thumbnailUrl;

  /// Home team(s) of the stadium
  final List<String> homeTeams;

  /// Sports played at the stadium
  final List<String> sports;

  /// Surface type (e.g., "Natural grass", "Artificial turf")
  final String? surfaceType;

  /// Whether stadium has a roof
  final bool hasRoof;

  /// Whether roof is retractable
  final bool retractableRoof;

  /// Key matches assigned (e.g., "Opening Match", "Semi-Final", "Final")
  final List<String> keyMatches;

  /// Number of matches to be hosted
  final int? matchCount;

  /// FIFA Fan Festival location for this city
  final String? fanFestivalLocation;

  /// Public transit options
  final List<String> publicTransit;

  /// Parking information
  final String? parkingInfo;

  /// Official venue website
  final String? websiteUrl;

  /// Description of the venue
  final String? description;

  /// Last updated timestamp
  final DateTime? updatedAt;

  const WorldCupVenue({
    required this.venueId,
    required this.name,
    this.worldCupName,
    required this.city,
    this.state,
    required this.country,
    required this.capacity,
    this.worldCupCapacity,
    this.yearOpened,
    this.latitude,
    this.longitude,
    this.address,
    this.timeZone,
    this.utcOffset,
    this.imageUrl,
    this.thumbnailUrl,
    this.homeTeams = const [],
    this.sports = const [],
    this.surfaceType,
    this.hasRoof = false,
    this.retractableRoof = false,
    this.keyMatches = const [],
    this.matchCount,
    this.fanFestivalLocation,
    this.publicTransit = const [],
    this.parkingInfo,
    this.websiteUrl,
    this.description,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [venueId, name, city, country];

  /// Get display name (World Cup name if available, otherwise regular name)
  String get displayName => worldCupName ?? name;

  /// Get full location string
  String get fullLocation {
    if (state != null) {
      return '$city, $state, ${country.displayName}';
    }
    return '$city, ${country.displayName}';
  }

  /// Get effective capacity for World Cup
  int get effectiveCapacity => worldCupCapacity ?? capacity;

  /// Whether this venue hosts a key match (semi-final, final, etc.)
  bool get hasKeyMatch => keyMatches.isNotEmpty;

  /// Factory to create from Firestore document
  factory WorldCupVenue.fromFirestore(Map<String, dynamic> data, String docId) {
    return WorldCupVenue(
      venueId: docId,
      name: data['name'] as String? ?? '',
      worldCupName: data['worldCupName'] as String?,
      city: data['city'] as String? ?? '',
      state: data['state'] as String?,
      country: parseHostCountry(data['country'] as String?),
      capacity: data['capacity'] as int? ?? 0,
      worldCupCapacity: data['worldCupCapacity'] as int?,
      yearOpened: data['yearOpened'] as int?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      address: data['address'] as String?,
      timeZone: data['timeZone'] as String?,
      utcOffset: data['utcOffset'] as int?,
      imageUrl: data['imageUrl'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      homeTeams: (data['homeTeams'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      sports: (data['sports'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      surfaceType: data['surfaceType'] as String?,
      hasRoof: data['hasRoof'] as bool? ?? false,
      retractableRoof: data['retractableRoof'] as bool? ?? false,
      keyMatches: (data['keyMatches'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      matchCount: data['matchCount'] as int?,
      fanFestivalLocation: data['fanFestivalLocation'] as String?,
      publicTransit: (data['publicTransit'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      parkingInfo: data['parkingInfo'] as String?,
      websiteUrl: data['websiteUrl'] as String?,
      description: data['description'] as String?,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'worldCupName': worldCupName,
      'city': city,
      'state': state,
      'country': country.name,
      'capacity': capacity,
      'worldCupCapacity': worldCupCapacity,
      'yearOpened': yearOpened,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timeZone': timeZone,
      'utcOffset': utcOffset,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'homeTeams': homeTeams,
      'sports': sports,
      'surfaceType': surfaceType,
      'hasRoof': hasRoof,
      'retractableRoof': retractableRoof,
      'keyMatches': keyMatches,
      'matchCount': matchCount,
      'fanFestivalLocation': fanFestivalLocation,
      'publicTransit': publicTransit,
      'parkingInfo': parkingInfo,
      'websiteUrl': websiteUrl,
      'description': description,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Convert to Map for caching
  Map<String, dynamic> toMap() {
    return {
      'venueId': venueId,
      'name': name,
      'worldCupName': worldCupName,
      'city': city,
      'state': state,
      'country': country.name,
      'capacity': capacity,
      'worldCupCapacity': worldCupCapacity,
      'yearOpened': yearOpened,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timeZone': timeZone,
      'utcOffset': utcOffset,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'homeTeams': homeTeams,
      'sports': sports,
      'surfaceType': surfaceType,
      'hasRoof': hasRoof,
      'retractableRoof': retractableRoof,
      'keyMatches': keyMatches,
      'matchCount': matchCount,
      'fanFestivalLocation': fanFestivalLocation,
      'publicTransit': publicTransit,
      'parkingInfo': parkingInfo,
      'websiteUrl': websiteUrl,
      'description': description,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Factory to create from cached Map
  factory WorldCupVenue.fromMap(Map<String, dynamic> map) {
    return WorldCupVenue(
      venueId: map['venueId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      worldCupName: map['worldCupName'] as String?,
      city: map['city'] as String? ?? '',
      state: map['state'] as String?,
      country: parseHostCountry(map['country'] as String?),
      capacity: map['capacity'] as int? ?? 0,
      worldCupCapacity: map['worldCupCapacity'] as int?,
      yearOpened: map['yearOpened'] as int?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      address: map['address'] as String?,
      timeZone: map['timeZone'] as String?,
      utcOffset: map['utcOffset'] as int?,
      imageUrl: map['imageUrl'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      homeTeams: (map['homeTeams'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      sports: (map['sports'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      surfaceType: map['surfaceType'] as String?,
      hasRoof: map['hasRoof'] as bool? ?? false,
      retractableRoof: map['retractableRoof'] as bool? ?? false,
      keyMatches: (map['keyMatches'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      matchCount: map['matchCount'] as int?,
      fanFestivalLocation: map['fanFestivalLocation'] as String?,
      publicTransit: (map['publicTransit'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      parkingInfo: map['parkingInfo'] as String?,
      websiteUrl: map['websiteUrl'] as String?,
      description: map['description'] as String?,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  WorldCupVenue copyWith({
    String? venueId,
    String? name,
    String? worldCupName,
    String? city,
    String? state,
    HostCountry? country,
    int? capacity,
    int? worldCupCapacity,
    int? yearOpened,
    double? latitude,
    double? longitude,
    String? address,
    String? timeZone,
    int? utcOffset,
    String? imageUrl,
    String? thumbnailUrl,
    List<String>? homeTeams,
    List<String>? sports,
    String? surfaceType,
    bool? hasRoof,
    bool? retractableRoof,
    List<String>? keyMatches,
    int? matchCount,
    String? fanFestivalLocation,
    List<String>? publicTransit,
    String? parkingInfo,
    String? websiteUrl,
    String? description,
    DateTime? updatedAt,
  }) {
    return WorldCupVenue(
      venueId: venueId ?? this.venueId,
      name: name ?? this.name,
      worldCupName: worldCupName ?? this.worldCupName,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      capacity: capacity ?? this.capacity,
      worldCupCapacity: worldCupCapacity ?? this.worldCupCapacity,
      yearOpened: yearOpened ?? this.yearOpened,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      timeZone: timeZone ?? this.timeZone,
      utcOffset: utcOffset ?? this.utcOffset,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      homeTeams: homeTeams ?? this.homeTeams,
      sports: sports ?? this.sports,
      surfaceType: surfaceType ?? this.surfaceType,
      hasRoof: hasRoof ?? this.hasRoof,
      retractableRoof: retractableRoof ?? this.retractableRoof,
      keyMatches: keyMatches ?? this.keyMatches,
      matchCount: matchCount ?? this.matchCount,
      fanFestivalLocation: fanFestivalLocation ?? this.fanFestivalLocation,
      publicTransit: publicTransit ?? this.publicTransit,
      parkingInfo: parkingInfo ?? this.parkingInfo,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      description: description ?? this.description,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => '$name ($city)';
}
