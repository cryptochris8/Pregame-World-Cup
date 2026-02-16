import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';

/// Handles parsing ESPN soccer API event data into GameSchedule objects.
/// Supports both basic schedule parsing and enhanced historical/live data parsing.
class ESPNScheduleParser {
  /// Format date for ESPN API (YYYYMMDD format)
  String formatDateForESPN(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  /// Parse ESPN soccer event data to GameSchedule object.
  /// Handles ESPN's soccer response format: competitions > competitors (teams),
  /// venue, broadcasts, match status, etc.
  GameSchedule? parseESPNEventToGameSchedule(Map<String, dynamic> event) {
    try {
      final eventId = event['id']?.toString() ?? '';
      final date = event['date'] ?? '';

      // Parse teams from competitions
      final competitions = event['competitions'] as List? ?? [];
      if (competitions.isEmpty) return null;

      final competition = competitions[0] as Map<String, dynamic>;
      final competitors = competition['competitors'] as List? ?? [];

      if (competitors.length < 2) return null;

      String awayTeamName = '';
      String homeTeamName = '';
      String? awayTeamLogoUrl;
      String? homeTeamLogoUrl;
      int? awayTeamId;
      int? homeTeamId;

      for (final competitor in competitors) {
        final team = competitor['team'] as Map<String, dynamic>? ?? {};
        final homeAway = competitor['homeAway'] as String? ?? '';
        final teamName = team['displayName'] ?? team['name'] ?? '';
        final teamId = int.tryParse(team['id']?.toString() ?? '');
        // ESPN soccer uses 'logo' or 'logos' array
        final logo = team['logo'] as String?;
        final logos = team['logos'] as List?;
        final logoUrl = logo ?? (logos != null && logos.isNotEmpty ? logos[0]['href'] : null);

        if (homeAway == 'home') {
          homeTeamName = teamName;
          homeTeamId = teamId;
          homeTeamLogoUrl = logoUrl;
        } else {
          awayTeamName = teamName;
          awayTeamId = teamId;
          awayTeamLogoUrl = logoUrl;
        }
      }

      // Parse venue information (stadium for World Cup matches)
      final venue = competition['venue'] as Map<String, dynamic>? ?? {};
      final venueName = venue['fullName'] ?? venue['name'] ?? '';
      final venueCity = venue['address']?['city'] ?? '';
      // Soccer venues use 'country' instead of 'state' for international matches
      final venueCountry = venue['address']?['country'] ?? venue['address']?['state'] ?? '';

      // Parse broadcast info
      final broadcasts = competition['broadcasts'] as List? ?? [];
      String? channel;
      if (broadcasts.isNotEmpty) {
        final broadcast = broadcasts[0] as Map<String, dynamic>;
        final networks = broadcast['names'] as List? ?? [];
        if (networks.isNotEmpty) {
          channel = networks[0].toString();
        }
      }

      // Parse date and time
      DateTime? gameDateTime;
      try {
        gameDateTime = DateTime.parse(date);
      } catch (e) {
        // Failed to parse date
      }

      // Create Stadium object if venue info exists
      Stadium? stadium;
      if (venueName.isNotEmpty) {
        stadium = Stadium(
          stadiumId: venue['id'] != null ? int.tryParse(venue['id'].toString()) : null,
          name: venueName,
          city: venueCity,
          state: venueCountry, // Country for international matches
          capacity: null,
          yearOpened: null,
          geoLat: null,
          geoLong: null,
          team: homeTeamName,
        );
      }

      return GameSchedule(
        gameId: 'espn_$eventId',
        season: '2026',
        week: null,
        status: 'Scheduled',
        dateTime: gameDateTime,
        dateTimeUTC: gameDateTime?.toUtc(),
        day: gameDateTime,
        awayTeamId: awayTeamId,
        homeTeamId: homeTeamId,
        awayTeamName: awayTeamName,
        homeTeamName: homeTeamName,
        stadium: stadium,
        channel: channel,
        awayTeamLogoUrl: awayTeamLogoUrl,
        homeTeamLogoUrl: homeTeamLogoUrl,
        neutralVenue: venue['neutralSite'] == true,
        updatedApi: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Enhanced parser for historical/live soccer data with scores and match status.
  /// Handles soccer-specific fields: goals, match period (1H/2H/ET/PK), etc.
  GameSchedule? parseESPNEventToGameScheduleWithYear(Map<String, dynamic> event, int year) {
    try {
      final eventId = event['id']?.toString() ?? '';
      final date = event['date'] ?? '';

      // Parse teams and scores
      final competitions = event['competitions'] as List? ?? [];
      if (competitions.isEmpty) return null;

      final competition = competitions[0] as Map<String, dynamic>;
      final competitors = competition['competitors'] as List? ?? [];

      if (competitors.length < 2) return null;

      String awayTeamName = '';
      String homeTeamName = '';
      String? awayTeamLogoUrl;
      String? homeTeamLogoUrl;
      int? awayTeamId;
      int? homeTeamId;
      int? awayScore;
      int? homeScore;

      for (final competitor in competitors) {
        final team = competitor['team'] as Map<String, dynamic>? ?? {};
        final homeAway = competitor['homeAway'] as String? ?? '';
        final teamName = team['displayName'] ?? team['name'] ?? '';
        final teamId = int.tryParse(team['id']?.toString() ?? '');
        final logo = team['logo'] as String?;
        final logos = team['logos'] as List?;
        final logoUrl = logo ?? (logos != null && logos.isNotEmpty ? logos[0]['href'] : null);

        // Parse score (goals in soccer)
        final score = int.tryParse(competitor['score']?.toString() ?? '');

        if (homeAway == 'home') {
          homeTeamName = teamName;
          homeTeamId = teamId;
          homeTeamLogoUrl = logoUrl;
          homeScore = score;
        } else {
          awayTeamName = teamName;
          awayTeamId = teamId;
          awayTeamLogoUrl = logoUrl;
          awayScore = score;
        }
      }

      // Parse match status (soccer uses: 1st Half, 2nd Half, Halftime,
      // Extra Time, Penalty Shootout, Full Time, etc.)
      final status = competition['status'] as Map<String, dynamic>? ?? {};
      final statusType = status['type'] as Map<String, dynamic>? ?? {};
      final gameStatus = statusType['name'] ?? 'Scheduled';
      final gameState = statusType['state'] ?? 'pre';
      final statusDetail = status['type']?['detail'] ?? '';

      // Parse match clock for live games
      final clock = status['displayClock'] as String?;

      // Parse venue information
      final venue = competition['venue'] as Map<String, dynamic>? ?? {};
      final venueName = venue['fullName'] ?? venue['name'] ?? '';
      final venueCity = venue['address']?['city'] ?? '';
      final venueCountry = venue['address']?['country'] ?? venue['address']?['state'] ?? '';

      // Parse broadcast info
      final broadcasts = competition['broadcasts'] as List? ?? [];
      String? channel;
      if (broadcasts.isNotEmpty) {
        final broadcast = broadcasts[0] as Map<String, dynamic>;
        final networks = broadcast['names'] as List? ?? [];
        if (networks.isNotEmpty) {
          channel = networks[0].toString();
        }
      }

      // Parse date and time
      DateTime? gameDateTime;
      try {
        gameDateTime = DateTime.parse(date);
      } catch (e) {
        // Failed to parse date
      }

      // Create Stadium object if venue info exists
      Stadium? stadium;
      if (venueName.isNotEmpty) {
        stadium = Stadium(
          stadiumId: venue['id'] != null ? int.tryParse(venue['id'].toString()) : null,
          name: venueName,
          city: venueCity,
          state: venueCountry,
          capacity: null,
          yearOpened: null,
          geoLat: null,
          geoLong: null,
          team: homeTeamName,
        );
      }

      // Determine match period for soccer
      String? period;
      if (statusDetail.isNotEmpty) {
        period = statusDetail;
      } else if (clock != null) {
        period = clock;
      }

      return GameSchedule(
        gameId: 'espn_$eventId',
        season: year.toString(),
        week: null, // Soccer uses matchday/round, not weeks
        status: gameStatus,
        dateTime: gameDateTime,
        dateTimeUTC: gameDateTime?.toUtc(),
        day: gameDateTime,
        awayTeamId: awayTeamId,
        homeTeamId: homeTeamId,
        awayTeamName: awayTeamName,
        homeTeamName: homeTeamName,
        awayScore: awayScore,
        homeScore: homeScore,
        stadium: stadium,
        channel: channel,
        awayTeamLogoUrl: awayTeamLogoUrl,
        homeTeamLogoUrl: homeTeamLogoUrl,
        neutralVenue: venue['neutralSite'] == true,
        updatedApi: DateTime.now(),
        // Live match state
        isLive: gameState == 'in',
        period: period,
        lastScoreUpdate: gameState == 'post' ? gameDateTime : null,
      );
    } catch (e) {
      return null;
    }
  }
}
