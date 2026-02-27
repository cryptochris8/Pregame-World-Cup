import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/core/services/cache_service.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/enhanced_match_data_service.dart';
import 'package:pregame_world_cup/features/schedule/data/datasources/espn_schedule_datasource.dart';

// Core service mocks
class MockCacheService extends Mock implements CacheService {}

// World Cup data source mocks
class MockWorldCupFirestoreDataSource extends Mock
    implements WorldCupFirestoreDataSource {}

class MockWorldCupCacheDataSource extends Mock
    implements WorldCupCacheDataSource {}

class MockWorldCupApiDataSource extends Mock
    implements WorldCupApiDataSource {}

// Enhanced data service mock
class MockEnhancedMatchDataService extends Mock
    implements EnhancedMatchDataService {}

// Schedule data source mock
class MockESPNScheduleDataSource extends Mock
    implements ESPNScheduleDataSource {}
