import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';

/// API Data Source for World Cup 2026 data
/// Fetches data from SportsData.io Soccer API
class WorldCupApiDataSource {
  final Dio _dio;
  final String _apiKey;

  // SportsData.io Soccer API base URL
  static const String _baseUrl = 'https://api.sportsdata.io/v4/soccer';

  // Competition ID for FIFA World Cup 2026 (will need to be updated when available)
  static const String _worldCupCompetitionId = 'FIFA_WORLDCUP_2026';

  WorldCupApiDataSource({
    Dio? dio,
    required String apiKey,
  }) : _dio = dio ?? Dio(),
       _apiKey = apiKey {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.queryParameters = {'key': _apiKey};
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Fetches all World Cup 2026 matches
  Future<List<WorldCupMatch>> fetchAllMatches() async {
    try {
      debugPrint('Fetching World Cup matches from API...');

      final response = await _dio.get(
        '/scores/json/GamesByCompetition/$_worldCupCompetitionId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        final matches = data.map((json) => _parseMatch(json)).toList();
        debugPrint('Fetched ${matches.length} matches from API');
        return matches;
      }

      return [];
    } on DioException catch (e) {
      debugPrint('API Error fetching matches: ${e.message}');
      throw Exception('Failed to fetch World Cup matches: ${e.message}');
    }
  }

  /// Fetches matches for a specific date
  Future<List<WorldCupMatch>> fetchMatchesByDate(DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final response = await _dio.get(
        '/scores/json/GamesByDate/$dateStr',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        // Filter for World Cup matches only
        final matches = data
            .where((json) => json['Competition']?['CompetitionId'] == _worldCupCompetitionId)
            .map((json) => _parseMatch(json))
            .toList();
        return matches;
      }

      return [];
    } on DioException catch (e) {
      debugPrint('API Error fetching matches by date: ${e.message}');
      throw Exception('Failed to fetch matches by date: ${e.message}');
    }
  }

