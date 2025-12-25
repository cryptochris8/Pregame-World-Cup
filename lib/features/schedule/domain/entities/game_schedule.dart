import 'package:cloud_firestore/cloud_firestore.dart';

// GameSchedule entity - Firebase dependencies removed for web development
class GameSchedule {
  final String gameId;
  final int? globalGameId;
  final String? season;
  final int? seasonType;
  final int? week;
  final String? status;
  final DateTime? day; // Date part
  final DateTime? dateTime; // Full date and time
  final DateTime? dateTimeUTC; // UTC date and time
  final int? awayTeamId;
  final int? homeTeamId;
  final String awayTeamName;
  final String homeTeamName;
  final int? globalAwayTeamId;
  final int? globalHomeTeamId;
  final int? stadiumId;
  final Stadium? stadium;
  final String? channel;
  final bool? neutralVenue;
  final DateTime? updatedApi; // Last updated from API
  final DateTime? updatedFs;  // Last updated in database
  final String? awayTeamLogoUrl; // New field for away team logo
  final String? homeTeamLogoUrl; // New field for home team logo
  
  // Live Score Fields
  final int? awayScore;
  final int? homeScore;
  final String? period; // Quarter, Half, etc.
  final String? timeRemaining; // Time left in current period
  final bool? isLive; // Whether game is currently live
  final DateTime? lastScoreUpdate; // When score was last updated
  
  // Social Features
  final int? userPredictions; // Number of user predictions
  final int? userComments; // Number of comments
  final int? userPhotos; // Number of photos shared
  final double? userRating; // Average user rating for the game experience

  GameSchedule({
    required this.gameId,
    this.globalGameId,
    this.season,
    this.seasonType,
    this.week,
    this.status,
    this.day,
    this.dateTime,
    this.dateTimeUTC,
    this.awayTeamId,
    this.homeTeamId,
    required this.awayTeamName,
    required this.homeTeamName,
    this.globalAwayTeamId,
    this.globalHomeTeamId,
    this.stadiumId,
    this.stadium,
    this.channel,
    this.neutralVenue,
    this.updatedApi,
    this.updatedFs,
    this.awayTeamLogoUrl,
    this.homeTeamLogoUrl,
    this.awayScore,
    this.homeScore,
    this.period,
    this.timeRemaining,
    this.isLive,
    this.lastScoreUpdate,
    this.userPredictions,
    this.userComments,
    this.userPhotos,
    this.userRating,
  });

  // Factory method to create from a Map (JSON data)
  factory GameSchedule.fromMap(Map<String, dynamic> data, {String? id}) {
    Stadium? stadiumData;
    if (data['stadium'] != null) {
      stadiumData = Stadium.fromMap(data['stadium'] as Map<String, dynamic>);
    }

    // Helper function to parse date strings to DateTime
    DateTime? parseDateTime(String? dateStr) {
      if (dateStr == null) return null;
      return DateTime.tryParse(dateStr);
    }

    return GameSchedule(
      gameId: data['gameId'] ?? id ?? 'unknown-id',
      globalGameId: data['globalGameId'] as int?,
      season: data['season'] as String?,
      seasonType: data['seasonType'] as int?,
      week: data['week'] as int?,
      status: data['status'] as String?,
      day: data['day'] is Timestamp 
          ? (data['day'] as Timestamp).toDate() 
          : parseDateTime(data['day'] as String?),
      dateTime: data['dateTime'] is Timestamp 
          ? (data['dateTime'] as Timestamp).toDate() 
          : parseDateTime(data['dateTime'] as String?),
      dateTimeUTC: data['dateTimeUTC'] is Timestamp 
          ? (data['dateTimeUTC'] as Timestamp).toDate() 
          : parseDateTime(data['dateTimeUTC'] as String?),
      awayTeamId: data['awayTeamId'] as int?,
      homeTeamId: data['homeTeamId'] as int?,
      awayTeamName: data['awayTeamName'] ?? 'N/A',
      homeTeamName: data['homeTeamName'] ?? 'N/A',
      globalAwayTeamId: data['globalAwayTeamId'] as int?,
      globalHomeTeamId: data['globalHomeTeamId'] as int?,
      stadiumId: data['stadiumId'] as int?,
      stadium: stadiumData,
      channel: data['channel'] as String?,
      neutralVenue: data['neutralVenue'] as bool?,
      updatedApi: data['updatedApi'] is Timestamp 
          ? (data['updatedApi'] as Timestamp).toDate() 
          : parseDateTime(data['updatedApi'] as String?),
      updatedFs: data['updatedFs'] is Timestamp 
          ? (data['updatedFs'] as Timestamp).toDate() 
          : parseDateTime(data['updatedFs'] as String?),
      awayTeamLogoUrl: data['awayTeamLogoUrl'] as String?,
      homeTeamLogoUrl: data['homeTeamLogoUrl'] as String?,
      awayScore: data['awayScore'] as int?,
      homeScore: data['homeScore'] as int?,
      period: data['period'] as String?,
      timeRemaining: data['timeRemaining'] as String?,
      isLive: data['isLive'] as bool?,
      lastScoreUpdate: data['lastScoreUpdate'] is Timestamp 
          ? (data['lastScoreUpdate'] as Timestamp).toDate() 
          : parseDateTime(data['lastScoreUpdate'] as String?),
      userPredictions: data['userPredictions'] as int?,
      userComments: data['userComments'] as int?,
      userPhotos: data['userPhotos'] as int?,
      userRating: data['userRating'] as double?,
    );
  }
  
