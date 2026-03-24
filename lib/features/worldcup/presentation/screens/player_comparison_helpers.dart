/// Shared helper for converting country codes to flag emojis
String getFlagEmoji(String teamCode) {
  const Map<String, String> codeMap = {
    'USA': 'US', 'GER': 'DE', 'ENG': 'GB', 'NED': 'NL', 'CRO': 'HR',
    'SUI': 'CH', 'POR': 'PT', 'KOR': 'KR', 'JPN': 'JP', 'IRN': 'IR',
    'SAU': 'SA', 'RSA': 'ZA', 'CRC': 'CR', 'URU': 'UY', 'PAR': 'PY',
    'CHI': 'CL', 'COL': 'CO', 'ECU': 'EC', 'VEN': 'VE', 'ALG': 'DZ',
    'MAR': 'MA', 'TUN': 'TN', 'NGA': 'NG', 'SEN': 'SN', 'GHA': 'GH',
    'CMR': 'CM', 'CIV': 'CI', 'EGY': 'EG',
  };

  final code = codeMap[teamCode] ?? teamCode.substring(0, 2);
  if (code.length < 2) return '';

  final firstChar = String.fromCharCode(0x1F1E6 + code.codeUnitAt(0) - 65);
  final secondChar = String.fromCharCode(0x1F1E6 + code.codeUnitAt(1) - 65);
  return '$firstChar$secondChar';
}
