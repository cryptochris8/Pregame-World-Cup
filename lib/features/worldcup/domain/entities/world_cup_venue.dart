import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Host country enum
enum HostCountry {
  usa,
  mexico,
  canada,
}

/// Extension for HostCountry
extension HostCountryExtension on HostCountry {
  String get displayName {
    switch (this) {
      case HostCountry.usa:
        return 'United States';
      case HostCountry.mexico:
        return 'Mexico';
      case HostCountry.canada:
        return 'Canada';
    }
  }

  String get code {
    switch (this) {
      case HostCountry.usa:
        return 'USA';
      case HostCountry.mexico:
        return 'MEX';
      case HostCountry.canada:
        return 'CAN';
    }
  }

  String get flagEmoji {
    switch (this) {
      case HostCountry.usa:
        return '\u{1F1FA}\u{1F1F8}';
      case HostCountry.mexico:
        return '\u{1F1F2}\u{1F1FD}';
      case HostCountry.canada:
        return '\u{1F1E8}\u{1F1E6}';
    }
  }
}

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
      country: _parseHostCountry(data['country'] as String?),
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
      country: _parseHostCountry(map['country'] as String?),
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

  /// Helper to parse host country from string
  static HostCountry _parseHostCountry(String? value) {
    if (value == null) return HostCountry.usa;

    final lower = value.toLowerCase();
    if (lower.contains('usa') || lower.contains('united states') ||
        lower.contains('america')) {
      return HostCountry.usa;
    } else if (lower.contains('mex') || lower.contains('mexico')) {
      return HostCountry.mexico;
    } else if (lower.contains('can') || lower.contains('canada')) {
      return HostCountry.canada;
    }

    return HostCountry.usa; // Default
  }

  @override
  String toString() => '$name ($city)';
}