  // Factory method to create from Firestore DocumentSnapshot
  factory GameSchedule.fromFirestore(Map<String, dynamic> data, String docId) {
    final String gameIdString = docId;

    final schedule = GameSchedule(
      gameId: gameIdString,
      globalGameId: data['GlobalGameID'] as int?,
      season: data['Season']?.toString(),
      seasonType: data['SeasonType'] as int?,
      week: data['Week'] as int?,
      status: data['Status'] as String?,
      day: _dateTimeFromDynamic(data['Day']),
      dateTime: _dateTimeFromDynamic(data['DateTime']),
      dateTimeUTC: _dateTimeFromDynamic(data['DateTimeUTC']),
      awayTeamId: data['AwayTeamID'] as int?,
      homeTeamId: data['HomeTeamID'] as int?,
      awayTeamName: data['awayTeamName'] as String? ?? 'N/A',
      homeTeamName: data['homeTeamName'] as String? ?? 'N/A',
      globalAwayTeamId: data['GlobalAwayTeamID'] as int?,
      globalHomeTeamId: data['GlobalHomeTeamID'] as int?,
      stadiumId: data['StadiumID'] as int?,
      stadium: data['Stadium'] != null && data['Stadium'] is Map<String, dynamic> 
                ? Stadium.fromDataSource(data['Stadium'] as Map<String, dynamic>) 
                : null,
      channel: data['Channel'] as String?,
      neutralVenue: data['NeutralVenue'] as bool?,
      updatedApi: _dateTimeFromDynamic(data['Updated']),
      updatedFs: _dateTimeFromDynamic(data['UpdatedFS']),
      awayScore: data['awayScore'] as int?,
      homeScore: data['homeScore'] as int?,
      period: data['period'] as String?,
      timeRemaining: data['timeRemaining'] as String?,
      isLive: data['isLive'] as bool?,
      lastScoreUpdate: _dateTimeFromDynamic(data['lastScoreUpdate']),
      userPredictions: data['userPredictions'] as int?,
      userComments: data['userComments'] as int?,
      userPhotos: data['userPhotos'] as int?,
      userRating: data['userRating'] as double?,
    );

    return schedule;
  }

