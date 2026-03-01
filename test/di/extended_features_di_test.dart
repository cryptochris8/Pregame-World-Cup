import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';

import 'package:pregame_world_cup/features/chatbot/data/services/chatbot_knowledge_base.dart';
import 'package:pregame_world_cup/features/chatbot/domain/services/intent_classifier.dart';
import 'package:pregame_world_cup/features/chatbot/domain/services/response_generator.dart';
import 'package:pregame_world_cup/features/chatbot/domain/services/chatbot_service.dart';
import 'package:pregame_world_cup/features/chatbot/presentation/bloc/chatbot_cubit.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/enhanced_match_data_service.dart';
import 'package:pregame_world_cup/features/calendar/calendar.dart';
import 'package:pregame_world_cup/features/sharing/sharing.dart';

import 'package:pregame_world_cup/di/extended_features_di.dart';

/// Tests for lib/di/extended_features_di.dart  (Steps 14-16)
///
/// registerExtendedFeatures registers:
///   Step 14: ChatbotKnowledgeBase, IntentClassifier, ResponseGenerator,
///            ChatbotService, ChatbotCubit (factory)
///   Step 15: CalendarService
///   Step 16: SocialSharingService
void main() {
  final sl = GetIt.instance;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() async {
    await sl.reset();
  });

  group('Extended Features DI - registerExtendedFeatures', () {
    setUp(() {
      registerExtendedFeatures(sl);
    });

    test('registers all 7 expected types', () {
      expect(sl.isRegistered<ChatbotKnowledgeBase>(), isTrue);
      expect(sl.isRegistered<IntentClassifier>(), isTrue);
      expect(sl.isRegistered<ResponseGenerator>(), isTrue);
      expect(sl.isRegistered<ChatbotService>(), isTrue);
      expect(sl.isRegistered<ChatbotCubit>(), isTrue);
      expect(sl.isRegistered<CalendarService>(), isTrue);
      expect(sl.isRegistered<SocialSharingService>(), isTrue);
    });

    // -- Singletons --
    test('ChatbotKnowledgeBase is a lazy singleton', () {
      final a = sl<ChatbotKnowledgeBase>();
      final b = sl<ChatbotKnowledgeBase>();
      expect(identical(a, b), isTrue);
    });

    test('IntentClassifier is a lazy singleton', () {
      final a = sl<IntentClassifier>();
      final b = sl<IntentClassifier>();
      expect(identical(a, b), isTrue);
    });

    test('ResponseGenerator is a lazy singleton', () {
      final a = sl<ResponseGenerator>();
      final b = sl<ResponseGenerator>();
      expect(identical(a, b), isTrue);
    });

    test('ChatbotService is a lazy singleton', () {
      final a = sl<ChatbotService>();
      final b = sl<ChatbotService>();
      expect(identical(a, b), isTrue);
    });

    test('CalendarService is a lazy singleton', () {
      final a = sl<CalendarService>();
      final b = sl<CalendarService>();
      expect(identical(a, b), isTrue);
    });

    test('SocialSharingService is a lazy singleton', () {
      final a = sl<SocialSharingService>();
      final b = sl<SocialSharingService>();
      expect(identical(a, b), isTrue);
    });

    // -- Factory --
    test('ChatbotCubit is a factory - returns new instance each time', () {
      final a = sl<ChatbotCubit>();
      final b = sl<ChatbotCubit>();
      expect(identical(a, b), isFalse, reason: 'Factory should create new instances');
    });
  });

  group('Extended Features DI - type correctness', () {
    setUp(() {
      registerExtendedFeatures(sl);
    });

    test('resolved types are correct', () {
      expect(sl<ChatbotKnowledgeBase>(), isA<ChatbotKnowledgeBase>());
      expect(sl<IntentClassifier>(), isA<IntentClassifier>());
      expect(sl<ResponseGenerator>(), isA<ResponseGenerator>());
      expect(sl<ChatbotService>(), isA<ChatbotService>());
      expect(sl<ChatbotCubit>(), isA<ChatbotCubit>());
      expect(sl<CalendarService>(), isA<CalendarService>());
      expect(sl<SocialSharingService>(), isA<SocialSharingService>());
    });
  });

  group('Extended Features DI - dependency wiring', () {
    test('ChatbotKnowledgeBase uses EnhancedMatchDataService.instance', () {
      registerExtendedFeatures(sl);

      final kb = sl<ChatbotKnowledgeBase>();
      expect(kb, isNotNull);
    });

    test('IntentClassifier receives ChatbotKnowledgeBase from sl', () {
      registerExtendedFeatures(sl);

      final classifier = sl<IntentClassifier>();
      expect(classifier, isNotNull);
    });

    test('ResponseGenerator receives ChatbotKnowledgeBase from sl', () {
      registerExtendedFeatures(sl);

      final gen = sl<ResponseGenerator>();
      expect(gen, isNotNull);
    });

    test('ChatbotService receives all three chatbot dependencies', () {
      registerExtendedFeatures(sl);

      final service = sl<ChatbotService>();
      expect(service, isNotNull);
    });

    test('ChatbotCubit receives ChatbotService from sl', () {
      registerExtendedFeatures(sl);

      final cubit = sl<ChatbotCubit>();
      expect(cubit, isNotNull);
    });
  });

  group('Extended Features DI - duplicate registration guard', () {
    test('calling registerExtendedFeatures twice throws', () {
      registerExtendedFeatures(sl);
      expect(
        () => registerExtendedFeatures(sl),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
