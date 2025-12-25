import 'package:hive/hive.dart';

part 'cached_venue_data.g.dart';

@HiveType(typeId: 0)
class CachedVenueData extends HiveObject {
  @override
  @HiveField(0)
  final String key;
  
  @HiveField(1)
  final String venuesJson;
  
  @HiveField(2)
  final DateTime cachedAt;
  
  @HiveField(3)
  final double latitude;
  
  @HiveField(4)
  final double longitude;
  
  @HiveField(5)
  final double radius;
  
  @HiveField(6)
  final List<String> types;

  CachedVenueData({
    required this.key,
    required this.venuesJson,
    required this.cachedAt,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.types,
  });
} 