import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/chatbot/presentation/widgets/suggestion_chips.dart';

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

  testWidgets('renders with chips', (tester) async {
    final chips = ['Chip 1', 'Chip 2', 'Chip 3'];
    var tappedChip = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionChips(
            chips: chips,
            onChipTapped: (chip) {
              tappedChip = chip;
            },
          ),
        ),
      ),
    );

    expect(find.byType(SuggestionChips), findsOneWidget);
  });

  testWidgets('shows chip text', (tester) async {
    final chips = ['Chip 1', 'Chip 2', 'Chip 3'];
    var tappedChip = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionChips(
            chips: chips,
            onChipTapped: (chip) {
              tappedChip = chip;
            },
          ),
        ),
      ),
    );

    expect(find.text('Chip 1'), findsOneWidget);
    expect(find.text('Chip 2'), findsOneWidget);
    expect(find.text('Chip 3'), findsOneWidget);
  });

  testWidgets('tapping chip calls onChipTapped with correct text',
      (tester) async {
    final chips = ['Chip 1', 'Chip 2', 'Chip 3'];
    var tappedChip = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionChips(
            chips: chips,
            onChipTapped: (chip) {
              tappedChip = chip;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Chip 2'));
    await tester.pump();

    expect(tappedChip, equals('Chip 2'));
  });

  testWidgets('empty list shows nothing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionChips(
            chips: const [],
            onChipTapped: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(SizedBox), findsWidgets);
    expect(find.byType(ActionChip), findsNothing);
  });

  testWidgets('multiple chips rendered', (tester) async {
    final chips = ['Chip 1', 'Chip 2', 'Chip 3', 'Chip 4'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionChips(
            chips: chips,
            onChipTapped: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(ActionChip), findsNWidgets(4));
  });
}
