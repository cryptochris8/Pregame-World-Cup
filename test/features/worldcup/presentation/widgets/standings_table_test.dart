import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/entities.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/widgets.dart';

import '../../presentation/bloc/mock_repositories.dart';

void main() {
  group('StandingsTable', () {
    testWidgets('renders group header', (tester) async {
      final group = TestDataFactory.createGroup(groupLetter: 'A');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StandingsTable(group: group),
            ),
          ),
        ),
      );

      expect(find.text('Group A'), findsOneWidget);
    });

    testWidgets('renders all team standings', (tester) async {
      final group = TestDataFactory.createGroup(
        groupLetter: 'B',
        standings: [
          TestDataFactory.createStanding(teamCode: 'USA', teamName: 'United States', position: 1),
          TestDataFactory.createStanding(teamCode: 'MEX', teamName: 'Mexico', position: 2),
          TestDataFactory.createStanding(teamCode: 'CAN', teamName: 'Canada', position: 3),
          TestDataFactory.createStanding(teamCode: 'JAM', teamName: 'Jamaica', position: 4),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StandingsTable(group: group),
            ),
          ),
        ),
      );

      expect(find.text('USA'), findsOneWidget);
      expect(find.text('MEX'), findsOneWidget);
      expect(find.text('CAN'), findsOneWidget);
      expect(find.text('JAM'), findsOneWidget);
    });

    testWidgets('shows points column', (tester) async {
      final group = TestDataFactory.createGroup(
        standings: [
          TestDataFactory.createStanding(won: 3, drawn: 0, lost: 0), // 9 points
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StandingsTable(group: group),
            ),
          ),
        ),
      );

      // Header should show Pts
      expect(find.text('Pts'), findsOneWidget);
      // Should show 9 points
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('renders complete standings table', (tester) async {
      final group = TestDataFactory.createGroup();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StandingsTable(group: group),
            ),
          ),
        ),
      );

      // Table should render
      expect(find.byType(StandingsTable), findsOneWidget);
    });
  });
}
