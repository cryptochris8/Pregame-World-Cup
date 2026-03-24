import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/core/services/cache_service.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/world_cup_ai_service.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import 'mock_repositories.dart';

// Mocks
class MockWorldCupAIService extends Mock implements WorldCupAIService {}

class MockCacheService extends Mock implements CacheService {}

// Fakes for registerFallbackValue
class FakeWorldCupMatch extends Fake implements WorldCupMatch {
  @override
  String get matchId => 'fake_match';

  @override
  String get homeTeamName => 'FakeHome';

  @override
  String get awayTeamName => 'FakeAway';

  @override
  String? get homeTeamCode => 'FH';

  @override
  String? get awayTeamCode => 'FA';
}

class FakeNationalTeam extends Fake implements NationalTeam {
  @override
  int? get worldRanking => 50;
}

// Test Data Helpers
AIMatchPrediction createTestAIPrediction({
  String matchId = 'match_1',
  AIPredictedOutcome predictedOutcome = AIPredictedOutcome.homeWin,
  int predictedHomeScore = 2,
  int predictedAwayScore = 1,
  int confidence = 65,
  int homeWinProbability = 55,
  int drawProbability = 25,
  int awayWinProbability = 20,
  List<String> keyFactors = const ['FIFA Ranking', 'Home advantage'],
  String analysis = 'Test analysis',
  String quickInsight = 'Home team favored 2-1',
  String provider = 'LocalEngine',
  DateTime? generatedAt,
  int ttlMinutes = 1440,
  bool isUpsetAlert = false,
}) {
  return AIMatchPrediction(
    matchId: matchId,
    predictedOutcome: predictedOutcome,
    predictedHomeScore: predictedHomeScore,
    predictedAwayScore: predictedAwayScore,
    confidence: confidence,
    homeWinProbability: homeWinProbability,
    drawProbability: drawProbability,
    awayWinProbability: awayWinProbability,
    keyFactors: keyFactors,
    analysis: analysis,
    quickInsight: quickInsight,
    provider: provider,
    generatedAt: generatedAt ?? DateTime.now(),
    ttlMinutes: ttlMinutes,
    isUpsetAlert: isUpsetAlert,
  );
}

