import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/local_match_summary_service.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/match_summary.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalMatchSummaryService service;

  setUp(() {
    service = LocalMatchSummaryService();
  });

  // Tests below rely on real bundled JSON files in
  // assets/data/worldcup/match_summaries/ that exist in the project.
  group('getMatchSummary', () {
    test('returns MatchSummary when asset file exists (canonical order)', () async {
      final result = await service.getMatchSummary('ARG', 'BRA');

      expect(result, isNotNull);
      expect(result!.id, 'ARG_BRA');
      expect(result.team1Code, anyOf('ARG', 'BRA'));
      expect(result.team2Code, anyOf('ARG', 'BRA'));
      expect(result.historicalAnalysis, isNotEmpty);
      expect(result.keyStorylines, isNotEmpty);
      expect(result.playersToWatch, isNotEmpty);
      expect(result.tacticalPreview, isNotEmpty);
      expect(result.prediction.predictedScore, isNotEmpty);
    });

    test('normalises team codes to uppercase before building filename', () async {
      final result = await service.getMatchSummary('arg', 'bra');
      expect(result, isNotNull);
      expect(result!.id, 'ARG_BRA');
    });

    test('sorts team codes alphabetically regardless of argument order', () async {
      final resultNormal = await service.getMatchSummary('ARG', 'BRA');
      service.clearCache();
      final resultReversed = await service.getMatchSummary('BRA', 'ARG');

      expect(resultNormal, isNotNull);
      expect(resultReversed, isNotNull);
      expect(resultNormal!.id, resultReversed!.id);
    });

    test('returns null when no JSON file exists for the matchup', () async {
      // No stub registered → rootBundle throws
      final result = await service.getMatchSummary('AAA', 'ZZZ');
      expect(result, isNull);
    });

    test('caches result — repeated calls return the same data', () async {
      final first = await service.getMatchSummary('ARG', 'BRA');
      final second = await service.getMatchSummary('ARG', 'BRA');

      // Both calls must succeed and produce equal results
      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(first!.id, second!.id);
      expect(first.historicalAnalysis, second.historicalAnalysis);
    });

    test('caches null for missing matchups — returns null on repeated calls',
        () async {
      final first = await service.getMatchSummary('AAA', 'ZZZ');
      final second = await service.getMatchSummary('AAA', 'ZZZ');

      expect(first, isNull);
      expect(second, isNull);
    });

    test('clearCache allows subsequent calls to succeed again', () async {
      // Load once
      final before = await service.getMatchSummary('ARG', 'BRA');
      expect(before, isNotNull);

      // Clear and reload — should still work
      service.clearCache();
      final after = await service.getMatchSummary('ARG', 'BRA');
      expect(after, isNotNull);
      expect(after!.id, before!.id);
    });
  });

  group('MatchSummary.fromJson', () {
    test('parses all fields correctly', () {
      final data = {
        'team1Code': 'FRA',
        'team2Code': 'ENG',
        'team1Name': 'France',
        'team2Name': 'England',
        'historicalAnalysis': 'Historic rivals.',
        'keyStorylines': ['2022 rematch'],
        'playersToWatch': [
          {
            'name': 'Mbappé',
            'teamCode': 'FRA',
            'position': 'Forward',
            'reason': 'Speed and goals',
          }
        ],
        'tacticalPreview': 'Tactical chess match.',
        'prediction': {
          'predictedOutcome': 'FRA',
          'predictedScore': '2-1',
          'confidence': 55,
          'reasoning': 'France are stronger.',
          'alternativeScenario': 'England could nick it.',
        },
        'pastEncountersSummary': 'France lead the H2H.',
        'funFacts': ['Their last WC meeting was 2022.'],
        'isFirstMeeting': false,
      };

      final summary = MatchSummary.fromJson(data);

      expect(summary.id, 'ENG_FRA'); // alphabetically sorted
      expect(summary.team1Code, 'FRA');
      expect(summary.team2Code, 'ENG');
      expect(summary.historicalAnalysis, 'Historic rivals.');
      expect(summary.keyStorylines, ['2022 rematch']);
      expect(summary.playersToWatch.first.name, 'Mbappé');
      expect(summary.tacticalPreview, 'Tactical chess match.');
      expect(summary.prediction.predictedOutcome, 'FRA');
      expect(summary.prediction.predictedScore, '2-1');
      expect(summary.prediction.confidence, 55);
      expect(summary.prediction.alternativeScenario, 'England could nick it.');
      expect(summary.pastEncountersSummary, 'France lead the H2H.');
      expect(summary.funFacts, ['Their last WC meeting was 2022.']);
      expect(summary.isFirstMeeting, false);
    });

    test('handles missing optional fields gracefully', () {
      final data = {
        'team1Code': 'USA',
        'team2Code': 'MEX',
        'team1Name': 'USA',
        'team2Name': 'Mexico',
        'historicalAnalysis': 'CONCACAF rivals.',
        'keyStorylines': <String>[],
        'playersToWatch': <Map<String, dynamic>>[],
        'tacticalPreview': 'Physical midfield battle.',
        'prediction': {
          'predictedOutcome': 'USA',
          'predictedScore': '1-0',
          'confidence': 50,
          'reasoning': 'Home advantage.',
        },
        'funFacts': <String>[],
        'isFirstMeeting': false,
      };

      final summary = MatchSummary.fromJson(data);

      expect(summary.pastEncountersSummary, isNull);
      expect(summary.prediction.alternativeScenario, isNull);
      expect(summary.updatedAt, isNull);
      expect(summary.keyStorylines, isEmpty);
      expect(summary.playersToWatch, isEmpty);
    });
  });
}
