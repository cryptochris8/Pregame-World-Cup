import 'package:get_it/get_it.dart';

import '../features/watch_party/domain/services/watch_party_service.dart';
import '../features/watch_party/domain/services/watch_party_payment_service.dart';
import '../features/watch_party/presentation/bloc/watch_party_bloc.dart';

/// Step 10: Watch party services and BLoC.
void registerWatchPartyServices(GetIt sl) {
  sl.registerLazySingleton<WatchPartyService>(() => WatchPartyService());
  sl.registerLazySingleton<WatchPartyPaymentService>(() => WatchPartyPaymentService());

  sl.registerFactory<WatchPartyBloc>(() => WatchPartyBloc(
    watchPartyService: sl(),
    paymentService: sl(),
  ));
}