void main() {
  late MockWorldCupAIService mockAIService;
  late MockCacheService mockCacheService;
  late WorldCupAICubit cubit;

  final testMatch = TestDataFactory.createMatch(
    matchId: 'match_1',
    homeTeamCode: 'USA',
    homeTeamName: 'United States',
    awayTeamCode: 'MEX',
    awayTeamName: 'Mexico',
  );

  final testMatch2 = TestDataFactory.createMatch(
    matchId: 'match_2',
    homeTeamCode: 'BRA',
    homeTeamName: 'Brazil',
    awayTeamCode: 'ARG',
    awayTeamName: 'Argentina',
  );

  final testHomeTeam = TestDataFactory.createTeam(
    teamCode: 'USA',
    countryName: 'United States',
    shortName: 'USA',
    worldRanking: 10,
  );

  final testAwayTeam = TestDataFactory.createTeam(
    teamCode: 'MEX',
    countryName: 'Mexico',
    shortName: 'Mexico',
    worldRanking: 15,
  );

  setUpAll(() {
    registerFallbackValue(FakeWorldCupMatch());
    registerFallbackValue(FakeNationalTeam());
    registerFallbackValue(const Duration(hours: 24));
  });

  setUp(() {
    mockAIService = MockWorldCupAIService();
    mockCacheService = MockCacheService();

    // Default stubs
    when(() => mockAIService.isAvailable).thenReturn(true);

    // Default catch-all stubs so unmocked calls don't return null for non-nullable types
    when(() => mockAIService.generateMatchPrediction(
          match: any(named: 'match'),
          homeTeam: any(named: 'homeTeam'),
          awayTeam: any(named: 'awayTeam'),
        )).thenAnswer((_) async => createTestAIPrediction());

    when(() => mockCacheService.get<Map<String, dynamic>>(any()))
        .thenAnswer((_) async => null);

    when(() => mockCacheService.set<Map<String, dynamic>>(
          any(),
          any(),
          duration: any(named: 'duration'),
        )).thenAnswer((_) async {});

    when(() => mockCacheService.remove(any())).thenAnswer((_) async {});

    cubit = WorldCupAICubit(
      aiService: mockAIService,
      cacheService: mockCacheService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('WorldCupAICubit', () {
    // -------------------------------------------------------
    // 1. Initial state
    // -------------------------------------------------------
    test('initial state is correct', () {
      expect(cubit.state, equals(WorldCupAIState.initial()));
      expect(cubit.state.predictions, isEmpty);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.loadingMatchId, isNull);
      expect(cubit.state.error, isNull);
      expect(cubit.state.errorMatchId, isNull);
      expect(cubit.state.isAvailable, isTrue);
    });

    // -------------------------------------------------------
    // 2. isAvailable delegates to AI service
    // -------------------------------------------------------
    test('isAvailable returns true when service is available', () {
      when(() => mockAIService.isAvailable).thenReturn(true);
      expect(cubit.isAvailable, isTrue);
    });

    test('isAvailable returns false when service is unavailable', () {
      when(() => mockAIService.isAvailable).thenReturn(false);
      expect(cubit.isAvailable, isFalse);
    });

    // -------------------------------------------------------
    // 3. loadPredictionWithTeams - fresh prediction (no cache)
    // -------------------------------------------------------
    group('loadPredictionWithTeams', () {
      blocTest<WorldCupAICubit, WorldCupAIState>(
        'fetches from service when no cache exists and emits prediction',
        build: () {
          final prediction = createTestAIPrediction(matchId: 'match_1');

          when(() => mockAIService.generateMatchPrediction(
                match: testMatch,
                homeTeam: testHomeTeam,
                awayTeam: testAwayTeam,
              )).thenAnswer((_) async => prediction);

          return cubit;
        },
        act: (cubit) => cubit.loadPredictionWithTeams(
          testMatch,
          testHomeTeam,
          testAwayTeam,
        ),
        expect: () => [
          // First: loading state for match_1
          isA<WorldCupAIState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.loadingMatchId, 'loadingMatchId', 'match_1'),
          // Second: prediction loaded
          isA<WorldCupAIState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.loadingMatchId, 'loadingMatchId', isNull)
              .having((s) => s.hasPrediction('match_1'), 'hasPrediction', true)
              .having(
                (s) => s.getPrediction('match_1')?.predictedHomeScore,
                'homeScore',
                2,
              ),
        ],
        verify: (_) {
          verify(() => mockAIService.generateMatchPrediction(
                match: testMatch,
                homeTeam: testHomeTeam,
                awayTeam: testAwayTeam,
              )).called(1);
        },
      );

      // -------------------------------------------------------
      // 4. loadPredictionWithTeams - returns from memory cache
      // -------------------------------------------------------
      blocTest<WorldCupAICubit, WorldCupAIState>(
        'returns cached prediction from memory state without service call',
        build: () => cubit,
        seed: () {
          final prediction = createTestAIPrediction(matchId: 'match_1');
          return WorldCupAIState.initial().withPrediction(prediction);
        },
        act: (cubit) => cubit.loadPredictionWithTeams(
          testMatch,
          testHomeTeam,
          testAwayTeam,
        ),
        // No state changes - returned from memory directly
        expect: () => [],
      );

      // -------------------------------------------------------
      // 5. loadPredictionWithTeams - returns from Hive cache
      // -------------------------------------------------------
      blocTest<WorldCupAICubit, WorldCupAIState>(
        'loads from Hive cache when memory cache is empty',
        build: () {
          final prediction = createTestAIPrediction(matchId: 'match_1');
          when(() => mockCacheService.get<Map<String, dynamic>>(
                'ai_prediction_match_1',
              )).thenAnswer((_) async => prediction.toMap());
          return cubit;
        },
        act: (cubit) => cubit.loadPredictionWithTeams(
          testMatch,
          testHomeTeam,
          testAwayTeam,
        ),
        expect: () => [
          // Prediction loaded from Hive (stored in memory state)
          isA<WorldCupAIState>()
              .having((s) => s.hasPrediction('match_1'), 'hasPrediction', true)
              .having((s) => s.isLoading, 'isLoading', false),
        ],
      );

      // -------------------------------------------------------
      // 6. loadPredictionWithTeams - skip if already loading
      // -------------------------------------------------------
      blocTest<WorldCupAICubit, WorldCupAIState>(
        'returns null if already loading the same match',
        build: () => cubit,
        seed: () => WorldCupAIState.initial().withLoading('match_1'),
        act: (cubit) => cubit.loadPredictionWithTeams(
          testMatch,
          testHomeTeam,
          testAwayTeam,
        ),
        expect: () => [],
      );

      // -------------------------------------------------------
      // 7. loadPredictionWithTeams - handles error with fallback
      // -------------------------------------------------------
      blocTest<WorldCupAICubit, WorldCupAIState>(
        'emits error and fallback prediction when AI service throws',
        build: () {
          // AI service throws
          when(() => mockAIService.generateMatchPrediction(
                match: testMatch,
                homeTeam: testHomeTeam,
                awayTeam: testAwayTeam,
              )).thenThrow(Exception('AI service unavailable'));

          return cubit;
        },
        act: (cubit) => cubit.loadPredictionWithTeams(
          testMatch,
          testHomeTeam,
          testAwayTeam,
        ),
        expect: () => [
          // First: loading state
          isA<WorldCupAIState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.loadingMatchId, 'loadingMatchId', 'match_1'),
          // Second: error state
          isA<WorldCupAIState>()
              .having((s) => s.error, 'error', isNotNull)
              .having((s) => s.errorMatchId, 'errorMatchId', 'match_1'),
          // Third: fallback prediction stored
          isA<WorldCupAIState>()
              .having((s) => s.hasPrediction('match_1'), 'hasPrediction', true)
              .having(
                (s) => s.getPrediction('match_1')?.provider,
                'provider',
                'Fallback',
              ),
        ],
      );

      // -------------------------------------------------------
      // 7b. loadPredictionWithTeams - expired Hive cache triggers fresh fetch
      // -------------------------------------------------------
      blocTest<WorldCupAICubit, WorldCupAIState>(
        'fetches from service when Hive cache is expired',
        build: () {
          // Hive returns expired prediction
          final expiredPrediction = createTestAIPrediction(
            matchId: 'match_1',
            generatedAt:
                DateTime.now().subtract(const Duration(hours: 25)),
            ttlMinutes: 1440,
          );
          when(() => mockCacheService.get<Map<String, dynamic>>(
                'ai_prediction_match_1',
              )).thenAnswer((_) async => expiredPrediction.toMap());

          // AI service returns fresh prediction
          final freshPrediction = createTestAIPrediction(
            matchId: 'match_1',
            quickInsight: 'Fresh prediction',
          );
          when(() => mockAIService.generateMatchPrediction(
                match: testMatch,
                homeTeam: testHomeTeam,
                awayTeam: testAwayTeam,
              )).thenAnswer((_) async => freshPrediction);

          return cubit;
        },
        act: (cubit) => cubit.loadPredictionWithTeams(
          testMatch,
          testHomeTeam,
          testAwayTeam,
        ),
        expect: () => [
          // Loading
          isA<WorldCupAIState>()
              .having((s) => s.isLoading, 'isLoading', true),
          // Fresh prediction loaded
          isA<WorldCupAIState>()
              .having((s) => s.hasPrediction('match_1'), 'hasPrediction', true)
              .having((s) => s.isLoading, 'isLoading', false),
        ],
      );
    });

    // -------------------------------------------------------
    // 8. loadPrediction delegates to loadPredictionWithTeams
    // -------------------------------------------------------
    group('loadPrediction', () {
      blocTest<WorldCupAICubit, WorldCupAIState>(
        'loadPrediction delegates to loadPredictionWithTeams with null teams',
        build: () {
          final prediction = createTestAIPrediction(matchId: 'match_1');

          when(() => mockAIService.generateMatchPrediction(
                match: testMatch,
                homeTeam: null,
                awayTeam: null,
              )).thenAnswer((_) async => prediction);

          return cubit;
        },
        act: (cubit) => cubit.loadPrediction(testMatch),
        expect: () => [
          isA<WorldCupAIState>()
              .having((s) => s.isLoading, 'isLoading', true),
          isA<WorldCupAIState>()
              .having((s) => s.hasPrediction('match_1'), 'hasPrediction', true),
        ],
      );
    });

    // -------------------------------------------------------
    // 9. getSuggestion - success
    // -------------------------------------------------------
    group('getSuggestion', () {
      test('returns suggestion from AI service', () async {
        final suggestion = {
          'homeScore': 2,
          'awayScore': 0,
          'confidence': 70,
          'reasoning': 'Strong home form',
          'provider': 'LocalEngine',
        };

        when(() => mockAIService.suggestPrediction(
              match: testMatch,
              homeTeam: testHomeTeam,
              awayTeam: testAwayTeam,
            )).thenAnswer((_) async => suggestion);

        final result = await cubit.getSuggestion(
          testMatch,
          homeTeam: testHomeTeam,
          awayTeam: testAwayTeam,
        );

        expect(result['homeScore'], 2);
        expect(result['awayScore'], 0);
        expect(result['confidence'], 70);
        expect(result['reasoning'], 'Strong home form');
      });

      // -------------------------------------------------------
      // 10. getSuggestion - returns fallback on error
      // -------------------------------------------------------
      test('returns fallback suggestion when AI service throws', () async {
        when(() => mockAIService.suggestPrediction(
              match: testMatch,
              homeTeam: testHomeTeam,
              awayTeam: testAwayTeam,
            )).thenThrow(Exception('Service error'));

        final result = await cubit.getSuggestion(
          testMatch,
          homeTeam: testHomeTeam,
          awayTeam: testAwayTeam,
        );

        expect(result['homeScore'], 1);
        expect(result['awayScore'], 1);
        expect(result['confidence'], 40);
        expect(result['reasoning'], 'Unable to generate AI suggestion');
        expect(result['provider'], 'Fallback');
      });
    });

    // -------------------------------------------------------
    // 11. getQuickInsight - from memory cache
    // -------------------------------------------------------
    group('getQuickInsight', () {
      test('returns quick insight from memory-cached prediction', () async {
        final prediction = createTestAIPrediction(
          matchId: 'match_1',
          quickInsight: 'USA favored 2-1',
        );
        cubit.emit(WorldCupAIState.initial().withPrediction(prediction));

        final result = await cubit.getQuickInsight(testMatch);

        expect(result, 'USA favored 2-1');
      });

      // -------------------------------------------------------
      // 12. getQuickInsight - from Hive cache
      // -------------------------------------------------------
      test('loads from Hive cache when not in memory', () async {
        final prediction = createTestAIPrediction(
          matchId: 'match_1',
          quickInsight: 'Hive cached insight',
        );
        when(() => mockCacheService.get<Map<String, dynamic>>(
              'ai_prediction_match_1',
            )).thenAnswer((_) async => prediction.toMap());

        final result = await cubit.getQuickInsight(testMatch);

        expect(result, 'Hive cached insight');
      });

      // -------------------------------------------------------
      // 13. getQuickInsight - from AI service
      // -------------------------------------------------------
      test('fetches from AI service when no cache exists', () async {
        when(() => mockAIService.generateQuickInsight(
              match: testMatch,
              homeTeam: testHomeTeam,
              awayTeam: testAwayTeam,
            )).thenAnswer((_) async => 'Fresh AI insight');

        final result = await cubit.getQuickInsight(
          testMatch,
          homeTeam: testHomeTeam,
          awayTeam: testAwayTeam,
        );

        expect(result, 'Fresh AI insight');
      });

      // -------------------------------------------------------
      // 14. getQuickInsight - fallback on error
      // -------------------------------------------------------
      test('returns fallback text when AI service throws', () async {
        when(() => mockAIService.generateQuickInsight(
              match: testMatch,
              homeTeam: testHomeTeam,
              awayTeam: testAwayTeam,
            )).thenThrow(Exception('Network error'));

        final result = await cubit.getQuickInsight(
          testMatch,
          homeTeam: testHomeTeam,
          awayTeam: testAwayTeam,
        );

        expect(result, 'AI prediction unavailable');
      });
    });

    // -------------------------------------------------------
    // 15. clearPrediction - removes from memory and Hive
    // -------------------------------------------------------
    group('clearPrediction', () {
      blocTest<WorldCupAICubit, WorldCupAIState>(
        'removes prediction from memory state and Hive cache',
        build: () => cubit,
        seed: () {
          final prediction = createTestAIPrediction(matchId: 'match_1');
          return WorldCupAIState.initial().withPrediction(prediction);
        },
        act: (cubit) => cubit.clearPrediction('match_1'),
        expect: () => [
          isA<WorldCupAIState>()
              .having(
                  (s) => s.hasPrediction('match_1'), 'hasPrediction', false)
              .having((s) => s.predictions, 'predictions', isEmpty),
        ],
        verify: (_) {
          verify(() => mockCacheService.remove('ai_prediction_match_1'))
              .called(1);
        },
      );

      blocTest<WorldCupAICubit, WorldCupAIState>(
        'handles Hive cache error gracefully during clearPrediction',
        build: () {
          when(() => mockCacheService.remove('ai_prediction_match_1'))
              .thenThrow(Exception('Cache error'));
          return cubit;
        },
        seed: () {
          final prediction = createTestAIPrediction(matchId: 'match_1');
          return WorldCupAIState.initial().withPrediction(prediction);
        },
        act: (cubit) => cubit.clearPrediction('match_1'),
        expect: () => [
          // Prediction still removed from memory even if Hive fails
          isA<WorldCupAIState>()
              .having(
                  (s) => s.hasPrediction('match_1'), 'hasPrediction', false),
        ],
      );
    });

    // -------------------------------------------------------
    // 16. clearAllPredictions - resets predictions, preserves isAvailable
    // -------------------------------------------------------
    group('clearAllPredictions', () {
      blocTest<WorldCupAICubit, WorldCupAIState>(
        'clears all predictions from memory and preserves isAvailable',
        build: () => cubit,
        seed: () {
          final p1 = createTestAIPrediction(matchId: 'match_1');
          final p2 = createTestAIPrediction(matchId: 'match_2');
          return WorldCupAIState.initial()
              .withPrediction(p1)
              .withPrediction(p2)
              .copyWith(isAvailable: true);
        },
        act: (cubit) => cubit.clearAllPredictions(),
        expect: () => [
          isA<WorldCupAIState>()
              .having((s) => s.predictions, 'predictions', isEmpty)
              .having((s) => s.isAvailable, 'isAvailable', true),
        ],
      );
    });

    // -------------------------------------------------------
    // 17. cleanupExpiredPredictions - removes expired, keeps valid
    // -------------------------------------------------------
    group('cleanupExpiredPredictions', () {
      blocTest<WorldCupAICubit, WorldCupAIState>(
        'removes expired predictions and keeps valid ones',
        build: () => cubit,
        seed: () {
          final validPrediction = createTestAIPrediction(
            matchId: 'match_valid',
            generatedAt: DateTime.now(),
            ttlMinutes: 1440,
          );
          final expiredPrediction = createTestAIPrediction(
            matchId: 'match_expired',
            generatedAt:
                DateTime.now().subtract(const Duration(hours: 25)),
            ttlMinutes: 1440,
          );
          return WorldCupAIState.initial()
              .withPrediction(validPrediction)
              .withPrediction(expiredPrediction);
        },
        act: (cubit) => cubit.cleanupExpiredPredictions(),
        expect: () => [
          isA<WorldCupAIState>()
              .having((s) => s.predictions.length, 'predictions count', 1)
              .having((s) => s.hasPrediction('match_valid'), 'has valid', true)
              .having(
                  (s) => s.hasPrediction('match_expired'), 'has expired', false),
        ],
      );

      blocTest<WorldCupAICubit, WorldCupAIState>(
        'does not emit when all predictions are still valid',
        build: () => cubit,
        seed: () {
          final p1 = createTestAIPrediction(
            matchId: 'match_1',
            generatedAt: DateTime.now(),
            ttlMinutes: 1440,
          );
          final p2 = createTestAIPrediction(
            matchId: 'match_2',
            generatedAt: DateTime.now(),
            ttlMinutes: 1440,
          );
          return WorldCupAIState.initial()
              .withPrediction(p1)
              .withPrediction(p2);
        },
        act: (cubit) => cubit.cleanupExpiredPredictions(),
        expect: () => [],
      );
    });

    // -------------------------------------------------------
    // 18. refreshPrediction - clears and reloads
    // -------------------------------------------------------
    group('refreshPrediction', () {
      blocTest<WorldCupAICubit, WorldCupAIState>(
        'clears existing prediction and fetches fresh one',
        build: () {
          final freshPrediction = createTestAIPrediction(
            matchId: 'match_1',
            predictedHomeScore: 3,
            predictedAwayScore: 0,
            quickInsight: 'Refreshed prediction',
          );

          when(() => mockAIService.generateMatchPrediction(
                match: testMatch,
                homeTeam: testHomeTeam,
                awayTeam: testAwayTeam,
              )).thenAnswer((_) async => freshPrediction);

          return cubit;
        },
        seed: () {
          final oldPrediction = createTestAIPrediction(
            matchId: 'match_1',
            predictedHomeScore: 1,
            predictedAwayScore: 1,
          );
          return WorldCupAIState.initial().withPrediction(oldPrediction);
        },
        act: (cubit) => cubit.refreshPrediction(
          testMatch,
          homeTeam: testHomeTeam,
          awayTeam: testAwayTeam,
        ),
        expect: () => [
          // First: old prediction cleared
          isA<WorldCupAIState>()
              .having(
                  (s) => s.hasPrediction('match_1'), 'hasPrediction', false),
          // Second: loading state for fresh fetch
          isA<WorldCupAIState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.loadingMatchId, 'loadingMatchId', 'match_1'),
          // Third: fresh prediction loaded
          isA<WorldCupAIState>()
              .having((s) => s.hasPrediction('match_1'), 'hasPrediction', true)
              .having(
                (s) => s.getPrediction('match_1')?.predictedHomeScore,
                'homeScore',
                3,
              ),
        ],
      );
    });

    // -------------------------------------------------------
    // 19. preloadPredictions - loads multiple matches
    // -------------------------------------------------------
    group('preloadPredictions', () {
      test('loads predictions for multiple matches', () async {
        final prediction1 = createTestAIPrediction(matchId: 'match_1');
        final prediction2 = createTestAIPrediction(matchId: 'match_2');

        when(() => mockAIService.generateMatchPrediction(
              match: testMatch,
              homeTeam: null,
              awayTeam: null,
            )).thenAnswer((_) async => prediction1);

        when(() => mockAIService.generateMatchPrediction(
              match: testMatch2,
              homeTeam: null,
              awayTeam: null,
            )).thenAnswer((_) async => prediction2);

        await cubit.preloadPredictions([testMatch, testMatch2]);

        // Allow time for the async operations to complete
        await Future.delayed(const Duration(milliseconds: 500));

        // Both predictions should be loaded in state
        expect(cubit.state.hasPrediction('match_1'), isTrue);
        expect(cubit.state.hasPrediction('match_2'), isTrue);
      });

      test('skips already cached predictions during preload', () async {
        final prediction1 = createTestAIPrediction(matchId: 'match_1');
        cubit.emit(WorldCupAIState.initial().withPrediction(prediction1));

        final prediction2 = createTestAIPrediction(matchId: 'match_2');

        when(() => mockAIService.generateMatchPrediction(
              match: testMatch2,
              homeTeam: null,
              awayTeam: null,
            )).thenAnswer((_) async => prediction2);

        await cubit.preloadPredictions([testMatch, testMatch2]);

        // Allow async ops
        await Future.delayed(const Duration(milliseconds: 500));

        // match_2 was loaded, match_1 was already cached
        expect(cubit.state.hasPrediction('match_1'), isTrue);
        expect(cubit.state.hasPrediction('match_2'), isTrue);
      });

      test('passes team details from teamsByCode map', () async {
        final prediction1 = createTestAIPrediction(matchId: 'match_1');

        when(() => mockAIService.generateMatchPrediction(
              match: testMatch,
              homeTeam: testHomeTeam,
              awayTeam: testAwayTeam,
            )).thenAnswer((_) async => prediction1);

        await cubit.preloadPredictions(
          [testMatch],
          teamsByCode: {
            'USA': testHomeTeam,
            'MEX': testAwayTeam,
          },
        );

        await Future.delayed(const Duration(milliseconds: 500));

        expect(cubit.state.hasPrediction('match_1'), isTrue);
      });
    });

    // -------------------------------------------------------
    // 20. Hive cache error handling
    // -------------------------------------------------------
    group('cache error handling', () {
      blocTest<WorldCupAICubit, WorldCupAIState>(
        'proceeds to AI service when Hive cache throws error',
        build: () {
          final prediction = createTestAIPrediction(matchId: 'match_1');

          // Hive cache throws
          when(() => mockCacheService.get<Map<String, dynamic>>(
                'ai_prediction_match_1',
              )).thenThrow(Exception('Hive corrupt'));

          // AI service returns prediction
          when(() => mockAIService.generateMatchPrediction(
                match: testMatch,
                homeTeam: null,
                awayTeam: null,
              )).thenAnswer((_) async => prediction);

          // Cache save also throws (should be handled gracefully)
          when(() => mockCacheService.set<Map<String, dynamic>>(
                any(),
                any(),
                duration: any(named: 'duration'),
              )).thenThrow(Exception('Hive write failed'));

          return cubit;
        },
        act: (cubit) => cubit.loadPrediction(testMatch),
        expect: () => [
          // Loading state
          isA<WorldCupAIState>()
              .having((s) => s.isLoading, 'isLoading', true),
          // Prediction loaded despite cache errors
          isA<WorldCupAIState>()
              .having((s) => s.hasPrediction('match_1'), 'hasPrediction', true),
        ],
      );
    });

    // -------------------------------------------------------
    // 21. WorldCupAIState helper methods
    // -------------------------------------------------------
    group('WorldCupAIState', () {
      test('hasPrediction returns false for expired predictions', () {
        final expired = createTestAIPrediction(
          matchId: 'match_1',
          generatedAt: DateTime.now().subtract(const Duration(hours: 25)),
          ttlMinutes: 1440,
        );
        final state = WorldCupAIState.initial().withPrediction(expired);
        expect(state.hasPrediction('match_1'), isFalse);
      });

      test('hasPrediction returns true for valid predictions', () {
        final valid = createTestAIPrediction(
          matchId: 'match_1',
          generatedAt: DateTime.now(),
          ttlMinutes: 1440,
        );
        final state = WorldCupAIState.initial().withPrediction(valid);
        expect(state.hasPrediction('match_1'), isTrue);
      });

      test('hasPrediction returns false for nonexistent matchId', () {
        final state = WorldCupAIState.initial();
        expect(state.hasPrediction('nonexistent'), isFalse);
      });

      test('isLoadingMatch checks both isLoading and matchId', () {
        final state = WorldCupAIState.initial().withLoading('match_1');
        expect(state.isLoadingMatch('match_1'), isTrue);
        expect(state.isLoadingMatch('match_2'), isFalse);
      });

      test('hasError checks matchId', () {
        final state = WorldCupAIState.initial().withError('match_1', 'err');
        expect(state.hasError('match_1'), isTrue);
        expect(state.hasError('match_2'), isFalse);
      });

      test('withPrediction clears loading and error', () {
        final loading = WorldCupAIState.initial().withLoading('match_1');
        final prediction = createTestAIPrediction(matchId: 'match_1');
        final withPred = loading.withPrediction(prediction);

        expect(withPred.isLoading, isFalse);
        expect(withPred.loadingMatchId, isNull);
        expect(withPred.error, isNull);
        expect(withPred.errorMatchId, isNull);
        expect(withPred.hasPrediction('match_1'), isTrue);
      });

      test('withoutPrediction removes prediction', () {
        final prediction = createTestAIPrediction(matchId: 'match_1');
        final state = WorldCupAIState.initial().withPrediction(prediction);
        final without = state.withoutPrediction('match_1');

        expect(without.predictions, isEmpty);
      });

      test('withLoading clears error', () {
        final withError =
            WorldCupAIState.initial().withError('match_1', 'Failed');
        final loading = withError.withLoading('match_2');

        expect(loading.isLoading, isTrue);
        expect(loading.loadingMatchId, 'match_2');
        expect(loading.error, isNull);
        expect(loading.errorMatchId, isNull);
      });

      test('withError clears loading', () {
        final loading = WorldCupAIState.initial().withLoading('match_1');
        final withErr = loading.withError('match_1', 'Something went wrong');

        expect(withErr.isLoading, isFalse);
        expect(withErr.loadingMatchId, isNull);
        expect(withErr.error, 'Something went wrong');
        expect(withErr.errorMatchId, 'match_1');
      });

      test('getPrediction returns null for nonexistent match', () {
        final state = WorldCupAIState.initial();
        expect(state.getPrediction('nonexistent'), isNull);
      });

      test('copyWith preserves fields when no overrides given', () {
        final prediction = createTestAIPrediction(matchId: 'match_1');
        final state = WorldCupAIState(
          predictions: {'match_1': prediction},
          isLoading: true,
          loadingMatchId: 'match_1',
          error: 'err',
          errorMatchId: 'match_1',
          isAvailable: false,
        );

        final copied = state.copyWith();
        expect(copied.predictions, state.predictions);
        expect(copied.isLoading, state.isLoading);
        expect(copied.loadingMatchId, state.loadingMatchId);
        expect(copied.error, state.error);
        expect(copied.errorMatchId, state.errorMatchId);
        expect(copied.isAvailable, state.isAvailable);
      });

      test('toString includes prediction count and loading/error info', () {
        final state = WorldCupAIState.initial();
        expect(state.toString(), contains('predictions: 0'));
        expect(state.toString(), contains('isLoading: false'));
      });
    });
  });
}
