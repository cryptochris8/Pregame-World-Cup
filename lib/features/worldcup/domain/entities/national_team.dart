import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// FIFA Confederation enum
enum Confederation {
  uefa,      // Europe
  conmebol,  // South America
  concacaf,  // North/Central America & Caribbean
  afc,       // Asia
  caf,       // Africa
  ofc,       // Oceania
}

/// Extension to get confederation display names
extension ConfederationExtension on Confederation {
  String get displayName {
    switch (this) {
      case Confederation.uefa:
        return 'UEFA';
      case Confederation.conmebol:
        return 'CONMEBOL';
      case Confederation.concacaf:
        return 'CONCACAF';
      case Confederation.afc:
        return 'AFC';
      case Confederation.caf:
        return 'CAF';
      case Confederation.ofc:
        return 'OFC';
    }
  }

  String get fullName {
    switch (this) {
      case Confederation.uefa:
        return 'Union of European Football Associations';
      case Confederation.conmebol:
        return 'South American Football Confederation';
      case Confederation.concacaf:
        return 'Confederation of North, Central America and Caribbean Association Football';
      case Confederation.afc:
        return 'Asian Football Confederation';
      case Confederation.caf:
        return 'Confederation of African Football';
      case Confederation.ofc:
        return 'Oceania Football Confederation';
    }
  }
}

/// NationalTeam entity representing a country's national football team
/// for the FIFA World Cup 2026
class NationalTeam extends Equatable {
  /// FIFA 3-letter country code (e.g., USA, MEX, GER, BRA)
  final String fifaCode;

  /// Full country name (e.g., "United States", "Germany")
  final String countryName;

  /// Short/common name (e.g., "USA", "Germany")
  final String shortName;

  /// URL to the team's flag image
  final String flagUrl;

  /// URL to the team's federation/association logo
  final String? federationLogoUrl;

  /// FIFA Confederation the team belongs to
  final Confederation confederation;

  /// Current FIFA World Ranking
  final int? fifaRanking;

  /// Head coach name
  final String? coachName;

  /// Team's primary color (hex code)
  final String? primaryColor;

  /// Team's secondary color (hex code)
  final String? secondaryColor;

  /// World Cup group assignment (A-L, null if not yet assigned)
  final String? group;

  /// Number of World Cup titles won
  final int worldCupTitles;

  /// Best World Cup finish (e.g., "Winner", "Runner-up", "Semi-finals")
  final String? bestFinish;

  /// Number of World Cup appearances
  final int worldCupAppearances;

  /// Whether this is a host nation (USA, Mexico, Canada)
  final bool isHostNation;

  /// Team's official nickname (e.g., "Die Mannschaft", "La Albiceleste")
  final String? nickname;

  /// Stadium used as home ground (for friendlies/qualifiers)
  final String? homeStadium;

  /// Captain's name
  final String? captainName;

  /// Star players (list of key player names)
  final List<String> starPlayers;

  /// Qualification method (e.g., "Host", "UEFA Qualifier", "Playoff winner")
  final String? qualificationMethod;

  /// Whether the team has qualified for World Cup 2026
  final bool isQualified;

  /// Last updated timestamp
  final DateTime? updatedAt;

