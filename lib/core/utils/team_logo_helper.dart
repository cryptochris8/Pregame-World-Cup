import 'package:flutter/material.dart';

/// Helper class for displaying World Cup 2026 national team flags.
///
/// Uses emoji flags as the primary display method. Supports lookup by
/// FIFA country code (e.g., 'USA', 'BRA') or full country name
/// (e.g., 'United States', 'Brazil').
class TeamLogoHelper {
  // ---------------------------------------------------------------------------
  // Emoji flag mapping for all 48 World Cup 2026 qualified teams
  // Keys are FIFA country codes.
  // ---------------------------------------------------------------------------
  static const Map<String, String> _countryCodeToFlag = {
    // AFC (Asia)
    'AUS': '\u{1F1E6}\u{1F1FA}', // Australia
    'IRN': '\u{1F1EE}\u{1F1F7}', // Iran
    'JPN': '\u{1F1EF}\u{1F1F5}', // Japan
    'KOR': '\u{1F1F0}\u{1F1F7}', // South Korea
    'KSA': '\u{1F1F8}\u{1F1E6}', // Saudi Arabia
    'QAT': '\u{1F1F6}\u{1F1E6}', // Qatar
    'UZB': '\u{1F1FA}\u{1F1FF}', // Uzbekistan
    'IRQ': '\u{1F1EE}\u{1F1F6}', // Iraq

    // CAF (Africa)
    'CMR': '\u{1F1E8}\u{1F1F2}', // Cameroon
    'EGY': '\u{1F1EA}\u{1F1EC}', // Egypt
    'MAR': '\u{1F1F2}\u{1F1E6}', // Morocco
    'NGA': '\u{1F1F3}\u{1F1EC}', // Nigeria
    'SEN': '\u{1F1F8}\u{1F1F3}', // Senegal

    // CONCACAF (North/Central America & Caribbean)
    'CAN': '\u{1F1E8}\u{1F1E6}', // Canada
    'CRC': '\u{1F1E8}\u{1F1F7}', // Costa Rica
    'HON': '\u{1F1ED}\u{1F1F3}', // Honduras
    'JAM': '\u{1F1EF}\u{1F1F2}', // Jamaica
    'MEX': '\u{1F1F2}\u{1F1FD}', // Mexico
    'PAN': '\u{1F1F5}\u{1F1E6}', // Panama
    'USA': '\u{1F1FA}\u{1F1F8}', // United States

    // CONMEBOL (South America)
    'ARG': '\u{1F1E6}\u{1F1F7}', // Argentina
    'BOL': '\u{1F1E7}\u{1F1F4}', // Bolivia
    'BRA': '\u{1F1E7}\u{1F1F7}', // Brazil
    'CHI': '\u{1F1E8}\u{1F1F1}', // Chile
    'COL': '\u{1F1E8}\u{1F1F4}', // Colombia
    'ECU': '\u{1F1EA}\u{1F1E8}', // Ecuador
    'PAR': '\u{1F1F5}\u{1F1FE}', // Paraguay
    'PER': '\u{1F1F5}\u{1F1EA}', // Peru
    'URU': '\u{1F1FA}\u{1F1FE}', // Uruguay
    'VEN': '\u{1F1FB}\u{1F1EA}', // Venezuela

    // OFC (Oceania)
    'NZL': '\u{1F1F3}\u{1F1FF}', // New Zealand

    // UEFA (Europe)
    'ALB': '\u{1F1E6}\u{1F1F1}', // Albania
    'AUT': '\u{1F1E6}\u{1F1F9}', // Austria
    'BEL': '\u{1F1E7}\u{1F1EA}', // Belgium
    'CRO': '\u{1F1ED}\u{1F1F7}', // Croatia
    'DEN': '\u{1F1E9}\u{1F1F0}', // Denmark
    'ENG': '\u{1F3F4}\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}', // England
    'FRA': '\u{1F1EB}\u{1F1F7}', // France
    'GER': '\u{1F1E9}\u{1F1EA}', // Germany
    'NED': '\u{1F1F3}\u{1F1F1}', // Netherlands
    'POL': '\u{1F1F5}\u{1F1F1}', // Poland
    'POR': '\u{1F1F5}\u{1F1F9}', // Portugal
    'SCO': '\u{1F3F4}\u{E0067}\u{E0062}\u{E0073}\u{E0063}\u{E0074}\u{E007F}', // Scotland
    'SRB': '\u{1F1F7}\u{1F1F8}', // Serbia
    'ESP': '\u{1F1EA}\u{1F1F8}', // Spain
    'SUI': '\u{1F1E8}\u{1F1ED}', // Switzerland
    'TUR': '\u{1F1F9}\u{1F1F7}', // Turkey
    'UKR': '\u{1F1FA}\u{1F1E6}', // Ukraine
    'WAL': '\u{1F3F4}\u{E0067}\u{E0062}\u{E0077}\u{E006C}\u{E0073}\u{E007F}', // Wales
  };

