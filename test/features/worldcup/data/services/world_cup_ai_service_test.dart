import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/local_prediction_engine.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/world_cup_ai_service.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/entities.dart';

// ==================== MOCKS ====================

class MockLocalPredictionEngine extends Mock implements LocalPredictionEngine {}

// ==================== FAKE CLASSES ====================

class FakeWorldCupMatch extends Fake implements WorldCupMatch {}

class FakeNationalTeam extends Fake implements NationalTeam {}

// ==================== TEST DATA ====================

final _futureMatchDate = DateTime.utc(2026, 7, 15, 20, 0, 0);

WorldCupMatch _createMatch({
  String matchId = 'match_1',
  String homeTeamName = 'Brazil',
  String awayTeamName = 'Argentina',
  String? homeTeamCode = 'BRA',
  String? awayTeamCode = 'ARG',
}) {
  return WorldCupMatch(
    matchId: matchId,
    matchNumber: 1,
    stage: MatchStage.groupStage,
    homeTeamName: homeTeamName,
    awayTeamName: awayTeamName,
    homeTeamCode: homeTeamCode,
    awayTeamCode: awayTeamCode,
    dateTimeUtc: _futureMatchDate,
  );
}

NationalTeam _createTeam({
  String teamCode = 'BRA',
  String countryName = 'Brazil',
  String shortName = 'Brazil',
  int? worldRanking = 3,
}) {
  return NationalTeam(
    teamCode: teamCode,
    countryName: countryName,
    shortName: shortName,
    flagUrl: 'https://example.com/flags/$teamCode.png',
    confederation: Confederation.conmebol,
    worldRanking: worldRanking,
  );
}

AIMatchPrediction _createPrediction({
  String matchId = 'match_1',
  int homeScore = 2,
  int awayScore = 1,
  int confidence = 65,
  String quickInsight = 'Brazil 2-1 (65%)',
  List<String> keyFactors = const ['Home advantage', 'World ranking'],
}) {
  return AIMatchPrediction(
    matchId: matchId,
    predictedOutcome: homeScore > awayScore
        ? AIPredictedOutcome.homeWin
        : homeScore < awayScore
            ? AIPredictedOutcome.awayWin
            : AIPredictedOutcome.draw,
    predictedHomeScore: homeScore,
    predictedAwayScore: awayScore,
    confidence: confidence,
    homeWinProbability: 55,
    drawProbability: 25,
    awayWinProbability: 20,
    keyFactors: keyFactors,
    analysis: 'Test analysis for $matchId',
    quickInsight: quickInsight,
    provider: 'Local',
    generatedAt: DateTime.now(),
  );
}

// ==================== TESTS ====================

