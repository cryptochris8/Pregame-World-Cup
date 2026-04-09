import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/match_narrative.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/ai_match_summary/narrative_tab.dart';

void main() {
  late MatchNarrative sampleNarrative;

  setUp(() {
    sampleNarrative = MatchNarrative.fromJson({
      'matchKey': 'ARG_BRA',
      'team1Code': 'ARG',
      'team2Code': 'BRA',
      'team1Name': 'Argentina',
      'team2Name': 'Brazil',
      'generatedAt': '2026-04-09T00:00:00Z',
      'dataVersion': 1,
      'headline': 'The Eternal Rivalry Meets Its Greatest Chapter',
      'subheadline': 'Messi faces desperate Brazil in the match of the tournament',
      'openingNarrative':
          'There are football matches, and then there is Argentina versus Brazil. '
          'This is not merely a game — it is a 111-chapter novel written in sweat and genius.\n\n'
          'Argentina arrive as defending world champions. Brazil haven\'t lifted the trophy since 2002.',
      'tacticalBreakdown': {
        'title': 'The Chess Match',
        'narrative': 'Argentina play a controlled 4-3-3. Brazil prefer a direct 4-2-3-1.',
        'team1Formation': '4-3-3',
        'team2Formation': '4-2-3-1',
        'keyMatchup': 'Enzo Fernández vs Bruno Guimarães in midfield',
      },
      'dataInsights': {
        'title': 'By The Numbers',
        'eloAnalysis': 'Argentina (1873) vs Brazil (1820).',
        'formAnalysis': 'Argentina won 12 of 18 qualifiers.',
        'squadValueComparison': 'Brazil outspend Argentina on paper.',
      },
      'playerSpotlights': [
        {
          'name': 'Lionel Messi',
          'teamCode': 'ARG',
          'narrative': 'Every step echoes with finality.',
          'statline': '8 goals in 15 appearances',
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
    });
  });

  Widget buildWidget(MatchNarrative narrative) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: NarrativeTab(narrative: narrative),
        ),
      ),
    );
  }

  group('NarrativeTab', () {
    testWidgets('renders headline and subheadline', (tester) async {
      await tester.pumpWidget(buildWidget(sampleNarrative));

      expect(find.text('The Eternal Rivalry Meets Its Greatest Chapter'), findsOneWidget);
      expect(find.text('Messi faces desperate Brazil in the match of the tournament'), findsOneWidget);
    });

    testWidgets('renders opening narrative paragraphs', (tester) async {
      await tester.pumpWidget(buildWidget(sampleNarrative));

      expect(find.textContaining('111-chapter novel'), findsOneWidget);
      expect(find.textContaining('defending world champions'), findsOneWidget);
    });

    testWidgets('renders tactical breakdown with formations', (tester) async {
      await tester.pumpWidget(buildWidget(sampleNarrative));

      expect(find.text('The Chess Match'), findsOneWidget);
      expect(find.text('4-3-3'), findsOneWidget);
      expect(find.text('4-2-3-1'), findsOneWidget);
    });

    testWidgets('renders key matchup callout', (tester) async {
      await tester.pumpWidget(buildWidget(sampleNarrative));

      expect(find.text('KEY MATCHUP'), findsOneWidget);
      expect(find.textContaining('Enzo Fernández vs Bruno Guimarães'), findsOneWidget);
    });

    testWidgets('renders data insights section', (tester) async {
      await tester.pumpWidget(buildWidget(sampleNarrative));
      await tester.scrollUntilVisible(
        find.text('Strength Rating'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Strength Rating'), findsOneWidget);
      expect(find.text('Current Form'), findsOneWidget);
      expect(find.text('Squad Investment'), findsOneWidget);
    });

    testWidgets('renders player spotlights', (tester) async {
      await tester.pumpWidget(buildWidget(sampleNarrative));
      await tester.scrollUntilVisible(
        find.text('Lionel Messi'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Lionel Messi'), findsOneWidget);
      expect(find.text('ARG'), findsAtLeast(1));
      expect(find.textContaining('8 goals'), findsOneWidget);
    });

    testWidgets('renders verdict with prediction and confidence', (tester) async {
      await tester.pumpWidget(buildWidget(sampleNarrative));
      await tester.scrollUntilVisible(
        find.text('Argentina 2-2 Brazil'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Argentina 2-2 Brazil'), findsOneWidget);
      expect(find.text('The Verdict'), findsOneWidget);
    });

    testWidgets('renders alternative scenarios', (tester) async {
      await tester.pumpWidget(buildWidget(sampleNarrative));
      await tester.scrollUntilVisible(
        find.text('ALTERNATIVE SCENARIOS'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('ALTERNATIVE SCENARIOS'), findsOneWidget);
      expect(find.text('Argentina 2-1 Brazil'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('renders closing line', (tester) async {
      await tester.pumpWidget(buildWidget(sampleNarrative));
      await tester.scrollUntilVisible(
        find.textContaining('remember it forever'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.textContaining('remember it forever'), findsOneWidget);
    });
  });
}
