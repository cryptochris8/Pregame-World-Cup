import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/entities.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/widgets.dart';

import '../../presentation/bloc/mock_repositories.dart';

void main() {
  group('TeamTile', () {
    testWidgets('renders team information', (tester) async {
      final team = TestDataFactory.createTeam(
        fifaCode: 'USA',
        countryName: 'United States',
        fifaRanking: 11,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamTile(team: team, showFavoriteButton: false),
          ),
        ),
      );

      expect(find.text('United States'), findsOneWidget);
    });

    testWidgets('shows FIFA ranking', (tester) async {
      final team = TestDataFactory.createTeam(
        fifaCode: 'BRA',
        countryName: 'Brazil',
        fifaRanking: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamTile(team: team, showFavoriteButton: false),
          ),
        ),
      );

      expect(find.text('#1'), findsOneWidget);
    });

    testWidgets('shows group assignment', (tester) async {
      final team = TestDataFactory.createTeam(
        fifaCode: 'GER',
        countryName: 'Germany',
        group: 'C',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamTile(team: team, showFavoriteButton: false),
          ),
        ),
      );

      expect(find.text('Group C'), findsOneWidget);
    });

    testWidgets('shows host nation badge', (tester) async {
      final team = TestDataFactory.createTeam(
        fifaCode: 'USA',
        countryName: 'United States',
        isHostNation: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamTile(team: team, showFavoriteButton: false),
          ),
        ),
      );

      // Should show HOST text
      expect(find.text('HOST'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      final team = TestDataFactory.createTeam();
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamTile(
              team: team,
              onTap: () => tapped = true,
              showFavoriteButton: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TeamTile));
      expect(tapped, isTrue);
    });

    testWidgets('shows World Cup titles', (tester) async {
      final team = TestDataFactory.createTeam(
        fifaCode: 'BRA',
        countryName: 'Brazil',
        worldCupTitles: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamTile(team: team, showFavoriteButton: false),
          ),
        ),
      );

      // Should show trophy count
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('shows favorite button when enabled', (tester) async {
      final team = TestDataFactory.createTeam();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamTile(
              team: team,
              showFavoriteButton: true,
              isFavorite: false,
            ),
          ),
        ),
      );

      expect(find.byType(FavoriteButton), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('shows filled heart when favorited', (tester) async {
      final team = TestDataFactory.createTeam();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamTile(
              team: team,
              showFavoriteButton: true,
              isFavorite: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('calls onFavoriteToggle when favorite button tapped', (tester) async {
      final team = TestDataFactory.createTeam();
      bool toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamTile(
              team: team,
              showFavoriteButton: true,
              isFavorite: false,
              onFavoriteToggle: () => toggleCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FavoriteButton));
      expect(toggleCalled, isTrue);
    });
  });

  group('TeamCard', () {
    testWidgets('renders in card format', (tester) async {
      final team = TestDataFactory.createTeam(
        fifaCode: 'ARG',
        countryName: 'Argentina',
        shortName: 'Argentina',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: TeamCard(team: team, showFavoriteButton: false),
            ),
          ),
        ),
      );

      expect(find.text('Argentina'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      final team = TestDataFactory.createTeam();
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: TeamCard(
                team: team,
                onTap: () => tapped = true,
                showFavoriteButton: false,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TeamCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows favorite button when enabled', (tester) async {
      final team = TestDataFactory.createTeam();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: TeamCard(
                team: team,
                showFavoriteButton: true,
                isFavorite: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FavoriteButton), findsOneWidget);
    });

    testWidgets('shows filled heart when favorited', (tester) async {
      final team = TestDataFactory.createTeam();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: TeamCard(
                team: team,
                showFavoriteButton: true,
                isFavorite: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  group('TeamChip', () {
    testWidgets('renders team code', (tester) async {
      final team = TestDataFactory.createTeam(
        fifaCode: 'USA',
        countryName: 'United States',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamChip(team: team),
          ),
        ),
      );

      expect(find.text('USA'), findsOneWidget);
    });

    testWidgets('shows selected state', (tester) async {
      final team = TestDataFactory.createTeam(
        fifaCode: 'BRA',
        countryName: 'Brazil',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamChip(
              team: team,
              selected: true,
            ),
          ),
        ),
      );

      expect(find.text('BRA'), findsOneWidget);
    });
  });
}
