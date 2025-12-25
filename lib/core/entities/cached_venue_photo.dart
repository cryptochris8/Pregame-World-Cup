import 'package:hive/hive.dart';

part 'cached_venue_photo.g.dart';

@HiveType(typeId: 3)
class CachedVenuePhotos extends HiveObject {
  @HiveField(0)
  final String placeId;
  
  @HiveField(1)
  final List<String> photoUrls;
  
  @HiveField(2)
  final DateTime timestamp;
  
  @HiveField(3)
  final Map<String, dynamic>? metadata;

  CachedVenuePhotos({
    required this.placeId,
    required this.photoUrls,
    required this.timestamp,
    this.metadata,
  });

  /// Create from JSON
  factory CachedVenuePhotos.fromJson(Map<String, dynamic> json) {
    return CachedVenuePhotos(
      placeId: json['place_id'] ?? '',
      photoUrls: List<String>.from(json['photo_urls'] ?? []),
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'photo_urls': photoUrls,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Check if photos are expired
  bool isExpired({Duration maxAge = const Duration(days: 7)}) {
    return DateTime.now().difference(timestamp) > maxAge;
  }

  /// Get first photo URL (primary photo)
  String? get primaryPhotoUrl => photoUrls.isNotEmpty ? photoUrls.first : null;

  /// Get photo count
  int get photoCount => photoUrls.length;

  /// Copy with new data
  CachedVenuePhotos copyWith({
    String? placeId,
    List<String>? photoUrls,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return CachedVenuePhotos(
      placeId: placeId ?? this.placeId,
      photoUrls: photoUrls ?? this.photoUrls,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'CachedVenuePhotos{placeId: $placeId, photoCount: ${photoUrls.length}, timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CachedVenuePhotos &&
        other.placeId == placeId &&
        other.photoUrls.length == photoUrls.length &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return placeId.hashCode ^ photoUrls.length.hashCode ^ timestamp.hashCode;
  }
} 