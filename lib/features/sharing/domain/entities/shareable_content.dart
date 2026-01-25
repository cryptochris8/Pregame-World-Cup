import 'package:equatable/equatable.dart';

/// Types of shareable content
enum ShareableContentType {
  prediction,
  matchResult,
  watchParty,
  bracket,
  achievement,
  invite,
}

/// Base class for shareable content
abstract class ShareableContent extends Equatable {
  final ShareableContentType type;
  final String title;
  final String description;
  final String? imageUrl;
  final String deepLink;
  final Map<String, String> utmParams;

  const ShareableContent({
    required this.type,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.deepLink,
    this.utmParams = const {},
  });

  /// Generate the full share URL with UTM parameters
  String get shareUrl {
    if (utmParams.isEmpty) return deepLink;

    final uri = Uri.parse(deepLink);
    final allParams = Map<String, String>.from(uri.queryParameters)
      ..addAll(utmParams);

    return uri.replace(queryParameters: allParams).toString();
  }

  /// Generate share text for social platforms
  String getShareText({bool includeUrl = true});

  /// Generate hashtags for the content
  List<String> get hashtags;

  @override
  List<Object?> get props => [type, title, deepLink];
}

/// Shareable prediction content
class ShareablePrediction extends ShareableContent {
  final String matchName;
  final String homeTeam;
  final String awayTeam;
  final int predictedHomeScore;
  final int predictedAwayScore;
  final String? predictedWinner;
  final int? confidenceLevel;
  final String? userDisplayName;

  const ShareablePrediction({
    required this.matchName,
    required this.homeTeam,
    required this.awayTeam,
    required this.predictedHomeScore,
    required this.predictedAwayScore,
    this.predictedWinner,
    this.confidenceLevel,
    this.userDisplayName,
    required super.deepLink,
    super.utmParams,
    super.imageUrl,
  }) : super(
          type: ShareableContentType.prediction,
          title: 'My Prediction: $homeTeam vs $awayTeam',
          description: '$homeTeam $predictedHomeScore - $predictedAwayScore $awayTeam',
        );

  @override
  String getShareText({bool includeUrl = true}) {
    final buffer = StringBuffer();

    buffer.writeln('My World Cup 2026 Prediction');
    buffer.writeln('$homeTeam $predictedHomeScore - $predictedAwayScore $awayTeam');

    if (predictedWinner != null) {
      buffer.writeln('Winner: $predictedWinner');
    }

    if (confidenceLevel != null) {
      buffer.writeln('Confidence: $confidenceLevel%');
    }

    buffer.writeln();
    buffer.writeln('Make your prediction on Pregame!');

    if (includeUrl) {
      buffer.writeln(shareUrl);
    }

    buffer.writeln();
    buffer.writeln(hashtags.map((h) => '#$h').join(' '));

    return buffer.toString();
  }

  @override
  List<String> get hashtags => [
        'WorldCup2026',
        'Prediction',
        homeTeam.replaceAll(' ', ''),
        awayTeam.replaceAll(' ', ''),
        'Pregame',
      ];
}

/// Shareable match result content
class ShareableMatchResult extends ShareableContent {
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final String? stage;
  final String? commentary;
  final bool isLive;
  final String? matchMinute;

  const ShareableMatchResult({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    this.stage,
    this.commentary,
    this.isLive = false,
    this.matchMinute,
    required super.deepLink,
    super.utmParams,
    super.imageUrl,
  }) : super(
          type: ShareableContentType.matchResult,
          title: '$homeTeam vs $awayTeam',
          description: '$homeTeam $homeScore - $awayScore $awayTeam',
        );

  @override
  String getShareText({bool includeUrl = true}) {
    final buffer = StringBuffer();

    if (isLive) {
      buffer.writeln('LIVE: $homeTeam $homeScore - $awayScore $awayTeam');
      if (matchMinute != null) {
        buffer.writeln("$matchMinute'");
      }
    } else {
      buffer.writeln('FULL TIME');
      buffer.writeln('$homeTeam $homeScore - $awayScore $awayTeam');
    }

    if (stage != null) {
      buffer.writeln(stage);
    }

    if (commentary != null && commentary!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(commentary);
    }

    buffer.writeln();
    buffer.writeln('Follow the World Cup on Pregame!');

    if (includeUrl) {
      buffer.writeln(shareUrl);
    }

    buffer.writeln();
    buffer.writeln(hashtags.map((h) => '#$h').join(' '));

    return buffer.toString();
  }

