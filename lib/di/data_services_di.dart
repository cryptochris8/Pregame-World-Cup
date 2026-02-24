import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';

import '../services/espn_service.dart';
import '../features/schedule/data/datasources/espn_schedule_datasource.dart';
import '../features/schedule/data/repositories/schedule_repository_impl.dart';
import '../features/schedule/domain/repositories/schedule_repository.dart';
import '../features/schedule/domain/usecases/get_upcoming_games.dart';
import '../features/schedule/presentation/bloc/schedule_bloc.dart';

/// Debug-only log helper.
void _diLog(String message) {
  if (kDebugMode) {
    print(message);
  }
}

/// Android diagnostic mode flag (must match injection_container.dart).
const bool _androidDiagnosticMode = false;

/// Steps 5-6: ESPN/API services and schedule services.
Future<void> registerDataServices(GetIt sl) async {
  // STEP 5: ESPN and API Services
  try {
    await Future.any([
      _registerESPNServices(sl),
      Future.delayed(const Duration(seconds: 5)),
    ]);
  } catch (e) {
    _diLog('DI STEP 5: ESPN and API Services - FAILED: $e');
    _registerFallbackServices(sl);
  }

  // STEP 6: Schedule Services
  sl.registerFactory(() => ScheduleBloc(
    getUpcomingGames: sl(),
    scheduleRepository: sl(),
  ));

  sl.registerLazySingleton(() => GetUpcomingGames(sl()));

  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(remoteDataSource: sl<ESPNScheduleDataSource>()),
  );
}

Future<void> _registerESPNServices(GetIt sl) async {
  sl.registerLazySingleton(() => ESPNService());

  sl.registerLazySingleton(() => ESPNScheduleDataSource(
    espnService: sl(),
    cacheService: sl(),
  ));
}

void _registerFallbackServices(GetIt sl) {
  try {
    sl.registerLazySingleton(() => ESPNService());

    sl.registerLazySingleton(() => ESPNScheduleDataSource(
      espnService: sl(),
      cacheService: sl(),
    ));

    if (_androidDiagnosticMode) {
      _diLog('FALLBACK: Registered fallback ESPN services');
    }
  } catch (e) {
    if (_androidDiagnosticMode) {
      _diLog('FALLBACK: Even fallback services failed: $e');
    }
  }
}
