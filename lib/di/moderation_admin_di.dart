import 'package:get_it/get_it.dart';

import '../features/moderation/moderation.dart';
import '../features/admin/domain/services/admin_service.dart';
import '../features/match_chat/match_chat.dart';

/// Steps 11-13: Moderation, Admin, and Match Chat services.
void registerModerationAdminServices(GetIt sl) {
  // STEP 11: Moderation Services
  sl.registerLazySingleton<ProfanityFilterService>(() => ProfanityFilterService());
  sl.registerLazySingleton<ModerationService>(() => ModerationService(
    profanityFilter: sl(),
  ));

  // STEP 12: Admin Services
  sl.registerLazySingleton<AdminService>(() => AdminService());

  // STEP 13: Match Chat Services
  sl.registerLazySingleton<MatchChatService>(() => MatchChatService());
  sl.registerFactory<MatchChatCubit>(() => MatchChatCubit(
    chatService: sl(),
  ));
}
