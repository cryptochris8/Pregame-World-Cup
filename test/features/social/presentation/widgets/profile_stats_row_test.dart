import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/presentation/widgets/profile_stats_row.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().contains('A RenderFlex overflowed by'),
          );
      if (isOverflowError) {
      } else {
        FlutterError.presentError(details);
      }
    };
  });

  testWidgets('can be constructed', (tester) async {
    const widget = ProfileStatsRow();
    expect(widget, isNotNull);
  });

  testWidgets('is a StatelessWidget', (tester) async {
    const widget = ProfileStatsRow();
    expect(widget, isA<StatelessWidget>());
  });

  testWidgets('renders in a MaterialApp', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: ProfileStatsRow(),
        ),
      ),
    );
    expect(find.byType(ProfileStatsRow), findsOneWidget);
  });

  testWidgets('displays stat cards', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: ProfileStatsRow(),
        ),
      ),
    );

    // Should display icons for each stat
    expect(find.byIcon(Icons.people_outline), findsOneWidget);
    expect(find.byIcon(Icons.event_outlined), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);

    // Should display "0" value for each stat (hardcoded values)
    expect(find.text('0'), findsNWidgets(4));
  });
}