  // Convert a GameSchedule to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'globalGameId': globalGameId,
      'season': season,
      'seasonType': seasonType,
      'week': week,
      'status': status,
      'day': day != null ? Timestamp.fromDate(day!) : null,
      'dateTime': dateTime != null ? Timestamp.fromDate(dateTime!) : null,
      'dateTimeUTC': dateTimeUTC != null ? Timestamp.fromDate(dateTimeUTC!) : null,
      'awayTeamId': awayTeamId,
      'homeTeamId': homeTeamId,
      'awayTeamName': awayTeamName,
      'homeTeamName': homeTeamName,
      'globalAwayTeamId': globalAwayTeamId,
      'globalHomeTeamId': globalHomeTeamId,
      'stadiumId': stadiumId,
      'stadium': stadium?.toFirestore(),
      'channel': channel,
      'neutralVenue': neutralVenue,
      'updatedApi': updatedApi != null ? Timestamp.fromDate(updatedApi!) : null,
      'updatedFs': updatedFs != null ? Timestamp.fromDate(updatedFs!) : null,
      'awayTeamLogoUrl': awayTeamLogoUrl,
      'homeTeamLogoUrl': homeTeamLogoUrl,
      'awayScore': awayScore,
      'homeScore': homeScore,
      'period': period,
      'timeRemaining': timeRemaining,
      'isLive': isLive,
      'lastScoreUpdate': lastScoreUpdate != null ? Timestamp.fromDate(lastScoreUpdate!) : null,
      'userPredictions': userPredictions,
      'userComments': userComments,
      'userPhotos': userPhotos,
      'userRating': userRating,
    };
  }

  // Factory method to create a GameSchedule from API JSON
  factory GameSchedule.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse integer from string or int
    int? parseIntSafely(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    // Helper function to safely parse double from string or number
    double? parseDoubleSafely(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    // Parse game data from nested structure
    final gameData = json['game'] ?? json;
    
    // Parse team data
    final awayTeam = gameData['away'] ?? {};
    final homeTeam = gameData['home'] ?? {};
    
    return GameSchedule(
      gameId: gameData['gameID']?.toString() ?? '',
      awayTeamName: awayTeam['names']?['short'] ?? awayTeam['name'] ?? 'Unknown',
      homeTeamName: homeTeam['names']?['short'] ?? homeTeam['name'] ?? 'Unknown',
      awayScore: parseIntSafely(awayTeam['score']),
      homeScore: parseIntSafely(homeTeam['score']),
      dateTimeUTC: gameData['startTimeEpoch'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(gameData['startTimeEpoch']) * 1000)
          : null,
      dateTime: gameData['startDate'] != null 
          ? DateTime.tryParse(gameData['startDate'])
          : null,
      day: gameData['startDate'] != null 
          ? DateTime.tryParse(gameData['startDate'])
          : null,
      week: parseIntSafely(json['week']),
      stadium: gameData['stadium'] != null 
          ? Stadium(
              stadiumId: null,
              name: gameData['stadium'],
              city: null,
              state: null,
            )
          : null,
      status: gameData['gameState'] ?? gameData['finalMessage'] ?? 'Scheduled',
      
      // Live game data
      isLive: gameData['gameState'] == 'live' || gameData['currentPeriod'] == 'LIVE',
      period: gameData['currentPeriod'],
      timeRemaining: gameData['contestClock'],
      lastScoreUpdate: DateTime.now(),
      
      // Social features (default to 0)
      userPredictions: 0,
      userComments: 0,
      userPhotos: 0,
      userRating: 0.0,
    );
  }

  // Factory method to create a GameSchedule from SportsData.io API JSON
  factory GameSchedule.fromSportsDataIo(Map<String, dynamic> json) {
    // Helper function to safely parse integer from string or int
    int? parseIntSafely(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    // Helper function to safely parse DateTime from string
    DateTime? parseDateTimeSafely(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        print('Error parsing date: $dateStr - $e');
        return null;
      }
    }

    // Parse stadium information
    Stadium? stadium;
    if (json['Stadium'] != null) {
      final stadiumData = json['Stadium'] as Map<String, dynamic>;
      stadium = Stadium(
        stadiumId: parseIntSafely(stadiumData['StadiumID']),
        name: stadiumData['Name'] as String?,
        city: stadiumData['City'] as String?,
        state: stadiumData['State'] as String?,
        geoLat: (stadiumData['GeoLat'] as num?)?.toDouble(),
        geoLong: (stadiumData['GeoLong'] as num?)?.toDouble(),
      );
    }

    return GameSchedule(
      gameId: json['GameID']?.toString() ?? '',
      globalGameId: parseIntSafely(json['GlobalGameID']),
      season: json['Season']?.toString(),
      seasonType: parseIntSafely(json['SeasonType']),
      week: parseIntSafely(json['Week']),
      status: json['Status'] as String?,
      day: parseDateTimeSafely(json['Day']),
      dateTime: parseDateTimeSafely(json['DateTime']),
      dateTimeUTC: parseDateTimeSafely(json['DateTimeUTC']) ?? parseDateTimeSafely(json['DateTime']),
      awayTeamId: parseIntSafely(json['AwayTeamID']),
      homeTeamId: parseIntSafely(json['HomeTeamID']),
      awayTeamName: json['AwayTeamName'] as String? ?? json['AwayTeam'] as String? ?? 'Unknown',
      homeTeamName: json['HomeTeamName'] as String? ?? json['HomeTeam'] as String? ?? 'Unknown',
      globalAwayTeamId: parseIntSafely(json['GlobalAwayTeamID']),
      globalHomeTeamId: parseIntSafely(json['GlobalHomeTeamID']),
      stadiumId: parseIntSafely(json['StadiumID']),
      stadium: stadium,
      channel: json['Channel'] as String?,
      neutralVenue: json['NeutralVenue'] as bool?,
      updatedApi: parseDateTimeSafely(json['Updated']),
      updatedFs: DateTime.now(), // Set current time for when we fetched it
      
      // Score information
      awayScore: parseIntSafely(json['AwayTeamScore']),
      homeScore: parseIntSafely(json['HomeTeamScore']),
      
      // Live game status
      isLive: json['Status'] == 'InProgress',
      period: json['Period'] as String?,
      timeRemaining: json['TimeRemainingMinutes']?.toString(),
      lastScoreUpdate: DateTime.now(),
      
      // Social features (initialize to 0)
      userPredictions: 0,
      userComments: 0,
      userPhotos: 0,
      userRating: 0.0,
    );
  }

  // Convert GameSchedule to Map for caching and data transfer
  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'globalGameId': globalGameId,
      'season': season,
      'seasonType': seasonType,
      'week': week,
      'status': status,
      'day': day?.toIso8601String(),
      'dateTime': dateTime?.toIso8601String(),
      'dateTimeUTC': dateTimeUTC?.toIso8601String(),
      'awayTeamId': awayTeamId,
      'homeTeamId': homeTeamId,
      'awayTeamName': awayTeamName,
      'homeTeamName': homeTeamName,
      'globalAwayTeamId': globalAwayTeamId,
      'globalHomeTeamId': globalHomeTeamId,
      'stadiumId': stadiumId,
      'stadium': stadium?.toFirestore(),
      'channel': channel,
      'neutralVenue': neutralVenue,
      'updatedApi': updatedApi?.toIso8601String(),
      'updatedFs': updatedFs?.toIso8601String(),
      'awayTeamLogoUrl': awayTeamLogoUrl,
      'homeTeamLogoUrl': homeTeamLogoUrl,
      'awayScore': awayScore,
      'homeScore': homeScore,
      'period': period,
      'timeRemaining': timeRemaining,
      'isLive': isLive,
      'lastScoreUpdate': lastScoreUpdate?.toIso8601String(),
      'userPredictions': userPredictions,
      'userComments': userComments,
      'userPhotos': userPhotos,
      'userRating': userRating,
    };
  }

  // Add this helper function to parse date/time fields safely
  static DateTime? _dateTimeFromDynamic(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null; // Handle invalid date string format
      }
    }
    if (value is int) {
      // Assume it's a Unix timestamp (milliseconds since epoch)
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    // Add more type checks if needed
    return null;
  }
}

