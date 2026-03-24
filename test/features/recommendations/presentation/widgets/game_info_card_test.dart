import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/recommendations/presentation/widgets/game_info_card.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';

import '../../../schedule/schedule_test_factory.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: child,
          ),
        ),
      ),
    );
  }

  group('GameInfoCard', () {
    testWidgets('renders with basic game data', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule();

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.byType(GameInfoCard), findsOneWidget);
    });

    testWidgets('displays Game Details header', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule();

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.text('Game Details'), findsOneWidget);
    });

    testWidgets('shows away team name', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule(
        awayTeamName: 'Argentina',
      );

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.text('Argentina'), findsOneWidget);
    });

    testWidgets('shows home team name', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule(
        homeTeamName: 'Brazil',
      );

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.text('Brazil'), findsOneWidget);
    });

    testWidgets('shows venue info when stadium is present', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule(
        stadium: Stadium(
          stadiumId: 1,
          name: 'MetLife Stadium',
          city: 'East Rutherford',
          state: 'NJ',
          capacity: 82500,
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.textContaining('MetLife Stadium'), findsOneWidget);
      expect(find.textContaining('East Rutherford'), findsOneWidget);
      expect(find.textContaining('NJ'), findsOneWidget);
    });

    testWidgets('shows Venue TBD when no stadium', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule(
        stadium: null,
      );

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.text('Venue TBD'), findsOneWidget);
    });

    testWidgets('shows week number when present', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule(
        week: 5,
      );

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.text('Week 5'), findsOneWidget);
    });

    testWidgets('shows channel info when present', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule(
        channel: 'FOX',
      );

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.text('TV: FOX'), findsOneWidget);
    });

    testWidgets('shows formatted date when dateTimeUTC is present', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule(
        dateTimeUTC: DateTime.utc(2026, 6, 21, 20, 0),
      );

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      // Should display formatted date, not "Time TBD"
      expect(find.text('Time TBD'), findsNothing);
    });

    testWidgets('displays sports_soccer icon', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule();

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });

    testWidgets('displays access_time icon', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule();

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('displays location_on icon', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule();

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('displays calendar_today icon when week is present', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule(week: 3);

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('displays tv icon when channel is present', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule(channel: 'ESPN');

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.byIcon(Icons.tv), findsOneWidget);
    });

    testWidgets('renders complete game with all info', (tester) async {
      final game = ScheduleTestFactory.createUpcomingGame(
        awayTeamName: 'Spain',
        homeTeamName: 'Portugal',
        week: 2,
        channel: 'NBC',
        stadium: Stadium(
          stadiumId: 2,
          name: 'Rose Bowl',
          city: 'Pasadena',
          state: 'CA',
          capacity: 90888,
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.text('Game Details'), findsOneWidget);
      expect(find.text('Spain'), findsOneWidget);
      expect(find.text('Portugal'), findsOneWidget);
      expect(find.text('Week 2'), findsOneWidget);
      expect(find.text('TV: NBC'), findsOneWidget);
      expect(find.textContaining('Rose Bowl'), findsOneWidget);
    });

    testWidgets('renders without optional fields', (tester) async {
      final game = ScheduleTestFactory.createGameSchedule(
        week: null,
        channel: null,
      );

      await tester.pumpWidget(
        buildTestWidget(GameInfoCard(game: game)),
      );

      expect(find.text('Game Details'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsNothing);
      expect(find.byIcon(Icons.tv), findsNothing);
    });
  });
}
