import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

/// User preference for how to display match times
enum TimezoneDisplayMode {
  /// Show times in user's local timezone
  local,
  /// Show times in the venue's local timezone
  venue,
  /// Show both local and venue times
  both,
}

/// Utility class for handling timezone conversions for World Cup matches
class TimezoneUtils {
  TimezoneUtils._();

  static bool _initialized = false;
  static const String _prefKeyTimezoneMode = 'timezone_display_mode';
  static const String _prefKeyUserTimezone = 'user_timezone_override';

  /// Initialize timezone database - must be called before using any timezone functions
  static Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  /// Get the user's local timezone name (IANA format)
  static String getLocalTimezoneName() {
    // Get the local timezone offset and try to determine the timezone
    final now = DateTime.now();
    final offset = now.timeZoneOffset;

    // Try to get a matching timezone from the database
    // This is a simplified approach - in production, you might want to use
    // device APIs to get the actual timezone name
    return _getTimezoneFromOffset(offset);
  }

  /// Get timezone location from IANA name
  static tz.Location getLocation(String timezoneName) {
    _ensureInitialized();
    try {
      return tz.getLocation(timezoneName);
    } catch (e) {
      // Fallback to UTC if timezone not found
      return tz.getLocation('UTC');
    }
  }

  /// Convert a UTC DateTime to a specific timezone
  static DateTime convertToTimezone(DateTime utcDateTime, String timezoneName) {
    _ensureInitialized();
    final location = getLocation(timezoneName);
    final tzDateTime = tz.TZDateTime.from(utcDateTime.toUtc(), location);
    return tzDateTime;
  }

  /// Convert a UTC DateTime to the user's local timezone
  static DateTime convertToLocal(DateTime utcDateTime) {
    return utcDateTime.toLocal();
  }

  /// Format a match time with timezone indicator
  /// [utcDateTime] - The match time in UTC
  /// [venueTimezone] - The venue's timezone (IANA format, e.g., "America/New_York")
  /// [mode] - How to display the time
  static String formatMatchTime({
    required DateTime utcDateTime,
    required String venueTimezone,
    TimezoneDisplayMode mode = TimezoneDisplayMode.local,
  }) {
    _ensureInitialized();

    switch (mode) {
      case TimezoneDisplayMode.local:
        return _formatLocalTime(utcDateTime);
      case TimezoneDisplayMode.venue:
        return _formatVenueTime(utcDateTime, venueTimezone);
      case TimezoneDisplayMode.both:
        return _formatBothTimes(utcDateTime, venueTimezone);
    }
  }

  /// Format time in user's local timezone with abbreviation
  static String _formatLocalTime(DateTime utcDateTime) {
    final localTime = utcDateTime.toLocal();
    final timeFormat = DateFormat('h:mm a');
    final abbrev = _getTimezoneAbbreviation(localTime);
    return '${timeFormat.format(localTime)} $abbrev';
  }

  /// Format time in venue's timezone with abbreviation
  static String _formatVenueTime(DateTime utcDateTime, String venueTimezone) {
    final location = getLocation(venueTimezone);
    final venueTime = tz.TZDateTime.from(utcDateTime.toUtc(), location);
    final timeFormat = DateFormat('h:mm a');
    final abbrev = venueTime.timeZoneOffset.inHours >= 0
        ? _getTimezoneAbbreviationFromName(venueTimezone)
        : _getTimezoneAbbreviationFromName(venueTimezone);
    return '${timeFormat.format(venueTime)} $abbrev';
  }

  /// Format both local and venue times
  static String _formatBothTimes(DateTime utcDateTime, String venueTimezone) {
    final localStr = _formatLocalTime(utcDateTime);
    final venueStr = _formatVenueTime(utcDateTime, venueTimezone);

    // Only show both if they're different
    if (_areTimezonesEquivalent(utcDateTime, venueTimezone)) {
      return localStr;
    }
    return '$localStr (Venue: $venueStr)';
  }

