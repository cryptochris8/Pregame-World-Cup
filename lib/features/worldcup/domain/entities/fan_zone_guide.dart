import 'package:equatable/equatable.dart';

/// Cross-border travel intelligence for a World Cup 2026 host city.
///
/// Covers fan zones, transit, visa requirements, weather, and local tips
/// for all 16 host cities across USA, Mexico, and Canada. This is the first
/// World Cup spanning 3 countries, making cross-border travel planning
/// essential for fans.
///
/// All data is bundled as local JSON — no runtime API calls.
class FanZoneGuide extends Equatable {
  final String cityId;
  final String cityName;
  final String country;
  final String stateOrProvince;
  final VenueStadium venueStadium;
  final List<FanZone> fanZones;
  final TransitInfo transit;
  final String timezone;
  final int utcOffset;
  final String currency;
  final String language;
  final VisaRequirements visaRequirements;
  final WeatherInfo weather;
  final List<String> localTips;
  final String emergencyNumber;

  const FanZoneGuide({
    required this.cityId,
    required this.cityName,
    required this.country,
    required this.stateOrProvince,
    required this.venueStadium,
    required this.fanZones,
    required this.transit,
    required this.timezone,
    required this.utcOffset,
    required this.currency,
    required this.language,
    required this.visaRequirements,
    required this.weather,
    required this.localTips,
    required this.emergencyNumber,
  });

  @override
  List<Object?> get props => [cityId];

  factory FanZoneGuide.fromJson(Map<String, dynamic> json) {
    return FanZoneGuide(
      cityId: json['cityId'] as String,
      cityName: json['cityName'] as String,
      country: json['country'] as String,
      stateOrProvince: json['stateOrProvince'] as String,
      venueStadium: VenueStadium.fromJson(
          json['venueStadium'] as Map<String, dynamic>),
      fanZones: (json['fanZones'] as List<dynamic>)
          .map((f) => FanZone.fromJson(f as Map<String, dynamic>))
          .toList(),
      transit:
          TransitInfo.fromJson(json['transit'] as Map<String, dynamic>),
      timezone: json['timezone'] as String,
      utcOffset: json['utcOffset'] as int,
      currency: json['currency'] as String,
      language: json['language'] as String,
      visaRequirements: VisaRequirements.fromJson(
          json['visaRequirements'] as Map<String, dynamic>),
      weather:
          WeatherInfo.fromJson(json['weather'] as Map<String, dynamic>),
      localTips: (json['localTips'] as List<dynamic>)
          .map((t) => t as String)
          .toList(),
      emergencyNumber: json['emergencyNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityId': cityId,
      'cityName': cityName,
      'country': country,
      'stateOrProvince': stateOrProvince,
      'venueStadium': venueStadium.toJson(),
      'fanZones': fanZones.map((f) => f.toJson()).toList(),
      'transit': transit.toJson(),
      'timezone': timezone,
      'utcOffset': utcOffset,
      'currency': currency,
      'language': language,
      'visaRequirements': visaRequirements.toJson(),
      'weather': weather.toJson(),
      'localTips': localTips,
      'emergencyNumber': emergencyNumber,
    };
  }
}

class VenueStadium {
  final String name;
  final int capacity;
  final String? tournamentName;

  const VenueStadium({
    required this.name,
    required this.capacity,
    this.tournamentName,
  });

  factory VenueStadium.fromJson(Map<String, dynamic> json) {
    return VenueStadium(
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      tournamentName: json['tournamentName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'capacity': capacity,
        'tournamentName': tournamentName,
      };
}

class FanZone {
  final String name;
  final String location;
  final String description;
  final List<String> features;

  const FanZone({
    required this.name,
    required this.location,
    required this.description,
    required this.features,
  });

  factory FanZone.fromJson(Map<String, dynamic> json) {
    return FanZone(
      name: json['name'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      features: (json['features'] as List<dynamic>)
          .map((f) => f as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'location': location,
        'description': description,
        'features': features,
      };
}

class TransitInfo {
  final List<String> airports;
  final String publicTransit;
  final List<String> tips;

  const TransitInfo({
    required this.airports,
    required this.publicTransit,
    required this.tips,
  });

  factory TransitInfo.fromJson(Map<String, dynamic> json) {
    return TransitInfo(
      airports: (json['airports'] as List<dynamic>)
          .map((a) => a as String)
          .toList(),
      publicTransit: json['publicTransit'] as String,
      tips:
          (json['tips'] as List<dynamic>).map((t) => t as String).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'airports': airports,
        'publicTransit': publicTransit,
        'tips': tips,
      };
}

class VisaRequirements {
  final String forUS;
  final String forCanada;
  final String forMexico;
  final String forEU;
  final String general;

  const VisaRequirements({
    required this.forUS,
    required this.forCanada,
    required this.forMexico,
    required this.forEU,
    required this.general,
  });

  factory VisaRequirements.fromJson(Map<String, dynamic> json) {
    return VisaRequirements(
      forUS: json['forUS'] as String,
      forCanada: json['forCanada'] as String,
      forMexico: json['forMexico'] as String,
      forEU: json['forEU'] as String,
      general: json['general'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'forUS': forUS,
        'forCanada': forCanada,
        'forMexico': forMexico,
        'forEU': forEU,
        'general': general,
      };
}

class WeatherInfo {
  final int juneAvgHigh;
  final int juneAvgLow;
  final int julyAvgHigh;
  final int julyAvgLow;
  final String rainySeasonNote;

  const WeatherInfo({
    required this.juneAvgHigh,
    required this.juneAvgLow,
    required this.julyAvgHigh,
    required this.julyAvgLow,
    required this.rainySeasonNote,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      juneAvgHigh: json['juneAvgHigh'] as int,
      juneAvgLow: json['juneAvgLow'] as int,
      julyAvgHigh: json['julyAvgHigh'] as int,
      julyAvgLow: json['julyAvgLow'] as int,
      rainySeasonNote: json['rainySeasonNote'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'juneAvgHigh': juneAvgHigh,
        'juneAvgLow': juneAvgLow,
        'julyAvgHigh': julyAvgHigh,
        'julyAvgLow': julyAvgLow,
        'rainySeasonNote': rainySeasonNote,
      };
}