class Stadium {
  final int? stadiumId;
  final String? name;
  final String? city;
  final String? state;
  final int? capacity;
  final int? yearOpened;
  final double? geoLat;  // Added for latitude
  final double? geoLong; // Added for longitude
  final String? team;

  Stadium({
    this.stadiumId,
    this.name,
    this.city,
    this.state,
    this.capacity,
    this.yearOpened,
    this.geoLat, // Added to constructor
    this.geoLong, // Added to constructor
    this.team,
  });

  // Factory to create from a map (like one from Firestore or JSON)
  factory Stadium.fromMap(Map<String, dynamic> map) {
    return Stadium(
      stadiumId: map['StadiumID'] as int? ?? map['stadiumId'] as int?,
      name: map['Name'] as String? ?? map['name'] as String?,
      city: map['City'] as String? ?? map['city'] as String?,
      state: map['State'] as String? ?? map['state'] as String?,
      capacity: map['Capacity'] as int? ?? map['capacity'] as int?,
      yearOpened: map['YearOpened'] as int? ?? map['yearOpened'] as int?,
      // Handle potential num type from JSON and ensure it's a double
      geoLat: (map['GeoLat'] as num?)?.toDouble() ?? (map['geoLat'] as num?)?.toDouble(),
      geoLong: (map['GeoLong'] as num?)?.toDouble() ?? (map['geoLong'] as num?)?.toDouble(),
      team: map['Team'] as String? ?? map['team'] as String?,
    );
  }

  // Convert Stadium object to a Map for Firestore
  // (Useful if you were to save/update stadium info from the app)
  Map<String, dynamic> toFirestore() {
    return {
      'StadiumID': stadiumId, // Using SportsData.io like casing for consistency if saving back
      'Name': name,
      'City': city,
      'State': state,
      'Capacity': capacity,
      'YearOpened': yearOpened,
      'GeoLat': geoLat,
      'GeoLong': geoLong,
      'Team': team,
    };
  }

  // Renaming the old fromJson to avoid confusion, as fromMap is more generic now.
  // This specifically handles the SportsData.io V3 / Firestore structure (PascalCase keys)
  // The cloud function saves data with PascalCase keys from SportsData.io
  factory Stadium.fromDataSource(Map<String, dynamic> json) {
    return Stadium(
      stadiumId: json['StadiumID'] as int?,
      name: json['Name'] as String?,
      city: json['City'] as String?,
      state: json['State'] as String?,
      capacity: json['Capacity'] as int?,
      yearOpened: json['YearOpened'] as int?,
      geoLat: (json['GeoLat'] as num?)?.toDouble(),
      geoLong: (json['GeoLong'] as num?)?.toDouble(),
      team: json['Team'] as String?,
    );
  }
} 

/// Time filter enum for filtering games by time period
enum TimeFilter {
  today,
  thisWeek,
  all,
} 