  // ---------------------------------------------------------------------------
  // Full country name -> FIFA code mapping (case-insensitive lookup).
  // Includes common aliases and alternate names.
  // ---------------------------------------------------------------------------
  static const Map<String, String> _nameToCode = {
    // AFC
    'australia': 'AUS',
    'socceroos': 'AUS',
    'iran': 'IRN',
    'ir iran': 'IRN',
    'team melli': 'IRN',
    'japan': 'JPN',
    'south korea': 'KOR',
    'korea republic': 'KOR',
    'korea': 'KOR',
    'saudi arabia': 'KSA',
    'qatar': 'QAT',
    'uzbekistan': 'UZB',
    'iraq': 'IRQ',

    // CAF
    'cameroon': 'CMR',
    'egypt': 'EGY',
    'morocco': 'MAR',
    'nigeria': 'NGA',
    'super eagles': 'NGA',
    'senegal': 'SEN',

    // CONCACAF
    'canada': 'CAN',
    'costa rica': 'CRC',
    'honduras': 'HON',
    'jamaica': 'JAM',
    'reggae boyz': 'JAM',
    'mexico': 'MEX',
    'el tri': 'MEX',
    'panama': 'PAN',
    'united states': 'USA',
    'usa': 'USA',
    'us': 'USA',
    'usmnt': 'USA',

    // CONMEBOL
    'argentina': 'ARG',
    'la albiceleste': 'ARG',
    'bolivia': 'BOL',
    'brazil': 'BRA',
    'brasil': 'BRA',
    'selecao': 'BRA',
    'chile': 'CHI',
    'la roja': 'CHI',
    'colombia': 'COL',
    'los cafeteros': 'COL',
    'ecuador': 'ECU',
    'paraguay': 'PAR',
    'peru': 'PER',
    'uruguay': 'URU',
    'la celeste': 'URU',
    'venezuela': 'VEN',

    // OFC
    'new zealand': 'NZL',
    'all whites': 'NZL',

    // UEFA
    'albania': 'ALB',
    'austria': 'AUT',
    'belgium': 'BEL',
    'red devils': 'BEL',
    'croatia': 'CRO',
    'denmark': 'DEN',
    'england': 'ENG',
    'three lions': 'ENG',
    'france': 'FRA',
    'les bleus': 'FRA',
    'germany': 'GER',
    'die mannschaft': 'GER',
    'netherlands': 'NED',
    'holland': 'NED',
    'the netherlands': 'NED',
    'oranje': 'NED',
    'poland': 'POL',
    'portugal': 'POR',
    'scotland': 'SCO',
    'serbia': 'SRB',
    'spain': 'ESP',
    'la furia roja': 'ESP',
    'switzerland': 'SUI',
    'turkey': 'TUR',
    'turkiye': 'TUR',
    'ukraine': 'UKR',
    'wales': 'WAL',
  };

  /// Resolve a team identifier (code or name) to a FIFA country code.
  /// Returns null if no match is found.
  static String? _resolveCode(String? teamIdentifier) {
    if (teamIdentifier == null || teamIdentifier.isEmpty) return null;

    final cleaned = teamIdentifier.trim();

    // 1. Direct code match (case-insensitive)
    final upper = cleaned.toUpperCase();
    if (_countryCodeToFlag.containsKey(upper)) return upper;

    // 2. Name lookup (case-insensitive)
    final lower = cleaned.toLowerCase();
    if (_nameToCode.containsKey(lower)) return _nameToCode[lower];

    return null;
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Get the emoji flag string for a team.
  ///
  /// [teamIdentifier] can be a FIFA code ('USA') or a full name ('United States').
  /// Returns null if the team is not recognized.
  static String? getTeamFlag(String? teamIdentifier) {
    final code = _resolveCode(teamIdentifier);
    if (code == null) return null;
    return _countryCodeToFlag[code];
  }

  /// Get a [Text] widget displaying the emoji flag at the given [size].
  ///
  /// Falls back to a soccer ball [Icon] when the team is not recognized.
  static Widget getTeamFlagWidget(
    String? teamIdentifier, {
    double size = 24,
    Color? fallbackColor,
  }) {
    final flag = getTeamFlag(teamIdentifier);

    if (flag != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            flag,
            style: TextStyle(fontSize: size * 0.85),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Icon(
      Icons.sports_soccer,
      size: size,
      color: fallbackColor ?? Colors.orange,
    );
  }

  /// Get a widget displaying the team flag (or fallback icon).
  ///
  /// Drop-in replacement for the legacy logo widget. All existing call sites
  /// that use [teamName], [size], and [fallbackColor] continue to work.
  static Widget getTeamLogoWidget({
    required String? teamName,
    double size = 24,
    Color? fallbackColor,
  }) {
    return getTeamFlagWidget(
      teamName,
      size: size,
      fallbackColor: fallbackColor,
    );
  }

  /// Get the pregame app logo widget.
  static Widget getPregameLogo({double height = 32}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height * 0.25),
      child: Image.asset(
        'assets/logos/pregame_logo.png',
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.sports_soccer,
            size: height,
            color: Colors.orange,
          );
        },
      ),
    );
  }

  /// Check if a team has a flag available.
  static bool hasTeamLogo(String? teamName) {
    return _resolveCode(teamName) != null;
  }

  /// Get all recognized FIFA country codes.
  static List<String> getAvailableTeamCodes() {
    return _countryCodeToFlag.keys.toList();
  }

  /// Get all recognized team names (lowercase).
  static List<String> getAvailableTeams() {
    return _nameToCode.keys.toList();
  }
}