  /// Fetches live match scores
  Future<List<WorldCupMatch>> fetchLiveMatches() async {
    try {
      final response = await _dio.get(
        '/scores/json/LiveGamesByCompetition/$_worldCupCompetitionId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => _parseMatch(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint('API Error fetching live matches: ${e.message}');
      throw Exception('Failed to fetch live matches: ${e.message}');
    }
  }

  /// Fetches all national teams for World Cup 2026
  Future<List<NationalTeam>> fetchAllTeams() async {
    try {
      debugPrint('Fetching World Cup teams from API...');

      final response = await _dio.get(
        '/scores/json/Teams/$_worldCupCompetitionId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        final teams = data.map((json) => _parseTeam(json)).toList();
        debugPrint('Fetched ${teams.length} teams from API');
        return teams;
      }

      return [];
    } on DioException catch (e) {
      debugPrint('API Error fetching teams: ${e.message}');
      throw Exception('Failed to fetch teams: ${e.message}');
    }
  }

  /// Fetches group standings
  Future<List<WorldCupGroup>> fetchGroupStandings() async {
    try {
      final response = await _dio.get(
        '/scores/json/Standings/$_worldCupCompetitionId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return _parseGroups(data);
      }

      return [];
    } on DioException catch (e) {
      debugPrint('API Error fetching standings: ${e.message}');
      throw Exception('Failed to fetch standings: ${e.message}');
    }
  }

  /// Fetches a specific match by ID
  Future<WorldCupMatch?> fetchMatchById(String matchId) async {
    try {
      final response = await _dio.get(
        '/scores/json/Game/$matchId',
      );

      if (response.statusCode == 200 && response.data != null) {
        return _parseMatch(response.data);
      }

      return null;
    } on DioException catch (e) {
      debugPrint('API Error fetching match: ${e.message}');
      throw Exception('Failed to fetch match: ${e.message}');
    }
  }

  /// Fetches venues/stadiums
  Future<List<WorldCupVenue>> fetchVenues() async {
    try {
      final response = await _dio.get(
        '/scores/json/Venues',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        // Filter for World Cup venues
        final venues = data
            .where((json) => _isWorldCupVenue(json))
            .map((json) => _parseVenue(json))
            .toList();
        return venues;
      }

      // Return static venue data if API doesn't have it
      return WorldCupVenues.all;
    } on DioException catch (e) {
      debugPrint('API Error fetching venues: ${e.message}');
      // Return static venue data as fallback
      return WorldCupVenues.all;
    }
  }

  // Parse API response to WorldCupMatch
  WorldCupMatch _parseMatch(Map<String, dynamic> json) {
    return WorldCupMatch(
      matchId: json['GameId']?.toString() ?? '',
      matchNumber: json['GameNumber'] ?? 0,
      stage: _parseStage(json['Round'] ?? json['Stage']),
      group: json['Group'],
      groupMatchDay: json['GroupMatchDay'],
      homeTeamCode: json['HomeTeamKey'],
      homeTeamName: json['HomeTeamName'] ?? 'TBD',
      homeTeamFlagUrl: json['HomeTeamLogo'],
      awayTeamCode: json['AwayTeamKey'],
      awayTeamName: json['AwayTeamName'] ?? 'TBD',
      awayTeamFlagUrl: json['AwayTeamLogo'],
      dateTime: json['DateTime'] != null
          ? DateTime.tryParse(json['DateTime'])
          : null,
      dateTimeUtc: json['DateTimeUTC'] != null
          ? DateTime.tryParse(json['DateTimeUTC'])
          : null,
      venueId: json['VenueId']?.toString(),
      broadcastChannels: (json['Channels'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      status: _parseStatus(json['Status']),
      minute: json['Clock'],
      homeScore: json['HomeTeamScore'],
      awayScore: json['AwayTeamScore'],
      homeHalfTimeScore: json['HomeTeamScoreHalftime'],
      awayHalfTimeScore: json['AwayTeamScoreHalftime'],
      homeExtraTimeScore: json['HomeTeamScoreExtraTime'],
      awayExtraTimeScore: json['AwayTeamScoreExtraTime'],
      homePenaltyScore: json['HomeTeamScorePenalties'],
      awayPenaltyScore: json['AwayTeamScorePenalties'],
      winnerTeamCode: json['WinnerTeamKey'],
      updatedAt: json['Updated'] != null
          ? DateTime.tryParse(json['Updated'])
          : null,
    );
  }

  // Parse API response to NationalTeam
  NationalTeam _parseTeam(Map<String, dynamic> json) {
    return NationalTeam(
      fifaCode: json['Key'] ?? json['TeamId']?.toString() ?? '',
      countryName: json['FullName'] ?? json['Name'] ?? '',
      shortName: json['ShortName'] ?? json['Name'] ?? '',
      flagUrl: json['WikipediaLogoUrl'] ?? json['FlagUrl'] ?? '',
      confederation: _parseConfederation(json['AreaName']),
      fifaRanking: json['GlobalTeamRanking'],
      coachName: json['Coach']?['Name'],
      group: json['Group'],
      isQualified: true,
      updatedAt: DateTime.now(),
    );
  }

  // Parse groups from standings API
  List<WorldCupGroup> _parseGroups(List<dynamic> data) {
    final Map<String, List<GroupTeamStanding>> groupMap = {};

    for (final item in data) {
      final groupLetter = item['Group'] as String?;
      if (groupLetter == null) continue;

      final standing = GroupTeamStanding(
        teamCode: item['TeamKey'] ?? '',
        teamName: item['TeamName'] ?? '',
        flagUrl: item['TeamLogo'],
        position: item['Rank'] ?? 0,
        played: item['Games'] ?? 0,
        won: item['Wins'] ?? 0,
        drawn: item['Draws'] ?? 0,
        lost: item['Losses'] ?? 0,
        goalsFor: item['GoalsScored'] ?? 0,
        goalsAgainst: item['GoalsAgainst'] ?? 0,
        points: item['Points'] ?? 0,
      );

      groupMap.putIfAbsent(groupLetter, () => []).add(standing);
    }

    return groupMap.entries.map((entry) {
      final standings = entry.value..sort((a, b) => a.position.compareTo(b.position));
      return WorldCupGroup(
        groupLetter: entry.key,
        standings: standings,
        updatedAt: DateTime.now(),
      );
    }).toList();
  }

  // Parse venue from API
  WorldCupVenue _parseVenue(Map<String, dynamic> json) {
    return WorldCupVenue(
      venueId: json['VenueId']?.toString() ?? '',
      name: json['Name'] ?? '',
      city: json['City'] ?? '',
      state: json['State'],
      country: _parseHostCountry(json['Country']),
      capacity: json['Capacity'] ?? 0,
      latitude: (json['GeoLat'] as num?)?.toDouble(),
      longitude: (json['GeoLong'] as num?)?.toDouble(),
      address: json['Address'],
      imageUrl: json['PhotoUrl'],
    );
  }

  // Check if venue is a World Cup venue
  bool _isWorldCupVenue(Map<String, dynamic> json) {
    final country = (json['Country'] as String?)?.toLowerCase() ?? '';
    return country.contains('united states') ||
           country.contains('usa') ||
           country.contains('mexico') ||
           country.contains('canada');
  }

  // Parse match stage
  MatchStage _parseStage(String? stage) {
    if (stage == null) return MatchStage.groupStage;

    final lower = stage.toLowerCase();
    if (lower.contains('group')) return MatchStage.groupStage;
    if (lower.contains('32')) return MatchStage.roundOf32;
    if (lower.contains('16')) return MatchStage.roundOf16;
    if (lower.contains('quarter')) return MatchStage.quarterFinal;
    if (lower.contains('semi')) return MatchStage.semiFinal;
    if (lower.contains('third') || lower.contains('3rd')) return MatchStage.thirdPlace;
    if (lower.contains('final') && !lower.contains('semi') && !lower.contains('quarter')) {
      return MatchStage.final_;
    }

    return MatchStage.groupStage;
  }

  // Parse match status
  MatchStatus _parseStatus(String? status) {
    if (status == null) return MatchStatus.scheduled;

    final lower = status.toLowerCase();
    if (lower.contains('scheduled') || lower.contains('upcoming')) {
      return MatchStatus.scheduled;
    }
    if (lower.contains('progress') || lower.contains('live')) {
      return MatchStatus.inProgress;
    }
    if (lower.contains('half')) return MatchStatus.halfTime;
    if (lower.contains('extra')) return MatchStatus.extraTime;
    if (lower.contains('penal')) return MatchStatus.penalties;
    if (lower.contains('final') || lower.contains('complete') || lower.contains('finished')) {
      return MatchStatus.completed;
    }
    if (lower.contains('postpone')) return MatchStatus.postponed;
    if (lower.contains('cancel')) return MatchStatus.cancelled;

    return MatchStatus.scheduled;
  }

  // Parse confederation
  Confederation _parseConfederation(String? area) {
    if (area == null) return Confederation.uefa;

    final lower = area.toLowerCase();
    if (lower.contains('europe')) return Confederation.uefa;
    if (lower.contains('south america')) return Confederation.conmebol;
    if (lower.contains('north') || lower.contains('central') || lower.contains('caribbean')) {
      return Confederation.concacaf;
    }
    if (lower.contains('asia')) return Confederation.afc;
    if (lower.contains('africa')) return Confederation.caf;
    if (lower.contains('oceania')) return Confederation.ofc;

    return Confederation.uefa;
  }

  // Parse host country
  HostCountry _parseHostCountry(String? country) {
    if (country == null) return HostCountry.usa;

    final lower = country.toLowerCase();
    if (lower.contains('mexico')) return HostCountry.mexico;
    if (lower.contains('canada')) return HostCountry.canada;

    return HostCountry.usa;
  }
}