  @override
  List<String> get hashtags => [
        'WorldCup2026',
        if (isLive) 'LiveScore',
        homeTeam.replaceAll(' ', ''),
        awayTeam.replaceAll(' ', ''),
        'FIFA',
      ];
}

/// Shareable watch party content
class ShareableWatchParty extends ShareableContent {
  final String partyName;
  final String matchName;
  final DateTime partyTime;
  final String? venueName;
  final String? venueAddress;
  final int currentAttendees;
  final int maxAttendees;
  final String hostName;
  final bool isPrivate;

  const ShareableWatchParty({
    required this.partyName,
    required this.matchName,
    required this.partyTime,
    this.venueName,
    this.venueAddress,
    required this.currentAttendees,
    required this.maxAttendees,
    required this.hostName,
    this.isPrivate = false,
    required super.deepLink,
    super.utmParams,
    super.imageUrl,
  }) : super(
          type: ShareableContentType.watchParty,
          title: partyName,
          description: 'Watch $matchName together!',
        );

  @override
  String getShareText({bool includeUrl = true}) {
    final buffer = StringBuffer();

    buffer.writeln("Join my Watch Party!");
    buffer.writeln();
    buffer.writeln(partyName);
    buffer.writeln('Watching: $matchName');

    if (venueName != null) {
      buffer.writeln('Location: $venueName');
    }

    buffer.writeln('Date: ${_formatDate(partyTime)}');
    buffer.writeln('Spots: ${maxAttendees - currentAttendees} remaining');

    buffer.writeln();
    buffer.writeln('Join us on Pregame!');

    if (includeUrl) {
      buffer.writeln(shareUrl);
    }

    buffer.writeln();
    buffer.writeln(hashtags.map((h) => '#$h').join(' '));

    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  List<String> get hashtags => [
        'WorldCup2026',
        'WatchParty',
        'Pregame',
      ];
}

/// Shareable bracket/tournament progress
class ShareableBracket extends ShareableContent {
  final String userName;
  final int correctPredictions;
  final int totalPredictions;
  final int rank;
  final String? championPick;

  const ShareableBracket({
    required this.userName,
    required this.correctPredictions,
    required this.totalPredictions,
    required this.rank,
    this.championPick,
    required super.deepLink,
    super.utmParams,
    super.imageUrl,
  }) : super(
          type: ShareableContentType.bracket,
          title: "$userName's World Cup Bracket",
          description: '$correctPredictions/$totalPredictions correct predictions',
        );

  @override
  String getShareText({bool includeUrl = true}) {
    final buffer = StringBuffer();

    buffer.writeln('My World Cup 2026 Bracket');
    buffer.writeln();
    buffer.writeln('$correctPredictions/$totalPredictions predictions correct');
    buffer.writeln('Current Rank: #$rank');

    if (championPick != null) {
      buffer.writeln('Champion Pick: $championPick');
    }

    buffer.writeln();
    buffer.writeln('Create your bracket on Pregame!');

    if (includeUrl) {
      buffer.writeln(shareUrl);
    }

    buffer.writeln();
    buffer.writeln(hashtags.map((h) => '#$h').join(' '));

    return buffer.toString();
  }

  @override
  List<String> get hashtags => [
        'WorldCup2026',
        'Bracket',
        'Predictions',
        'Pregame',
      ];
}

/// Shareable app invite
class ShareableInvite extends ShareableContent {
  final String inviterName;
  final String? referralCode;

  const ShareableInvite({
    required this.inviterName,
    this.referralCode,
    required super.deepLink,
    super.utmParams,
  }) : super(
          type: ShareableContentType.invite,
          title: 'Join me on Pregame!',
          description: 'The ultimate World Cup 2026 companion app',
        );

  @override
  String getShareText({bool includeUrl = true}) {
    final buffer = StringBuffer();

    buffer.writeln('Join me on Pregame!');
    buffer.writeln();
    buffer.writeln('The ultimate World Cup 2026 companion app:');
    buffer.writeln('- Live scores & match updates');
    buffer.writeln('- Create watch parties');
    buffer.writeln('- Make predictions');
    buffer.writeln('- Connect with fans');

    if (includeUrl) {
      buffer.writeln();
      buffer.writeln(shareUrl);
    }

    if (referralCode != null) {
      buffer.writeln();
      buffer.writeln('Use my code: $referralCode');
    }

    return buffer.toString();
  }

  @override
  List<String> get hashtags => [
        'WorldCup2026',
        'Pregame',
      ];
}
