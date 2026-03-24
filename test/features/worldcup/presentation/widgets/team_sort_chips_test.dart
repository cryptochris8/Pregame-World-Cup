import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

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

  Widget buildWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('TeamSortChips', () {
    testWidgets('renders chips for all sort options', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          TeamSortChips(
            selectedOption: TeamsSortOption.alphabetical,
            onOptionChanged: (_) {},
          ),
        ),
      );

      // Verify all sort option chips are rendered
      expect(find.text('A-Z'), findsOneWidget);
      expect(find.text('FIFA Ranking'), findsOneWidget);
      expect(find.text('Confederation'), findsOneWidget);
      expect(find.text('Group'), findsOneWidget);
    });

    testWidgets('A-Z chip is selected when selectedOption is alphabetical', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          TeamSortChips(
            selectedOption: TeamsSortOption.alphabetical,
            onOptionChanged: (_) {},
          ),
        ),
      );

      final alphabeticalChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('A-Z'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(alphabeticalChip.selected, isTrue);
    });

    testWidgets('FIFA Ranking chip is selected when selectedOption is worldRanking', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          TeamSortChips(
            selectedOption: TeamsSortOption.worldRanking,
            onOptionChanged: (_) {},
          ),
        ),
      );

      final worldRankingChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('FIFA Ranking'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(worldRankingChip.selected, isTrue);
    });

    testWidgets('Confederation chip is selected when selectedOption is confederation', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          TeamSortChips(
            selectedOption: TeamsSortOption.confederation,
            onOptionChanged: (_) {},
          ),
        ),
      );

      final confederationChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Confederation'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(confederationChip.selected, isTrue);
    });

    testWidgets('Group chip is selected when selectedOption is group', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          TeamSortChips(
            selectedOption: TeamsSortOption.group,
            onOptionChanged: (_) {},
          ),
        ),
      );

      final groupChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Group'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(groupChip.selected, isTrue);
    });

    testWidgets('tapping A-Z chip calls callback with alphabetical', (tester) async {
      TeamsSortOption? capturedOption;

      await tester.pumpWidget(
        buildWidget(
          TeamSortChips(
            selectedOption: TeamsSortOption.worldRanking,
            onOptionChanged: (option) {
              capturedOption = option;
            },
          ),
        ),
      );

      await tester.tap(find.text('A-Z'));
      await tester.pumpAndSettle();

      expect(capturedOption, TeamsSortOption.alphabetical);
    });

    testWidgets('tapping FIFA Ranking chip calls callback with worldRanking', (tester) async {
      TeamsSortOption? capturedOption;

      await tester.pumpWidget(
        buildWidget(
          TeamSortChips(
            selectedOption: TeamsSortOption.alphabetical,
            onOptionChanged: (option) {
              capturedOption = option;
            },
          ),
        ),
      );

      await tester.tap(find.text('FIFA Ranking'));
      await tester.pumpAndSettle();

      expect(capturedOption, TeamsSortOption.worldRanking);
    });

    testWidgets('tapping Confederation chip calls callback with confederation', (tester) async {
      TeamsSortOption? capturedOption;

      await tester.pumpWidget(
        buildWidget(
          TeamSortChips(
            selectedOption: TeamsSortOption.alphabetical,
            onOptionChanged: (option) {
              capturedOption = option;
            },
          ),
        ),
      );

      await tester.tap(find.text('Confederation'));
      await tester.pumpAndSettle();

      expect(capturedOption, TeamsSortOption.confederation);
    });

    testWidgets('tapping Group chip calls callback with group', (tester) async {
      TeamsSortOption? capturedOption;

      await tester.pumpWidget(
        buildWidget(
          TeamSortChips(
            selectedOption: TeamsSortOption.alphabetical,
            onOptionChanged: (option) {
              capturedOption = option;
            },
          ),
        ),
      );

      await tester.tap(find.text('Group'));
      await tester.pumpAndSettle();

      expect(capturedOption, TeamsSortOption.group);
    });

    testWidgets('only selected chip is highlighted', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          TeamSortChips(
            selectedOption: TeamsSortOption.confederation,
            onOptionChanged: (_) {},
          ),
        ),
      );

      // A-Z should not be selected
      final alphabeticalChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('A-Z'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(alphabeticalChip.selected, isFalse);

      // FIFA Ranking should not be selected
      final worldRankingChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('FIFA Ranking'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(worldRankingChip.selected, isFalse);

      // Confederation should be selected
      final confederationChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Confederation'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(confederationChip.selected, isTrue);

      // Group should not be selected
      final groupChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Group'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(groupChip.selected, isFalse);
    });

    testWidgets('renders in horizontal scrollable container', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          TeamSortChips(
            selectedOption: TeamsSortOption.alphabetical,
            onOptionChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.scrollDirection, Axis.horizontal);
    });

    testWidgets('can switch between all options', (tester) async {
      final options = TeamsSortOption.values;

      for (final option in options) {
        TeamsSortOption? capturedOption;

        await tester.pumpWidget(
          buildWidget(
            TeamSortChips(
              selectedOption: TeamsSortOption.alphabetical,
              onOptionChanged: (opt) {
                capturedOption = opt;
              },
            ),
          ),
        );

        final labelMap = {
          TeamsSortOption.alphabetical: 'A-Z',
          TeamsSortOption.worldRanking: 'FIFA Ranking',
          TeamsSortOption.confederation: 'Confederation',
          TeamsSortOption.group: 'Group',
        };

        await tester.tap(find.text(labelMap[option]!));
        await tester.pumpAndSettle();

        expect(capturedOption, option);
      }
    });

    testWidgets('renders exactly 4 chips', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          TeamSortChips(
            selectedOption: TeamsSortOption.alphabetical,
            onOptionChanged: (_) {},
          ),
        ),
      );

      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
      expect(chips.length, 4);
    });

    testWidgets('chips appear in correct order', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          TeamSortChips(
            selectedOption: TeamsSortOption.alphabetical,
            onOptionChanged: (_) {},
          ),
        ),
      );

      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();

      // Get the labels from each chip
      final labels = chips.map((chip) {
        final text = (chip.label as Text);
        return text.data;
      }).toList();

      expect(labels, ['A-Z', 'FIFA Ranking', 'Confederation', 'Group']);
    });
  });
}
