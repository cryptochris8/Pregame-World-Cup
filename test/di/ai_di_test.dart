import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';

import 'package:pregame_world_cup/core/services/unified_venue_service.dart';
import 'package:pregame_world_cup/core/ai/services/ai_service.dart';
import 'package:pregame_world_cup/core/ai/services/claude_service.dart';
import 'package:pregame_world_cup/core/ai/services/multi_provider_ai_service.dart';
import 'package:pregame_world_cup/core/ai/services/ai_historical_knowledge_service.dart';
import 'package:pregame_world_cup/core/ai/services/ai_team_season_summary_service.dart';
import 'package:pregame_world_cup/core/ai/services/enhanced_ai_game_analysis_service.dart';
import 'package:pregame_world_cup/core/services/historical_game_analysis_service.dart';
import 'package:pregame_world_cup/core/services/user_learning_service.dart';

import 'package:pregame_world_cup/di/ai_di.dart';

/// Tests for lib/di/ai_di.dart  (Steps 3-4)
///
/// registerAIServices registers:
///   Step 3: UnifiedVenueService
///   Step 4: AIService, ClaudeService, MultiProviderAIService,
///           UserLearningService, AIHistoricalKnowledgeService,
///           AITeamSeasonSummaryService, EnhancedAIGameAnalysisService,
///           HistoricalGameAnalysisService
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

  group('AI DI - registerAIServices', () {
    setUp(() {
      registerAIServices(sl);
    });

    test('registers all 9 expected types', () {
      expect(sl.isRegistered<UnifiedVenueService>(), isTrue);
      expect(sl.isRegistered<AIService>(), isTrue);
      expect(sl.isRegistered<ClaudeService>(), isTrue);
      expect(sl.isRegistered<MultiProviderAIService>(), isTrue);
      expect(sl.isRegistered<UserLearningService>(), isTrue);
      expect(sl.isRegistered<AIHistoricalKnowledgeService>(), isTrue);
      expect(sl.isRegistered<AITeamSeasonSummaryService>(), isTrue);
      expect(sl.isRegistered<EnhancedAIGameAnalysisService>(), isTrue);
      expect(sl.isRegistered<HistoricalGameAnalysisService>(), isTrue);
    });

    test('UnifiedVenueService is a lazy singleton', () {
      final a = sl<UnifiedVenueService>();
      final b = sl<UnifiedVenueService>();
      expect(identical(a, b), isTrue);
    });

    test('AIService is a lazy singleton', () {
      final a = sl<AIService>();
      final b = sl<AIService>();
      expect(identical(a, b), isTrue);
    });

    test('ClaudeService is a lazy singleton', () {
      final a = sl<ClaudeService>();
      final b = sl<ClaudeService>();
      expect(identical(a, b), isTrue);
    });

    test('MultiProviderAIService is a lazy singleton', () {
      final a = sl<MultiProviderAIService>();
      final b = sl<MultiProviderAIService>();
      expect(identical(a, b), isTrue);
    });

    test('UserLearningService is a lazy singleton', () {
      final a = sl<UserLearningService>();
      final b = sl<UserLearningService>();
      expect(identical(a, b), isTrue);
    });

    test('AIHistoricalKnowledgeService is a lazy singleton', () {
      final a = sl<AIHistoricalKnowledgeService>();
      final b = sl<AIHistoricalKnowledgeService>();
      expect(identical(a, b), isTrue);
    });

    test('AITeamSeasonSummaryService is a lazy singleton', () {
      final a = sl<AITeamSeasonSummaryService>();
      final b = sl<AITeamSeasonSummaryService>();
      expect(identical(a, b), isTrue);
    });

    test('EnhancedAIGameAnalysisService is a lazy singleton', () {
      final a = sl<EnhancedAIGameAnalysisService>();
      final b = sl<EnhancedAIGameAnalysisService>();
      expect(identical(a, b), isTrue);
    });

    test('HistoricalGameAnalysisService is a lazy singleton', () {
      final a = sl<HistoricalGameAnalysisService>();
      final b = sl<HistoricalGameAnalysisService>();
      expect(identical(a, b), isTrue);
    });
  });

  group('AI DI - type correctness', () {
    setUp(() {
      registerAIServices(sl);
    });

    test('resolved types are correct concrete types', () {
      expect(sl<UnifiedVenueService>(), isA<UnifiedVenueService>());
      expect(sl<AIService>(), isA<AIService>());
      expect(sl<ClaudeService>(), isA<ClaudeService>());
      expect(sl<MultiProviderAIService>(), isA<MultiProviderAIService>());
      expect(sl<UserLearningService>(), isA<UserLearningService>());
      expect(sl<AIHistoricalKnowledgeService>(), isA<AIHistoricalKnowledgeService>());
      expect(sl<AITeamSeasonSummaryService>(), isA<AITeamSeasonSummaryService>());
      expect(sl<EnhancedAIGameAnalysisService>(), isA<EnhancedAIGameAnalysisService>());
      expect(sl<HistoricalGameAnalysisService>(), isA<HistoricalGameAnalysisService>());
    });
  });

  group('AI DI - duplicate registration guard', () {
    test('calling registerAIServices twice throws', () {
      registerAIServices(sl);
      expect(() => registerAIServices(sl), throwsA(isA<ArgumentError>()));
    });
  });
}
