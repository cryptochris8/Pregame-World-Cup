import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import 'mock_repositories.dart';

void main() {
  late MockGroupRepository mockRepository;
  late GroupStandingsCubit cubit;

  setUp(() {
    mockRepository = MockGroupRepository();
    cubit = GroupStandingsCubit(groupRepository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('GroupStandingsCubit', () {
    final testGroups = TestDataFactory.createGroupList(count: 12);

    test('initial state is correct', () {
      expect(cubit.state, equals(GroupStandingsState.initial()));
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.groups, isEmpty);
    });

    blocTest<GroupStandingsCubit, GroupStandingsState>(
      'loadGroups emits loaded state with groups',
      build: () {
        when(() => mockRepository.getAllGroups())
            .thenAnswer((_) async => testGroups);
        return cubit;
      },
      act: (cubit) => cubit.loadGroups(),
      expect: () => [
        isA<GroupStandingsState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<GroupStandingsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.groups.length, 'groups length', 12),
      ],
      verify: (_) {
        verify(() => mockRepository.getAllGroups()).called(1);
      },
    );

    blocTest<GroupStandingsCubit, GroupStandingsState>(
      'loadGroups handles errors',
      build: () {
        when(() => mockRepository.getAllGroups())
            .thenThrow(Exception('Network error'));
        return cubit;
      },
      act: (cubit) => cubit.loadGroups(),
      expect: () => [
        isA<GroupStandingsState>().having((s) => s.isLoading, 'isLoading', true),
        isA<GroupStandingsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'has error', isNotNull),
      ],
    );

    blocTest<GroupStandingsCubit, GroupStandingsState>(
      'selectGroup updates selectedGroup',
      build: () => cubit,
      seed: () => GroupStandingsState(
        groups: testGroups,
        isLoading: false,
      ),
      act: (cubit) => cubit.selectGroup('A'),
      expect: () => [
        isA<GroupStandingsState>()
            .having((s) => s.selectedGroup?.groupLetter, 'selected', 'A'),
      ],
    );

    blocTest<GroupStandingsCubit, GroupStandingsState>(
      'clearSelectedGroup clears selection',
      build: () => cubit,
      seed: () => GroupStandingsState(
        groups: testGroups,
        selectedGroup: testGroups.first,
        isLoading: false,
      ),
      act: (cubit) => cubit.clearSelectedGroup(),
      expect: () => [
        isA<GroupStandingsState>()
            .having((s) => s.selectedGroup, 'selected', isNull),
      ],
    );

    blocTest<GroupStandingsCubit, GroupStandingsState>(
      'refreshGroups calls repository and updates state',
      build: () {
        when(() => mockRepository.refreshGroups())
            .thenAnswer((_) async => testGroups);
        return cubit;
      },
      seed: () => GroupStandingsState(
        groups: [],
        isLoading: false,
      ),
      act: (cubit) => cubit.refreshGroups(),
      expect: () => [
        isA<GroupStandingsState>().having((s) => s.isRefreshing, 'refreshing', true),
        isA<GroupStandingsState>()
            .having((s) => s.isRefreshing, 'refreshing', false)
            .having((s) => s.groups.length, 'groups', 12),
      ],
      verify: (_) {
        verify(() => mockRepository.refreshGroups()).called(1);
      },
    );

    test('getTeamStanding returns correct standing', () {
      final group = TestDataFactory.createGroup(groupLetter: 'A');
      cubit.emit(GroupStandingsState(
        groups: [group],
        isLoading: false,
      ));

      final standing = cubit.getTeamStanding('USA');
      expect(standing, isNotNull);
      expect(standing!.teamCode, 'USA');
      expect(standing.position, 1);
    });

    test('doesTeamQualify returns true for top 2', () {
      final group = TestDataFactory.createGroup(groupLetter: 'A');
      cubit.emit(GroupStandingsState(
        groups: [group],
        isLoading: false,
      ));

      expect(cubit.doesTeamQualify('USA'), isTrue); // Position 1
      expect(cubit.doesTeamQualify('MEX'), isTrue); // Position 2
      expect(cubit.doesTeamQualify('CAN'), isFalse); // Position 3
    });

    test('getQualifiedTeams returns top 2 from each group', () {
      cubit.emit(GroupStandingsState(
        groups: testGroups,
        isLoading: false,
      ));

      final qualified = cubit.getQualifiedTeams();
      // 12 groups * 2 teams = 24 qualified
      expect(qualified.length, 24);
      expect(qualified.every((s) => s.position <= 2), isTrue);
    });
  });
}