  /// Check if user's local timezone matches the venue timezone
  static bool _areTimezonesEquivalent(DateTime utcDateTime, String venueTimezone) {
    final localTime = utcDateTime.toLocal();
    final location = getLocation(venueTimezone);
    final venueTime = tz.TZDateTime.from(utcDateTime.toUtc(), location);
    return localTime.timeZoneOffset == venueTime.timeZoneOffset;
  }

  /// Get timezone abbreviation for a local DateTime
  static String _getTimezoneAbbreviation(DateTime localTime) {
    final offset = localTime.timeZoneOffset;
    final hours = offset.inHours;
    final minutes = offset.inMinutes.remainder(60).abs();

    // Common US timezone abbreviations based on offset and DST
    // This is simplified - a more robust solution would use the actual timezone name
    if (hours == -5 && minutes == 0) return 'EST';
    if (hours == -4 && minutes == 0) return 'EDT';
    if (hours == -6 && minutes == 0) return 'CST';
    if (hours == -5 && minutes == 0) return 'CDT';
    if (hours == -7 && minutes == 0) return 'MST';
    if (hours == -6 && minutes == 0) return 'MDT';
    if (hours == -8 && minutes == 0) return 'PST';
    if (hours == -7 && minutes == 0) return 'PDT';

    // Generic offset format for other timezones
    final sign = hours >= 0 ? '+' : '';
    if (minutes == 0) {
      return 'UTC$sign$hours';
    }
    return 'UTC$sign$hours:${minutes.toString().padLeft(2, '0')}';
  }

  /// Get timezone abbreviation from IANA timezone name
  static String _getTimezoneAbbreviationFromName(String timezoneName) {
    // Map common World Cup venue timezones to abbreviations
    // Use the timezone abbreviation from the TZDateTime
    final now = DateTime.now();
    final location = getLocation(timezoneName);
    final tzDateTime = tz.TZDateTime.from(now.toUtc(), location);

    // Get the timezone abbreviation from the location
    final abbrev = tzDateTime.timeZoneName;

    // Common abbreviation mappings for readability
    switch (abbrev) {
      case 'EST':
      case 'EDT':
      case 'CST':
      case 'CDT':
      case 'MST':
      case 'MDT':
      case 'PST':
      case 'PDT':
        return abbrev;
      default:
        // For other timezones, use offset-based abbreviation
        return _getTimezoneAbbreviation(tzDateTime);
    }
  }

  /// Get timezone offset from name (in hours)
  static int getTimezoneOffset(String timezoneName) {
    _ensureInitialized();
    final location = getLocation(timezoneName);
    final now = tz.TZDateTime.now(location);
    return now.timeZoneOffset.inHours;
  }

  /// Determine timezone from offset (simplified mapping)
  static String _getTimezoneFromOffset(Duration offset) {
    final hours = offset.inHours;

    // Map common offsets to timezone names
    // This is US-centric for World Cup 2026
    switch (hours) {
      case -5:
        return 'America/New_York';
      case -4:
        return 'America/New_York'; // EDT
      case -6:
        return 'America/Chicago';
      case -7:
        return 'America/Denver';
      case -8:
        return 'America/Los_Angeles';
      default:
        return 'UTC';
    }
  }

