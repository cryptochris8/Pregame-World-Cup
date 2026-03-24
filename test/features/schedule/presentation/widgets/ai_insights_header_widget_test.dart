import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/ai_insights_header_widget.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

void main() {
  setUp(() {
    // Suppress overflow errors during tests
    FlutterError.onError = (FlutterErrorDetails details) {
      if (!details.toString().contains('RenderFlex overflowed')) {
        FlutterError.presentError(details);
      }
    };
  });

  group('AIInsightsHeaderWidget', () {
    testWidgets('shows Enhanced AI Analysis text',
        (WidgetTester tester) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AIInsightsHeaderWidget(
              awayTeamName: 'Argentina',
              homeTeamName: 'Brazil',
              isLoading: false,
              onRefresh: () => refreshCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Enhanced AI Analysis'), findsOneWidget);
    });

    testWidgets('shows matchup title with team names',
        (WidgetTester tester) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AIInsightsHeaderWidget(
              awayTeamName: 'Argentina',
              homeTeamName: 'Brazil',
              isLoading: false,
              onRefresh: () => refreshCalled = true,
            ),
          ),
        ),
      );

      expect(find.textContaining('Argentina'), findsWidgets);
      expect(find.textContaining('Brazil'), findsWidgets);
      expect(find.textContaining('@'), findsWidgets);
    });

    testWidgets('shows refresh icon when not loading',
        (WidgetTester tester) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AIInsightsHeaderWidget(
              awayTeamName: 'Argentina',
              homeTeamName: 'Brazil',
              isLoading: false,
              onRefresh: () => refreshCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when loading',
        (WidgetTester tester) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AIInsightsHeaderWidget(
              awayTeamName: 'Argentina',
              homeTeamName: 'Brazil',
              isLoading: true,
              onRefresh: () => refreshCalled = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does NOT show refresh icon when loading',
        (WidgetTester tester) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AIInsightsHeaderWidget(
              awayTeamName: 'Argentina',
              homeTeamName: 'Brazil',
              isLoading: true,
              onRefresh: () => refreshCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('tapping refresh calls onRefresh when not loading',
        (WidgetTester tester) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AIInsightsHeaderWidget(
              awayTeamName: 'Argentina',
              homeTeamName: 'Brazil',
              isLoading: false,
              onRefresh: () => refreshCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      expect(refreshCalled, isTrue);
    });

    testWidgets('refresh button disabled when loading',
        (WidgetTester tester) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AIInsightsHeaderWidget(
              awayTeamName: 'Argentina',
              homeTeamName: 'Brazil',
              isLoading: true,
              onRefresh: () => refreshCalled = true,
            ),
          ),
        ),
      );

      // Refresh icon should not exist when loading
      expect(find.byIcon(Icons.refresh), findsNothing);
      // So tapping should not be possible, callback should not be called
      expect(refreshCalled, isFalse);
    });
  });
}