void main() {
  late MockLocalPredictionEngine mockEngine;
  late WorldCupAIService service;

  setUpAll(() {
    registerFallbackValue(FakeWorldCupMatch());
    registerFallbackValue(FakeNationalTeam());
  });

  setUp(() {
    mockEngine = MockLocalPredictionEngine();
    service = WorldCupAIService(localEngine: mockEngine);
  });

  group('WorldCupAIService', () {
    // =========================================================================
    // Constructor
    // =========================================================================
    test('creates instance with required localEngine', () {
      expect(service, isNotNull);
    });

    test('isAvailable always returns true', () {
      expect(service.isAvailable, true);
    });

    // =========================================================================
    // generateMatchPrediction tests
    // =========================================================================
    group('generateMatchPrediction', () {
      test('returns prediction from local engine', () async {
        final match = _createMatch();
        final homeTeam = _createTeam(teamCode: 'BRA', worldRanking: 3);
        final awayTeam =
            _createTeam(teamCode: 'ARG', shortName: 'Argentina', worldRanking: 1);
        final expectedPrediction = _createPrediction();

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenAnswer((_) async => expectedPrediction);

        final result = await service.generateMatchPrediction(
          match: match,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
        );

        expect(result.matchId, 'match_1');
        expect(result.predictedHomeScore, 2);
        expect(result.predictedAwayScore, 1);
        expect(result.confidence, 65);
        expect(result.provider, 'Local');
      });

      test('calls local engine with correct parameters', () async {
        final match = _createMatch();
        final homeTeam = _createTeam();
        final awayTeam = _createTeam(teamCode: 'ARG', shortName: 'Argentina');
        final prediction = _createPrediction();

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenAnswer((_) async => prediction);

        await service.generateMatchPrediction(
          match: match,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
        );

        verify(() => mockEngine.generatePrediction(
              match: match,
              homeTeam: homeTeam,
              awayTeam: awayTeam,
            )).called(1);
      });

      test('returns fallback prediction when engine throws', () async {
        final match = _createMatch();
        final homeTeam = _createTeam(worldRanking: 5);
        final awayTeam = _createTeam(
          teamCode: 'ARG',
          shortName: 'Argentina',
          worldRanking: 1,
        );

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenThrow(Exception('Engine failure'));

        final result = await service.generateMatchPrediction(
          match: match,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
        );

        expect(result.matchId, 'match_1');
        expect(result.provider, 'Fallback');
        expect(result.confidence, 40);
        expect(result.keyFactors, contains('World Rankings comparison'));
      });

      test('fallback uses team rankings to determine prediction', () async {
        final match = _createMatch(
          homeTeamName: 'Lower Ranked',
          awayTeamName: 'Higher Ranked',
        );
        final homeTeam = _createTeam(worldRanking: 50);
        final awayTeam = _createTeam(
          teamCode: 'ARG',
          shortName: 'Higher Ranked',
          worldRanking: 5,
        );

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenThrow(Exception('Engine failure'));

        final result = await service.generateMatchPrediction(
          match: match,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
        );

        // Away team ranked higher (lower number), so away should be favored
        expect(result.predictedOutcome, AIPredictedOutcome.awayWin);
      });

      test('works with null teams (no rankings)', () async {
        final match = _createMatch();

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenThrow(Exception('Engine failure'));

        final result = await service.generateMatchPrediction(
          match: match,
          homeTeam: null,
          awayTeam: null,
        );

        // With null teams, both default to ranking 50 -> equal
        expect(result.provider, 'Fallback');
        expect(result.predictedOutcome, AIPredictedOutcome.draw);
      });
    });

    // =========================================================================
    // generateQuickInsight tests
    // =========================================================================
    group('generateQuickInsight', () {
      test('returns quickInsight from prediction', () async {
        final match = _createMatch();
        final prediction = _createPrediction(quickInsight: 'Brazil 2-1 (65%)');

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenAnswer((_) async => prediction);

        final result = await service.generateQuickInsight(
          match: match,
        );

        expect(result, 'Brazil 2-1 (65%)');
      });

      test('returns fallback insight when engine throws', () async {
        final match = _createMatch(
          homeTeamName: 'Brazil',
          awayTeamName: 'Mexico',
        );
        final homeTeam = _createTeam(worldRanking: 3, shortName: 'Brazil');
        final awayTeam = _createTeam(
          teamCode: 'MEX',
          shortName: 'Mexico',
          worldRanking: 15,
        );

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenThrow(Exception('Engine failure'));

        final result = await service.generateQuickInsight(
          match: match,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
        );

        // homeRank(3) < awayRank(15) - 10(=5), difference is 12 > 10
        expect(result, contains('Brazil'));
        expect(result, contains('2-1'));
        expect(result, contains('60%'));
      });

      test('fallback for away team favored', () async {
        final match = _createMatch();
        final homeTeam = _createTeam(worldRanking: 40);
        final awayTeam = _createTeam(
          teamCode: 'ARG',
          shortName: 'Argentina',
          worldRanking: 1,
        );

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenThrow(Exception('Engine failure'));

        final result = await service.generateQuickInsight(
          match: match,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
        );

        // awayRank(1) < homeRank(40) - 10(=30)
        expect(result, contains('Argentina'));
        expect(result, contains('1-2'));
      });

      test('fallback for evenly matched teams', () async {
        final match = _createMatch();
        final homeTeam = _createTeam(worldRanking: 10);
        final awayTeam = _createTeam(
          teamCode: 'ARG',
          shortName: 'Argentina',
          worldRanking: 12,
        );

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenThrow(Exception('Engine failure'));

        final result = await service.generateQuickInsight(
          match: match,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
        );

        // Ranks within 10 of each other
        expect(result, contains('Draw'));
        expect(result, contains('1-1'));
        expect(result, contains('45%'));
      });

      test('fallback with null teams uses default rank 50', () async {
        final match = _createMatch();

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenThrow(Exception('Engine failure'));

        final result = await service.generateQuickInsight(
          match: match,
        );

        // Both default to 50, so evenly matched
        expect(result, contains('Draw'));
      });
    });

    // =========================================================================
    // suggestPrediction tests
    // =========================================================================
    group('suggestPrediction', () {
      test('returns suggestion map from prediction', () async {
        final match = _createMatch();
        final prediction = _createPrediction(
          homeScore: 2,
          awayScore: 0,
          confidence: 70,
          keyFactors: ['Strong home support'],
        );

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenAnswer((_) async => prediction);

        final result = await service.suggestPrediction(match: match);

        expect(result['homeScore'], 2);
        expect(result['awayScore'], 0);
        expect(result['confidence'], 70);
        expect(result['reasoning'], 'Strong home support');
        expect(result['provider'], 'Local');
      });

      test('uses "Based on team analysis" when no key factors', () async {
        final match = _createMatch();
        final prediction = _createPrediction(keyFactors: []);

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenAnswer((_) async => prediction);

        final result = await service.suggestPrediction(match: match);

        expect(result['reasoning'], 'Based on team analysis');
      });

      test('returns fallback suggestion when engine throws', () async {
        // When engine throws, generateMatchPrediction catches internally
        // and returns AIMatchPrediction.fallback(). suggestPrediction wraps
        // the fallback prediction into a map using keyFactors.first as reasoning.
        final match = _createMatch();
        final homeTeam = _createTeam(worldRanking: 3);
        final awayTeam = _createTeam(
          teamCode: 'ARG',
          shortName: 'Argentina',
          worldRanking: 1,
        );

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenThrow(Exception('Engine failure'));

        final result = await service.suggestPrediction(
          match: match,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
        );

        expect(result['provider'], 'Fallback');
        expect(result['confidence'], 40);
        // Fallback uses AIMatchPrediction.fallback which has
        // keyFactors: ['World Rankings comparison', ...]
        expect(result['reasoning'], 'World Rankings comparison');
        // homeRank=3, awayRank=1: away team ranked higher, diff=2
        // awayScore = diff > 20 ? 2 : 1 -> 1
        // homeScore = diff > 30 ? 0 : 1 -> 1
        expect(result['homeScore'], 1);
        expect(result['awayScore'], 1);
      });

      test('fallback suggestion for home team favored (large diff)', () async {
        // Need a large ranking difference to get different scores
        final match = _createMatch();
        final homeTeam = _createTeam(worldRanking: 3);
        final awayTeam = _createTeam(
          teamCode: 'ARG',
          shortName: 'Argentina',
          worldRanking: 50,
        );

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenThrow(Exception('Engine failure'));

        final result = await service.suggestPrediction(
          match: match,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
        );

        // homeRank=3, awayRank=50: home team ranked higher, diff=47
        // homeScore = diff > 20 ? 2 : 1 -> 2
        // awayScore = diff > 30 ? 0 : 1 -> 0
        expect(result['homeScore'], 2);
        expect(result['awayScore'], 0);
        expect(result['reasoning'], 'World Rankings comparison');
      });

      test('fallback suggestion for evenly matched teams', () async {
        final match = _createMatch();
        final homeTeam = _createTeam(worldRanking: 10);
        final awayTeam = _createTeam(
          teamCode: 'ARG',
          shortName: 'Argentina',
          worldRanking: 10,
        );

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenThrow(Exception('Engine failure'));

        final result = await service.suggestPrediction(
          match: match,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
        );

        // Equal rankings -> draw
        expect(result['homeScore'], 1);
        expect(result['awayScore'], 1);
        expect(result['confidence'], 40);
        expect(result['reasoning'], 'World Rankings comparison');
      });

      test('fallback suggestion with null teams', () async {
        final match = _createMatch();

        when(() => mockEngine.generatePrediction(
              match: any(named: 'match'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
            )).thenThrow(Exception('Engine failure'));

        final result = await service.suggestPrediction(match: match);

        expect(result['provider'], 'Fallback');
        // Both default to rank 50, so even
        expect(result['homeScore'], 1);
        expect(result['awayScore'], 1);
      });
    });

    // =========================================================================
    // AIMatchPrediction entity tests
    // =========================================================================
    group('AIMatchPrediction entity', () {
      test('scoreDisplay formats correctly', () {
        final prediction = _createPrediction(homeScore: 3, awayScore: 2);
        expect(prediction.scoreDisplay, '3-2');
      });

      test('confidenceDescription at each threshold', () {
        expect(
          _createPrediction(confidence: 85).confidenceDescription,
          'Very High',
        );
        expect(
          _createPrediction(confidence: 70).confidenceDescription,
          'High',
        );
        expect(
          _createPrediction(confidence: 55).confidenceDescription,
          'Moderate',
        );
        expect(
          _createPrediction(confidence: 40).confidenceDescription,
          'Low',
        );
        expect(
          _createPrediction(confidence: 20).confidenceDescription,
          'Very Low',
        );
      });

      test('isValid returns true within TTL', () {
        final prediction = AIMatchPrediction(
          matchId: 'match_1',
          predictedOutcome: AIPredictedOutcome.homeWin,
          predictedHomeScore: 2,
          predictedAwayScore: 1,
          confidence: 60,
          homeWinProbability: 50,
          drawProbability: 25,
          awayWinProbability: 25,
          keyFactors: const [],
          analysis: '',
          quickInsight: '',
          provider: 'Test',
          generatedAt: DateTime.now(),
          ttlMinutes: 1440,
        );

        expect(prediction.isValid, true);
      });

      test('isValid returns false after TTL expires', () {
        final prediction = AIMatchPrediction(
          matchId: 'match_1',
          predictedOutcome: AIPredictedOutcome.homeWin,
          predictedHomeScore: 2,
          predictedAwayScore: 1,
          confidence: 60,
          homeWinProbability: 50,
          drawProbability: 25,
          awayWinProbability: 25,
          keyFactors: const [],
          analysis: '',
          quickInsight: '',
          provider: 'Test',
          generatedAt: DateTime.now().subtract(const Duration(days: 2)),
          ttlMinutes: 1440, // 24 hours
        );

        expect(prediction.isValid, false);
      });

      test('fallback factory creates correct prediction for higher home rank', () {
        final prediction = AIMatchPrediction.fallback(
          matchId: 'match_fb',
          homeTeamName: 'Brazil',
          awayTeamName: 'New Zealand',
          homeRanking: 3,
          awayRanking: 100,
        );

        expect(prediction.matchId, 'match_fb');
        expect(prediction.provider, 'Fallback');
        expect(prediction.confidence, 40);
        expect(prediction.predictedOutcome, AIPredictedOutcome.homeWin);
        expect(prediction.predictedHomeScore, greaterThanOrEqualTo(1));
      });

      test('fallback factory creates correct prediction for higher away rank', () {
        final prediction = AIMatchPrediction.fallback(
          matchId: 'match_fb2',
          homeTeamName: 'New Zealand',
          awayTeamName: 'Brazil',
          homeRanking: 100,
          awayRanking: 3,
        );

        expect(prediction.predictedOutcome, AIPredictedOutcome.awayWin);
      });

      test('fallback factory creates draw for equal rankings', () {
        final prediction = AIMatchPrediction.fallback(
          matchId: 'match_fb3',
          homeTeamName: 'Team A',
          awayTeamName: 'Team B',
          homeRanking: 25,
          awayRanking: 25,
        );

        expect(prediction.predictedOutcome, AIPredictedOutcome.draw);
        expect(prediction.predictedHomeScore, 1);
        expect(prediction.predictedAwayScore, 1);
      });

      test('fallback factory handles null rankings', () {
        final prediction = AIMatchPrediction.fallback(
          matchId: 'match_fb4',
          homeTeamName: 'Team A',
          awayTeamName: 'Team B',
          homeRanking: null,
          awayRanking: null,
        );

        // Both default to 50, so equal
        expect(prediction.predictedOutcome, AIPredictedOutcome.draw);
      });

      test('fromMap creates correct prediction', () {
        final map = {
          'predictedHomeScore': 3,
          'predictedAwayScore': 1,
          'confidence': 75,
          'homeWinProbability': 60,
          'drawProbability': 20,
          'awayWinProbability': 20,
          'keyFactors': ['Factor 1', 'Factor 2'],
          'analysis': 'Detailed analysis',
          'quickInsight': '3-1 Home',
          'provider': 'Claude',
          'generatedAt': DateTime.now().toIso8601String(),
          'isUpsetAlert': true,
          'upsetAlertText': 'Upset possible!',
        };

        final prediction = AIMatchPrediction.fromMap(map, 'match_fm');

        expect(prediction.matchId, 'match_fm');
        expect(prediction.predictedHomeScore, 3);
        expect(prediction.predictedAwayScore, 1);
        expect(prediction.predictedOutcome, AIPredictedOutcome.homeWin);
        expect(prediction.confidence, 75);
        expect(prediction.keyFactors, ['Factor 1', 'Factor 2']);
        expect(prediction.provider, 'Claude');
        expect(prediction.isUpsetAlert, true);
        expect(prediction.upsetAlertText, 'Upset possible!');
      });

      test('toMap serializes correctly', () {
        final prediction = _createPrediction(
          matchId: 'match_tm',
          homeScore: 1,
          awayScore: 0,
        );

        final map = prediction.toMap();

        expect(map['matchId'], 'match_tm');
        expect(map['predictedHomeScore'], 1);
        expect(map['predictedAwayScore'], 0);
        expect(map['predictedOutcome'], 'homeWin');
        expect(map['provider'], 'Local');
        expect(map['generatedAt'], isA<String>());
      });

      test('copyWith updates fields correctly', () {
        final original = _createPrediction(confidence: 50);
        final updated = original.copyWith(
          confidence: 80,
          provider: 'Updated',
        );

        expect(updated.confidence, 80);
        expect(updated.provider, 'Updated');
        expect(updated.matchId, original.matchId);
        expect(updated.predictedHomeScore, original.predictedHomeScore);
      });

      test('toString returns readable format', () {
        final prediction = _createPrediction(
          matchId: 'match_ts',
          homeScore: 2,
          awayScore: 1,
          confidence: 65,
        );

        expect(
          prediction.toString(),
          'AIMatchPrediction(match_ts: 2-1, confidence: 65%)',
        );
      });
    });

    // =========================================================================
    // AIPredictedOutcome tests
    // =========================================================================
    group('AIPredictedOutcome', () {
      test('displayName returns correct values', () {
        expect(AIPredictedOutcome.homeWin.displayName, 'Home Win');
        expect(AIPredictedOutcome.draw.displayName, 'Draw');
        expect(AIPredictedOutcome.awayWin.displayName, 'Away Win');
      });
    });
  });
}
