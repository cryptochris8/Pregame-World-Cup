import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import '../features/worldcup/presentation/bloc/mock_repositories.dart';

// ---------------------------------------------------------------
// Mock repositories
// ---------------------------------------------------------------
class MockPredictionsRepository extends Mock
    implements PredictionsRepository {}

class MockWorldCupMatchRepository extends Mock
    implements WorldCupMatchRepository {}

// ---------------------------------------------------------------
// Test Data Helper for Predictions
// ---------------------------------------------------------------
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

  // =============================================================
  // Test Group: Predictions Flow
  // =============================================================
  group('Predictions Flow', () {
    // ---------------------------------------------------------
    // 1. Init loads predictions from repository
    // ---------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'init loads predictions from repository',
      build: () {
        final predictions = [
          createTestPrediction(
            predictionId: 'pred_1',
            matchId: 'match_1',
            predictedHomeScore: 2,
            predictedAwayScore: 1,
          ),
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
        ];
        final stats = PredictionStats(
          totalPredictions: 2,
          correctResults: 0,
          exactScores: 0,
          totalPoints: 0,
          pendingPredictions: 2,
        );

        when(() => mockPredictionsRepository.getAllPredictions())
            .thenAnswer((_) async => predictions);
        when(() => mockPredictionsRepository.getPredictionStats())
            .thenAnswer((_) async => stats);

        return cubit;
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        // First emission: loading
        isA<PredictionsState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        // Second emission: loaded with data
        isA<PredictionsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.predictions.length, 'predictions length', 2)
            .having(
              (s) => s.predictions.first.predictedHomeScore,
              'first prediction home score',
              2,
            ),
      ],
      verify: (_) {
        verify(() => mockPredictionsRepository.getAllPredictions()).called(1);
        verify(() => mockPredictionsRepository.getPredictionStats()).called(1);
      },
    );

    // ---------------------------------------------------------
    // 2. Save prediction updates state with new prediction
    // ---------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'save prediction updates state with new prediction',
      build: () {
        final newPrediction = createTestPrediction(
          predictionId: 'pred_new',
          matchId: 'match_new',
          predictedHomeScore: 3,
          predictedAwayScore: 0,
          homeTeamCode: 'GER',
          homeTeamName: 'Germany',
          awayTeamCode: 'FRA',
          awayTeamName: 'France',
        );
        when(() => mockPredictionsRepository.createPrediction(
              matchId: 'match_new',
              predictedHomeScore: 3,
              predictedAwayScore: 0,
              homeTeamCode: 'GER',
              homeTeamName: 'Germany',
              awayTeamCode: 'FRA',
              awayTeamName: 'France',
              matchDate: any(named: 'matchDate'),
            )).thenAnswer((_) async => newPrediction);

        return cubit;
      },
      seed: () => const PredictionsState(
        predictions: [],
        isLoading: false,
      ),
      act: (cubit) => cubit.savePrediction(
        matchId: 'match_new',
        homeScore: 3,
        awayScore: 0,
        homeTeamCode: 'GER',
        homeTeamName: 'Germany',
        awayTeamCode: 'FRA',
        awayTeamName: 'France',
        matchDate: DateTime(2026, 6, 15),
      ),
      expect: () => [
        // First: isSaving true
        isA<PredictionsState>()
            .having((s) => s.isSaving, 'isSaving', true)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        // Second: saved with new prediction
        isA<PredictionsState>()
            .having((s) => s.isSaving, 'isSaving', false)
            .having((s) => s.predictions.length, 'predictions length', 1)
            .having(
              (s) => s.predictions.first.matchId,
              'new prediction matchId',
              'match_new',
            )
            .having(
              (s) => s.predictions.first.predictedHomeScore,
              'predicted home score',
              3,
            )
            .having(
              (s) => s.successMessage,
              'successMessage',
              'Prediction saved!',
            ),
      ],
    );

    // ---------------------------------------------------------
    // 3. Save prediction for existing match updates in place
    // ---------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'save prediction for existing match updates in place (no duplicates)',
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
        predictions: [
          createTestPrediction(
            predictionId: 'pred_1',
            matchId: 'match_1',
            predictedHomeScore: 2,
            predictedAwayScore: 1,
          ),
          createTestPrediction(
            predictionId: 'pred_2',
            matchId: 'match_2',
            homeTeamCode: 'BRA',
            homeTeamName: 'Brazil',
            awayTeamCode: 'ARG',
            awayTeamName: 'Argentina',
          ),
        ],
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
        // Second: same list length, updated score
        isA<PredictionsState>()
            .having((s) => s.isSaving, 'isSaving', false)
            .having((s) => s.predictions.length, 'predictions length', 2)
            .having(
              (s) => s.predictions
                  .firstWhere((p) => p.matchId == 'match_1')
                  .predictedHomeScore,
              'updated home score',
              4,
            )
            .having(
              (s) => s.successMessage,
              'successMessage',
              'Prediction saved!',
            ),
      ],
    );

    // ---------------------------------------------------------
    // 4. Delete prediction removes from state
    // ---------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'delete prediction removes from state',
      build: () {
        when(() => mockPredictionsRepository.deletePrediction('pred_1'))
            .thenAnswer((_) async {});
        return cubit;
      },
      seed: () => PredictionsState(
        predictions: [
          createTestPrediction(
            predictionId: 'pred_1',
            matchId: 'match_1',
          ),
          createTestPrediction(
            predictionId: 'pred_2',
            matchId: 'match_2',
            homeTeamCode: 'BRA',
            homeTeamName: 'Brazil',
            awayTeamCode: 'ARG',
            awayTeamName: 'Argentina',
          ),
        ],
        isLoading: false,
      ),
      act: (cubit) => cubit.deletePrediction('pred_1'),
      expect: () => [
        isA<PredictionsState>()
            .having((s) => s.predictions.length, 'predictions length', 1)
            .having(
              (s) => s.predictions.any((p) => p.predictionId == 'pred_1'),
              'pred_1 removed',
              false,
            )
            .having(
              (s) => s.predictions.first.predictionId,
              'remaining prediction',
              'pred_2',
            )
            .having(
              (s) => s.successMessage,
              'successMessage',
              'Prediction deleted',
            ),
      ],
      verify: (_) {
        verify(() => mockPredictionsRepository.deletePrediction('pred_1'))
            .called(1);
      },
    );

    // ---------------------------------------------------------
    // 5. Evaluate predictions scores against completed matches
    // ---------------------------------------------------------
    blocTest<PredictionsCubit, PredictionsState>(
      'evaluate predictions scores against completed matches',
      build: () {
        // Set up completed matches
        final completedMatch = TestDataFactory.createMatch(
          matchId: 'match_1',
          status: MatchStatus.completed,
          homeScore: 2,
          awayScore: 1,
          homeTeamCode: 'USA',
          homeTeamName: 'United States',
          awayTeamCode: 'MEX',
          awayTeamName: 'Mexico',
        );
        final scheduledMatch = TestDataFactory.createMatch(
          matchId: 'match_2',
          status: MatchStatus.scheduled,
          homeTeamCode: 'BRA',
          homeTeamName: 'Brazil',
          awayTeamCode: 'ARG',
          awayTeamName: 'Argentina',
        );

        when(() => mockMatchRepository.getAllMatches())
            .thenAnswer((_) async => [completedMatch, scheduledMatch]);
        when(() => mockPredictionsRepository.evaluatePredictions(any()))
            .thenAnswer((_) async {});

        // After evaluation, return updated predictions with scores
        final evaluatedPredictions = [
          createTestPrediction(
            predictionId: 'pred_1',
            matchId: 'match_1',
            predictedHomeScore: 2,
            predictedAwayScore: 1,
            actualOutcome: PredictionOutcome.correct,
            resultCorrect: true,
            exactScoreCorrect: true,
            pointsEarned: 3,
          ),
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
        ];
        when(() => mockPredictionsRepository.getAllPredictions())
            .thenAnswer((_) async => evaluatedPredictions);

        return cubit;
      },
      seed: () => PredictionsState(
        predictions: [
          createTestPrediction(
            predictionId: 'pred_1',
            matchId: 'match_1',
            predictedHomeScore: 2,
            predictedAwayScore: 1,
          ),
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
        ],
        isLoading: false,
      ),
      act: (cubit) => cubit.evaluatePredictions(),
      expect: () => [
        // Evaluate emits updated predictions
        isA<PredictionsState>()
            .having((s) => s.predictions.length, 'predictions length', 2),
      ],
      verify: (_) {
        // Verify only completed matches were passed to evaluatePredictions
        verify(() => mockMatchRepository.getAllMatches()).called(1);
        final captured = verify(
          () => mockPredictionsRepository.evaluatePredictions(captureAny()),
        ).captured;
        final completedMatches = captured.first as List<WorldCupMatch>;
        expect(completedMatches.length, 1);
        expect(completedMatches.first.matchId, 'match_1');
        expect(completedMatches.first.status, MatchStatus.completed);

        // Verify predictions were reloaded after evaluation
        verify(() => mockPredictionsRepository.getAllPredictions()).called(1);
      },
    );

    // ---------------------------------------------------------
    // 6. Full prediction lifecycle
    //    Init -> Save -> Evaluate -> Check stats -> Delete -> Verify empty
    // ---------------------------------------------------------
    test('full prediction lifecycle', () async {
      // ---- Step 1: Init with empty predictions ----
      when(() => mockPredictionsRepository.getAllPredictions())
          .thenAnswer((_) async => []);
      when(() => mockPredictionsRepository.getPredictionStats())
          .thenAnswer((_) async => const PredictionStats());

      await cubit.init();

      expect(cubit.state.isLoading, false);
      expect(cubit.state.predictions, isEmpty);
      expect(cubit.state.stats.totalPredictions, 0);

      // ---- Step 2: Save a prediction ----
      final savedPrediction = createTestPrediction(
        predictionId: 'pred_lifecycle',
        matchId: 'match_lifecycle',
        predictedHomeScore: 2,
        predictedAwayScore: 0,
        homeTeamCode: 'USA',
        homeTeamName: 'United States',
        awayTeamCode: 'MEX',
        awayTeamName: 'Mexico',
      );
      when(() => mockPredictionsRepository.createPrediction(
            matchId: 'match_lifecycle',
            predictedHomeScore: 2,
            predictedAwayScore: 0,
            homeTeamCode: 'USA',
            homeTeamName: 'United States',
            awayTeamCode: 'MEX',
            awayTeamName: 'Mexico',
            matchDate: any(named: 'matchDate'),
          )).thenAnswer((_) async => savedPrediction);

      await cubit.savePrediction(
        matchId: 'match_lifecycle',
        homeScore: 2,
        awayScore: 0,
        homeTeamCode: 'USA',
        homeTeamName: 'United States',
        awayTeamCode: 'MEX',
        awayTeamName: 'Mexico',
        matchDate: DateTime(2026, 6, 20),
      );

      expect(cubit.state.predictions.length, 1);
      expect(cubit.state.predictions.first.matchId, 'match_lifecycle');
      expect(cubit.state.successMessage, 'Prediction saved!');
      expect(cubit.hasPredictionForMatch('match_lifecycle'), isTrue);

      // ---- Step 3: Evaluate predictions ----
      final completedMatch = TestDataFactory.createMatch(
        matchId: 'match_lifecycle',
        status: MatchStatus.completed,
        homeScore: 2,
        awayScore: 0,
      );
      when(() => mockMatchRepository.getAllMatches())
          .thenAnswer((_) async => [completedMatch]);
      when(() => mockPredictionsRepository.evaluatePredictions(any()))
          .thenAnswer((_) async {});

      final evaluatedPrediction = createTestPrediction(
        predictionId: 'pred_lifecycle',
        matchId: 'match_lifecycle',
        predictedHomeScore: 2,
        predictedAwayScore: 0,
        actualOutcome: PredictionOutcome.correct,
        resultCorrect: true,
        exactScoreCorrect: true,
        pointsEarned: 3,
      );
      when(() => mockPredictionsRepository.getAllPredictions())
          .thenAnswer((_) async => [evaluatedPrediction]);

      await cubit.evaluatePredictions();

      expect(cubit.state.predictions.length, 1);
      expect(cubit.state.predictions.first.resultCorrect, isTrue);
      expect(cubit.state.predictions.first.exactScoreCorrect, isTrue);
      expect(cubit.state.predictions.first.pointsEarned, 3);

      // ---- Step 4: Check stats are updated ----
      expect(cubit.state.stats.totalPredictions, 1);

      // ---- Step 5: Delete prediction ----
      when(() => mockPredictionsRepository.deletePrediction('pred_lifecycle'))
          .thenAnswer((_) async {});

      await cubit.deletePrediction('pred_lifecycle');

      expect(cubit.state.predictions, isEmpty);
      expect(cubit.state.successMessage, 'Prediction deleted');
      expect(cubit.hasPredictionForMatch('match_lifecycle'), isFalse);
    });

    // ---------------------------------------------------------
    // Additional: getPredictionForMatch returns correct prediction
    // ---------------------------------------------------------
    test('getPredictionForMatch returns correct prediction', () {
      final predictions = [
        createTestPrediction(predictionId: 'pred_1', matchId: 'match_1'),
        createTestPrediction(
          predictionId: 'pred_2',
          matchId: 'match_2',
          homeTeamCode: 'BRA',
          homeTeamName: 'Brazil',
          awayTeamCode: 'ARG',
          awayTeamName: 'Argentina',
        ),
      ];

      cubit.emit(PredictionsState(
        predictions: predictions,
        isLoading: false,
      ));

      final prediction = cubit.getPredictionForMatch('match_2');
      expect(prediction, isNotNull);
      expect(prediction!.predictionId, 'pred_2');
      expect(prediction.homeTeamCode, 'BRA');

      // Non-existent match returns null
      final missing = cubit.getPredictionForMatch('nonexistent');
      expect(missing, isNull);
    });

    // ---------------------------------------------------------
    // Additional: hasPredictionForMatch returns correct boolean
    // ---------------------------------------------------------
    test('hasPredictionForMatch returns correct boolean', () {
      cubit.emit(PredictionsState(
        predictions: [
          createTestPrediction(predictionId: 'pred_1', matchId: 'match_1'),
        ],
        isLoading: false,
      ));

      expect(cubit.hasPredictionForMatch('match_1'), isTrue);
      expect(cubit.hasPredictionForMatch('match_999'), isFalse);
    });

    // ---------------------------------------------------------
    // Additional: Save then update same match shows single entry
    // ---------------------------------------------------------
    test('save then update same match shows single entry', () async {
      // First save
      final firstPrediction = createTestPrediction(
        predictionId: 'pred_1',
        matchId: 'match_1',
        predictedHomeScore: 1,
        predictedAwayScore: 0,
      );
      when(() => mockPredictionsRepository.createPrediction(
            matchId: 'match_1',
            predictedHomeScore: 1,
            predictedAwayScore: 0,
            homeTeamCode: any(named: 'homeTeamCode'),
            homeTeamName: any(named: 'homeTeamName'),
            awayTeamCode: any(named: 'awayTeamCode'),
            awayTeamName: any(named: 'awayTeamName'),
            matchDate: any(named: 'matchDate'),
          )).thenAnswer((_) async => firstPrediction);

      cubit.emit(const PredictionsState(isLoading: false));

      await cubit.savePrediction(
        matchId: 'match_1',
        homeScore: 1,
        awayScore: 0,
      );

      expect(cubit.state.predictions.length, 1);
      expect(cubit.state.predictions.first.predictedHomeScore, 1);

      // Second save (update)
      final updatedPrediction = createTestPrediction(
        predictionId: 'pred_1',
        matchId: 'match_1',
        predictedHomeScore: 3,
        predictedAwayScore: 2,
      );
      when(() => mockPredictionsRepository.createPrediction(
            matchId: 'match_1',
            predictedHomeScore: 3,
            predictedAwayScore: 2,
            homeTeamCode: any(named: 'homeTeamCode'),
            homeTeamName: any(named: 'homeTeamName'),
            awayTeamCode: any(named: 'awayTeamCode'),
            awayTeamName: any(named: 'awayTeamName'),
            matchDate: any(named: 'matchDate'),
          )).thenAnswer((_) async => updatedPrediction);

      await cubit.savePrediction(
        matchId: 'match_1',
        homeScore: 3,
        awayScore: 2,
      );

      // Still only 1 prediction, but with updated score
      expect(cubit.state.predictions.length, 1);
      expect(cubit.state.predictions.first.predictedHomeScore, 3);
      expect(cubit.state.predictions.first.predictedAwayScore, 2);
    });
  });
}