  /// Save user's timezone display preference
  static Future<void> setTimezoneDisplayMode(TimezoneDisplayMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyTimezoneMode, mode.index);
  }

  /// Get user's timezone display preference
  static Future<TimezoneDisplayMode> getTimezoneDisplayMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_prefKeyTimezoneMode) ?? TimezoneDisplayMode.local.index;
    return TimezoneDisplayMode.values[index];
  }

  /// Save user's timezone override (if they want to manually set their timezone)
  static Future<void> setUserTimezoneOverride(String? timezone) async {
    final prefs = await SharedPreferences.getInstance();
    if (timezone == null) {
      await prefs.remove(_prefKeyUserTimezone);
    } else {
      await prefs.setString(_prefKeyUserTimezone, timezone);
    }
  }

  /// Get user's timezone override
  static Future<String?> getUserTimezoneOverride() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKeyUserTimezone);
  }

  /// Format a full date and time for a match
  /// Returns format like "Jun 14, 7:00 PM EDT" or "Jun 14, 2026 7:00 PM EDT"
  static String formatMatchDateTime({
    required DateTime utcDateTime,
    required String venueTimezone,
    TimezoneDisplayMode mode = TimezoneDisplayMode.local,
    bool includeYear = false,
  }) {
    _ensureInitialized();

    final DateTime displayTime;
    final String abbrev;

    switch (mode) {
      case TimezoneDisplayMode.local:
        displayTime = utcDateTime.toLocal();
        abbrev = _getTimezoneAbbreviation(displayTime);
        break;
      case TimezoneDisplayMode.venue:
        final location = getLocation(venueTimezone);
        displayTime = tz.TZDateTime.from(utcDateTime.toUtc(), location);
        abbrev = _getTimezoneAbbreviationFromName(venueTimezone);
        break;
      case TimezoneDisplayMode.both:
        // For full datetime, just use local in "both" mode
        displayTime = utcDateTime.toLocal();
        abbrev = _getTimezoneAbbreviation(displayTime);
        break;
    }

    final dateFormat = includeYear
        ? DateFormat('MMM d, yyyy')
        : DateFormat('MMM d');
    final timeFormat = DateFormat('h:mm a');

    return '${dateFormat.format(displayTime)}, ${timeFormat.format(displayTime)} $abbrev';
  }

  /// Format relative date (Today, Tomorrow, or date)
  static String formatRelativeDate({
    required DateTime utcDateTime,
    required String venueTimezone,
    TimezoneDisplayMode mode = TimezoneDisplayMode.local,
  }) {
    _ensureInitialized();

    final DateTime displayTime;
    final String abbrev;

    if (mode == TimezoneDisplayMode.venue) {
      final location = getLocation(venueTimezone);
      displayTime = tz.TZDateTime.from(utcDateTime.toUtc(), location);
      abbrev = _getTimezoneAbbreviationFromName(venueTimezone);
    } else {
      displayTime = utcDateTime.toLocal();
      abbrev = _getTimezoneAbbreviation(displayTime);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final matchDay = DateTime(displayTime.year, displayTime.month, displayTime.day);

    final timeFormat = DateFormat('h:mm a');
    final timeStr = '${timeFormat.format(displayTime)} $abbrev';

    if (matchDay == today) {
      return 'Today, $timeStr';
    } else if (matchDay == tomorrow) {
      return 'Tomorrow, $timeStr';
    } else {
      final dateFormat = DateFormat('MMM d');
      return '${dateFormat.format(displayTime)}, $timeStr';
    }
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'TimezoneUtils not initialized. Call TimezoneUtils.initialize() first.',
      );
    }
  }

  /// List of all World Cup 2026 venue timezones for settings UI
  static const List<Map<String, String>> worldCupTimezones = [
    {'name': 'America/New_York', 'label': 'Eastern Time (New York, Miami, Philadelphia)'},
    {'name': 'America/Chicago', 'label': 'Central Time (Houston, Dallas, Kansas City)'},
    {'name': 'America/Denver', 'label': 'Mountain Time (Denver)'},
    {'name': 'America/Los_Angeles', 'label': 'Pacific Time (Los Angeles, San Francisco, Seattle)'},
    {'name': 'America/Mexico_City', 'label': 'Mexico City Time (Mexico City, Guadalajara)'},
    {'name': 'America/Monterrey', 'label': 'Monterrey Time'},
    {'name': 'America/Vancouver', 'label': 'Pacific Time (Vancouver)'},
    {'name': 'America/Toronto', 'label': 'Eastern Time (Toronto)'},
  ];
}

/// Extension on DateTime for convenient timezone conversion
extension DateTimeTimezoneExtension on DateTime {
  /// Convert this UTC datetime to a specific timezone
  DateTime toTimezone(String timezoneName) {
    return TimezoneUtils.convertToTimezone(this, timezoneName);
  }
}
