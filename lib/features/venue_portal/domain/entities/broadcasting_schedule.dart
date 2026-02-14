import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BroadcastingSchedule extends Equatable {
  final List<String> matchIds;
  final DateTime lastUpdated;
  final List<String> autoSelectByTeam;

  const BroadcastingSchedule({
    this.matchIds = const [],
    required this.lastUpdated,
    this.autoSelectByTeam = const [],
  });

  factory BroadcastingSchedule.empty() => BroadcastingSchedule(
        matchIds: const [],
        lastUpdated: DateTime.now(),
        autoSelectByTeam: const [],
      );

  BroadcastingSchedule copyWith({
    List<String>? matchIds,
    DateTime? lastUpdated,
    List<String>? autoSelectByTeam,
  }) {
    return BroadcastingSchedule(
      matchIds: matchIds ?? this.matchIds,
      lastUpdated: lastUpdated ?? DateTime.now(),
      autoSelectByTeam: autoSelectByTeam ?? this.autoSelectByTeam,
    );
  }

  bool isBroadcastingMatch(String matchId) => matchIds.contains(matchId);

  factory BroadcastingSchedule.fromJson(Map<String, dynamic> json) {
    return BroadcastingSchedule(
      matchIds: List<String>.from(json['matchIds'] ?? []),
      lastUpdated: json['lastUpdated'] != null
          ? (json['lastUpdated'] is Timestamp
              ? (json['lastUpdated'] as Timestamp).toDate()
              : DateTime.parse(json['lastUpdated'] as String))
          : DateTime.now(),
      autoSelectByTeam: List<String>.from(json['autoSelectByTeam'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchIds': matchIds,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'autoSelectByTeam': autoSelectByTeam,
    };
  }

  @override
  List<Object?> get props => [matchIds, lastUpdated, autoSelectByTeam];
}