/// Pre-defined World Cup 2026 venues
class WorldCupVenues {
  static const List<WorldCupVenue> all = [
    // United States venues
    WorldCupVenue(
      venueId: 'metlife',
      name: 'MetLife Stadium',
      worldCupName: 'New York New Jersey Stadium',
      city: 'East Rutherford',
      state: 'New Jersey',
      country: HostCountry.usa,
      capacity: 82500,
      yearOpened: 2010,
      latitude: 40.8128,
      longitude: -74.0742,
      timeZone: 'America/New_York',
      utcOffset: -5,
      homeTeams: ['New York Giants', 'New York Jets'],
      sports: ['American Football'],
      hasRoof: false,
      keyMatches: ['Final'],
      matchCount: 8,
    ),
    WorldCupVenue(
      venueId: 'sofi',
      name: 'SoFi Stadium',
      city: 'Inglewood',
      state: 'California',
      country: HostCountry.usa,
      capacity: 70000,
      yearOpened: 2020,
      latitude: 33.9534,
      longitude: -118.3390,
      timeZone: 'America/Los_Angeles',
      utcOffset: -8,
      homeTeams: ['Los Angeles Rams', 'Los Angeles Chargers'],
      sports: ['American Football'],
      hasRoof: true,
      retractableRoof: true,
      keyMatches: ['Quarter-Final'],
      matchCount: 7,
    ),
    WorldCupVenue(
      venueId: 'att',
      name: 'AT&T Stadium',
      city: 'Arlington',
      state: 'Texas',
      country: HostCountry.usa,
      capacity: 80000,
      worldCupCapacity: 92000,
      yearOpened: 2009,
      latitude: 32.7473,
      longitude: -97.0945,
      timeZone: 'America/Chicago',
      utcOffset: -6,
      homeTeams: ['Dallas Cowboys'],
      sports: ['American Football'],
      hasRoof: true,
      retractableRoof: true,
      keyMatches: ['Semi-Final'],
      matchCount: 9,
    ),
    WorldCupVenue(
      venueId: 'mercedes_benz',
      name: 'Mercedes-Benz Stadium',
      city: 'Atlanta',
      state: 'Georgia',
      country: HostCountry.usa,
      capacity: 71000,
      yearOpened: 2017,
      latitude: 33.7553,
      longitude: -84.4006,
      timeZone: 'America/New_York',
      utcOffset: -5,
      homeTeams: ['Atlanta Falcons', 'Atlanta United'],
      sports: ['American Football', 'Soccer'],
      hasRoof: true,
      retractableRoof: true,
      keyMatches: ['Semi-Final'],
      matchCount: 7,
    ),
    WorldCupVenue(
      venueId: 'hard_rock',
      name: 'Hard Rock Stadium',
      city: 'Miami Gardens',
      state: 'Florida',
      country: HostCountry.usa,
      capacity: 65000,
      yearOpened: 1987,
      latitude: 25.9580,
      longitude: -80.2389,
      timeZone: 'America/New_York',
      utcOffset: -5,
      homeTeams: ['Miami Dolphins', 'Inter Miami CF'],
      sports: ['American Football', 'Soccer'],
      hasRoof: false,
      matchCount: 7,
    ),
    WorldCupVenue(
      venueId: 'nrg',
      name: 'NRG Stadium',
      city: 'Houston',
      state: 'Texas',
      country: HostCountry.usa,
      capacity: 72000,
      yearOpened: 2002,
      latitude: 29.6847,
      longitude: -95.4107,
      timeZone: 'America/Chicago',
      utcOffset: -6,
      homeTeams: ['Houston Texans'],
      sports: ['American Football'],
      hasRoof: true,
      retractableRoof: true,
      matchCount: 5,
    ),
    WorldCupVenue(
      venueId: 'lincoln_financial',
      name: 'Lincoln Financial Field',
      city: 'Philadelphia',
      state: 'Pennsylvania',
      country: HostCountry.usa,
      capacity: 69000,
      yearOpened: 2003,
      latitude: 39.9008,
      longitude: -75.1675,
      timeZone: 'America/New_York',
      utcOffset: -5,
      homeTeams: ['Philadelphia Eagles'],
      sports: ['American Football'],
      hasRoof: false,
      matchCount: 6,
    ),
    WorldCupVenue(
      venueId: 'lumen',
      name: 'Lumen Field',
      city: 'Seattle',
      state: 'Washington',
      country: HostCountry.usa,
      capacity: 69000,
      yearOpened: 2002,
      latitude: 47.5952,
      longitude: -122.3316,
      timeZone: 'America/Los_Angeles',
      utcOffset: -8,
      homeTeams: ['Seattle Seahawks', 'Seattle Sounders'],
      sports: ['American Football', 'Soccer'],
      hasRoof: false,
      matchCount: 6,
    ),
    WorldCupVenue(
      venueId: 'levis',
      name: "Levi's Stadium",
      city: 'Santa Clara',
      state: 'California',
      country: HostCountry.usa,
      capacity: 68500,
      yearOpened: 2014,
      latitude: 37.4033,
      longitude: -121.9695,
      timeZone: 'America/Los_Angeles',
      utcOffset: -8,
      homeTeams: ['San Francisco 49ers'],
      sports: ['American Football'],
      hasRoof: false,
      matchCount: 6,
    ),
    WorldCupVenue(
      venueId: 'gillette',
      name: 'Gillette Stadium',
      city: 'Foxborough',
      state: 'Massachusetts',
      country: HostCountry.usa,
      capacity: 65000,
      yearOpened: 2002,
      latitude: 42.0909,
      longitude: -71.2643,
      timeZone: 'America/New_York',
      utcOffset: -5,
      homeTeams: ['New England Patriots', 'New England Revolution'],
      sports: ['American Football', 'Soccer'],
      hasRoof: false,
      matchCount: 6,
    ),
    WorldCupVenue(
      venueId: 'arrowhead',
      name: 'GEHA Field at Arrowhead Stadium',
      city: 'Kansas City',
      state: 'Missouri',
      country: HostCountry.usa,
      capacity: 76000,
      yearOpened: 1972,
      latitude: 39.0489,
      longitude: -94.4839,
      timeZone: 'America/Chicago',
      utcOffset: -6,
      homeTeams: ['Kansas City Chiefs'],
      sports: ['American Football'],
      hasRoof: false,
      matchCount: 6,
    ),
    // Mexico venues
    WorldCupVenue(
      venueId: 'azteca',
      name: 'Estadio Azteca',
      city: 'Mexico City',
      country: HostCountry.mexico,
      capacity: 87000,
      worldCupCapacity: 90000,
      yearOpened: 1966,
      latitude: 19.3029,
      longitude: -99.1506,
      timeZone: 'America/Mexico_City',
      utcOffset: -6,
      homeTeams: ['Club América', 'Cruz Azul', 'Mexico National Team'],
      sports: ['Soccer'],
      hasRoof: false,
      keyMatches: ['Opening Match'],
      matchCount: 6,
      description: 'Only stadium to host 3 World Cup tournaments (1970, 1986, 2026)',
    ),
    WorldCupVenue(
      venueId: 'akron',
      name: 'Estadio Akron',
      city: 'Guadalajara',
      state: 'Jalisco',
      country: HostCountry.mexico,
      capacity: 49850,
      yearOpened: 2010,
      latitude: 20.6821,
      longitude: -103.4621,
      timeZone: 'America/Mexico_City',
      utcOffset: -6,
      homeTeams: ['C.D. Guadalajara (Chivas)'],
      sports: ['Soccer'],
      hasRoof: false,
      matchCount: 5,
    ),
    WorldCupVenue(
      venueId: 'bbva',
      name: 'Estadio BBVA',
      city: 'Monterrey',
      state: 'Nuevo León',
      country: HostCountry.mexico,
      capacity: 53500,
      yearOpened: 2015,
      latitude: 25.6703,
      longitude: -100.2438,
      timeZone: 'America/Monterrey',
      utcOffset: -6,
      homeTeams: ['C.F. Monterrey'],
      sports: ['Soccer'],
      hasRoof: false,
      matchCount: 5,
    ),
    // Canada venues
    WorldCupVenue(
      venueId: 'bmo',
      name: 'BMO Field',
      city: 'Toronto',
      state: 'Ontario',
      country: HostCountry.canada,
      capacity: 45500,
      yearOpened: 2007,
      latitude: 43.6332,
      longitude: -79.4186,
      timeZone: 'America/Toronto',
      utcOffset: -5,
      homeTeams: ['Toronto FC', 'Toronto Argonauts'],
      sports: ['Soccer', 'Canadian Football'],
      hasRoof: false,
      keyMatches: ['Canada Opening Match'],
      matchCount: 6,
    ),
    WorldCupVenue(
      venueId: 'bc_place',
      name: 'BC Place',
      city: 'Vancouver',
      state: 'British Columbia',
      country: HostCountry.canada,
      capacity: 54500,
      yearOpened: 1983,
      latitude: 49.2768,
      longitude: -123.1119,
      timeZone: 'America/Vancouver',
      utcOffset: -8,
      homeTeams: ['Vancouver Whitecaps', 'BC Lions'],
      sports: ['Soccer', 'Canadian Football'],
      hasRoof: true,
      retractableRoof: true,
      matchCount: 6,
    ),
  ];

  /// Get venue by ID
  static WorldCupVenue? getById(String venueId) {
    try {
      return all.firstWhere((v) => v.venueId == venueId);
    } catch (_) {
      return null;
    }
  }

  /// Get venues by country
  static List<WorldCupVenue> getByCountry(HostCountry country) {
    return all.where((v) => v.country == country).toList();
  }

  /// Get venues with key matches
  static List<WorldCupVenue> getKeyMatchVenues() {
    return all.where((v) => v.hasKeyMatch).toList();
  }
}
