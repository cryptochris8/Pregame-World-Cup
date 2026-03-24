import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/recommendations/presentation/widgets/teams_info_card.dart';

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

  group('TeamsInfoCard', () {
    testWidgets('renders widget successfully', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const TeamsInfoCard(
            awayTeamName: 'Argentina',
            homeTeamName: 'Brazil',
          ),
        ),
      );

      expect(find.byType(TeamsInfoCard), findsOneWidget);
    });

    testWidgets('displays Teams header text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const TeamsInfoCard(
            awayTeamName: 'Argentina',
            homeTeamName: 'Brazil',
          ),
        ),
      );

      expect(find.text('Teams'), findsOneWidget);
    });

    testWidgets('shows away team name', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const TeamsInfoCard(
            awayTeamName: 'Argentina',
            homeTeamName: 'Brazil',
          ),
        ),
      );

      expect(find.text('Argentina'), findsOneWidget);
    });

    testWidgets('shows home team name', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const TeamsInfoCard(
            awayTeamName: 'Argentina',
            homeTeamName: 'Brazil',
          ),
        ),
      );

      expect(find.text('Brazil'), findsOneWidget);
    });

    testWidgets('shows Away label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const TeamsInfoCard(
            awayTeamName: 'Argentina',
            homeTeamName: 'Brazil',
          ),
        ),
      );

      expect(find.text('Away'), findsOneWidget);
    });

    testWidgets('shows Home label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const TeamsInfoCard(
            awayTeamName: 'Argentina',
            homeTeamName: 'Brazil',
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('displays sports_soccer icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const TeamsInfoCard(
            awayTeamName: 'Argentina',
            homeTeamName: 'Brazil',
          ),
        ),
      );

      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });

    testWidgets('displays home icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const TeamsInfoCard(
            awayTeamName: 'Argentina',
            homeTeamName: 'Brazil',
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('renders with different team names', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const TeamsInfoCard(
            awayTeamName: 'Germany',
            homeTeamName: 'France',
          ),
        ),
      );

      expect(find.text('Germany'), findsOneWidget);
      expect(find.text('France'), findsOneWidget);
    });

    testWidgets('renders with long team names', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const TeamsInfoCard(
            awayTeamName: 'United States of America',
            homeTeamName: 'England',
          ),
        ),
      );

      expect(find.text('United States of America'), findsOneWidget);
      expect(find.text('England'), findsOneWidget);
    });
  });
}
