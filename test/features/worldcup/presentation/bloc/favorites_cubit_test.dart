import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import 'mock_repositories.dart';

void main() {
  late MockUserPreferencesRepository mockPreferencesRepo;
  late MockNationalTeamRepository mockTeamRepo;
  late MockWorldCupMatchRepository mockMatchRepo;
  late FavoritesCubit cubit;
  late StreamController<UserPreferences> preferencesStreamController;

  final emptyPreferences = UserPreferences.empty();

  const preferencesWithTeam = UserPreferences(
    favoriteTeamCodes: ['USA'],
  );

  const preferencesWithMatch = UserPreferences(
    favoriteMatchIds: ['match_1'],
  );

  const preferencesWithBoth = UserPreferences(
    favoriteTeamCodes: ['USA', 'BRA'],
    favoriteMatchIds: ['match_1', 'match_2'],
  );

  const updatedNotificationPreferences = UserPreferences(
    notifyFavoriteTeamMatches: false,
    notifyLiveUpdates: false,
    notifyGoals: true,
  );

  final testTeamUSA = TestDataFactory.createTeam(
    fifaCode: 'USA',
    countryName: 'United States',
  );

  final testTeamBRA = TestDataFactory.createTeam(
    fifaCode: 'BRA',
    countryName: 'Brazil',
    confederation: Confederation.conmebol,
    isHostNation: false,
  );

  final testMatch1 = TestDataFactory.createMatch(
    matchId: 'match_1',
    matchNumber: 1,
    homeTeamCode: 'USA',
    awayTeamCode: 'MEX',
  );

  final testMatch2 = TestDataFactory.createMatch(
    matchId: 'match_2',
    matchNumber: 2,
    homeTeamCode: 'BRA',
    awayTeamCode: 'ARG',
  );

  setUp(() {
    mockPreferencesRepo = MockUserPreferencesRepository();
    mockTeamRepo = MockNationalTeamRepository();
    mockMatchRepo = MockWorldCupMatchRepository();
    preferencesStreamController = StreamController<UserPreferences>.broadcast();

    // Default stub for watchPreferences to avoid missing stub errors
    when(() => mockPreferencesRepo.watchPreferences())
        .thenAnswer((_) => preferencesStreamController.stream);

    cubit = FavoritesCubit(
      preferencesRepository: mockPreferencesRepo,
    );
  });

  tearDown(() {
    cubit.close();
    preferencesStreamController.close();
  });

  group('FavoritesCubit', () {
    // -------------------------------------------------------
    // 1. Initial state
    // -------------------------------------------------------
    test('initial state is correct', () {
      expect(cubit.state, equals(FavoritesState.initial()));
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.favoriteTeams, isEmpty);
      expect(cubit.state.favoriteMatches, isEmpty);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.preferences, equals(const UserPreferences()));
    });

    // -------------------------------------------------------
    // 2. init() loads preferences and emits loaded state
    // -------------------------------------------------------
    blocTest<FavoritesCubit, FavoritesState>(
      'init() loads preferences and emits loaded state',
      build: () {
        when(() => mockPreferencesRepo.getPreferences())
            .thenAnswer((_) async => preferencesWithTeam);
        return cubit;
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        // First: loading state with cleared error
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        // Second: loaded state with preferences
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.preferences, 'preferences', preferencesWithTeam),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.getPreferences()).called(1);
        verify(() => mockPreferencesRepo.watchPreferences()).called(1);
      },
    );

    // -------------------------------------------------------
    // 3. init() handles errors
    // -------------------------------------------------------
    blocTest<FavoritesCubit, FavoritesState>(
      'init() handles errors gracefully',
      build: () {
        when(() => mockPreferencesRepo.getPreferences())
            .thenThrow(Exception('Network error'));
        return cubit;
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'errorMessage contains text',
              contains('Failed to load preferences'),
            ),
      ],
    );

    // -------------------------------------------------------
    // 4. toggleFavoriteTeam adds/removes team from favorites
    // -------------------------------------------------------
    blocTest<FavoritesCubit, FavoritesState>(
      'toggleFavoriteTeam adds team when not favorited',
      build: () {
        when(() => mockPreferencesRepo.toggleFavoriteTeam('USA'))
            .thenAnswer((_) async => preferencesWithTeam);
        return cubit;
      },
      seed: () => FavoritesState(
        preferences: emptyPreferences,
        isLoading: false,
      ),
      act: (cubit) => cubit.toggleFavoriteTeam('USA'),
      expect: () => [
        isA<FavoritesState>()
            .having(
              (s) => s.preferences.favoriteTeamCodes,
              'favoriteTeamCodes',
              ['USA'],
            ),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.toggleFavoriteTeam('USA')).called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'toggleFavoriteTeam removes team when already favorited',
      build: () {
        when(() => mockPreferencesRepo.toggleFavoriteTeam('USA'))
            .thenAnswer((_) async => emptyPreferences);
        return cubit;
      },
      seed: () => const FavoritesState(
        preferences: preferencesWithTeam,
        isLoading: false,
      ),
      act: (cubit) => cubit.toggleFavoriteTeam('USA'),
      expect: () => [
        isA<FavoritesState>()
            .having(
              (s) => s.preferences.favoriteTeamCodes,
              'favoriteTeamCodes',
              isEmpty,
            ),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.toggleFavoriteTeam('USA')).called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'toggleFavoriteTeam emits error on failure',
      build: () {
        when(() => mockPreferencesRepo.toggleFavoriteTeam('USA'))
            .thenThrow(Exception('DB error'));
        return cubit;
      },
      seed: () => FavoritesState(
        preferences: emptyPreferences,
        isLoading: false,
      ),
      act: (cubit) => cubit.toggleFavoriteTeam('USA'),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'error text',
              contains('Failed to update favorite'),
            ),
      ],
    );

    // -------------------------------------------------------
    // 5. addFavoriteTeam adds team
    // -------------------------------------------------------
    blocTest<FavoritesCubit, FavoritesState>(
      'addFavoriteTeam adds team to favorites',
      build: () {
        when(() => mockPreferencesRepo.addFavoriteTeam('BRA'))
            .thenAnswer((_) async => const UserPreferences(
                  favoriteTeamCodes: ['USA', 'BRA'],
                ));
        return cubit;
      },
      seed: () => const FavoritesState(
        preferences: preferencesWithTeam,
        isLoading: false,
      ),
      act: (cubit) => cubit.addFavoriteTeam('BRA'),
      expect: () => [
        isA<FavoritesState>()
            .having(
              (s) => s.preferences.favoriteTeamCodes,
              'favoriteTeamCodes',
              ['USA', 'BRA'],
            ),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.addFavoriteTeam('BRA')).called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'addFavoriteTeam emits error on failure',
      build: () {
        when(() => mockPreferencesRepo.addFavoriteTeam('BRA'))
            .thenThrow(Exception('DB error'));
        return cubit;
      },
      seed: () => FavoritesState(
        preferences: emptyPreferences,
        isLoading: false,
      ),
      act: (cubit) => cubit.addFavoriteTeam('BRA'),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'error text',
              contains('Failed to add favorite'),
            ),
      ],
    );

    // -------------------------------------------------------
    // 6. removeFavoriteTeam removes team
    // -------------------------------------------------------
    blocTest<FavoritesCubit, FavoritesState>(
      'removeFavoriteTeam removes team from favorites',
      build: () {
        when(() => mockPreferencesRepo.removeFavoriteTeam('USA'))
            .thenAnswer((_) async => emptyPreferences);
        return cubit;
      },
      seed: () => const FavoritesState(
        preferences: preferencesWithTeam,
        isLoading: false,
      ),
      act: (cubit) => cubit.removeFavoriteTeam('USA'),
      expect: () => [
        isA<FavoritesState>()
            .having(
              (s) => s.preferences.favoriteTeamCodes,
              'favoriteTeamCodes',
              isEmpty,
            ),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.removeFavoriteTeam('USA')).called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'removeFavoriteTeam emits error on failure',
      build: () {
        when(() => mockPreferencesRepo.removeFavoriteTeam('USA'))
            .thenThrow(Exception('DB error'));
        return cubit;
      },
      seed: () => const FavoritesState(
        preferences: preferencesWithTeam,
        isLoading: false,
      ),
      act: (cubit) => cubit.removeFavoriteTeam('USA'),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'error text',
              contains('Failed to remove favorite'),
            ),
      ],
    );

    // -------------------------------------------------------
    // 7. toggleFavoriteMatch adds/removes match
    // -------------------------------------------------------
    blocTest<FavoritesCubit, FavoritesState>(
      'toggleFavoriteMatch adds match when not favorited',
      build: () {
        when(() => mockPreferencesRepo.toggleFavoriteMatch('match_1'))
            .thenAnswer((_) async => preferencesWithMatch);
        return cubit;
      },
      seed: () => FavoritesState(
        preferences: emptyPreferences,
        isLoading: false,
      ),
      act: (cubit) => cubit.toggleFavoriteMatch('match_1'),
      expect: () => [
        isA<FavoritesState>()
            .having(
              (s) => s.preferences.favoriteMatchIds,
              'favoriteMatchIds',
              ['match_1'],
            ),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.toggleFavoriteMatch('match_1'))
            .called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'toggleFavoriteMatch removes match when already favorited',
      build: () {
        when(() => mockPreferencesRepo.toggleFavoriteMatch('match_1'))
            .thenAnswer((_) async => emptyPreferences);
        return cubit;
      },
      seed: () => const FavoritesState(
        preferences: preferencesWithMatch,
        isLoading: false,
      ),
      act: (cubit) => cubit.toggleFavoriteMatch('match_1'),
      expect: () => [
        isA<FavoritesState>()
            .having(
              (s) => s.preferences.favoriteMatchIds,
              'favoriteMatchIds',
              isEmpty,
            ),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.toggleFavoriteMatch('match_1'))
            .called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'toggleFavoriteMatch emits error on failure',
      build: () {
        when(() => mockPreferencesRepo.toggleFavoriteMatch('match_1'))
            .thenThrow(Exception('DB error'));
        return cubit;
      },
      seed: () => FavoritesState(
        preferences: emptyPreferences,
        isLoading: false,
      ),
      act: (cubit) => cubit.toggleFavoriteMatch('match_1'),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'error text',
              contains('Failed to update favorite'),
            ),
      ],
    );

    // -------------------------------------------------------
    // 8. addFavoriteMatch adds match
    // -------------------------------------------------------
    blocTest<FavoritesCubit, FavoritesState>(
      'addFavoriteMatch adds match to favorites',
      build: () {
        when(() => mockPreferencesRepo.addFavoriteMatch('match_1'))
            .thenAnswer((_) async => preferencesWithMatch);
        return cubit;
      },
      seed: () => FavoritesState(
        preferences: emptyPreferences,
        isLoading: false,
      ),
      act: (cubit) => cubit.addFavoriteMatch('match_1'),
      expect: () => [
        isA<FavoritesState>()
            .having(
              (s) => s.preferences.favoriteMatchIds,
              'favoriteMatchIds',
              ['match_1'],
            ),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.addFavoriteMatch('match_1')).called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'addFavoriteMatch emits error on failure',
      build: () {
        when(() => mockPreferencesRepo.addFavoriteMatch('match_1'))
            .thenThrow(Exception('DB error'));
        return cubit;
      },
      seed: () => FavoritesState(
        preferences: emptyPreferences,
        isLoading: false,
      ),
      act: (cubit) => cubit.addFavoriteMatch('match_1'),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'error text',
              contains('Failed to add favorite'),
            ),
      ],
    );

    // -------------------------------------------------------
    // 9. removeFavoriteMatch removes match
    // -------------------------------------------------------
    blocTest<FavoritesCubit, FavoritesState>(
      'removeFavoriteMatch removes match from favorites',
      build: () {
        when(() => mockPreferencesRepo.removeFavoriteMatch('match_1'))
            .thenAnswer((_) async => emptyPreferences);
        return cubit;
      },
      seed: () => const FavoritesState(
        preferences: preferencesWithMatch,
        isLoading: false,
      ),
      act: (cubit) => cubit.removeFavoriteMatch('match_1'),
      expect: () => [
        isA<FavoritesState>()
            .having(
              (s) => s.preferences.favoriteMatchIds,
              'favoriteMatchIds',
              isEmpty,
            ),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.removeFavoriteMatch('match_1'))
            .called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'removeFavoriteMatch emits error on failure',
      build: () {
        when(() => mockPreferencesRepo.removeFavoriteMatch('match_1'))
            .thenThrow(Exception('DB error'));
        return cubit;
      },
      seed: () => const FavoritesState(
        preferences: preferencesWithMatch,
        isLoading: false,
      ),
      act: (cubit) => cubit.removeFavoriteMatch('match_1'),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'error text',
              contains('Failed to remove favorite'),
            ),
      ],
    );

    // -------------------------------------------------------
    // 10. updateNotificationSettings updates settings
    // -------------------------------------------------------
    blocTest<FavoritesCubit, FavoritesState>(
      'updateNotificationSettings updates preferences',
      build: () {
        when(() => mockPreferencesRepo.updateNotificationSettings(
              notifyFavoriteTeamMatches: false,
              notifyLiveUpdates: false,
              notifyGoals: true,
            )).thenAnswer((_) async => updatedNotificationPreferences);
        return cubit;
      },
      seed: () => FavoritesState(
        preferences: emptyPreferences,
        isLoading: false,
      ),
      act: (cubit) => cubit.updateNotificationSettings(
        notifyFavoriteTeamMatches: false,
        notifyLiveUpdates: false,
        notifyGoals: true,
      ),
      expect: () => [
        isA<FavoritesState>()
            .having(
              (s) => s.preferences.notifyFavoriteTeamMatches,
              'notifyFavoriteTeamMatches',
              false,
            )
            .having(
              (s) => s.preferences.notifyLiveUpdates,
              'notifyLiveUpdates',
              false,
            )
            .having(
              (s) => s.preferences.notifyGoals,
              'notifyGoals',
              true,
            ),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.updateNotificationSettings(
              notifyFavoriteTeamMatches: false,
              notifyLiveUpdates: false,
              notifyGoals: true,
            )).called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'updateNotificationSettings emits error on failure',
      build: () {
        when(() => mockPreferencesRepo.updateNotificationSettings(
              notifyFavoriteTeamMatches: false,
            )).thenThrow(Exception('DB error'));
        return cubit;
      },
      seed: () => FavoritesState(
        preferences: emptyPreferences,
        isLoading: false,
      ),
      act: (cubit) => cubit.updateNotificationSettings(
        notifyFavoriteTeamMatches: false,
      ),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'error text',
              contains('Failed to update settings'),
            ),
      ],
    );

    // -------------------------------------------------------
    // 11. isTeamFavorite returns correct value
    // -------------------------------------------------------
    test('isTeamFavorite returns true for favorited team', () {
      cubit.emit(const FavoritesState(
        preferences: preferencesWithTeam,
        isLoading: false,
      ));

      expect(cubit.isTeamFavorite('USA'), isTrue);
    });

    test('isTeamFavorite returns false for non-favorited team', () {
      cubit.emit(const FavoritesState(
        preferences: preferencesWithTeam,
        isLoading: false,
      ));

      expect(cubit.isTeamFavorite('BRA'), isFalse);
    });

    test('isTeamFavorite returns false when no favorites', () {
      cubit.emit(FavoritesState(
        preferences: emptyPreferences,
        isLoading: false,
      ));

      expect(cubit.isTeamFavorite('USA'), isFalse);
    });

    // -------------------------------------------------------
    // 12. isMatchFavorite returns correct value
    // -------------------------------------------------------
    test('isMatchFavorite returns true for favorited match', () {
      cubit.emit(const FavoritesState(
        preferences: preferencesWithMatch,
        isLoading: false,
      ));

      expect(cubit.isMatchFavorite('match_1'), isTrue);
    });

    test('isMatchFavorite returns false for non-favorited match', () {
      cubit.emit(const FavoritesState(
        preferences: preferencesWithMatch,
        isLoading: false,
      ));

      expect(cubit.isMatchFavorite('match_99'), isFalse);
    });

    test('isMatchFavorite returns false when no favorites', () {
      cubit.emit(FavoritesState(
        preferences: emptyPreferences,
        isLoading: false,
      ));

      expect(cubit.isMatchFavorite('match_1'), isFalse);
    });

    // -------------------------------------------------------
    // 13. clearFavorites resets all preferences
    // -------------------------------------------------------
    blocTest<FavoritesCubit, FavoritesState>(
      'clearFavorites resets all preferences',
      build: () {
        when(() => mockPreferencesRepo.clearPreferences())
            .thenAnswer((_) async {});
        return cubit;
      },
      seed: () => FavoritesState(
        preferences: preferencesWithBoth,
        isLoading: false,
        favoriteTeams: [testTeamUSA, testTeamBRA],
        favoriteMatches: [testMatch1, testMatch2],
      ),
      act: (cubit) => cubit.clearFavorites(),
      expect: () => [
        isA<FavoritesState>()
            .having(
              (s) => s.preferences,
              'preferences',
              UserPreferences.empty(),
            )
            .having(
              (s) => s.favoriteTeams,
              'favoriteTeams',
              isEmpty,
            )
            .having(
              (s) => s.favoriteMatches,
              'favoriteMatches',
              isEmpty,
            ),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.clearPreferences()).called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'clearFavorites emits error on failure',
      build: () {
        when(() => mockPreferencesRepo.clearPreferences())
            .thenThrow(Exception('DB error'));
        return cubit;
      },
      seed: () => const FavoritesState(
        preferences: preferencesWithBoth,
        isLoading: false,
      ),
      act: (cubit) => cubit.clearFavorites(),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'error text',
              contains('Failed to clear favorites'),
            ),
      ],
    );

    // -------------------------------------------------------
    // 14. clearError clears error message
    // -------------------------------------------------------
    blocTest<FavoritesCubit, FavoritesState>(
      'clearError clears error message',
      build: () => cubit,
      seed: () => FavoritesState(
        preferences: emptyPreferences,
        isLoading: false,
        errorMessage: 'Some error occurred',
      ),
      act: (cubit) => cubit.clearError(),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    // -------------------------------------------------------
    // 15. init() loads favorite team/match entities when repos provided
    // -------------------------------------------------------
    blocTest<FavoritesCubit, FavoritesState>(
      'init() loads favorite team entities when team repository provided',
      build: () {
        when(() => mockPreferencesRepo.getPreferences())
            .thenAnswer((_) async => preferencesWithTeam);
        when(() => mockTeamRepo.getTeamByCode('USA'))
            .thenAnswer((_) async => testTeamUSA);

        cubit = FavoritesCubit(
          preferencesRepository: mockPreferencesRepo,
          teamRepository: mockTeamRepo,
        );
        return cubit;
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        // Loading state
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', true),
        // Loaded with preferences
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.preferences, 'preferences', preferencesWithTeam),
        // Loaded with favorite team entities
        isA<FavoritesState>()
            .having((s) => s.favoriteTeams.length, 'favoriteTeams count', 1)
            .having(
              (s) => s.favoriteTeams.first.fifaCode,
              'first team code',
              'USA',
            ),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.getPreferences()).called(1);
        verify(() => mockTeamRepo.getTeamByCode('USA')).called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'init() loads favorite match entities when match repository provided',
      build: () {
        when(() => mockPreferencesRepo.getPreferences())
            .thenAnswer((_) async => preferencesWithMatch);
        when(() => mockMatchRepo.getMatchById('match_1'))
            .thenAnswer((_) async => testMatch1);

        cubit = FavoritesCubit(
          preferencesRepository: mockPreferencesRepo,
          matchRepository: mockMatchRepo,
        );
        return cubit;
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        // Loading state
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', true),
        // Loaded with preferences
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.preferences, 'preferences', preferencesWithMatch),
        // Loaded with favorite match entities
        isA<FavoritesState>()
            .having(
              (s) => s.favoriteMatches.length,
              'favoriteMatches count',
              1,
            )
            .having(
              (s) => s.favoriteMatches.first.matchId,
              'first match id',
              'match_1',
            ),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.getPreferences()).called(1);
        verify(() => mockMatchRepo.getMatchById('match_1')).called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'init() loads both teams and matches when both repos provided',
      build: () {
        when(() => mockPreferencesRepo.getPreferences())
            .thenAnswer((_) async => preferencesWithBoth);
        when(() => mockTeamRepo.getTeamByCode('USA'))
            .thenAnswer((_) async => testTeamUSA);
        when(() => mockTeamRepo.getTeamByCode('BRA'))
            .thenAnswer((_) async => testTeamBRA);
        when(() => mockMatchRepo.getMatchById('match_1'))
            .thenAnswer((_) async => testMatch1);
        when(() => mockMatchRepo.getMatchById('match_2'))
            .thenAnswer((_) async => testMatch2);

        cubit = FavoritesCubit(
          preferencesRepository: mockPreferencesRepo,
          teamRepository: mockTeamRepo,
          matchRepository: mockMatchRepo,
        );
        return cubit;
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        // Loading state
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', true),
        // Loaded with preferences
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.preferences, 'preferences', preferencesWithBoth),
        // Loaded with favorite team entities
        isA<FavoritesState>()
            .having((s) => s.favoriteTeams.length, 'favoriteTeams count', 2),
        // Loaded with both teams and match entities
        isA<FavoritesState>()
            .having((s) => s.favoriteTeams.length, 'favoriteTeams count', 2)
            .having(
              (s) => s.favoriteMatches.length,
              'favoriteMatches count',
              2,
            ),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.getPreferences()).called(1);
        verify(() => mockTeamRepo.getTeamByCode('USA')).called(1);
        verify(() => mockTeamRepo.getTeamByCode('BRA')).called(1);
        verify(() => mockMatchRepo.getMatchById('match_1')).called(1);
        verify(() => mockMatchRepo.getMatchById('match_2')).called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'init() skips loading entities when no favorites exist',
      build: () {
        when(() => mockPreferencesRepo.getPreferences())
            .thenAnswer((_) async => emptyPreferences);

        cubit = FavoritesCubit(
          preferencesRepository: mockPreferencesRepo,
          teamRepository: mockTeamRepo,
          matchRepository: mockMatchRepo,
        );
        return cubit;
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.preferences, 'preferences', emptyPreferences),
      ],
      verify: (_) {
        verify(() => mockPreferencesRepo.getPreferences()).called(1);
        verifyNever(() => mockTeamRepo.getTeamByCode(any()));
        verifyNever(() => mockMatchRepo.getMatchById(any()));
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'init() handles null team from repository gracefully',
      build: () {
        when(() => mockPreferencesRepo.getPreferences())
            .thenAnswer((_) async => preferencesWithTeam);
        when(() => mockTeamRepo.getTeamByCode('USA'))
            .thenAnswer((_) async => null);

        cubit = FavoritesCubit(
          preferencesRepository: mockPreferencesRepo,
          teamRepository: mockTeamRepo,
        );
        return cubit;
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', true),
        // Loaded with preferences but favoriteTeams stays empty
        // because getTeamByCode returned null. Since empty list == empty list
        // via Equatable, no third emission occurs.
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.preferences, 'preferences', preferencesWithTeam)
            .having((s) => s.favoriteTeams, 'favoriteTeams', isEmpty),
      ],
      verify: (_) {
        verify(() => mockTeamRepo.getTeamByCode('USA')).called(1);
      },
    );

    // -------------------------------------------------------
    // FavoritesState helper property tests
    // -------------------------------------------------------
    test('FavoritesState.hasFavorites returns true when teams exist', () {
      const state = FavoritesState(
        preferences: preferencesWithTeam,
        isLoading: false,
      );
      expect(state.hasFavorites, isTrue);
    });

    test('FavoritesState.hasFavorites returns true when matches exist', () {
      const state = FavoritesState(
        preferences: preferencesWithMatch,
        isLoading: false,
      );
      expect(state.hasFavorites, isTrue);
    });

    test('FavoritesState.hasFavorites returns false when empty', () {
      final state = FavoritesState(
        preferences: emptyPreferences,
        isLoading: false,
      );
      expect(state.hasFavorites, isFalse);
    });

    test('FavoritesState.favoriteTeamCount returns correct count', () {
      const state = FavoritesState(
        preferences: preferencesWithBoth,
        isLoading: false,
      );
      expect(state.favoriteTeamCount, 2);
    });

    test('FavoritesState.favoriteMatchCount returns correct count', () {
      const state = FavoritesState(
        preferences: preferencesWithBoth,
        isLoading: false,
      );
      expect(state.favoriteMatchCount, 2);
    });

    // -------------------------------------------------------
    // Stream subscription test
    // -------------------------------------------------------
    blocTest<FavoritesCubit, FavoritesState>(
      'cubit receives updates from watchPreferences stream',
      build: () {
        when(() => mockPreferencesRepo.getPreferences())
            .thenAnswer((_) async => emptyPreferences);
        return cubit;
      },
      act: (cubit) async {
        await cubit.init();
        // Push an update through the stream
        preferencesStreamController.add(preferencesWithTeam);
        // Allow stream event to be processed
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        // init loading
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', true),
        // init loaded
        isA<FavoritesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.preferences, 'preferences', emptyPreferences),
        // stream update
        isA<FavoritesState>()
            .having((s) => s.preferences, 'preferences', preferencesWithTeam),
      ],
    );
  });
}
