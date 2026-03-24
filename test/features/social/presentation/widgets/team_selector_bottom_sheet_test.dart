import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/presentation/widgets/team_selector_bottom_sheet.dart';

void main() {
  late List<String> testAvailableTeams;
  late List<String> testSelectedTeams;

  setUp(() {
    testAvailableTeams = [
      'USA',
      'Brazil',
      'Germany',
      'France',
      'Argentina',
      'England',
    ];
    testSelectedTeams = ['USA', 'Brazil'];
  });

  test('can be constructed with required parameters', () {
    final widget = TeamSelectorBottomSheet(
      availableTeams: testAvailableTeams,
      selectedTeams: testSelectedTeams,
      onTeamToggled: (team) {},
      onMaxReached: () {},
    );
    expect(widget, isNotNull);
  });

  test('is a StatelessWidget', () {
    final widget = TeamSelectorBottomSheet(
      availableTeams: testAvailableTeams,
      selectedTeams: testSelectedTeams,
      onTeamToggled: (team) {},
      onMaxReached: () {},
    );
    expect(widget, isA<StatelessWidget>());
  });

  test('stores availableTeams list', () {
    final widget = TeamSelectorBottomSheet(
      availableTeams: testAvailableTeams,
      selectedTeams: testSelectedTeams,
      onTeamToggled: (team) {},
      onMaxReached: () {},
    );
    expect(widget.availableTeams, equals(testAvailableTeams));
    expect(widget.availableTeams.length, equals(6));
  });

  test('stores selectedTeams list', () {
    final widget = TeamSelectorBottomSheet(
      availableTeams: testAvailableTeams,
      selectedTeams: testSelectedTeams,
      onTeamToggled: (team) {},
      onMaxReached: () {},
    );
    expect(widget.selectedTeams, equals(testSelectedTeams));
    expect(widget.selectedTeams.length, equals(2));
    expect(widget.selectedTeams, contains('USA'));
    expect(widget.selectedTeams, contains('Brazil'));
  });

  test('stores onTeamToggled callback', () {
    String? toggledTeam;

    final widget = TeamSelectorBottomSheet(
      availableTeams: testAvailableTeams,
      selectedTeams: testSelectedTeams,
      onTeamToggled: (team) {
        toggledTeam = team;
      },
      onMaxReached: () {},
    );

    widget.onTeamToggled('Germany');
    expect(toggledTeam, equals('Germany'));
  });

  test('stores onMaxReached callback', () {
    bool maxReachedCalled = false;

    final widget = TeamSelectorBottomSheet(
      availableTeams: testAvailableTeams,
      selectedTeams: testSelectedTeams,
      onTeamToggled: (team) {},
      onMaxReached: () {
        maxReachedCalled = true;
      },
    );

    widget.onMaxReached();
    expect(maxReachedCalled, isTrue);
  });

  test('can be constructed with empty availableTeams', () {
    final widget = TeamSelectorBottomSheet(
      availableTeams: [],
      selectedTeams: testSelectedTeams,
      onTeamToggled: (team) {},
      onMaxReached: () {},
    );
    expect(widget, isNotNull);
    expect(widget.availableTeams, isEmpty);
  });

  test('can be constructed with empty selectedTeams', () {
    final widget = TeamSelectorBottomSheet(
      availableTeams: testAvailableTeams,
      selectedTeams: [],
      onTeamToggled: (team) {},
      onMaxReached: () {},
    );
    expect(widget, isNotNull);
    expect(widget.selectedTeams, isEmpty);
  });

  test('onTeamToggled receives correct team names', () {
    final toggledTeams = <String>[];

    final widget = TeamSelectorBottomSheet(
      availableTeams: testAvailableTeams,
      selectedTeams: testSelectedTeams,
      onTeamToggled: (team) {
        toggledTeams.add(team);
      },
      onMaxReached: () {},
    );

    widget.onTeamToggled('Germany');
    widget.onTeamToggled('France');
    widget.onTeamToggled('Argentina');

    expect(toggledTeams.length, equals(3));
    expect(toggledTeams[0], equals('Germany'));
    expect(toggledTeams[1], equals('France'));
    expect(toggledTeams[2], equals('Argentina'));
  });

  test('callbacks work independently', () {
    String? toggledTeam;
    bool maxReachedCalled = false;

    final widget = TeamSelectorBottomSheet(
      availableTeams: testAvailableTeams,
      selectedTeams: testSelectedTeams,
      onTeamToggled: (team) {
        toggledTeam = team;
      },
      onMaxReached: () {
        maxReachedCalled = true;
      },
    );

    widget.onTeamToggled('England');
    expect(toggledTeam, equals('England'));
    expect(maxReachedCalled, isFalse);

    widget.onMaxReached();
    expect(maxReachedCalled, isTrue);
  });
}
