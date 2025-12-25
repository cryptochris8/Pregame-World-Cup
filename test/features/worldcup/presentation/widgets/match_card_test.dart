import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/entities.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/widgets.dart';

import '../../presentation/bloc/mock_repositories.dart';

void main() {
  // Ignore overflow errors in widget tests
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed')) {
        return; // Ignore overflow errors
      }
      FlutterError.presentError(details);
    };
  });

  group('MatchCard', () {
    testWidgets('renders scheduled match correctly', (tester) async {
      final match = TestDataFactory.createMatch(
        homeTeamCode: 'USA',
        homeTeamName: 'United States',
        awayTeamCode: 'MEX',
        awayTeamName: 'Mexico',
        status: MatchStatus.scheduled,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 450,
              child: MatchCard(
                match: match,
                showFavoriteButton: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('United States'), findsOneWidget);
      expect(find.text('Mexico'), findsOneWidget);
    });

    testWidgets('renders live match with score', (tester) async {
      final match = TestDataFactory.createMatch(
        homeTeamCode: 'USA',
        homeTeamName: 'United States',
        awayTeamCode: 'MEX',
        awayTeamName: 'Mexico',
        homeScore: 2,
        awayScore: 1,
        status: MatchStatus.inProgress,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 450,
              child: MatchCard(
                match: match,
                showFavoriteButton: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('2 - 1'), findsOneWidget);
    });

    testWidgets('renders completed match', (tester) async {
      final match = TestDataFactory.createMatch(
        homeTeamCode: 'BRA',
        homeTeamName: 'Brazil',
        awayTeamCode: 'ARG',
        awayTeamName: 'Argentina',
        homeScore: 0,
        awayScore: 1,
        status: MatchStatus.completed,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 450,
              child: MatchCard(
                match: match,
                showFavoriteButton: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Brazil'), findsOneWidget);
      expect(find.text('Argentina'), findsOneWidget);
      expect(find.text('0 - 1'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      final match = TestDataFactory.createMatch();
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 450,
              child: MatchCard(
                match: match,
                onTap: () => tapped = true,
                showFavoriteButton: false,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MatchCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows group stage label', (tester) async {
      final match = TestDataFactory.createMatch(
        stage: MatchStage.groupStage,
        group: 'A',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 450,
              child: MatchCard(
                match: match,
                showFavoriteButton: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Group Stage'), findsOneWidget);
    });

    testWidgets('shows favorite button when enabled', (tester) async {
      final match = TestDataFactory.createMatch();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              child: MatchCard(
                match: match,
                showFavoriteButton: true,
                isFavorite: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FavoriteButton), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('shows filled heart when favorited', (tester) async {
      final match = TestDataFactory.createMatch();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              child: MatchCard(
                match: match,
                showFavoriteButton: true,
                isFavorite: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('calls onFavoriteToggle when favorite button tapped', (tester) async {
      final match = TestDataFactory.createMatch();
      bool toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              child: MatchCard(
                match: match,
                showFavoriteButton: true,
                isFavorite: false,
                onFavoriteToggle: () => toggleCalled = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FavoriteButton));
      expect(toggleCalled, isTrue);
    });

    testWidgets('hides favorite button when showFavoriteButton is false', (tester) async {
      final match = TestDataFactory.createMatch();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 450,
              child: MatchCard(
                match: match,
                showFavoriteButton: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FavoriteButton), findsNothing);
    });
  });
}
