/// Utility class for handling country flags and FIFA/ISO code conversions
class FlagUtils {
  FlagUtils._();

  /// FIFA code to ISO country code mapping
  /// Used for flagcdn.com which requires ISO codes
  static const Map<String, String> fifaToIsoCode = {
    // CONCACAF
    'USA': 'us', 'MEX': 'mx', 'CAN': 'ca', 'CRC': 'cr', 'JAM': 'jm',
    'HON': 'hn', 'PAN': 'pa', 'SLV': 'sv', 'GTM': 'gt', 'NCA': 'ni',
    'CUB': 'cu', 'HAI': 'ht', 'TRI': 'tt',
    // CONMEBOL
    'BRA': 'br', 'ARG': 'ar', 'URU': 'uy', 'COL': 'co', 'ECU': 'ec',
    'CHI': 'cl', 'PER': 'pe', 'PAR': 'py', 'BOL': 'bo', 'VEN': 've',
    // UEFA
    'FRA': 'fr', 'ENG': 'gb-eng', 'ESP': 'es', 'GER': 'de', 'NED': 'nl',
    'POR': 'pt', 'BEL': 'be', 'ITA': 'it', 'CRO': 'hr', 'DEN': 'dk',
    'SUI': 'ch', 'AUT': 'at', 'POL': 'pl', 'SRB': 'rs', 'UKR': 'ua',
    'WAL': 'gb-wls', 'SCO': 'gb-sct', 'NIR': 'gb-nir', 'IRL': 'ie',
    'CZE': 'cz', 'ROU': 'ro', 'GRE': 'gr', 'HUN': 'hu', 'SWE': 'se',
    'NOR': 'no', 'FIN': 'fi', 'TUR': 'tr', 'RUS': 'ru', 'SVK': 'sk',
    'SVN': 'si', 'BUL': 'bg', 'BIH': 'ba', 'MNE': 'me', 'MKD': 'mk',
    'ALB': 'al', 'KOS': 'xk', 'ISL': 'is', 'LUX': 'lu', 'CYP': 'cy',
    'GEO': 'ge', 'ARM': 'am', 'AZE': 'az',
    // AFC
    'JPN': 'jp', 'KOR': 'kr', 'AUS': 'au', 'IRN': 'ir', 'KSA': 'sa',
    'QAT': 'qa', 'UAE': 'ae', 'CHN': 'cn', 'IND': 'in', 'THA': 'th',
    'VIE': 'vn', 'IDN': 'id', 'MAS': 'my', 'SIN': 'sg', 'PHI': 'ph',
    'IRQ': 'iq', 'SYR': 'sy', 'JOR': 'jo', 'LBN': 'lb', 'OMA': 'om',
    'BHR': 'bh', 'KUW': 'kw', 'UZB': 'uz', 'PRK': 'kp',
    // CAF
    'MAR': 'ma', 'SEN': 'sn', 'NGA': 'ng', 'EGY': 'eg', 'GHA': 'gh',
    'CMR': 'cm', 'CIV': 'ci', 'ALG': 'dz', 'TUN': 'tn', 'RSA': 'za',
    'MLI': 'ml', 'BFA': 'bf', 'GUI': 'gn', 'COD': 'cd', 'CGO': 'cg',
    'GAB': 'ga', 'ZAM': 'zm', 'ZIM': 'zw', 'ANG': 'ao', 'MOZ': 'mz',
    'ETH': 'et', 'KEN': 'ke', 'UGA': 'ug', 'TAN': 'tz', 'SUD': 'sd',
    'LBY': 'ly', 'MTN': 'mr', 'CPV': 'cv', 'TOG': 'tg', 'BEN': 'bj',
    'NIG': 'ne', 'GAM': 'gm', 'SLE': 'sl', 'LBR': 'lr', 'NAM': 'na',
    'BOT': 'bw', 'MWI': 'mw', 'RWA': 'rw', 'BDI': 'bi', 'CAR': 'cf',
    'GNB': 'gw', 'EQG': 'gq', 'MAD': 'mg', 'COM': 'km', 'MRI': 'mu',
    // OFC
    'NZL': 'nz', 'FIJ': 'fj', 'PNG': 'pg', 'NCL': 'nc', 'TAH': 'pf',
    'SOL': 'sb', 'VAN': 'vu', 'SAM': 'ws', 'TGA': 'to',
  };

  /// Get ISO country code from FIFA code
  static String getIsoCode(String fifaCode) {
    return fifaToIsoCode[fifaCode.toUpperCase()] ?? fifaCode.toLowerCase();
  }

  /// Get flag URL for a FIFA code using flagcdn.com
  /// [width] - Width of the flag image (default 80, options: 16, 20, 24, 32, 40, 48, 64, 80, 160, 320)
  static String getFlagUrl(String fifaCode, {int width = 80}) {
    final isoCode = getIsoCode(fifaCode);
    return 'https://flagcdn.com/w$width/$isoCode.png';
  }

  /// Get high-resolution flag URL (SVG format)
  static String getFlagSvgUrl(String fifaCode) {
    final isoCode = getIsoCode(fifaCode);
    return 'https://flagcdn.com/$isoCode.svg';
  }

  /// Get flag emoji from FIFA code
  static String getFlagEmoji(String fifaCode) {
    final isoCode = getIsoCode(fifaCode).toUpperCase();

    // Handle special cases for GB subdivisions
    if (isoCode.startsWith('GB-')) {
      return _getGBSubdivisionEmoji(isoCode);
    }

    // Only works for 2-letter codes
    if (isoCode.length != 2) return '🏳️';

    // Convert to regional indicator symbols
    final firstChar = String.fromCharCode(0x1F1E6 + isoCode.codeUnitAt(0) - 65);
    final secondChar = String.fromCharCode(0x1F1E6 + isoCode.codeUnitAt(1) - 65);
    return '$firstChar$secondChar';
  }

  static String _getGBSubdivisionEmoji(String isoCode) {
    switch (isoCode) {
      case 'GB-ENG':
        return '🏴󠁧󠁢󠁥󠁮󠁧󠁿'; // England
      case 'GB-SCT':
        return '🏴󠁧󠁢󠁳󠁣󠁴󠁿'; // Scotland
      case 'GB-WLS':
        return '🏴󠁧󠁢󠁷󠁬󠁳󠁿'; // Wales
      case 'GB-NIR':
        return '🇬🇧'; // Northern Ireland (uses UK flag)
      default:
        return '🇬🇧'; // United Kingdom
    }
  }

  /// Check if a FIFA code has a known ISO mapping
  static bool hasKnownMapping(String fifaCode) {
    return fifaToIsoCode.containsKey(fifaCode.toUpperCase());
  }
}
