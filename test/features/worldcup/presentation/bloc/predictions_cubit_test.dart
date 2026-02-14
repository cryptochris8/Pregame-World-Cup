import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import 'mock_repositories.dart';

// Mock for PredictionsRepository
class MockPredictionsRepository extends Mock implements PredictionsRepository {}

// Test Data Factory Helpers for Predictions
MatchPrediction createTestPrediction({
  String predictionId = 'pred_1',
  String matchId = 'match_1',
  String? userId,
  int predictedHomeScore = 2,
  int predictedAwayScore = 1,
  PredictionOutcome predictedOutcome = PredictionOutcome.pending,
  PredictionOutcome? actualOutcome,
  int pointsEarned = 0,
  bool exactScoreCorrect = false,
  bool resultCorrect = false,
  bool tokenRewardGiven = false,
  int tokensAwarded = 0,
  DateTime? matchDate,
  String? homeTeamCode = 'USA',
  String? homeTeamName = 'United States',
  String? awayTeamCode = 'MEX',
  String? awayTeamName = 'Mexico',
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return MatchPrediction(
    predictionId: predictionId,
    matchId: matchId,
    userId: userId,
    predictedHomeScore: predictedHomeScore,
    predictedAwayScore: predictedAwayScore,
    predictedOutcome: predictedOutcome,
    actualOutcome: actualOutcome,
    pointsEarned: pointsEarned,
    exactScoreCorrect: exactScoreCorrect,
    resultCorrect: resultCorrect,
    tokenRewardGiven: tokenRewardGiven,
    tokensAwarded: tokensAwarded,
    matchDate: matchDate ?? DateTime(2026, 6, 11, 18, 0),
    homeTeamCode: homeTeamCode,
    homeTeamName: homeTeamName,
    awayTeamCode: awayTeamCode,
    awayTeamName: awayTeamName,
    createdAt: createdAt ?? DateTime(2026, 6, 10, 12, 0),
    updatedAt: updatedAt,
  );
}

PredictionStats createTestStats({
  int totalPredictions = 3,
  int correctResults = 1,
  int exactScores = 0,
  int totalPoints = 1,
  int pendingPredictions = 2,
}) {
  return PredictionStats(
    totalPredictions: totalPredictions,
    correctResults: correctResults,
    exactScores: exactScores,
    totalPoints: totalPoints,
    pendingPredictions: pendingPredictions,
  );
}

void main() {
  late MockPredictionsRepository mockPredictionsRepository;
  late MockWorldCupMatchRepository mockMatchRepository;
  late PredictionsCubit cubit;

  setUp(() {
    mockPredictionsRepository = MockPredictionsRepository();
    mockMatchRepository = MockWorldCupMatchRepository();

    // Default stubs for streams used in _subscribeToChanges
    when(() => mockPredictionsRepository.watchPredictions())
        .thenAnswer((_) => const Stream.empty());
    when(() => mockPredictionsRepository.watchPredictionStats())
        .thenAnswer((_) => const Stream.empty());

    cubit = PredictionsCubit(
      predictionsRepository: mockPredictionsRepository,
      matchRepository: mockMatchRepository,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('PredictionsCubit', () {
    final testPredictions = [
      createTestPrediction(predictionId: 'pred_1', matchId: 'match_1'),
      createTestPrediction(
        predictionId: 'pred_2',
        matchId: 'match_2',
        predictedHomeScore: 1,
        predictedAwayScore: 1,
        homeTeamCode: 'BRA',
        homeTeamName: 'Brazil',
        awayTeamCode: 'ARG',
        awayTeamName: 'Argentina',
      ),
      createTestPrediction(
        predictionId: 'pred_3',
        matchId: 'match_3',
        predictedHomeScore: 0,
        predictedAwayScore: 3,
        homeTeamCode: 'GER',
        homeTeamName: 'Germany',
        awayTeamCode: 'FRA',
        awayTeamName: 'France',
      ),
    ];
    final testStats = createTestStats();

    // -------------------------------------------------------
    // 1. Initial state is correct
    // -------------------------------------------------------
    test('initial state is correct', () {
      expect(cubit.state, equals(PredictionsState.initial()));
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.predictions, isEmpty);
      expect(cubit.state.stats, equals(const PredictionStats()));
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.successMessage, isNull);
      expect(cubit.state.selectedMatchId, isNull);
      expect(cubit.state.isSaving, isFalse);
    });

    // -------------------------------------------------------
    // 2. init() loads predictions and stats, emits loaded state
    // -------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'init() loads predictions and stats, emits loaded state',
      build: () {
        when(() => mockPredictionsRepository.getAllPredictions())
            .thenAnswer((_) async => testPredictions);
        when(() => mockPredictionsRepository.getPredictionStats())
            .thenAnswer((_) async => testStats);
        return cubit;
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        // First emission: isLoading true, clearError
        isA<PredictionsState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        // Second emission: loaded with data
        isA<PredictionsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.predictions.length, 'predictions length', 3)
            .having((s) => s.stats, 'stats', testStats),
      ],
      verify: (_) {
        verify(() => mockPredictionsRepository.getAllPredictions()).called(1);
        verify(() => mockPredictionsRepository.getPredictionStats()).called(1);
        verify(() => mockPredictionsRepository.watchPredictions()).called(1);
        verify(() => mockPredictionsRepository.watchPredictionStats()).called(1);
      },
    );

    // -------------------------------------------------------
    // 3. init() handles errors
    // -------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'init() handles errors gracefully',
      build: () {
        when(() => mockPredictionsRepository.getAllPredictions())
            .thenThrow(Exception('Network error'));
        return cubit;
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        isA<PredictionsState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<PredictionsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'error contains message',
              contains('Failed to load predictions'),
            ),
      ],
    );

    // -------------------------------------------------------
    // 4. savePrediction creates new prediction
    // -------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'savePrediction creates new prediction and adds to list',
      build: () {
        final newPrediction = createTestPrediction(
          predictionId: 'pred_new',
          matchId: 'match_new',
          predictedHomeScore: 3,
          predictedAwayScore: 0,
        );
        when(() => mockPredictionsRepository.createPrediction(
              matchId: 'match_new',
              predictedHomeScore: 3,
              predictedAwayScore: 0,
              homeTeamCode: 'USA',
              homeTeamName: 'United States',
              awayTeamCode: 'MEX',
              awayTeamName: 'Mexico',
              matchDate: any(named: 'matchDate'),
            )).thenAnswer((_) async => newPrediction);
        return cubit;
      },
      seed: () => PredictionsState(
        predictions: [testPredictions[0]],
        stats: const PredictionStats(totalPredictions: 1),
        isLoading: false,
      ),
      act: (cubit) => cubit.savePrediction(
        matchId: 'match_new',
        homeScore: 3,
        awayScore: 0,
        homeTeamCode: 'USA',
        homeTeamName: 'United States',
        awayTeamCode: 'MEX',
        awayTeamName: 'Mexico',
        matchDate: DateTime(2026, 6, 15),
      ),
      expect: () => [
        // First: isSaving true
        isA<PredictionsState>()
            .having((s) => s.isSaving, 'isSaving', true)
            .having((s) => s.errorMessage, 'errorMessage', isNull)
            .having((s) => s.successMessage, 'successMessage', isNull),
        // Second: saved with new prediction added
        isA<PredictionsState>()
            .having((s) => s.isSaving, 'isSaving', false)
            .having((s) => s.predictions.length, 'predictions length', 2)
            .having(
              (s) => s.predictions.any((p) => p.matchId == 'match_new'),
              'has new prediction',
              true,
            )
            .having((s) => s.successMessage, 'successMessage', 'Prediction saved!'),
      ],
    );

    // -------------------------------------------------------
    // 5. savePrediction updates existing prediction (same matchId)
    // -------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'savePrediction updates existing prediction when matchId already exists',
      build: () {
        final updatedPrediction = createTestPrediction(
          predictionId: 'pred_1',
          matchId: 'match_1',
          predictedHomeScore: 4,
          predictedAwayScore: 0,
        );
        when(() => mockPredictionsRepository.createPrediction(
              matchId: 'match_1',
              predictedHomeScore: 4,
              predictedAwayScore: 0,
              homeTeamCode: any(named: 'homeTeamCode'),
              homeTeamName: any(named: 'homeTeamName'),
              awayTeamCode: any(named: 'awayTeamCode'),
              awayTeamName: any(named: 'awayTeamName'),
              matchDate: any(named: 'matchDate'),
            )).thenAnswer((_) async => updatedPrediction);
        return cubit;
      },
      seed: () => PredictionsState(
        predictions: testPredictions,
        stats: testStats,
        isLoading: false,
      ),
      act: (cubit) => cubit.savePrediction(
        matchId: 'match_1',
        homeScore: 4,
        awayScore: 0,
      ),
      expect: () => [
        // First: isSaving true
        isA<PredictionsState>()
            .having((s) => s.isSaving, 'isSaving', true),
        // Second: same list length but updated prediction
        isA<PredictionsState>()
            .having((s) => s.isSaving, 'isSaving', false)
            .having((s) => s.predictions.length, 'predictions length', 3)
            .having(
              (s) => s.predictions
                  .firstWhere((p) => p.matchId == 'match_1')
                  .predictedHomeScore,
              'updated home score',
              4,
            )
            .having((s) => s.successMessage, 'successMessage', 'Prediction saved!'),
      ],
    );

    // -------------------------------------------------------
    // 6. savePrediction handles errors
    // -------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'savePrediction handles errors',
      build: () {
        when(() => mockPredictionsRepository.createPrediction(
              matchId: any(named: 'matchId'),
              predictedHomeScore: any(named: 'predictedHomeScore'),
              predictedAwayScore: any(named: 'predictedAwayScore'),
              homeTeamCode: any(named: 'homeTeamCode'),
              homeTeamName: any(named: 'homeTeamName'),
              awayTeamCode: any(named: 'awayTeamCode'),
              awayTeamName: any(named: 'awayTeamName'),
              matchDate: any(named: 'matchDate'),
            )).thenThrow(Exception('Save failed'));
        return cubit;
      },
      act: (cubit) => cubit.savePrediction(
        matchId: 'match_1',
        homeScore: 2,
        awayScore: 1,
      ),
      expect: () => [
        isA<PredictionsState>()
            .having((s) => s.isSaving, 'isSaving', true),
        isA<PredictionsState>()
            .having((s) => s.isSaving, 'isSaving', false)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'error contains message',
              contains('Failed to save prediction'),
            ),
      ],
    );

    // -------------------------------------------------------
    // 7. deletePrediction removes prediction from list
    // -------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'deletePrediction removes prediction by predictionId',
      build: () {
        when(() => mockPredictionsRepository.deletePrediction('pred_2'))
            .thenAnswer((_) async {});
        return cubit;
      },
      seed: () => PredictionsState(
        predictions: testPredictions,
        stats: testStats,
        isLoading: false,
      ),
      act: (cubit) => cubit.deletePrediction('pred_2'),
      expect: () => [
        isA<PredictionsState>()
            .having((s) => s.predictions.length, 'predictions length', 2)
            .having(
              (s) => s.predictions.any((p) => p.predictionId == 'pred_2'),
              'pred_2 removed',
              false,
            )
            .having((s) => s.successMessage, 'successMessage', 'Prediction deleted'),
      ],
      verify: (_) {
        verify(() => mockPredictionsRepository.deletePrediction('pred_2')).called(1);
      },
    );

    blocTest<PredictionsCubit, PredictionsState>(
      'deletePrediction handles errors',
      build: () {
        when(() => mockPredictionsRepository.deletePrediction('pred_1'))
            .thenThrow(Exception('Delete failed'));
        return cubit;
      },
      seed: () => PredictionsState(
        predictions: testPredictions,
        isLoading: false,
      ),
      act: (cubit) => cubit.deletePrediction('pred_1'),
      expect: () => [
        isA<PredictionsState>()
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'error contains message',
              contains('Failed to delete prediction'),
            ),
      ],
    );

    // -------------------------------------------------------
    // 8. deletePredictionForMatch removes by matchId
    // -------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'deletePredictionForMatch removes prediction by matchId',
      build: () {
        when(() => mockPredictionsRepository.deletePredictionForMatch('match_3'))
            .thenAnswer((_) async {});
        return cubit;
      },
      seed: () => PredictionsState(
        predictions: testPredictions,
        stats: testStats,
        isLoading: false,
      ),
      act: (cubit) => cubit.deletePredictionForMatch('match_3'),
      expect: () => [
        isA<PredictionsState>()
            .having((s) => s.predictions.length, 'predictions length', 2)
            .having(
              (s) => s.predictions.any((p) => p.matchId == 'match_3'),
              'match_3 removed',
              false,
            )
            .having((s) => s.successMessage, 'successMessage', 'Prediction deleted'),
      ],
      verify: (_) {
        verify(() => mockPredictionsRepository.deletePredictionForMatch('match_3'))
            .called(1);
      },
    );

    blocTest<PredictionsCubit, PredictionsState>(
      'deletePredictionForMatch handles errors',
      build: () {
        when(() => mockPredictionsRepository.deletePredictionForMatch('match_1'))
            .thenThrow(Exception('Delete failed'));
        return cubit;
      },
      seed: () => PredictionsState(
        predictions: testPredictions,
        isLoading: false,
      ),
      act: (cubit) => cubit.deletePredictionForMatch('match_1'),
      expect: () => [
        isA<PredictionsState>()
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'error contains message',
              contains('Failed to delete prediction'),
            ),
      ],
    );

    // -------------------------------------------------------
    // 9. evaluatePredictions fetches completed matches and evaluates
    // -------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'evaluatePredictions fetches completed matches and evaluates',
      build: () {
        final completedMatch = TestDataFactory.createMatch(
          matchId: 'match_1',
          status: MatchStatus.completed,
          homeScore: 2,
          awayScore: 1,
        );
        final scheduledMatch = TestDataFactory.createMatch(
          matchId: 'match_2',
          status: MatchStatus.scheduled,
        );
        when(() => mockMatchRepository.getAllMatches())
            .thenAnswer((_) async => [completedMatch, scheduledMatch]);
        when(() => mockPredictionsRepository.evaluatePredictions(
              any(),
            )).thenAnswer((_) async {});

        final evaluatedPredictions = [
          createTestPrediction(
            predictionId: 'pred_1',
            matchId: 'match_1',
            actualOutcome: PredictionOutcome.correct,
            resultCorrect: true,
            pointsEarned: 1,
          ),
          createTestPrediction(
            predictionId: 'pred_2',
            matchId: 'match_2',
          ),
        ];
        when(() => mockPredictionsRepository.getAllPredictions())
            .thenAnswer((_) async => evaluatedPredictions);

        return cubit;
      },
      seed: () => PredictionsState(
        predictions: testPredictions.sublist(0, 2),
        isLoading: false,
      ),
      act: (cubit) => cubit.evaluatePredictions(),
      expect: () => [
        isA<PredictionsState>()
            .having((s) => s.predictions.length, 'predictions length', 2),
      ],
      verify: (_) {
        verify(() => mockMatchRepository.getAllMatches()).called(1);
        verify(() => mockPredictionsRepository.evaluatePredictions(
              any(),
            )).called(1);
        // getAllPredictions called once during evaluate (reload)
        verify(() => mockPredictionsRepository.getAllPredictions()).called(1);
      },
    );

    // -------------------------------------------------------
    // 10. evaluatePredictions does nothing when matchRepository is null
    // -------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'evaluatePredictions does nothing when matchRepository is null',
      build: () {
        return PredictionsCubit(
          predictionsRepository: mockPredictionsRepository,
          matchRepository: null,
        );
      },
      act: (cubit) => cubit.evaluatePredictions(),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockMatchRepository.getAllMatches());
      },
    );

    // -------------------------------------------------------
    // 11. selectMatchForPrediction sets selectedMatchId
    // -------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'selectMatchForPrediction sets selectedMatchId',
      build: () => cubit,
      seed: () => const PredictionsState(isLoading: false),
      act: (cubit) => cubit.selectMatchForPrediction('match_42'),
      expect: () => [
        isA<PredictionsState>()
            .having((s) => s.selectedMatchId, 'selectedMatchId', 'match_42'),
      ],
    );

    // -------------------------------------------------------
    // 12. clearSelectedMatch clears selection
    // -------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'clearSelectedMatch clears selection',
      build: () => cubit,
      seed: () => const PredictionsState(
        selectedMatchId: 'match_42',
        isLoading: false,
      ),
      act: (cubit) => cubit.clearSelectedMatch(),
      expect: () => [
        isA<PredictionsState>()
            .having((s) => s.selectedMatchId, 'selectedMatchId', isNull),
      ],
    );

    // -------------------------------------------------------
    // 13. clearAllPredictions empties list
    // -------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'clearAllPredictions empties list and resets stats',
      build: () {
        when(() => mockPredictionsRepository.clearAllPredictions())
            .thenAnswer((_) async {});
        return cubit;
      },
      seed: () => PredictionsState(
        predictions: testPredictions,
        stats: testStats,
        isLoading: false,
      ),
      act: (cubit) => cubit.clearAllPredictions(),
      expect: () => [
        isA<PredictionsState>()
            .having((s) => s.predictions, 'predictions', isEmpty)
            .having((s) => s.stats, 'stats', const PredictionStats())
            .having((s) => s.successMessage, 'successMessage', 'All predictions cleared'),
      ],
      verify: (_) {
        verify(() => mockPredictionsRepository.clearAllPredictions()).called(1);
      },
    );

    blocTest<PredictionsCubit, PredictionsState>(
      'clearAllPredictions handles errors',
      build: () {
        when(() => mockPredictionsRepository.clearAllPredictions())
            .thenThrow(Exception('Clear failed'));
        return cubit;
      },
      seed: () => PredictionsState(
        predictions: testPredictions,
        isLoading: false,
      ),
      act: (cubit) => cubit.clearAllPredictions(),
      expect: () => [
        isA<PredictionsState>()
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'error contains message',
              contains('Failed to clear predictions'),
            ),
      ],
    );

    // -------------------------------------------------------
    // 14. getPredictionForMatch returns prediction
    // -------------------------------------------------------
    test('getPredictionForMatch returns prediction when it exists', () {
      cubit.emit(PredictionsState(
        predictions: testPredictions,
        isLoading: false,
      ));

      final prediction = cubit.getPredictionForMatch('match_2');
      expect(prediction, isNotNull);
      expect(prediction!.matchId, 'match_2');
      expect(prediction.predictionId, 'pred_2');
      expect(prediction.predictedHomeScore, 1);
      expect(prediction.predictedAwayScore, 1);
    });

    test('getPredictionForMatch returns null when prediction does not exist', () {
      cubit.emit(PredictionsState(
        predictions: testPredictions,
        isLoading: false,
      ));

      final prediction = cubit.getPredictionForMatch('nonexistent_match');
      expect(prediction, isNull);
    });

    // -------------------------------------------------------
    // 15. hasPredictionForMatch returns boolean
    // -------------------------------------------------------
    test('hasPredictionForMatch returns true when prediction exists', () {
      cubit.emit(PredictionsState(
        predictions: testPredictions,
        isLoading: false,
      ));

      expect(cubit.hasPredictionForMatch('match_1'), isTrue);
      expect(cubit.hasPredictionForMatch('match_2'), isTrue);
      expect(cubit.hasPredictionForMatch('match_3'), isTrue);
    });

    test('hasPredictionForMatch returns false when prediction does not exist', () {
      cubit.emit(PredictionsState(
        predictions: testPredictions,
        isLoading: false,
      ));

      expect(cubit.hasPredictionForMatch('nonexistent_match'), isFalse);
    });

    test('hasPredictionForMatch returns false when predictions list is empty', () {
      cubit.emit(const PredictionsState(
        predictions: [],
        isLoading: false,
      ));

      expect(cubit.hasPredictionForMatch('match_1'), isFalse);
    });

    // -------------------------------------------------------
    // 16. clearError clears error
    // -------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'clearError clears error message',
      build: () => cubit,
      seed: () => const PredictionsState(
        errorMessage: 'Something went wrong',
        isLoading: false,
      ),
      act: (cubit) => cubit.clearError(),
      expect: () => [
        isA<PredictionsState>()
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    // -------------------------------------------------------
    // 17. clearSuccess clears success
    // -------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'clearSuccess clears success message',
      build: () => cubit,
      seed: () => const PredictionsState(
        successMessage: 'Prediction saved!',
        isLoading: false,
      ),
      act: (cubit) => cubit.clearSuccess(),
      expect: () => [
        isA<PredictionsState>()
            .having((s) => s.successMessage, 'successMessage', isNull),
      ],
    );

    // -------------------------------------------------------
    // Additional stream subscription tests
    // -------------------------------------------------------
    group('stream subscriptions', () {
      blocTest<PredictionsCubit, PredictionsState>(
        'updates predictions when stream emits new data',
        build: () {
          final streamController = StreamController<List<MatchPrediction>>();
          final statsStreamController = StreamController<PredictionStats>();

          when(() => mockPredictionsRepository.getAllPredictions())
              .thenAnswer((_) async => []);
          when(() => mockPredictionsRepository.getPredictionStats())
              .thenAnswer((_) async => const PredictionStats());
          when(() => mockPredictionsRepository.watchPredictions())
              .thenAnswer((_) => streamController.stream);
          when(() => mockPredictionsRepository.watchPredictionStats())
              .thenAnswer((_) => statsStreamController.stream);

          // Schedule stream events after init completes
          Future.delayed(const Duration(milliseconds: 100), () {
            streamController.add(testPredictions);
          });
          Future.delayed(const Duration(milliseconds: 200), () {
            streamController.close();
            statsStreamController.close();
          });

          return cubit;
        },
        act: (cubit) async {
          await cubit.init();
          // Allow time for stream events
          await Future.delayed(const Duration(milliseconds: 150));
        },
        expect: () => [
          // init: isLoading true
          isA<PredictionsState>()
              .having((s) => s.isLoading, 'isLoading', true),
          // init: loaded with empty data
          isA<PredictionsState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.predictions, 'predictions', isEmpty),
          // stream: updated predictions
          isA<PredictionsState>()
              .having((s) => s.predictions.length, 'predictions length', 3),
        ],
      );

      blocTest<PredictionsCubit, PredictionsState>(
        'updates stats when stats stream emits new data',
        build: () {
          final predictionsStreamController =
              StreamController<List<MatchPrediction>>();
          final statsStreamController = StreamController<PredictionStats>();

          when(() => mockPredictionsRepository.getAllPredictions())
              .thenAnswer((_) async => []);
          when(() => mockPredictionsRepository.getPredictionStats())
              .thenAnswer((_) async => const PredictionStats());
          when(() => mockPredictionsRepository.watchPredictions())
              .thenAnswer((_) => predictionsStreamController.stream);
          when(() => mockPredictionsRepository.watchPredictionStats())
              .thenAnswer((_) => statsStreamController.stream);

          final newStats = createTestStats(
            totalPredictions: 10,
            correctResults: 5,
            totalPoints: 8,
          );

          Future.delayed(const Duration(milliseconds: 100), () {
            statsStreamController.add(newStats);
          });
          Future.delayed(const Duration(milliseconds: 200), () {
            predictionsStreamController.close();
            statsStreamController.close();
          });

          return cubit;
        },
        act: (cubit) async {
          await cubit.init();
          await Future.delayed(const Duration(milliseconds: 150));
        },
        expect: () => [
          // init: isLoading true
          isA<PredictionsState>()
              .having((s) => s.isLoading, 'isLoading', true),
          // init: loaded with empty data
          isA<PredictionsState>()
              .having((s) => s.isLoading, 'isLoading', false),
          // stream: updated stats
          isA<PredictionsState>()
              .having((s) => s.stats.totalPredictions, 'totalPredictions', 10)
              .having((s) => s.stats.correctResults, 'correctResults', 5)
              .having((s) => s.stats.totalPoints, 'totalPoints', 8),
        ],
      );
    });

    // -------------------------------------------------------
    // Additional edge case tests
    // -------------------------------------------------------
    group('edge cases', () {
      blocTest<PredictionsCubit, PredictionsState>(
        'evaluatePredictions handles errors silently',
        build: () {
          when(() => mockMatchRepository.getAllMatches())
              .thenThrow(Exception('Network error'));
          return cubit;
        },
        seed: () => PredictionsState(
          predictions: testPredictions,
          isLoading: false,
        ),
        act: (cubit) => cubit.evaluatePredictions(),
        // The cubit catches the error silently - no state changes emitted
        expect: () => [],
      );

      blocTest<PredictionsCubit, PredictionsState>(
        'evaluatePredictions passes only completed matches to repository',
        build: () {
          final matches = [
            TestDataFactory.createMatch(
              matchId: 'match_completed',
              status: MatchStatus.completed,
              homeScore: 2,
              awayScore: 1,
            ),
            TestDataFactory.createMatch(
              matchId: 'match_scheduled',
              status: MatchStatus.scheduled,
            ),
            TestDataFactory.createMatch(
              matchId: 'match_inprogress',
              status: MatchStatus.inProgress,
            ),
          ];
          when(() => mockMatchRepository.getAllMatches())
              .thenAnswer((_) async => matches);
          when(() => mockPredictionsRepository.evaluatePredictions(any()))
              .thenAnswer((_) async {});
          when(() => mockPredictionsRepository.getAllPredictions())
              .thenAnswer((_) async => []);

          return cubit;
        },
        act: (cubit) => cubit.evaluatePredictions(),
        verify: (_) {
          final captured = verify(
            () => mockPredictionsRepository.evaluatePredictions(captureAny()),
          ).captured;
          final completedMatches = captured.first as List<WorldCupMatch>;
          expect(completedMatches.length, 1);
          expect(completedMatches.first.matchId, 'match_completed');
        },
      );

      blocTest<PredictionsCubit, PredictionsState>(
        'multiple rapid savePrediction calls work correctly',
        build: () {
          when(() => mockPredictionsRepository.createPrediction(
                matchId: any(named: 'matchId'),
                predictedHomeScore: any(named: 'predictedHomeScore'),
                predictedAwayScore: any(named: 'predictedAwayScore'),
                homeTeamCode: any(named: 'homeTeamCode'),
                homeTeamName: any(named: 'homeTeamName'),
                awayTeamCode: any(named: 'awayTeamCode'),
                awayTeamName: any(named: 'awayTeamName'),
                matchDate: any(named: 'matchDate'),
              )).thenAnswer((invocation) async {
            final matchId =
                invocation.namedArguments[const Symbol('matchId')] as String;
            return createTestPrediction(
              predictionId: 'pred_$matchId',
              matchId: matchId,
            );
          });
          return cubit;
        },
        seed: () => const PredictionsState(isLoading: false),
        act: (cubit) async {
          await cubit.savePrediction(
            matchId: 'match_A',
            homeScore: 1,
            awayScore: 0,
          );
          await cubit.savePrediction(
            matchId: 'match_B',
            homeScore: 2,
            awayScore: 2,
          );
        },
        expect: () => [
          // First save: isSaving true
          isA<PredictionsState>().having((s) => s.isSaving, 'isSaving', true),
          // First save: complete
          isA<PredictionsState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.predictions.length, 'length', 1),
          // Second save: isSaving true
          isA<PredictionsState>().having((s) => s.isSaving, 'isSaving', true),
          // Second save: complete
          isA<PredictionsState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.predictions.length, 'length', 2),
        ],
      );
    });
  });
}
