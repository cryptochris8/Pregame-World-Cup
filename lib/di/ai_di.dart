import 'package:get_it/get_it.dart';

import '../core/services/unified_venue_service.dart';
import '../core/ai/services/ai_service.dart';
import '../core/ai/services/claude_service.dart';
import '../core/ai/services/multi_provider_ai_service.dart';
import '../core/ai/services/ai_historical_knowledge_service.dart';
import '../core/ai/services/ai_team_season_summary_service.dart';
import '../core/ai/services/enhanced_ai_game_analysis_service.dart';
import '../core/services/historical_game_analysis_service.dart';
import '../core/services/user_learning_service.dart';

/// Steps 3-4: Basic analysis and AI services.
void registerAIServices(GetIt sl) {
  // STEP 3: Basic Analysis Services
  sl.registerLazySingleton(() => UnifiedVenueService());

  // STEP 4: AI Services
  sl.registerLazySingleton(() => AIService());
  sl.registerLazySingleton(() => ClaudeService());
  sl.registerLazySingleton(() => MultiProviderAIService.instance);

  sl.registerLazySingleton(() => UserLearningService());

  sl.registerLazySingleton(() => AIHistoricalKnowledgeService.instance);
  sl.registerLazySingleton(() => AITeamSeasonSummaryService.instance);
  sl.registerLazySingleton(() => EnhancedAIGameAnalysisService.instance);
  sl.registerLazySingleton(() => HistoricalGameAnalysisService());
}
