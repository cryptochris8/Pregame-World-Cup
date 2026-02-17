/// Enums and extensions for World Cup venue entities.
library;

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

/// Helper to parse host country from string
HostCountry parseHostCountry(String? value) {
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
