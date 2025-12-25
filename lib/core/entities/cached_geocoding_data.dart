import 'package:hive/hive.dart';

part 'cached_geocoding_data.g.dart';

@HiveType(typeId: 1)
class CachedGeocodingData extends HiveObject {
  @override
  @HiveField(0)
  final String key;
  
  @HiveField(1)
  final String address;
  
  @HiveField(2)
  final double latitude;
  
  @HiveField(3)
  final double longitude;
  
  @HiveField(4)
  final DateTime cachedAt;

  CachedGeocodingData({
    required this.key,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.cachedAt,
  });
} 