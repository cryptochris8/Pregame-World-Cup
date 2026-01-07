import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveCapacity extends Equatable {
  final int currentOccupancy;
  final int maxCapacity;
  final DateTime lastUpdated;
  final bool reservationsAvailable;
  final int? waitTimeMinutes;

  const LiveCapacity({
    this.currentOccupancy = 0,
    required this.maxCapacity,
    required this.lastUpdated,
    this.reservationsAvailable = true,
    this.waitTimeMinutes,
  });

  factory LiveCapacity.empty({int maxCapacity = 100}) => LiveCapacity(
        maxCapacity: maxCapacity,
        lastUpdated: DateTime.now(),
      );

  LiveCapacity copyWith({
    int? currentOccupancy,
    int? maxCapacity,
    DateTime? lastUpdated,
    bool? reservationsAvailable,
    int? waitTimeMinutes,
  }) {
    return LiveCapacity(
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      lastUpdated: lastUpdated ?? DateTime.now(),
      reservationsAvailable: reservationsAvailable ?? this.reservationsAvailable,
      waitTimeMinutes: waitTimeMinutes ?? this.waitTimeMinutes,
    );
  }

  double get occupancyPercent =>
      maxCapacity > 0 ? (currentOccupancy / maxCapacity * 100).clamp(0, 100) : 0;

  String get occupancyText => '${occupancyPercent.round()}% Full';

  String get statusText {
    if (occupancyPercent >= 95) return 'At Capacity';
    if (occupancyPercent >= 80) return 'Almost Full';
    if (occupancyPercent >= 50) return 'Busy';
    if (occupancyPercent >= 25) return 'Moderate';
    return 'Plenty of Room';
  }

  String get waitTimeText {
    if (waitTimeMinutes == null || waitTimeMinutes == 0) return 'No Wait';
    if (waitTimeMinutes! < 15) return '~${waitTimeMinutes}m wait';
    if (waitTimeMinutes! < 30) return '~15-30m wait';
    if (waitTimeMinutes! < 60) return '~30-60m wait';
    return '1hr+ wait';
  }

  bool get isStale {
    final difference = DateTime.now().difference(lastUpdated);
    return difference.inMinutes > 30;
  }

  factory LiveCapacity.fromJson(Map<String, dynamic> json) {
    return LiveCapacity(
      currentOccupancy: json['currentOccupancy'] as int? ?? 0,
      maxCapacity: json['maxCapacity'] as int? ?? 100,
      lastUpdated: json['lastUpdated'] != null
          ? (json['lastUpdated'] is Timestamp
              ? (json['lastUpdated'] as Timestamp).toDate()
              : DateTime.parse(json['lastUpdated'] as String))
          : DateTime.now(),
      reservationsAvailable: json['reservationsAvailable'] as bool? ?? true,
      waitTimeMinutes: json['waitTimeMinutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentOccupancy': currentOccupancy,
      'maxCapacity': maxCapacity,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'reservationsAvailable': reservationsAvailable,
      'waitTimeMinutes': waitTimeMinutes,
    };
  }

  @override
  List<Object?> get props => [
        currentOccupancy,
        maxCapacity,
        lastUpdated,
        reservationsAvailable,
        waitTimeMinutes,
      ];
}