  const NationalTeam({
    required this.fifaCode,
    required this.countryName,
    required this.shortName,
    required this.flagUrl,
    this.federationLogoUrl,
    required this.confederation,
    this.fifaRanking,
    this.coachName,
    this.primaryColor,
    this.secondaryColor,
    this.group,
    this.worldCupTitles = 0,
    this.bestFinish,
    this.worldCupAppearances = 0,
    this.isHostNation = false,
    this.nickname,
    this.homeStadium,
    this.captainName,
    this.starPlayers = const [],
    this.qualificationMethod,
    this.isQualified = false,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    fifaCode,
    countryName,
    shortName,
    flagUrl,
    confederation,
    fifaRanking,
    group,
    isQualified,
  ];

  /// Factory to create from Firestore document
  factory NationalTeam.fromFirestore(Map<String, dynamic> data, String docId) {
    return NationalTeam(
      fifaCode: data['fifaCode'] as String? ?? docId,
      countryName: data['countryName'] as String? ?? '',
      shortName: data['shortName'] as String? ?? '',
      flagUrl: data['flagUrl'] as String? ?? '',
      federationLogoUrl: data['federationLogoUrl'] as String?,
      confederation: _parseConfederation(data['confederation'] as String?),
      fifaRanking: data['fifaRanking'] as int?,
      coachName: data['coachName'] as String?,
      primaryColor: data['primaryColor'] as String?,
      secondaryColor: data['secondaryColor'] as String?,
      group: data['group'] as String?,
      worldCupTitles: data['worldCupTitles'] as int? ?? 0,
      bestFinish: data['bestFinish'] as String?,
      worldCupAppearances: data['worldCupAppearances'] as int? ?? 0,
      isHostNation: data['isHostNation'] as bool? ?? false,
      nickname: data['nickname'] as String?,
      homeStadium: data['homeStadium'] as String?,
      captainName: data['captainName'] as String?,
      starPlayers: (data['starPlayers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      qualificationMethod: data['qualificationMethod'] as String?,
      isQualified: data['isQualified'] as bool? ?? false,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Factory to create from API JSON (SportsData.io format)
  factory NationalTeam.fromApi(Map<String, dynamic> json) {
    return NationalTeam(
      fifaCode: json['Key'] as String? ?? json['TeamId']?.toString() ?? '',
      countryName: json['FullName'] as String? ?? json['Name'] as String? ?? '',
      shortName: json['ShortName'] as String? ?? json['Name'] as String? ?? '',
      flagUrl: json['WikipediaLogoUrl'] as String? ??
               json['FlagUrl'] as String? ?? '',
      confederation: _parseConfederation(json['AreaName'] as String?),
      fifaRanking: json['GlobalTeamRanking'] as int?,
      coachName: json['Coach']?['Name'] as String?,
      isQualified: true, // If in API, assume qualified
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'fifaCode': fifaCode,
      'countryName': countryName,
      'shortName': shortName,
      'flagUrl': flagUrl,
      'federationLogoUrl': federationLogoUrl,
      'confederation': confederation.name,
      'fifaRanking': fifaRanking,
      'coachName': coachName,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'group': group,
      'worldCupTitles': worldCupTitles,
      'bestFinish': bestFinish,
      'worldCupAppearances': worldCupAppearances,
      'isHostNation': isHostNation,
      'nickname': nickname,
      'homeStadium': homeStadium,
      'captainName': captainName,
      'starPlayers': starPlayers,
      'qualificationMethod': qualificationMethod,
      'isQualified': isQualified,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Convert to Map for caching
  Map<String, dynamic> toMap() {
    return {
      'fifaCode': fifaCode,
      'countryName': countryName,
      'shortName': shortName,
      'flagUrl': flagUrl,
      'federationLogoUrl': federationLogoUrl,
      'confederation': confederation.name,
      'fifaRanking': fifaRanking,
      'coachName': coachName,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'group': group,
      'worldCupTitles': worldCupTitles,
      'bestFinish': bestFinish,
      'worldCupAppearances': worldCupAppearances,
      'isHostNation': isHostNation,
      'nickname': nickname,
      'homeStadium': homeStadium,
      'captainName': captainName,
      'starPlayers': starPlayers,
      'qualificationMethod': qualificationMethod,
      'isQualified': isQualified,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Factory to create from cached Map
  factory NationalTeam.fromMap(Map<String, dynamic> map) {
    return NationalTeam(
      fifaCode: map['fifaCode'] as String? ?? '',
      countryName: map['countryName'] as String? ?? '',
      shortName: map['shortName'] as String? ?? '',
      flagUrl: map['flagUrl'] as String? ?? '',
      federationLogoUrl: map['federationLogoUrl'] as String?,
      confederation: _parseConfederation(map['confederation'] as String?),
      fifaRanking: map['fifaRanking'] as int?,
      coachName: map['coachName'] as String?,
      primaryColor: map['primaryColor'] as String?,
      secondaryColor: map['secondaryColor'] as String?,
      group: map['group'] as String?,
      worldCupTitles: map['worldCupTitles'] as int? ?? 0,
      bestFinish: map['bestFinish'] as String?,
      worldCupAppearances: map['worldCupAppearances'] as int? ?? 0,
      isHostNation: map['isHostNation'] as bool? ?? false,
      nickname: map['nickname'] as String?,
      homeStadium: map['homeStadium'] as String?,
      captainName: map['captainName'] as String?,
      starPlayers: (map['starPlayers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      qualificationMethod: map['qualificationMethod'] as String?,
      isQualified: map['isQualified'] as bool? ?? false,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  NationalTeam copyWith({
    String? fifaCode,
    String? countryName,
    String? shortName,
    String? flagUrl,
    String? federationLogoUrl,
    Confederation? confederation,
    int? fifaRanking,
    String? coachName,
    String? primaryColor,
    String? secondaryColor,
    String? group,
    int? worldCupTitles,
    String? bestFinish,
    int? worldCupAppearances,
    bool? isHostNation,
    String? nickname,
    String? homeStadium,
    String? captainName,
    List<String>? starPlayers,
    String? qualificationMethod,
    bool? isQualified,
    DateTime? updatedAt,
  }) {
    return NationalTeam(
      fifaCode: fifaCode ?? this.fifaCode,
      countryName: countryName ?? this.countryName,
      shortName: shortName ?? this.shortName,
      flagUrl: flagUrl ?? this.flagUrl,
      federationLogoUrl: federationLogoUrl ?? this.federationLogoUrl,
      confederation: confederation ?? this.confederation,
      fifaRanking: fifaRanking ?? this.fifaRanking,
      coachName: coachName ?? this.coachName,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      group: group ?? this.group,
      worldCupTitles: worldCupTitles ?? this.worldCupTitles,
      bestFinish: bestFinish ?? this.bestFinish,
      worldCupAppearances: worldCupAppearances ?? this.worldCupAppearances,
      isHostNation: isHostNation ?? this.isHostNation,
      nickname: nickname ?? this.nickname,
      homeStadium: homeStadium ?? this.homeStadium,
      captainName: captainName ?? this.captainName,
      starPlayers: starPlayers ?? this.starPlayers,
      qualificationMethod: qualificationMethod ?? this.qualificationMethod,
      isQualified: isQualified ?? this.isQualified,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper to parse confederation from string
  static Confederation _parseConfederation(String? value) {
    if (value == null) return Confederation.uefa;

    final lower = value.toLowerCase();
    if (lower.contains('uefa') || lower.contains('europe')) {
      return Confederation.uefa;
    } else if (lower.contains('conmebol') || lower.contains('south america')) {
      return Confederation.conmebol;
    } else if (lower.contains('concacaf') || lower.contains('north america') ||
               lower.contains('central america')) {
      return Confederation.concacaf;
    } else if (lower.contains('afc') || lower.contains('asia')) {
      return Confederation.afc;
    } else if (lower.contains('caf') || lower.contains('africa')) {
      return Confederation.caf;
    } else if (lower.contains('ofc') || lower.contains('oceania')) {
      return Confederation.ofc;
    }

    return Confederation.uefa; // Default
  }

  /// Get flag emoji based on FIFA code
  String get flagEmoji {
    // Convert FIFA code to flag emoji using regional indicator symbols
    // This works for most 2-letter country codes
    final code = fifaCode.length >= 2 ? fifaCode.substring(0, 2).toUpperCase() : 'XX';

    // Special cases where FIFA code differs from ISO code
    final Map<String, String> specialCases = {
      'USA': 'US',
      'GER': 'DE',
      'ENG': 'GB', // England uses GB flag
      'NED': 'NL',
      'CRO': 'HR',
      'SUI': 'CH',
      'POR': 'PT',
      'KOR': 'KR',
      'JPN': 'JP',
      'IRN': 'IR',
      'KSA': 'SA',
      'RSA': 'ZA',
      'CRC': 'CR',
      'URU': 'UY',
      'PAR': 'PY',
      'CHI': 'CL',
      'COL': 'CO',
      'ECU': 'EC',
      'VEN': 'VE',
      'ALG': 'DZ',
      'MAR': 'MA',
      'TUN': 'TN',
      'NGA': 'NG',
      'SEN': 'SN',
      'GHA': 'GH',
      'CMR': 'CM',
      'CIV': 'CI',
      'EGY': 'EG',
    };

    final isoCode = specialCases[fifaCode] ?? code;

    // Convert to regional indicator symbols (flag emoji)
    final firstChar = String.fromCharCode(0x1F1E6 + isoCode.codeUnitAt(0) - 65);
    final secondChar = String.fromCharCode(0x1F1E6 + isoCode.codeUnitAt(1) - 65);

    return '$firstChar$secondChar';
  }

  @override
  String toString() => '$shortName ($fifaCode)';
}
