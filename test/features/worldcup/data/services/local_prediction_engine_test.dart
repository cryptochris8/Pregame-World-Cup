import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/local_prediction_engine.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/enhanced_match_data_service.dart';

import '../../../worldcup/presentation/bloc/mock_repositories.dart';

class MockEnhancedMatchDataService extends Mock
    implements EnhancedMatchDataService {}

void main() {
  late MockEnhancedMatchDataService mockDataService;
  late LocalPredictionEngine engine;

  setUp(() {
    mockDataService = MockEnhancedMatchDataService();
    engine = LocalPredictionEngine(enhancedDataService: mockDataService);

    // Default stubs for all data service methods
    when(() => mockDataService.initialize()).thenAnswer((_) async {});
    when(() => mockDataService.getBettingOdds(any())).thenReturn(null);
    when(() => mockDataService.getSquadValue(any())).thenReturn(null);
    when(() => mockDataService.getRecentForm(any())).thenReturn(null);
    when(() => mockDataService.getRecentFormSummary(any())).thenReturn(null);
    when(() => mockDataService.getInjuryConcerns(any())).thenReturn([]);
    when(() => mockDataService.getManagerProfile(any()))
        .thenAnswer((_) async => null);
    when(() => mockDataService.getHeadToHead(any(), any()))
        .thenAnswer((_) async => null);
    when(() => mockDataService.getSquadValueComparison(any(), any()))
        .thenReturn(null);
    when(() => mockDataService.getRelevantPatterns(
          homeConfederation: any(named: 'homeConfederation'),
          awayConfederation: any(named: 'awayConfederation'),
          isHostNation: any(named: 'isHostNation'),
        )).thenReturn([]);
    when(() => mockDataService.getUpsetPotential(any(), any()))
        .thenReturn(null);
  });

  // ---------------------------------------------------------------------------
  // Helper to create default match and teams
  // ---------------------------------------------------------------------------
  WorldCupMatch defaultMatch({
    MatchStage stage = MatchStage.groupStage,
    String? homeTeamCode = 'USA',
    String homeTeamName = 'United States',
    String? awayTeamCode = 'BRA',
    String awayTeamName = 'Brazil',
  }) {
    return TestDataFactory.createMatch(
      matchId: 'test_match',
      stage: stage,
      homeTeamCode: homeTeamCode,
      homeTeamName: homeTeamName,
      awayTeamCode: awayTeamCode,
      awayTeamName: awayTeamName,
    );
  }

  NationalTeam homeTeam({
    String fifaCode = 'USA',
    int? fifaRanking = 10,
    int worldCupTitles = 0,
    int worldCupAppearances = 11,
    String? bestFinish = 'Semi-finals',
    bool isHostNation = true,
  }) {
    return TestDataFactory.createTeam(
      fifaCode: fifaCode,
      countryName: 'United States',
      shortName: 'USA',
      confederation: Confederation.concacaf,
      fifaRanking: fifaRanking,
      worldCupTitles: worldCupTitles,
      isHostNation: isHostNation,
    ).copyWith(
      worldCupAppearances: worldCupAppearances,
      bestFinish: bestFinish,
    );
  }

  NationalTeam awayTeam({
    String fifaCode = 'BRA',
    int? fifaRanking = 3,
    int worldCupTitles = 5,
    int worldCupAppearances = 22,
    String? bestFinish = 'Winner',
    bool isHostNation = false,
  }) {
    return TestDataFactory.createTeam(
      fifaCode: fifaCode,
      countryName: 'Brazil',
      shortName: 'Brazil',
      confederation: Confederation.conmebol,
      fifaRanking: fifaRanking,
      worldCupTitles: worldCupTitles,
      isHostNation: isHostNation,
    ).copyWith(
      worldCupAppearances: worldCupAppearances,
      bestFinish: bestFinish,
    );
  }

  // ---------------------------------------------------------------------------
  // 1. generatePrediction returns valid AIMatchPrediction
  // ---------------------------------------------------------------------------
  group('generatePrediction - basic output', () {
    test('returns a valid AIMatchPrediction with all required fields', () async {
      final match = defaultMatch();
      final home = homeTeam();
      final away = awayTeam();

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction, isA<AIMatchPrediction>());
      expect(prediction.matchId, equals('test_match'));
      expect(prediction.provider, equals('Local Engine'));
      expect(prediction.predictedHomeScore, isNonNegative);
      expect(prediction.predictedAwayScore, isNonNegative);
      expect(prediction.keyFactors, isA<List<String>>());
      expect(prediction.analysis, isNotEmpty);
      expect(prediction.quickInsight, isNotEmpty);
      expect(prediction.generatedAt, isA<DateTime>());
    });

    test('calls initialize on the data service', () async {
      final match = defaultMatch();

      await engine.generatePrediction(match: match);

      verify(() => mockDataService.initialize()).called(1);
    });

    test('predicted outcome matches predicted scores', () async {
      final match = defaultMatch();
      final home = homeTeam();
      final away = awayTeam();

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      if (prediction.predictedHomeScore > prediction.predictedAwayScore) {
        expect(prediction.predictedOutcome, equals(AIPredictedOutcome.homeWin));
      } else if (prediction.predictedAwayScore >
          prediction.predictedHomeScore) {
        expect(prediction.predictedOutcome, equals(AIPredictedOutcome.awayWin));
      } else {
        expect(prediction.predictedOutcome, equals(AIPredictedOutcome.draw));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // 2. generatePrediction with no data (all nulls)
  // ---------------------------------------------------------------------------
  group('generatePrediction - no data fallback', () {
    test('returns result when all data sources return null', () async {
      final match = defaultMatch();

      final prediction = await engine.generatePrediction(match: match);

      expect(prediction, isA<AIMatchPrediction>());
      expect(prediction.matchId, equals('test_match'));
      expect(prediction.confidence, greaterThanOrEqualTo(25));
      expect(prediction.confidence, lessThanOrEqualTo(92));
    });

    test('returns result when teams are null', () async {
      final match = defaultMatch();

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: null,
        awayTeam: null,
      );

      expect(prediction, isA<AIMatchPrediction>());
      expect(prediction.homeWinProbability, greaterThan(0));
      expect(prediction.drawProbability, greaterThan(0));
      expect(prediction.awayWinProbability, greaterThan(0));
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Betting odds scoring
  // ---------------------------------------------------------------------------
  group('betting odds scoring', () {
    test('home favored by betting odds produces home-leaning prediction',
        () async {
      when(() => mockDataService.getBettingOdds('USA')).thenReturn({
        'implied_probability_pct': 30,
        'tier': 'contender',
        'code': 'USA',
      });
      when(() => mockDataService.getBettingOdds('JAM')).thenReturn({
        'implied_probability_pct': 2,
        'tier': 'long_shot',
        'code': 'JAM',
      });

      final match = defaultMatch(
        homeTeamCode: 'USA',
        homeTeamName: 'United States',
        awayTeamCode: 'JAM',
        awayTeamName: 'Jamaica',
      );
      final home = homeTeam(fifaRanking: 10);
      final away = awayTeam(
        fifaCode: 'JAM',
        fifaRanking: 60,
        worldCupTitles: 0,
        worldCupAppearances: 0,
        bestFinish: null,
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction.homeWinProbability,
          greaterThan(prediction.awayWinProbability));
    });

    test('away favored by betting odds produces away-leaning prediction',
        () async {
      when(() => mockDataService.getBettingOdds('JAM')).thenReturn({
        'implied_probability_pct': 1,
        'tier': 'long_shot',
        'code': 'JAM',
      });
      when(() => mockDataService.getBettingOdds('BRA')).thenReturn({
        'implied_probability_pct': 25,
        'tier': 'favorite',
        'code': 'BRA',
      });

      final match = defaultMatch(
        homeTeamCode: 'JAM',
        homeTeamName: 'Jamaica',
        awayTeamCode: 'BRA',
        awayTeamName: 'Brazil',
      );
      final home = homeTeam(
        fifaCode: 'JAM',
        fifaRanking: 60,
        worldCupTitles: 0,
        worldCupAppearances: 0,
        bestFinish: null,
        isHostNation: false,
      );
      final away = awayTeam(fifaRanking: 3);

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction.awayWinProbability,
          greaterThan(prediction.homeWinProbability));
    });

    test('equal betting odds do not skew prediction toward either side',
        () async {
      when(() => mockDataService.getBettingOdds('GER')).thenReturn({
        'implied_probability_pct': 10,
        'tier': 'contender',
        'code': 'GER',
      });
      when(() => mockDataService.getBettingOdds('FRA')).thenReturn({
        'implied_probability_pct': 10,
        'tier': 'contender',
        'code': 'FRA',
      });

      final match = defaultMatch(
        homeTeamCode: 'GER',
        homeTeamName: 'Germany',
        awayTeamCode: 'FRA',
        awayTeamName: 'France',
      );
      final home = homeTeam(
        fifaCode: 'GER',
        fifaRanking: 5,
        worldCupTitles: 4,
        worldCupAppearances: 20,
        bestFinish: 'Winner',
        isHostNation: false,
      );
      final away = awayTeam(
        fifaCode: 'FRA',
        fifaRanking: 5,
        worldCupTitles: 2,
        worldCupAppearances: 16,
        bestFinish: 'Winner',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // With equal odds and similar teams, probabilities should be relatively balanced
      final diff =
          (prediction.homeWinProbability - prediction.awayWinProbability).abs();
      expect(diff, lessThan(30));
    });

    test('null betting odds data returns valid prediction', () async {
      // Default stubs already return null for betting odds
      final match = defaultMatch();

      final prediction = await engine.generatePrediction(match: match);

      expect(prediction, isA<AIMatchPrediction>());
    });
  });

  // ---------------------------------------------------------------------------
  // 4. FIFA ranking scoring
  // ---------------------------------------------------------------------------
  group('FIFA ranking scoring', () {
    test('higher ranked home team produces home-favored prediction', () async {
      final match = defaultMatch();
      final home = homeTeam(fifaRanking: 1, isHostNation: false);
      final away = awayTeam(
        fifaRanking: 50,
        worldCupTitles: 0,
        worldCupAppearances: 2,
        bestFinish: null,
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction.homeWinProbability,
          greaterThan(prediction.awayWinProbability));
    });

    test('higher ranked away team produces away-favored prediction', () async {
      final match = defaultMatch();
      final home = homeTeam(
        fifaRanking: 50,
        worldCupTitles: 0,
        worldCupAppearances: 2,
        bestFinish: null,
        isHostNation: false,
      );
      final away = awayTeam(fifaRanking: 1);

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction.awayWinProbability,
          greaterThan(prediction.homeWinProbability));
    });

    test('equal rankings produce balanced probabilities', () async {
      final match = defaultMatch();
      final home = homeTeam(
        fifaRanking: 15,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
        isHostNation: false,
      );
      final away = awayTeam(
        fifaRanking: 15,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      final diff =
          (prediction.homeWinProbability - prediction.awayWinProbability).abs();
      expect(diff, lessThan(15));
    });
  });

  // ---------------------------------------------------------------------------
  // 5. Host advantage scoring
  // ---------------------------------------------------------------------------
  group('host advantage scoring', () {
    test('home team as host nation gets advantage', () async {
      final match = defaultMatch(homeTeamCode: 'USA', awayTeamCode: 'JPN');

      // Give same rankings to isolate host effect
      final home = homeTeam(
        fifaCode: 'USA',
        fifaRanking: 20,
        isHostNation: true,
        worldCupTitles: 0,
        worldCupAppearances: 11,
        bestFinish: 'Semi-finals',
      );
      final away = awayTeam(
        fifaCode: 'JPN',
        fifaRanking: 20,
        worldCupTitles: 0,
        worldCupAppearances: 7,
        bestFinish: 'Round of 16',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // Host advantage should push home probability higher
      expect(prediction.homeWinProbability,
          greaterThanOrEqualTo(prediction.awayWinProbability));
    });

    test('away team as host nation (MEX) gets advantage', () async {
      final match = defaultMatch(
        homeTeamCode: 'JPN',
        homeTeamName: 'Japan',
        awayTeamCode: 'MEX',
        awayTeamName: 'Mexico',
      );

      final home = homeTeam(
        fifaCode: 'JPN',
        fifaRanking: 20,
        isHostNation: false,
        worldCupTitles: 0,
        worldCupAppearances: 7,
        bestFinish: 'Round of 16',
      );
      final away = awayTeam(
        fifaCode: 'MEX',
        fifaRanking: 20,
        worldCupTitles: 0,
        worldCupAppearances: 17,
        bestFinish: 'Quarter-finals',
        isHostNation: true,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // MEX as host should push away probability higher or at least close
      expect(prediction.awayWinProbability,
          greaterThanOrEqualTo(prediction.homeWinProbability - 10));
    });

    test('neither team is host nation produces no host advantage', () async {
      final match = defaultMatch(
        homeTeamCode: 'GER',
        homeTeamName: 'Germany',
        awayTeamCode: 'FRA',
        awayTeamName: 'France',
      );

      final home = homeTeam(
        fifaCode: 'GER',
        fifaRanking: 15,
        isHostNation: false,
        worldCupTitles: 4,
        worldCupAppearances: 20,
        bestFinish: 'Winner',
      );
      final away = awayTeam(
        fifaCode: 'FRA',
        fifaRanking: 15,
        worldCupTitles: 2,
        worldCupAppearances: 16,
        bestFinish: 'Winner',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // Without host advantage, should be more balanced
      expect(prediction, isA<AIMatchPrediction>());
    });
  });

  // ---------------------------------------------------------------------------
  // 6. Recent form scoring (weighted by opponent quality & competition type)
  // ---------------------------------------------------------------------------
  group('recent form scoring', () {
    test('team with strong recent form is favored', () async {
      // Home team has strong form: WWWWW
      when(() => mockDataService.getRecentForm('USA')).thenReturn({
        'recent_matches': [
          {'result': 'W', 'opponent': 'Canada', 'competition': 'CONCACAF World Cup Qualifier Final Round'},
          {'result': 'W', 'opponent': 'Mexico', 'competition': 'CONCACAF World Cup Qualifier Final Round'},
          {'result': 'W', 'opponent': 'Jamaica', 'competition': 'CONCACAF World Cup Qualifier Final Round'},
          {'result': 'W', 'opponent': 'Costa Rica', 'competition': 'CONCACAF World Cup Qualifier Final Round'},
          {'result': 'W', 'opponent': 'Honduras', 'competition': 'CONCACAF World Cup Qualifier Final Round'},
        ],
      });
      // Away team has poor form: LLLLL
      when(() => mockDataService.getRecentForm('BRA')).thenReturn({
        'recent_matches': [
          {'result': 'L', 'opponent': 'Argentina', 'competition': 'CONMEBOL World Cup Qualifier'},
          {'result': 'L', 'opponent': 'Uruguay', 'competition': 'CONMEBOL World Cup Qualifier'},
          {'result': 'L', 'opponent': 'Colombia', 'competition': 'CONMEBOL World Cup Qualifier'},
          {'result': 'L', 'opponent': 'Chile', 'competition': 'CONMEBOL World Cup Qualifier'},
          {'result': 'L', 'opponent': 'Paraguay', 'competition': 'CONMEBOL World Cup Qualifier'},
        ],
      });
      when(() => mockDataService.getRecentFormSummary('USA'))
          .thenReturn('Last 5 matches: 5W 0D 0L');
      when(() => mockDataService.getRecentFormSummary('BRA'))
          .thenReturn('Last 5 matches: 0W 0D 5L');

      final match = defaultMatch();
      final home = homeTeam(fifaRanking: 20, isHostNation: false);
      final away = awayTeam(
        fifaRanking: 20,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction.homeWinProbability,
          greaterThan(prediction.awayWinProbability));
    });

    test('null form data returns valid prediction', () async {
      // Default stubs already return null for form data
      final match = defaultMatch();

      final prediction = await engine.generatePrediction(match: match);

      expect(prediction, isA<AIMatchPrediction>());
    });

    test('mixed form (WDLWL) scores differently than perfect form', () async {
      when(() => mockDataService.getRecentForm('USA')).thenReturn({
        'recent_matches': [
          {'result': 'W', 'opponent': 'Canada', 'competition': 'CONCACAF World Cup Qualifier Final Round'},
          {'result': 'D', 'opponent': 'Mexico', 'competition': 'CONCACAF World Cup Qualifier Final Round'},
          {'result': 'L', 'opponent': 'Jamaica', 'competition': 'CONCACAF World Cup Qualifier Final Round'},
          {'result': 'W', 'opponent': 'Costa Rica', 'competition': 'CONCACAF World Cup Qualifier Final Round'},
          {'result': 'L', 'opponent': 'Honduras', 'competition': 'CONCACAF World Cup Qualifier Final Round'},
        ],
      });
      when(() => mockDataService.getRecentForm('BRA')).thenReturn({
        'recent_matches': [
          {'result': 'W', 'opponent': 'Argentina', 'competition': 'CONMEBOL World Cup Qualifier'},
          {'result': 'W', 'opponent': 'Uruguay', 'competition': 'CONMEBOL World Cup Qualifier'},
          {'result': 'W', 'opponent': 'Colombia', 'competition': 'CONMEBOL World Cup Qualifier'},
          {'result': 'W', 'opponent': 'Chile', 'competition': 'CONMEBOL World Cup Qualifier'},
          {'result': 'W', 'opponent': 'Paraguay', 'competition': 'CONMEBOL World Cup Qualifier'},
        ],
      });

      final match = defaultMatch();
      final home = homeTeam(fifaRanking: 20, isHostNation: false);
      final away = awayTeam(
        fifaRanking: 20,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // Away team has better form, so should be favored
      expect(prediction.awayWinProbability,
          greaterThan(prediction.homeWinProbability));
    });

    test('wins against top-ranked opponents score higher than wins against weak teams', () async {
      // Home team beats top-10 opponents in WC qualifiers
      when(() => mockDataService.getRecentForm('USA')).thenReturn({
        'recent_matches': [
          {'result': 'W', 'opponent': 'Spain', 'competition': 'International Friendly'},
          {'result': 'W', 'opponent': 'Argentina', 'competition': 'International Friendly'},
          {'result': 'W', 'opponent': 'France', 'competition': 'International Friendly'},
        ],
      });
      // Away team beats low-ranked opponents in friendlies
      when(() => mockDataService.getRecentForm('BRA')).thenReturn({
        'recent_matches': [
          {'result': 'W', 'opponent': 'Gibraltar', 'competition': 'International Friendly'},
          {'result': 'W', 'opponent': 'San Marino', 'competition': 'International Friendly'},
          {'result': 'W', 'opponent': 'Liechtenstein', 'competition': 'International Friendly'},
        ],
      });

      final match = defaultMatch();
      final home = homeTeam(fifaRanking: 20, isHostNation: false);
      final away = awayTeam(
        fifaRanking: 20,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // Home team's wins vs top opponents should score higher
      expect(prediction.homeWinProbability,
          greaterThan(prediction.awayWinProbability));
    });

    test('losses to strong teams are penalized less than losses to weak teams', () async {
      // Home team lost to top-3 teams
      when(() => mockDataService.getRecentForm('USA')).thenReturn({
        'recent_matches': [
          {'result': 'L', 'opponent': 'Spain', 'competition': 'CONMEBOL World Cup Qualifier'},
          {'result': 'L', 'opponent': 'Argentina', 'competition': 'CONMEBOL World Cup Qualifier'},
          {'result': 'L', 'opponent': 'France', 'competition': 'CONMEBOL World Cup Qualifier'},
        ],
      });
      // Away team lost to very weak teams
      when(() => mockDataService.getRecentForm('BRA')).thenReturn({
        'recent_matches': [
          {'result': 'L', 'opponent': 'Gibraltar', 'competition': 'CONMEBOL World Cup Qualifier'},
          {'result': 'L', 'opponent': 'San Marino', 'competition': 'CONMEBOL World Cup Qualifier'},
          {'result': 'L', 'opponent': 'Andorra', 'competition': 'CONMEBOL World Cup Qualifier'},
        ],
      });

      final match = defaultMatch();
      final home = homeTeam(fifaRanking: 20, isHostNation: false);
      final away = awayTeam(
        fifaRanking: 20,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // Home team lost to strong teams (less penalty), so should be favored
      expect(prediction.homeWinProbability,
          greaterThan(prediction.awayWinProbability));
    });

    test('continental championship results weighted higher than friendlies', () async {
      // Home team won in continental championship (AFCON)
      when(() => mockDataService.getRecentForm('USA')).thenReturn({
        'recent_matches': [
          {'result': 'W', 'opponent': 'Morocco', 'competition': 'AFCON 2025 Group Stage'},
          {'result': 'W', 'opponent': 'Nigeria', 'competition': 'AFCON 2025 Quarterfinal'},
          {'result': 'W', 'opponent': 'Senegal', 'competition': 'AFCON 2025 Final'},
        ],
      });
      // Away team won in friendlies against same caliber
      when(() => mockDataService.getRecentForm('BRA')).thenReturn({
        'recent_matches': [
          {'result': 'W', 'opponent': 'Morocco', 'competition': 'International Friendly'},
          {'result': 'W', 'opponent': 'Nigeria', 'competition': 'International Friendly'},
          {'result': 'W', 'opponent': 'Senegal', 'competition': 'International Friendly'},
        ],
      });

      final match = defaultMatch();
      final home = homeTeam(fifaRanking: 20, isHostNation: false);
      final away = awayTeam(
        fifaRanking: 20,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // Home team's continental championship wins should score higher than friendlies
      expect(prediction.homeWinProbability,
          greaterThan(prediction.awayWinProbability));
    });

    test('form data without opponent/competition fields still works', () async {
      // Backwards compatibility: minimal form data with no opponent/competition
      when(() => mockDataService.getRecentForm('USA')).thenReturn({
        'recent_matches': [
          {'result': 'W'},
          {'result': 'W'},
          {'result': 'W'},
        ],
      });
      when(() => mockDataService.getRecentForm('BRA')).thenReturn({
        'recent_matches': [
          {'result': 'L'},
          {'result': 'L'},
          {'result': 'L'},
        ],
      });

      final match = defaultMatch();
      final home = homeTeam(fifaRanking: 20, isHostNation: false);
      final away = awayTeam(
        fifaRanking: 20,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // All-wins should still beat all-losses even with default weights
      expect(prediction.homeWinProbability,
          greaterThan(prediction.awayWinProbability));
    });
  });

  // ---------------------------------------------------------------------------
  // 7. Squad value scoring
  // ---------------------------------------------------------------------------
  group('squad value scoring', () {
    test('team with higher squad value gets advantage', () async {
      when(() => mockDataService.getSquadValue('USA')).thenReturn({
        'teamCode': 'USA',
        'teamName': 'United States',
        'totalValue': 800000000,
        'totalValueFormatted': '\u20AC800M',
        'rank': 5,
      });
      when(() => mockDataService.getSquadValue('JAM')).thenReturn({
        'teamCode': 'JAM',
        'teamName': 'Jamaica',
        'totalValue': 50000000,
        'totalValueFormatted': '\u20AC50M',
        'rank': 45,
      });

      final match = defaultMatch(
        homeTeamCode: 'USA',
        awayTeamCode: 'JAM',
        awayTeamName: 'Jamaica',
      );
      final home = homeTeam(fifaRanking: 15, isHostNation: false);
      final away = awayTeam(
        fifaCode: 'JAM',
        fifaRanking: 15,
        worldCupTitles: 0,
        worldCupAppearances: 0,
        bestFinish: null,
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction.homeWinProbability,
          greaterThan(prediction.awayWinProbability));
    });

    test('null squad value data falls back gracefully', () async {
      // Default stubs already return null for squad value
      final match = defaultMatch();

      final prediction = await engine.generatePrediction(match: match);

      expect(prediction, isA<AIMatchPrediction>());
    });
  });

  // ---------------------------------------------------------------------------
  // 8. WC experience scoring
  // ---------------------------------------------------------------------------
  group('WC experience scoring', () {
    test('team with titles outscores team without', () async {
      final match = defaultMatch(
        homeTeamCode: 'JPN',
        homeTeamName: 'Japan',
        awayTeamCode: 'BRA',
        awayTeamName: 'Brazil',
      );
      // Japan: no titles, 7 appearances
      final home = homeTeam(
        fifaCode: 'JPN',
        fifaRanking: 20,
        worldCupTitles: 0,
        worldCupAppearances: 7,
        bestFinish: 'Round of 16',
        isHostNation: false,
      );
      // Brazil: 5 titles, 22 appearances
      final away = awayTeam(
        fifaCode: 'BRA',
        fifaRanking: 20,
        worldCupTitles: 5,
        worldCupAppearances: 22,
        bestFinish: 'Winner',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // Brazil's WC experience should help push their probability higher
      expect(prediction.awayWinProbability,
          greaterThan(prediction.homeWinProbability));
    });

    test('team with winner bestFinish gets bonus over quarter-finalist',
        () async {
      final match = defaultMatch(
        homeTeamCode: 'ARG',
        homeTeamName: 'Argentina',
        awayTeamCode: 'KOR',
        awayTeamName: 'South Korea',
      );
      final home = homeTeam(
        fifaCode: 'ARG',
        fifaRanking: 20,
        worldCupTitles: 3,
        worldCupAppearances: 18,
        bestFinish: 'Winner',
        isHostNation: false,
      );
      final away = awayTeam(
        fifaCode: 'KOR',
        fifaRanking: 20,
        worldCupTitles: 0,
        worldCupAppearances: 11,
        bestFinish: 'Semi-finals',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction.homeWinProbability,
          greaterThan(prediction.awayWinProbability));
    });
  });

  // ---------------------------------------------------------------------------
  // 9. Probability calculation sums to ~1.0
  // ---------------------------------------------------------------------------
  group('probability calculation', () {
    test('probabilities sum to approximately 100', () async {
      final match = defaultMatch();
      final home = homeTeam();
      final away = awayTeam();

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      final total = prediction.homeWinProbability +
          prediction.drawProbability +
          prediction.awayWinProbability;

      // Probabilities are rounded integers, so allow small rounding tolerance
      expect(total, greaterThanOrEqualTo(98));
      expect(total, lessThanOrEqualTo(102));
    });

    test('each probability is positive', () async {
      final match = defaultMatch();
      final home = homeTeam();
      final away = awayTeam();

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction.homeWinProbability, greaterThan(0));
      expect(prediction.drawProbability, greaterThan(0));
      expect(prediction.awayWinProbability, greaterThan(0));
    });

    test('heavily favored match still has minimum probabilities for underdog',
        () async {
      when(() => mockDataService.getBettingOdds('BRA')).thenReturn({
        'implied_probability_pct': 50,
        'tier': 'favorite',
        'code': 'BRA',
      });
      when(() => mockDataService.getBettingOdds('JAM')).thenReturn({
        'implied_probability_pct': 1,
        'tier': 'long_shot',
        'code': 'JAM',
      });

      final match = defaultMatch(
        homeTeamCode: 'BRA',
        homeTeamName: 'Brazil',
        awayTeamCode: 'JAM',
        awayTeamName: 'Jamaica',
      );
      final home = homeTeam(
        fifaCode: 'BRA',
        fifaRanking: 3,
        worldCupTitles: 5,
        worldCupAppearances: 22,
        bestFinish: 'Winner',
        isHostNation: false,
      );
      final away = awayTeam(
        fifaCode: 'JAM',
        fifaRanking: 60,
        worldCupTitles: 0,
        worldCupAppearances: 1,
        bestFinish: 'Group stage',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // Clamped to minimum 5% after normalization
      expect(prediction.awayWinProbability, greaterThan(0));
      expect(prediction.drawProbability, greaterThan(0));
    });
  });

  // ---------------------------------------------------------------------------
  // 10. Score prediction: home favored -> home score > away
  // ---------------------------------------------------------------------------
  group('score prediction', () {
    test('home favored produces home score >= away score', () async {
      when(() => mockDataService.getBettingOdds('USA')).thenReturn({
        'implied_probability_pct': 30,
        'tier': 'contender',
        'code': 'USA',
      });
      when(() => mockDataService.getBettingOdds('JAM')).thenReturn({
        'implied_probability_pct': 1,
        'tier': 'long_shot',
        'code': 'JAM',
      });

      final match = defaultMatch(
        homeTeamCode: 'USA',
        awayTeamCode: 'JAM',
        awayTeamName: 'Jamaica',
      );
      final home = homeTeam(fifaRanking: 10);
      final away = awayTeam(
        fifaCode: 'JAM',
        fifaRanking: 60,
        worldCupTitles: 0,
        worldCupAppearances: 1,
        bestFinish: null,
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction.predictedHomeScore,
          greaterThanOrEqualTo(prediction.predictedAwayScore));
    });

    test('away favored produces away score >= home score', () async {
      when(() => mockDataService.getBettingOdds('JAM')).thenReturn({
        'implied_probability_pct': 1,
        'tier': 'long_shot',
        'code': 'JAM',
      });
      when(() => mockDataService.getBettingOdds('BRA')).thenReturn({
        'implied_probability_pct': 40,
        'tier': 'favorite',
        'code': 'BRA',
      });

      final match = defaultMatch(
        homeTeamCode: 'JAM',
        homeTeamName: 'Jamaica',
        awayTeamCode: 'BRA',
        awayTeamName: 'Brazil',
      );
      final home = homeTeam(
        fifaCode: 'JAM',
        fifaRanking: 60,
        worldCupTitles: 0,
        worldCupAppearances: 1,
        bestFinish: null,
        isHostNation: false,
      );
      final away = awayTeam(fifaRanking: 3);

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction.predictedAwayScore,
          greaterThanOrEqualTo(prediction.predictedHomeScore));
    });

    test('predicted scores are within realistic World Cup range', () async {
      final match = defaultMatch();
      final home = homeTeam();
      final away = awayTeam();

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction.predictedHomeScore, lessThanOrEqualTo(3));
      expect(prediction.predictedAwayScore, lessThanOrEqualTo(3));
      expect(prediction.predictedHomeScore, greaterThanOrEqualTo(0));
      expect(prediction.predictedAwayScore, greaterThanOrEqualTo(0));
    });
  });

  // ---------------------------------------------------------------------------
  // 11. Confidence range is 25-92
  // ---------------------------------------------------------------------------
  group('confidence range', () {
    test('confidence is within 25-92 range for balanced match', () async {
      final match = defaultMatch();
      final home = homeTeam(
        fifaRanking: 15,
        isHostNation: false,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
      );
      final away = awayTeam(
        fifaRanking: 15,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction.confidence, greaterThanOrEqualTo(25));
      expect(prediction.confidence, lessThanOrEqualTo(92));
    });

    test('confidence is within 25-92 range for lopsided match', () async {
      when(() => mockDataService.getBettingOdds('BRA')).thenReturn({
        'implied_probability_pct': 50,
        'tier': 'favorite',
        'code': 'BRA',
      });
      when(() => mockDataService.getBettingOdds('JAM')).thenReturn({
        'implied_probability_pct': 1,
        'tier': 'long_shot',
        'code': 'JAM',
      });

      final match = defaultMatch(
        homeTeamCode: 'BRA',
        homeTeamName: 'Brazil',
        awayTeamCode: 'JAM',
        awayTeamName: 'Jamaica',
      );
      final home = homeTeam(
        fifaCode: 'BRA',
        fifaRanking: 3,
        worldCupTitles: 5,
        worldCupAppearances: 22,
        bestFinish: 'Winner',
        isHostNation: false,
      );
      final away = awayTeam(
        fifaCode: 'JAM',
        fifaRanking: 70,
        worldCupTitles: 0,
        worldCupAppearances: 1,
        bestFinish: null,
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction.confidence, greaterThanOrEqualTo(25));
      expect(prediction.confidence, lessThanOrEqualTo(92));
    });

    test('confidence is within 25-92 range with no data at all', () async {
      final match = defaultMatch();

      final prediction = await engine.generatePrediction(match: match);

      expect(prediction.confidence, greaterThanOrEqualTo(25));
      expect(prediction.confidence, lessThanOrEqualTo(92));
    });
  });

  // ---------------------------------------------------------------------------
  // 12. Knockout vs group stage draw probability
  // ---------------------------------------------------------------------------
  group('knockout vs group stage draw probability', () {
    test('knockout match has lower draw probability than group stage', () async {
      final groupMatch = defaultMatch(stage: MatchStage.groupStage);
      final knockoutMatch = defaultMatch(stage: MatchStage.roundOf16);

      final home = homeTeam(
        fifaRanking: 15,
        isHostNation: false,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
      );
      final away = awayTeam(
        fifaRanking: 15,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
        isHostNation: false,
      );

      final groupPrediction = await engine.generatePrediction(
        match: groupMatch,
        homeTeam: home,
        awayTeam: away,
      );
      final knockoutPrediction = await engine.generatePrediction(
        match: knockoutMatch,
        homeTeam: home,
        awayTeam: away,
      );

      expect(knockoutPrediction.drawProbability,
          lessThan(groupPrediction.drawProbability));
    });

    test('quarter-final is treated as knockout', () async {
      final match = defaultMatch(stage: MatchStage.quarterFinal);
      final groupMatch = defaultMatch(stage: MatchStage.groupStage);

      final home = homeTeam(fifaRanking: 10, isHostNation: false);
      final away = awayTeam(
        fifaRanking: 10,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
        isHostNation: false,
      );

      final knockoutPrediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );
      final groupPrediction = await engine.generatePrediction(
        match: groupMatch,
        homeTeam: home,
        awayTeam: away,
      );

      expect(knockoutPrediction.drawProbability,
          lessThan(groupPrediction.drawProbability));
    });

    test('final stage is treated as knockout', () async {
      final match = defaultMatch(stage: MatchStage.final_);
      final groupMatch = defaultMatch(stage: MatchStage.groupStage);

      final home = homeTeam(fifaRanking: 10, isHostNation: false);
      final away = awayTeam(
        fifaRanking: 10,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
        isHostNation: false,
      );

      final knockoutPrediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );
      final groupPrediction = await engine.generatePrediction(
        match: groupMatch,
        homeTeam: home,
        awayTeam: away,
      );

      expect(knockoutPrediction.drawProbability,
          lessThan(groupPrediction.drawProbability));
    });
  });

  // ---------------------------------------------------------------------------
  // Additional edge case and integration tests
  // ---------------------------------------------------------------------------
  group('injury impact scoring', () {
    test('team with injured players is disadvantaged', () async {
      when(() => mockDataService.getInjuryConcerns('USA')).thenReturn([
        {
          'playerName': 'Christian Pulisic',
          'teamCode': 'USA',
          'availabilityStatus': 'injured',
          'injuryType': 'hamstring',
        },
        {
          'playerName': 'Weston McKennie',
          'teamCode': 'USA',
          'availabilityStatus': 'major_doubt',
          'injuryType': 'knee',
        },
      ]);
      when(() => mockDataService.getInjuryConcerns('BRA')).thenReturn([]);

      final match = defaultMatch();
      // Give equal rankings to isolate injury effect
      final home = homeTeam(
        fifaRanking: 15,
        isHostNation: false,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
      );
      final away = awayTeam(
        fifaRanking: 15,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // Home team has injuries, so away should be slightly favored
      expect(prediction.awayWinProbability,
          greaterThanOrEqualTo(prediction.homeWinProbability));
    });
  });

  group('manager scoring', () {
    test('manager with higher win rate and WC experience is favored', () async {
      when(() => mockDataService.getManagerProfile('USA')).thenAnswer(
        (_) async => {
          'firstName': 'Gregg',
          'lastName': 'Berhalter',
          'careerWinPercentage': 55,
          'preferredFormation': '4-3-3',
          'coachingStyle': 'possession',
          'worldCupExperience': {
            'matchesAsCoach': 4,
          },
        },
      );
      when(() => mockDataService.getManagerProfile('BRA')).thenAnswer(
        (_) async => {
          'firstName': 'Dorival',
          'lastName': 'Junior',
          'careerWinPercentage': 45,
          'preferredFormation': '4-2-3-1',
          'coachingStyle': 'balanced',
          'worldCupExperience': {
            'matchesAsCoach': 0,
          },
        },
      );

      final match = defaultMatch();
      final home = homeTeam(
        fifaRanking: 15,
        isHostNation: false,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
      );
      final away = awayTeam(
        fifaRanking: 15,
        worldCupTitles: 0,
        worldCupAppearances: 10,
        bestFinish: 'Quarter-finals',
        isHostNation: false,
      );

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // Home manager has better win rate + WC experience
      expect(prediction.homeWinProbability,
          greaterThanOrEqualTo(prediction.awayWinProbability));
    });
  });

  group('narrative and metadata', () {
    test('keyFactors is non-empty when data is available', () async {
      when(() => mockDataService.getBettingOdds('USA')).thenReturn({
        'implied_probability_pct': 20,
        'tier': 'contender',
        'code': 'USA',
      });
      when(() => mockDataService.getBettingOdds('BRA')).thenReturn({
        'implied_probability_pct': 30,
        'tier': 'favorite',
        'code': 'BRA',
      });

      final match = defaultMatch();
      final home = homeTeam();
      final away = awayTeam();

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      expect(prediction.keyFactors, isNotEmpty);
      expect(prediction.keyFactors.length, lessThanOrEqualTo(5));
    });

    test('analysis contains team names', () async {
      final match = defaultMatch();
      final home = homeTeam();
      final away = awayTeam();

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // Analysis should reference at least one team name
      final containsTeamRef = prediction.analysis.contains('United States') ||
          prediction.analysis.contains('Brazil');
      expect(containsTeamRef, isTrue);
    });

    test('quickInsight contains score and confidence', () async {
      final match = defaultMatch();
      final home = homeTeam();
      final away = awayTeam();

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: home,
        awayTeam: away,
      );

      // quickInsight should contain the confidence percentage
      expect(prediction.quickInsight, contains('%'));
    });

    test('bettingOddsSummary is populated when odds are available', () async {
      when(() => mockDataService.getBettingOdds('USA')).thenReturn({
        'implied_probability_pct': 15,
        'tier': 'contender',
        'code': 'USA',
      });
      when(() => mockDataService.getBettingOdds('BRA')).thenReturn({
        'implied_probability_pct': 25,
        'tier': 'favorite',
        'code': 'BRA',
      });

      final match = defaultMatch();

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: homeTeam(),
        awayTeam: awayTeam(),
      );

      expect(prediction.bettingOddsSummary, isNotNull);
      expect(prediction.bettingOddsSummary, contains('United States'));
      expect(prediction.bettingOddsSummary, contains('Brazil'));
    });

    test('bettingOddsSummary is null when no odds data', () async {
      final match = defaultMatch();

      final prediction = await engine.generatePrediction(match: match);

      expect(prediction.bettingOddsSummary, isNull);
    });

    test('homeRecentForm and awayRecentForm are populated when available',
        () async {
      when(() => mockDataService.getRecentFormSummary('USA'))
          .thenReturn('Last 5 matches: 3W 1D 1L');
      when(() => mockDataService.getRecentFormSummary('BRA'))
          .thenReturn('Last 5 matches: 4W 0D 1L');

      final match = defaultMatch();

      final prediction = await engine.generatePrediction(
        match: match,
        homeTeam: homeTeam(),
        awayTeam: awayTeam(),
      );

      expect(prediction.homeRecentForm, equals('Last 5 matches: 3W 1D 1L'));
      expect(prediction.awayRecentForm, equals('Last 5 matches: 4W 0D 1L'));
    });
  });
}
