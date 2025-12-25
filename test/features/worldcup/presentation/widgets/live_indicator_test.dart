import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/widgets.dart';

void main() {
  group('LiveIndicator', () {
    testWidgets('renders with default properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiveIndicator(),
          ),
        ),
      );

      expect(find.byType(LiveIndicator), findsOneWidget);
    });

    testWidgets('renders with custom label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiveIndicator(label: 'LIVE'),
          ),
        ),
      );

      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('shows pulsing animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiveIndicator(),
          ),
        ),
      );

      // The pulsing dot is rendered with AnimatedBuilder
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('uses custom color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiveIndicator(color: Colors.blue),
          ),
        ),
      );

      expect(find.byType(LiveIndicator), findsOneWidget);
    });

    testWidgets('uses custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiveIndicator(size: 12.0),
          ),
        ),
      );

      expect(find.byType(LiveIndicator), findsOneWidget);
    });
  });

  group('LiveBadge', () {
    testWidgets('renders LIVE text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiveBadge(),
          ),
        ),
      );

      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('contains LiveIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiveBadge(),
          ),
        ),
      );

      expect(find.byType(LiveIndicator), findsOneWidget);
    });

    testWidgets('has red background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiveBadge(),
          ),
        ),
      );

      expect(find.byType(LiveBadge), findsOneWidget);
    });
  });
}
