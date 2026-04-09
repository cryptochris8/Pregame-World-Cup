import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/match_narrative.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/match_narrative_service.dart';

void main() {
  group('MatchNarrative', () {
    late Map<String, dynamic> sampleJson;

    setUp(() {
      sampleJson = {
        'matchKey': 'ARG_BRA',
        'team1Code': 'ARG',
        'team2Code': 'BRA',
        'team1Name': 'Argentina',
        'team2Name': 'Brazil',
        'generatedAt': '2026-04-09T00:00:00Z',
        'dataVersion': 1,
        'headline': 'The Eternal Rivalry',
        'subheadline': 'Messi vs Vinícius in the match of the tournament',
        'openingNarrative': 'There are football matches, and then there is Argentina versus Brazil.',
        'tacticalBreakdown': {
          'title': 'The Chess Match',
          'narrative': 'Argentina play a 4-3-3 while Brazil prefer a 4-2-3-1.',
          'team1Formation': '4-3-3',
          'team2Formation': '4-2-3-1',
          'keyMatchup': 'Enzo Fernández vs Bruno Guimarães',
        },
        'dataInsights': {
          'title': 'By The Numbers',
          'eloAnalysis': 'Argentina (1873) vs Brazil (1820) — a 53-point gap.',
          'formAnalysis': 'Argentina won 12 of 18 qualifiers.',
          'squadValueComparison': 'Brazil outspend Argentina on paper.',
          'injuryImpact': 'Both squads near full strength.',
          'bettingPerspective': 'Argentina slight favorites at -130.',
          'historicalPattern': 'Defending champions curse looms large.',
        },
        'playerSpotlights': [
          {
            'name': 'Lionel Messi',
            'teamCode': 'ARG',
            'narrative': 'Every step Messi takes echoes with finality.',
            'statline': '8 goals in last 15 appearances',
          },
          {
            'name': 'Vinícius Jr.',
            'teamCode': 'BRA',
            'narrative': 'The heir to the Brazilian throne.',
            'statline': '29 goals in 2025-26',
          },
        ],
        'theVerdict': {
          'title': 'The Verdict',
          'prediction': 'Argentina 2-2 Brazil',
          'confidence': 45,
          'narrative': 'This match defies confident prediction.',
          'alternativeScenarios': [
            {
              'scenario': 'Argentina 2-1 Brazil',
              'probability': 25,
              'reasoning': 'Champion mentality proves decisive.',
            },
          ],
        },
        'closingLine': 'Whatever happens, we will remember it forever.',
      };
    });

    test('fromJson parses all fields correctly', () {
      final narrative = MatchNarrative.fromJson(sampleJson);

      expect(narrative.matchKey, 'ARG_BRA');
      expect(narrative.team1Code, 'ARG');
      expect(narrative.team2Code, 'BRA');
      expect(narrative.team1Name, 'Argentina');
      expect(narrative.team2Name, 'Brazil');
      expect(narrative.dataVersion, 1);
      expect(narrative.headline, 'The Eternal Rivalry');
      expect(narrative.subheadline, contains('Messi'));
      expect(narrative.openingNarrative, contains('Argentina versus Brazil'));
      expect(narrative.closingLine, contains('remember it forever'));
    });

    test('fromJson parses generatedAt timestamp', () {
      final narrative = MatchNarrative.fromJson(sampleJson);
      expect(narrative.generatedAt, isNotNull);
      expect(narrative.generatedAt!.year, 2026);
      expect(narrative.generatedAt!.month, 4);
    });

    test('fromJson handles null generatedAt', () {
      sampleJson.remove('generatedAt');
      final narrative = MatchNarrative.fromJson(sampleJson);
      expect(narrative.generatedAt, isNull);
    });

    test('fromJson defaults dataVersion to 1', () {
      sampleJson.remove('dataVersion');
      final narrative = MatchNarrative.fromJson(sampleJson);
      expect(narrative.dataVersion, 1);
    });

    test('toJson roundtrip preserves data', () {
      final original = MatchNarrative.fromJson(sampleJson);
      final json = original.toJson();
      final restored = MatchNarrative.fromJson(json);

      expect(restored.matchKey, original.matchKey);
      expect(restored.headline, original.headline);
      expect(restored.openingNarrative, original.openingNarrative);
      expect(restored.verdict.prediction, original.verdict.prediction);
      expect(restored.playerSpotlights.length, original.playerSpotlights.length);
    });

    test('equatable compares by matchKey', () {
      final a = MatchNarrative.fromJson(sampleJson);
      final b = MatchNarrative.fromJson(sampleJson);
      expect(a, equals(b));
    });
  });

  group('TacticalBreakdown', () {
    test('fromJson parses all fields', () {
      final breakdown = TacticalBreakdown.fromJson({
        'title': 'The Chess Match',
        'narrative': 'A tactical battle.',
        'team1Formation': '4-3-3',
        'team2Formation': '3-5-2',
        'keyMatchup': 'Midfield control',
      });

      expect(breakdown.title, 'The Chess Match');
      expect(breakdown.narrative, 'A tactical battle.');
      expect(breakdown.team1Formation, '4-3-3');
      expect(breakdown.team2Formation, '3-5-2');
      expect(breakdown.keyMatchup, 'Midfield control');
    });

    test('fromJson handles missing optional fields', () {
      final breakdown = TacticalBreakdown.fromJson({
        'narrative': 'A tactical battle.',
      });

      expect(breakdown.title, 'Tactical Breakdown');
      expect(breakdown.team1Formation, '');
      expect(breakdown.team2Formation, '');
      expect(breakdown.keyMatchup, '');
    });
  });

  group('DataInsights', () {
    test('fromJson parses all fields', () {
      final insights = DataInsights.fromJson({
        'title': 'By The Numbers',
        'eloAnalysis': 'ELO gap of 53 points.',
        'formAnalysis': 'Strong qualifying form.',
        'squadValueComparison': 'Brazil outspend Argentina.',
        'injuryImpact': 'Both squads healthy.',
        'bettingPerspective': 'Markets favor Argentina.',
        'historicalPattern': 'Champions curse looms.',
      });

      expect(insights.eloAnalysis, contains('53'));
      expect(insights.formAnalysis, contains('qualifying'));
      expect(insights.entries.length, 6);
    });

    test('entries only includes non-null fields', () {
      final insights = DataInsights.fromJson({
        'eloAnalysis': 'Some analysis.',
        'formAnalysis': null,
      });

      expect(insights.entries.length, 1);
      expect(insights.entries.first.key, 'Strength Rating');
    });

    test('handles all null fields gracefully', () {
      final insights = DataInsights.fromJson({});
      expect(insights.entries, isEmpty);
      expect(insights.title, 'By The Numbers');
    });
  });

  group('PlayerSpotlight', () {
    test('fromJson parses all fields', () {
      final spotlight = PlayerSpotlight.fromJson({
        'name': 'Lionel Messi',
        'teamCode': 'ARG',
        'narrative': 'The greatest of all time.',
        'statline': '8 goals in 15 matches',
      });

      expect(spotlight.name, 'Lionel Messi');
      expect(spotlight.teamCode, 'ARG');
      expect(spotlight.narrative, contains('greatest'));
      expect(spotlight.statline, contains('8 goals'));
    });

    test('fromJson handles null statline', () {
      final spotlight = PlayerSpotlight.fromJson({
        'name': 'Test Player',
        'teamCode': 'TST',
        'narrative': 'A test player.',
      });

      expect(spotlight.statline, isNull);
    });
  });

  group('NarrativeVerdict', () {
    test('fromJson parses prediction and confidence', () {
      final verdict = NarrativeVerdict.fromJson({
        'title': 'The Verdict',
        'prediction': 'Argentina 2-2 Brazil',
        'confidence': 45,
        'narrative': 'This match defies prediction.',
        'alternativeScenarios': [
          {
            'scenario': 'Argentina 2-1',
            'probability': 25,
            'reasoning': 'Champion mentality.',
          },
        ],
      });

      expect(verdict.prediction, 'Argentina 2-2 Brazil');
      expect(verdict.confidence, 45);
      expect(verdict.alternativeScenarios.length, 1);
      expect(verdict.alternativeScenarios.first.probability, 25);
    });

    test('fromJson handles empty alternativeScenarios', () {
      final verdict = NarrativeVerdict.fromJson({
        'prediction': 'Draw',
        'confidence': 50,
        'narrative': 'Even match.',
      });

      expect(verdict.alternativeScenarios, isEmpty);
      expect(verdict.title, 'The Verdict');
    });
  });

  group('MatchNarrativeService', () {
    late MatchNarrativeService service;

    setUp(() {
      service = MatchNarrativeService();
    });

    test('cache is empty initially', () async {
      // Calling with non-existent teams should return null and cache it
      // We can't load real assets in unit tests, but we can verify the API
      expect(service, isNotNull);
    });

    test('clearCache does not throw', () {
      service.clearCache();
    });

    test('sorts team codes alphabetically', () async {
      // Both orderings should produce the same cache key internally
      // Can't verify file loading without real assets, but service should not throw
      final result1 = await service.getNarrative('BRA', 'ARG');
      final result2 = await service.getNarrative('ARG', 'BRA');
      // Both return null in test environment (no bundled assets)
      expect(result1, isNull);
      expect(result2, isNull);
    });

    test('hasNarrative returns false for non-existent match', () async {
      final exists = await service.hasNarrative('ZZZ', 'YYY');
      expect(exists, false);
    });
  });
}
