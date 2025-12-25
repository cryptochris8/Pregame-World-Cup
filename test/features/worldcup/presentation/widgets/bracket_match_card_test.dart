import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/entities.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/widgets.dart';

import '../../presentation/bloc/mock_repositories.dart';

void main() {
  group('BracketMatchCard', () {
    testWidgets('renders scheduled bracket match', (tester) async {
      final match = TestDataFactory.createBracketMatch(
        stage: MatchStage.roundOf16,
        status: MatchStatus.scheduled,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BracketMatchCard(match: match),
          ),
        ),
      );

      expect(find.byType(BracketMatchCard), findsOneWidget);
      expect(find.text('USA'), findsOneWidget);
      expect(find.text('MEX'), findsOneWidget);
    });

    testWidgets('renders live bracket match with scores', (tester) async {
      final match = TestDataFactory.createBracketMatch(
        stage: MatchStage.quarterFinal,
        homeSlot: TestDataFactory.createBracketSlot(
          teamCode: 'BRA',
          teamNameOrPlaceholder: 'Brazil',
          score: 2,
        ),
        awaySlot: TestDataFactory.createBracketSlot(
          teamCode: 'ARG',
          teamNameOrPlaceholder: 'Argentina',
          score: 1,
        ),
        status: MatchStatus.inProgress,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: BracketMatchCard(match: match),
            ),
          ),
        ),
      );

      expect(find.text('BRA'), findsOneWidget);
      expect(find.text('ARG'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('renders completed match with winner highlighted', (tester) async {
      final match = TestDataFactory.createBracketMatch(
        stage: MatchStage.semiFinal,
        homeSlot: TestDataFactory.createBracketSlot(
          teamCode: 'GER',
          teamNameOrPlaceholder: 'Germany',
          score: 3,
        ),
        awaySlot: TestDataFactory.createBracketSlot(
          teamCode: 'FRA',
          teamNameOrPlaceholder: 'France',
          score: 2,
        ),
        status: MatchStatus.completed,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BracketMatchCard(match: match),
          ),
        ),
      );

      expect(find.text('GER'), findsOneWidget);
      expect(find.text('FRA'), findsOneWidget);
    });

    testWidgets('shows TBD for undetermined teams', (tester) async {
      final match = TestDataFactory.createBracketMatch(
        homeSlot: TestDataFactory.createBracketSlot(
          teamCode: null,
          teamNameOrPlaceholder: 'Winner QF1',
          isConfirmed: false,
        ),
        awaySlot: TestDataFactory.createBracketSlot(
          teamCode: null,
          teamNameOrPlaceholder: 'Winner QF2',
          isConfirmed: false,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BracketMatchCard(match: match),
          ),
        ),
      );

      expect(find.text('Winner QF1'), findsOneWidget);
      expect(find.text('Winner QF2'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      final match = TestDataFactory.createBracketMatch();
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BracketMatchCard(
              match: match,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BracketMatchCard));
      expect(tapped, isTrue);
    });

  });
}
