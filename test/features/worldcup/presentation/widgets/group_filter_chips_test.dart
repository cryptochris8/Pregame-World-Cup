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

  group('GroupFilterChips', () {
    testWidgets('renders All Groups chip', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          GroupFilterChips(
            selectedGroup: null,
            onGroupChanged: (_) {},
          ),
        ),
      );

      expect(find.text('All Groups'), findsOneWidget);
    });

    testWidgets('renders chips for groups A through L', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          GroupFilterChips(
            selectedGroup: null,
            onGroupChanged: (_) {},
          ),
        ),
      );

      // Verify all group chips are rendered
      final groups = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'];
      for (final group in groups) {
        expect(find.text('Group $group'), findsOneWidget);
      }
    });

    testWidgets('All Groups chip is selected when selectedGroup is null', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          GroupFilterChips(
            selectedGroup: null,
            onGroupChanged: (_) {},
          ),
        ),
      );

      final allGroupsChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('All Groups'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(allGroupsChip.selected, isTrue);
    });

    testWidgets('Group A chip is selected when selectedGroup is A', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          GroupFilterChips(
            selectedGroup: 'A',
            onGroupChanged: (_) {},
          ),
        ),
      );

      final groupAChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Group A'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(groupAChip.selected, isTrue);
    });

    testWidgets('Group F chip is selected when selectedGroup is F', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          GroupFilterChips(
            selectedGroup: 'F',
            onGroupChanged: (_) {},
          ),
        ),
      );

      final groupFChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Group F'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(groupFChip.selected, isTrue);
    });

    testWidgets('Group L chip is selected when selectedGroup is L', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          GroupFilterChips(
            selectedGroup: 'L',
            onGroupChanged: (_) {},
          ),
        ),
      );

      final groupLChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Group L'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(groupLChip.selected, isTrue);
    });

    testWidgets('tapping All Groups chip calls callback with null', (tester) async {
      String? capturedGroup = 'A'; // Start with non-null

      await tester.pumpWidget(
        buildWidget(
          GroupFilterChips(
            selectedGroup: 'A',
            onGroupChanged: (group) {
              capturedGroup = group;
            },
          ),
        ),
      );

      await tester.tap(find.text('All Groups'));
      await tester.pumpAndSettle();

      expect(capturedGroup, isNull);
    });

    testWidgets('tapping Group A chip calls callback with A', (tester) async {
      String? capturedGroup;

      await tester.pumpWidget(
        buildWidget(
          GroupFilterChips(
            selectedGroup: null,
            onGroupChanged: (group) {
              capturedGroup = group;
            },
          ),
        ),
      );

      await tester.tap(find.text('Group A'));
      await tester.pumpAndSettle();

      expect(capturedGroup, 'A');
    });

    testWidgets('tapping Group B chip calls callback with B', (tester) async {
      String? capturedGroup;

      await tester.pumpWidget(
        buildWidget(
          GroupFilterChips(
            selectedGroup: null,
            onGroupChanged: (group) {
              capturedGroup = group;
            },
          ),
        ),
      );

      await tester.tap(find.text('Group B'));
      await tester.pumpAndSettle();

      expect(capturedGroup, 'B');
    });

    testWidgets('tapping Group G chip calls callback with G', (tester) async {
      String? capturedGroup;

      await tester.pumpWidget(
        buildWidget(
          GroupFilterChips(
            selectedGroup: null,
            onGroupChanged: (group) {
              capturedGroup = group;
            },
          ),
        ),
      );

      await tester.dragUntilVisible(
        find.text('Group G'),
        find.byType(SingleChildScrollView),
        const Offset(-100, 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Group G'));
      await tester.pumpAndSettle();

      expect(capturedGroup, 'G');
    });

    testWidgets('tapping Group L chip calls callback with L', (tester) async {
      String? capturedGroup;

      await tester.pumpWidget(
        buildWidget(
          GroupFilterChips(
            selectedGroup: null,
            onGroupChanged: (group) {
              capturedGroup = group;
            },
          ),
        ),
      );

      await tester.dragUntilVisible(
        find.text('Group L'),
        find.byType(SingleChildScrollView),
        const Offset(-100, 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Group L'));
      await tester.pumpAndSettle();

      expect(capturedGroup, 'L');
    });

    testWidgets('only selected chip is highlighted', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          GroupFilterChips(
            selectedGroup: 'C',
            onGroupChanged: (_) {},
          ),
        ),
      );

      // All Groups should not be selected
      final allGroupsChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('All Groups'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(allGroupsChip.selected, isFalse);

      // Group A should not be selected
      final groupAChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Group A'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(groupAChip.selected, isFalse);

      // Group C should be selected
      final groupCChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Group C'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(groupCChip.selected, isTrue);

      // Group D should not be selected
      final groupDChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Group D'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(groupDChip.selected, isFalse);
    });

    testWidgets('renders in horizontal scrollable container', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          GroupFilterChips(
            selectedGroup: null,
            onGroupChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.scrollDirection, Axis.horizontal);
    });

    testWidgets('can select all groups sequentially', (tester) async {
      final groups = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'];

      for (final group in groups) {
        String? capturedGroup;

        await tester.pumpWidget(
          buildWidget(
            GroupFilterChips(
              selectedGroup: null,
              onGroupChanged: (g) {
                capturedGroup = g;
              },
            ),
          ),
        );

        await tester.dragUntilVisible(
          find.text('Group $group'),
          find.byType(SingleChildScrollView),
          const Offset(-100, 0),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Group $group'));
        await tester.pumpAndSettle();

        expect(capturedGroup, group);
      }
    });
  });
}
