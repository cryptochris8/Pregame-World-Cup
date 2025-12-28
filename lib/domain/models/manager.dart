import 'package:cloud_firestore/cloud_firestore.dart';

/// Manager model representing a World Cup 2026 manager/coach
/// Corresponds to the manager data in Firestore
class Manager {
  final String managerId;
  final String fifaCode;
  final String firstName;
  final String lastName;
  final String fullName;
  final String commonName;
  final DateTime dateOfBirth;
  final int age;
  final String nationality;
  final String photoUrl;
  final String currentTeam;
  final DateTime appointedDate;
  final List<String> previousClubs;
  final int managerialCareerStart;
  final int yearsOfExperience;
  final ManagerStats stats;
  final List<String> honors;
  final String tacticalStyle;
  final String philosophy;
  final List<String> strengths;
  final List<String> weaknesses;
  final String keyMoment;
  final String famousQuote;
  final String managerStyle;
  final String worldCup2026Prediction;
  final List<String> controversies;
  final ManagerSocialMedia socialMedia;
  final List<String> trivia;

  Manager({
    required this.managerId,
    required this.fifaCode,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.commonName,
    required this.dateOfBirth,
    required this.age,
    required this.nationality,
    required this.photoUrl,
    required this.currentTeam,
    required this.appointedDate,
    required this.previousClubs,
    required this.managerialCareerStart,
    required this.yearsOfExperience,
    required this.stats,
    required this.honors,
    required this.tacticalStyle,
    required this.philosophy,
    required this.strengths,
    required this.weaknesses,
    required this.keyMoment,
    required this.famousQuote,
    required this.managerStyle,
    required this.worldCup2026Prediction,
    required this.controversies,
    required this.socialMedia,
    required this.trivia,
  });

  /// Create Manager from Firestore document
  factory Manager.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Manager(
      managerId: data['managerId'] ?? '',
      fifaCode: data['fifaCode'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      fullName: data['fullName'] ?? '',
      commonName: data['commonName'] ?? '',
      dateOfBirth: DateTime.parse(data['dateOfBirth'] ?? '1970-01-01'),
      age: data['age'] ?? 0,
      nationality: data['nationality'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      currentTeam: data['currentTeam'] ?? '',
      appointedDate: DateTime.parse(data['appointedDate'] ?? '2020-01-01'),
      previousClubs: List<String>.from(data['previousClubs'] ?? []),
      managerialCareerStart: data['managerialCareerStart'] ?? 2000,
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      stats: ManagerStats.fromMap(data['stats'] ?? {}),
      honors: List<String>.from(data['honors'] ?? []),
      tacticalStyle: data['tacticalStyle'] ?? '',
      philosophy: data['philosophy'] ?? '',
      strengths: List<String>.from(data['strengths'] ?? []),
      weaknesses: List<String>.from(data['weaknesses'] ?? []),
      keyMoment: data['keyMoment'] ?? '',
      famousQuote: data['famousQuote'] ?? '',
      managerStyle: data['managerStyle'] ?? '',
      worldCup2026Prediction: data['worldCup2026Prediction'] ?? '',
      controversies: List<String>.from(data['controversies'] ?? []),
      socialMedia: ManagerSocialMedia.fromMap(data['socialMedia'] ?? {}),
      trivia: List<String>.from(data['trivia'] ?? []),
    );
  }

  /// Convert Manager to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'managerId': managerId,
      'fifaCode': fifaCode,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'commonName': commonName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'age': age,
      'nationality': nationality,
      'photoUrl': photoUrl,
      'currentTeam': currentTeam,
      'appointedDate': appointedDate.toIso8601String(),
      'previousClubs': previousClubs,
      'managerialCareerStart': managerialCareerStart,
      'yearsOfExperience': yearsOfExperience,
      'stats': stats.toMap(),
      'honors': honors,
      'tacticalStyle': tacticalStyle,
      'philosophy': philosophy,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'keyMoment': keyMoment,
      'famousQuote': famousQuote,
      'managerStyle': managerStyle,
      'worldCup2026Prediction': worldCup2026Prediction,
      'controversies': controversies,
      'socialMedia': socialMedia.toMap(),
      'trivia': trivia,
    };
  }

  /// Get years in current role
  int get yearsInCurrentRole {
    final now = DateTime.now();
    return now.year - appointedDate.year;
  }

  /// Check if manager is controversial
  bool get isControversial {
    return controversies.isNotEmpty;
  }

  /// Get experience category
  String get experienceCategory {
    if (yearsOfExperience < 5) return 'Emerging';
    if (yearsOfExperience < 10) return 'Developing';
    if (yearsOfExperience < 20) return 'Experienced';
    return 'Veteran';
  }

  /// Get age category
  String get ageCategory {
    if (age < 45) return 'Young';
    if (age < 55) return 'Middle-aged';
    if (age < 65) return 'Experienced';
    return 'Veteran';
  }
}

/// Manager statistics
class ManagerStats {
  final int matchesManaged;
  final int wins;
  final int draws;
  final int losses;
  final double winPercentage;
  final int titlesWon;

  ManagerStats({
    required this.matchesManaged,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.winPercentage,
    required this.titlesWon,
  });

  factory ManagerStats.fromMap(Map<String, dynamic> map) {
    return ManagerStats(
      matchesManaged: map['matchesManaged'] ?? 0,
      wins: map['wins'] ?? 0,
      draws: map['draws'] ?? 0,
      losses: map['losses'] ?? 0,
      winPercentage: (map['winPercentage'] ?? 0.0).toDouble(),
      titlesWon: map['titlesWon'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matchesManaged': matchesManaged,
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'winPercentage': winPercentage,
      'titlesWon': titlesWon,
    };
  }

  /// Get formatted win percentage
  String get formattedWinPercentage {
    return '${winPercentage.toStringAsFixed(1)}%';
  }

  /// Get win/draw/loss ratio display
  String get recordDisplay {
    return '$wins-$draws-$losses';
  }
}

/// Manager social media information
class ManagerSocialMedia {
  final String instagram;
  final String twitter;
  final int followers;

  ManagerSocialMedia({
    required this.instagram,
    required this.twitter,
    required this.followers,
  });

  factory ManagerSocialMedia.fromMap(Map<String, dynamic> map) {
    return ManagerSocialMedia(
      instagram: map['instagram'] ?? '',
      twitter: map['twitter'] ?? '',
      followers: map['followers'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'instagram': instagram,
      'twitter': twitter,
      'followers': followers,
    };
  }

  /// Get formatted follower count (e.g., "4.2M")
  String get formattedFollowers {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(0)}K';
    }
    return followers.toString();
  }

  /// Check if manager has social media presence
  bool get hasSocialMedia {
    return instagram.isNotEmpty || twitter.isNotEmpty;
  }
}
