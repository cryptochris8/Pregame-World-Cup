import 'package:get_it/get_it.dart';

import '../features/chatbot/data/services/chatbot_knowledge_base.dart';
import '../features/chatbot/domain/services/intent_classifier.dart';
import '../features/chatbot/domain/services/response_generator.dart';
import '../features/chatbot/domain/services/chatbot_service.dart';
import '../features/chatbot/presentation/bloc/chatbot_cubit.dart';
import '../features/worldcup/data/services/enhanced_match_data_service.dart';
import '../features/calendar/calendar.dart';
import '../features/sharing/sharing.dart';

/// Steps 14-16: Chatbot, Calendar, and Sharing services.
void registerExtendedFeatures(GetIt sl) {
  // STEP 14: Chatbot Services
  sl.registerLazySingleton<ChatbotKnowledgeBase>(() => ChatbotKnowledgeBase(
    enhancedData: EnhancedMatchDataService.instance,
  ));

  sl.registerLazySingleton<IntentClassifier>(() => IntentClassifier(
    knowledgeBase: sl<ChatbotKnowledgeBase>(),
  ));

  sl.registerLazySingleton<ResponseGenerator>(() => ResponseGenerator(
    knowledgeBase: sl<ChatbotKnowledgeBase>(),
  ));

  sl.registerLazySingleton<ChatbotService>(() => ChatbotService(
    knowledgeBase: sl<ChatbotKnowledgeBase>(),
    classifier: sl<IntentClassifier>(),
    responseGenerator: sl<ResponseGenerator>(),
  ));

  sl.registerFactory<ChatbotCubit>(() => ChatbotCubit(
    chatbotService: sl<ChatbotService>(),
  ));

  // STEP 15: Calendar Services
  sl.registerLazySingleton<CalendarService>(() => CalendarService());

  // STEP 16: Sharing Services
  sl.registerLazySingleton<SocialSharingService>(() => SocialSharingService());
}
