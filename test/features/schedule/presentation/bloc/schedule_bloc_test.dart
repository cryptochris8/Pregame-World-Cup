import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import 'package:pregame_world_cup/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:pregame_world_cup/features/schedule/domain/usecases/get_upcoming_games.dart';
import 'package:pregame_world_cup/features/schedule/presentation/bloc/schedule_bloc.dart';

// Mocks
class MockScheduleRepository extends Mock implements ScheduleRepository {}

class MockGetUpcomingGames extends Mock implements GetUpcomingGames {}

void main() {
  late MockScheduleRepository mockRepository;
  late MockGetUpcomingGames mockGetUpcomingGames;
  late ScheduleBloc bloc;

  // Test data
  final testGames = [
    GameSchedule(
      gameId: 'game_1',
      awayTeamName: 'Brazil',
      homeTeamName: 'Germany',
      status: 'Scheduled',
      dateTime: DateTime(2026, 6, 15, 18, 0),
    ),
    GameSchedule(
      gameId: 'game_2',
      awayTeamName: 'Argentina',
      homeTeamName: 'France',
      status: 'Scheduled',
      dateTime: DateTime(2026, 6, 16, 20, 0),
    ),
    GameSchedule(
      gameId: 'game_3',
      awayTeamName: 'United States',
      homeTeamName: 'Mexico',
      status: 'Scheduled',
      dateTime: DateTime(2026, 6, 17, 19, 0),
    ),
  ];

  setUp(() {
    mockRepository = MockScheduleRepository();
    mockGetUpcomingGames = MockGetUpcomingGames();
    bloc = ScheduleBloc(
      getUpcomingGames: mockGetUpcomingGames,
      scheduleRepository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ScheduleBloc', () {
    test('initial state is ScheduleInitial', () {
      expect(bloc.state, isA<ScheduleInitial>());
    });

    group('GetUpcomingGamesEvent', () {
      blocTest<ScheduleBloc, ScheduleState>(
        'emits [ScheduleLoading, UpcomingGamesLoaded] on success',
        build: () {
          when(() => mockGetUpcomingGames(limit: 10))
              .thenAnswer((_) async => testGames);
          return bloc;
        },
        act: (bloc) => bloc.add(const GetUpcomingGamesEvent()),
        expect: () => [
          isA<ScheduleLoading>(),
          isA<UpcomingGamesLoaded>()
              .having(
                (s) => s.upcomingGames.length,
                'games count',
                3,
              )
              .having(
                (s) => s.showFavoritesOnly,
                'showFavoritesOnly',
                false,
              ),
        ],
        verify: (_) {
          verify(() => mockGetUpcomingGames(limit: 10)).called(1);
        },
      );

      blocTest<ScheduleBloc, ScheduleState>(
        'emits [ScheduleLoading, ScheduleError] on failure',
        build: () {
          when(() => mockGetUpcomingGames(limit: 10))
              .thenThrow(Exception('Network error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetUpcomingGamesEvent()),
        expect: () => [
          isA<ScheduleLoading>(),
          isA<ScheduleError>().having(
            (s) => s.message,
            'error message',
            contains('Network error'),
          ),
        ],
      );

      blocTest<ScheduleBloc, ScheduleState>(
        'uses custom limit when specified',
        build: () {
          when(() => mockGetUpcomingGames(limit: 20))
              .thenAnswer((_) async => testGames);
          return bloc;
        },
        act: (bloc) => bloc.add(const GetUpcomingGamesEvent(limit: 20)),
        expect: () => [
          isA<ScheduleLoading>(),
          isA<UpcomingGamesLoaded>(),
        ],
        verify: (_) {
          verify(() => mockGetUpcomingGames(limit: 20)).called(1);
        },
      );
    });

    group('GetScheduleForWeekEvent', () {
      blocTest<ScheduleBloc, ScheduleState>(
        'emits [ScheduleLoading, WeeklyScheduleLoaded] on success',
        build: () {
          when(() => mockRepository.getScheduleForWeek(2026, 1))
              .thenAnswer((_) async => testGames);
          return bloc;
        },
        act: (bloc) => bloc.add(const GetScheduleForWeekEvent(2026, 1)),
        expect: () => [
          isA<ScheduleLoading>(),
          isA<WeeklyScheduleLoaded>()
              .having((s) => s.weeklySchedule.length, 'games count', 3)
              .having((s) => s.year, 'year', 2026)
              .having((s) => s.week, 'week', 1),
        ],
        verify: (_) {
          verify(() => mockRepository.getScheduleForWeek(2026, 1)).called(1);
        },
      );

      blocTest<ScheduleBloc, ScheduleState>(
        'emits [ScheduleLoading, ScheduleError] on failure',
        build: () {
          when(() => mockRepository.getScheduleForWeek(2026, 1))
              .thenThrow(Exception('Failed to load'));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetScheduleForWeekEvent(2026, 1)),
        expect: () => [
          isA<ScheduleLoading>(),
          isA<ScheduleError>(),
        ],
      );
    });

    group('FilterByFavoriteTeamsEvent', () {
      blocTest<ScheduleBloc, ScheduleState>(
        'filters UpcomingGamesLoaded state by favorite teams',
        build: () => bloc,
        seed: () => UpcomingGamesLoaded(
          testGames,
          showFavoritesOnly: false,
          favoriteTeams: const [],
        ),
        act: (bloc) => bloc.add(const FilterByFavoriteTeamsEvent(
          showFavoritesOnly: true,
          favoriteTeams: ['Brazil', 'Germany'],
        )),
        expect: () => [
          isA<UpcomingGamesLoaded>()
              .having((s) => s.showFavoritesOnly, 'showFavoritesOnly', true)
              .having((s) => s.favoriteTeams.length, 'favoriteTeams', 2)
              .having(
                (s) => s.favoriteTeams,
                'favoriteTeams values',
                ['Brazil', 'Germany'],
              ),
        ],
      );

      blocTest<ScheduleBloc, ScheduleState>(
        'filters WeeklyScheduleLoaded state by favorite teams',
        build: () => bloc,
        seed: () => WeeklyScheduleLoaded(
          testGames,
          2026,
          1,
          showFavoritesOnly: false,
          favoriteTeams: const [],
        ),
        act: (bloc) => bloc.add(const FilterByFavoriteTeamsEvent(
          showFavoritesOnly: true,
          favoriteTeams: ['Argentina'],
        )),
        expect: () => [
          isA<WeeklyScheduleLoaded>()
              .having((s) => s.showFavoritesOnly, 'showFavoritesOnly', true)
              .having((s) => s.favoriteTeams, 'favoriteTeams', ['Argentina']),
        ],
      );

      blocTest<ScheduleBloc, ScheduleState>(
        'does not emit if state is ScheduleInitial',
        build: () => bloc,
        act: (bloc) => bloc.add(const FilterByFavoriteTeamsEvent(
          showFavoritesOnly: true,
          favoriteTeams: ['Brazil'],
        )),
        expect: () => [],
      );
    });

    group('ForceRefreshUpcomingGamesEvent', () {
      blocTest<ScheduleBloc, ScheduleState>(
        'bypasses smart refresh and loads games',
        build: () {
          when(() => mockGetUpcomingGames(limit: 10))
              .thenAnswer((_) async => testGames);
          return bloc;
        },
        act: (bloc) => bloc.add(const ForceRefreshUpcomingGamesEvent()),
        expect: () => [
          isA<ScheduleLoading>(),
          isA<UpcomingGamesLoaded>()
              .having((s) => s.upcomingGames.length, 'games count', 3),
        ],
      );

      blocTest<ScheduleBloc, ScheduleState>(
        'emits error on force refresh failure',
        build: () {
          when(() => mockGetUpcomingGames(limit: 10))
              .thenThrow(Exception('Server down'));
          return bloc;
        },
        act: (bloc) => bloc.add(const ForceRefreshUpcomingGamesEvent()),
        expect: () => [
          isA<ScheduleLoading>(),
          isA<ScheduleError>().having(
            (s) => s.message,
            'error message',
            contains('Server down'),
          ),
        ],
      );

      blocTest<ScheduleBloc, ScheduleState>(
        'uses custom limit on force refresh',
        build: () {
          when(() => mockGetUpcomingGames(limit: 50))
              .thenAnswer((_) async => testGames);
          return bloc;
        },
        act: (bloc) => bloc.add(const ForceRefreshUpcomingGamesEvent(limit: 50)),
        expect: () => [
          isA<ScheduleLoading>(),
          isA<UpcomingGamesLoaded>(),
        ],
        verify: (_) {
          verify(() => mockGetUpcomingGames(limit: 50)).called(1);
        },
      );
    });
  });

  group('ScheduleState', () {
    group('ScheduleInitial', () {
      test('has empty props', () {
        final state = ScheduleInitial();
        expect(state.props, isEmpty);
      });
    });

    group('ScheduleLoading', () {
      test('has empty props', () {
        final state = ScheduleLoading();
        expect(state.props, isEmpty);
      });
    });

    group('ScheduleError', () {
      test('has message in props', () {
        const state = ScheduleError('Something went wrong');
        expect(state.message, equals('Something went wrong'));
        expect(state.props, [equals('Something went wrong')]);
      });

      test('two errors with same message are equal', () {
        const error1 = ScheduleError('Network failure');
        const error2 = ScheduleError('Network failure');
        expect(error1, equals(error2));
      });

      test('two errors with different messages are not equal', () {
        const error1 = ScheduleError('Error A');
        const error2 = ScheduleError('Error B');
        expect(error1, isNot(equals(error2)));
      });
    });

    group('UpcomingGamesLoaded', () {
      test('filteredUpcomingGames returns all when not filtering', () {
        final state = UpcomingGamesLoaded(
          testGames,
          showFavoritesOnly: false,
          favoriteTeams: const [],
        );

        expect(state.filteredUpcomingGames.length, equals(3));
      });

      test('filteredUpcomingGames returns all when favorites is empty', () {
        final state = UpcomingGamesLoaded(
          testGames,
          showFavoritesOnly: true,
          favoriteTeams: const [],
        );

        expect(state.filteredUpcomingGames.length, equals(3));
      });

      test('props contain correct values', () {
        final state = UpcomingGamesLoaded(
          testGames,
          showFavoritesOnly: true,
          favoriteTeams: const ['Brazil'],
        );

        expect(state.props, containsAll([testGames, true, ['Brazil']]));
      });
    });

    group('WeeklyScheduleLoaded', () {
      test('contains year and week', () {
        final state = WeeklyScheduleLoaded(
          testGames,
          2026,
          3,
        );

        expect(state.year, equals(2026));
        expect(state.week, equals(3));
        expect(state.weeklySchedule.length, equals(3));
      });

      test('filteredWeeklySchedule returns all when not filtering', () {
        final state = WeeklyScheduleLoaded(
          testGames,
          2026,
          1,
          showFavoritesOnly: false,
          favoriteTeams: const [],
        );

        expect(state.filteredWeeklySchedule.length, equals(3));
      });
    });
  });

  group('ScheduleEvent', () {
    group('GetUpcomingGamesEvent', () {
      test('default limit is 10', () {
        const event = GetUpcomingGamesEvent();
        expect(event.limit, equals(10));
      });

      test('custom limit is preserved', () {
        const event = GetUpcomingGamesEvent(limit: 25);
        expect(event.limit, equals(25));
      });

      test('two events with same limit are equal', () {
        const event1 = GetUpcomingGamesEvent(limit: 10);
        const event2 = GetUpcomingGamesEvent(limit: 10);
        expect(event1, equals(event2));
      });

      test('two events with different limits are not equal', () {
        const event1 = GetUpcomingGamesEvent(limit: 10);
        const event2 = GetUpcomingGamesEvent(limit: 20);
        expect(event1, isNot(equals(event2)));
      });
    });

    group('GetScheduleForWeekEvent', () {
      test('stores year and week', () {
        const event = GetScheduleForWeekEvent(2026, 5);
        expect(event.year, equals(2026));
        expect(event.week, equals(5));
      });

      test('two events with same year/week are equal', () {
        const event1 = GetScheduleForWeekEvent(2026, 5);
        const event2 = GetScheduleForWeekEvent(2026, 5);
        expect(event1, equals(event2));
      });

      test('two events with different year/week are not equal', () {
        const event1 = GetScheduleForWeekEvent(2026, 5);
        const event2 = GetScheduleForWeekEvent(2026, 6);
        expect(event1, isNot(equals(event2)));
      });
    });

    group('FilterByFavoriteTeamsEvent', () {
      test('stores filter parameters', () {
        const event = FilterByFavoriteTeamsEvent(
          showFavoritesOnly: true,
          favoriteTeams: ['USA', 'Brazil'],
        );
        expect(event.showFavoritesOnly, isTrue);
        expect(event.favoriteTeams, equals(['USA', 'Brazil']));
      });
    });

    group('ForceRefreshUpcomingGamesEvent', () {
      test('default limit is 10', () {
        const event = ForceRefreshUpcomingGamesEvent();
        expect(event.limit, equals(10));
      });

      test('custom limit is preserved', () {
        const event = ForceRefreshUpcomingGamesEvent(limit: 50);
        expect(event.limit, equals(50));
      });
    });

    group('RefreshLiveScoresEvent', () {
      test('has empty props', () {
        const event = RefreshLiveScoresEvent();
        expect(event.props, isEmpty);
      });
    });
  });
}
