import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import '../bloc/mock_repositories.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().contains('A RenderFlex overflowed by'),
          );
      if (isOverflowError) {
        FlutterError.presentError(details);
      }
    };
  });

  group('ReminderButton', () {
    testWidgets('can be constructed with match', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = ReminderButton(match: match);

      expect(widget, isNotNull);
      expect(widget.match, equals(match));
    });

    testWidgets('is a StatefulWidget', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = ReminderButton(match: match);

      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('has default showLabel as false', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = ReminderButton(match: match);

      expect(widget.showLabel, isFalse);
    });

    testWidgets('can be constructed with showLabel true', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = ReminderButton(
        match: match,
        showLabel: true,
      );

      expect(widget.showLabel, isTrue);
    });

    testWidgets('has default iconSize as 24.0', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = ReminderButton(match: match);

      expect(widget.iconSize, 24.0);
    });

    testWidgets('can be constructed with custom iconSize', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = ReminderButton(
        match: match,
        iconSize: 32.0,
      );

      expect(widget.iconSize, 32.0);
    });

    testWidgets('can be constructed with custom colors', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = ReminderButton(
        match: match,
        activeColor: Colors.blue,
        inactiveColor: Colors.grey,
      );

      expect(widget.activeColor, Colors.blue);
      expect(widget.inactiveColor, Colors.grey);
    });

    testWidgets('stores match data correctly', (tester) async {
      final match = TestDataFactory.createMatch(
        matchId: 'test_match',
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        dateTime: DateTime(2026, 6, 15, 18, 0),
      );

      final widget = ReminderButton(match: match);

      expect(widget.match.matchId, 'test_match');
      expect(widget.match.homeTeamName, 'Brazil');
      expect(widget.match.awayTeamName, 'Argentina');
      expect(widget.match.dateTime, DateTime(2026, 6, 15, 18, 0));
    });

    testWidgets('can be constructed with key', (tester) async {
      final match = TestDataFactory.createMatch();
      final key = const Key('reminder_button');

      final widget = ReminderButton(
        key: key,
        match: match,
      );

      expect(widget.key, equals(key));
      expect(widget.match, equals(match));
    });

    testWidgets('widget type verification', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = ReminderButton(match: match);

      expect(widget, isA<Widget>());
      expect(widget, isA<StatefulWidget>());
      expect(widget.runtimeType.toString(), 'ReminderButton');
    });

    testWidgets('handles future matches', (tester) async {
      final futureMatch = TestDataFactory.createMatch(
        dateTime: DateTime.now().add(const Duration(days: 7)),
      );

      final widget = ReminderButton(match: futureMatch);

      expect(widget.match.dateTime!.isAfter(DateTime.now()), isTrue);
    });

    testWidgets('handles past matches', (tester) async {
      final pastMatch = TestDataFactory.createMatch(
        dateTime: DateTime.now().subtract(const Duration(days: 7)),
      );

      final widget = ReminderButton(match: pastMatch);

      expect(widget.match.dateTime!.isBefore(DateTime.now()), isTrue);
    });
  });

  group('ReminderIndicator', () {
    testWidgets('can be constructed with matchId', (tester) async {
      const matchId = 'match_123';

      final widget = ReminderIndicator(matchId: matchId);

      expect(widget, isNotNull);
      expect(widget.matchId, matchId);
    });

    testWidgets('is a StatelessWidget', (tester) async {
      const matchId = 'match_123';

      final widget = ReminderIndicator(matchId: matchId);

      expect(widget, isA<StatelessWidget>());
    });

    testWidgets('stores matchId correctly', (tester) async {
      const matchId = 'test_match_456';

      final widget = ReminderIndicator(matchId: matchId);

      expect(widget.matchId, 'test_match_456');
    });

    testWidgets('can be constructed with key', (tester) async {
      const matchId = 'match_123';
      final key = const Key('reminder_indicator');

      final widget = ReminderIndicator(
        key: key,
        matchId: matchId,
      );

      expect(widget.key, equals(key));
      expect(widget.matchId, matchId);
    });

    testWidgets('widget type verification', (tester) async {
      const matchId = 'match_123';

      final widget = ReminderIndicator(matchId: matchId);

      expect(widget, isA<Widget>());
      expect(widget, isA<StatelessWidget>());
      expect(widget.runtimeType.toString(), 'ReminderIndicator');
    });
  });
}
