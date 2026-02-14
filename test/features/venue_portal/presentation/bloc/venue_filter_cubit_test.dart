import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/entities.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/services/venue_enhancement_service.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/bloc/venue_filter_cubit.dart';

class MockVenueEnhancementService extends Mock
    implements VenueEnhancementService {}

void main() {
  late MockVenueEnhancementService mockService;
  late VenueFilterCubit cubit;

  final now = DateTime(2026, 6, 15);

  // Helper to build a VenueEnhancement with sensible defaults
  VenueEnhancement createEnhancement({
    required String venueId,
    String ownerId = 'owner1',
    SubscriptionTier tier = SubscriptionTier.premium,
    bool showsMatches = false,
    BroadcastingSchedule? broadcastingSchedule,
    TvSetup? tvSetup,
    List<GameDaySpecial> gameSpecials = const [],
    AtmosphereSettings? atmosphere,
    LiveCapacity? liveCapacity,
  }) {
    return VenueEnhancement(
      venueId: venueId,
      ownerId: ownerId,
      subscriptionTier: tier,
      showsMatches: showsMatches,
      broadcastingSchedule: broadcastingSchedule,
      tvSetup: tvSetup,
      gameSpecials: gameSpecials,
      atmosphere: atmosphere,
      liveCapacity: liveCapacity,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() {
    mockService = MockVenueEnhancementService();
    cubit = VenueFilterCubit(service: mockService);
  });

  tearDown(() {
    cubit.close();
  });

  group('VenueFilterCubit', () {
    // =========================================================================
    // 1. Initial state
    // =========================================================================
    test('initial state is correct (no filters, no enhancements, not loading)',
        () {
      expect(cubit.state, equals(const VenueFilterState()));
      expect(cubit.state.criteria, equals(const VenueFilterCriteria()));
      expect(cubit.state.enhancements, isEmpty);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.hasActiveFilters, isFalse);
      expect(cubit.state.activeFilterCount, 0);
    });

    // =========================================================================
    // 2. loadEnhancementsForVenues - success
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'loadEnhancementsForVenues loads and stores enhancements',
      build: () {
        final enhancements = {
          'venue1': createEnhancement(venueId: 'venue1'),
          'venue2': createEnhancement(venueId: 'venue2'),
        };
        when(() => mockService.getEnhancementsForVenues(['venue1', 'venue2']))
            .thenAnswer((_) async => enhancements);
        return cubit;
      },
      act: (cubit) => cubit.loadEnhancementsForVenues(['venue1', 'venue2']),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<VenueFilterState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.enhancements.length, 'enhancements count', 2)
            .having((s) => s.enhancements.containsKey('venue1'),
                'has venue1', true)
            .having((s) => s.enhancements.containsKey('venue2'),
                'has venue2', true),
      ],
      verify: (_) {
        verify(() =>
                mockService.getEnhancementsForVenues(['venue1', 'venue2']))
            .called(1);
      },
    );

    // =========================================================================
    // 3. loadEnhancementsForVenues - empty list
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'loadEnhancementsForVenues does nothing for empty list',
      build: () => cubit,
      act: (cubit) => cubit.loadEnhancementsForVenues([]),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockService.getEnhancementsForVenues(any()));
      },
    );

    // =========================================================================
    // 4. loadEnhancementsForVenues - error handling
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'loadEnhancementsForVenues handles errors',
      build: () {
        when(() => mockService.getEnhancementsForVenues(any()))
            .thenThrow(Exception('Network error'));
        return cubit;
      },
      act: (cubit) => cubit.loadEnhancementsForVenues(['venue1']),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<VenueFilterState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'has error', isNotNull)
            .having((s) => s.errorMessage, 'error message',
                contains('Failed to load venue data')),
      ],
    );

    // =========================================================================
    // 5. setShowsMatchFilter - sets match ID
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'setShowsMatchFilter sets match ID filter',
      build: () => cubit,
      act: (cubit) => cubit.setShowsMatchFilter('match_42'),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.criteria.showsMatchId, 'showsMatchId', 'match_42')
            .having((s) => s.hasActiveFilters, 'hasActiveFilters', true),
      ],
    );

    // =========================================================================
    // 6. setShowsMatchFilter - null clears match filter
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'setShowsMatchFilter with null clears match filter',
      build: () => cubit,
      seed: () => const VenueFilterState(
        criteria: VenueFilterCriteria(showsMatchId: 'match_42'),
      ),
      act: (cubit) => cubit.setShowsMatchFilter(null),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.criteria.showsMatchId, 'showsMatchId', isNull)
            .having((s) => s.hasActiveFilters, 'hasActiveFilters', false),
      ],
    );

    // =========================================================================
    // 7. setHasTvsFilter - sets TV filter
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'setHasTvsFilter sets TV filter',
      build: () => cubit,
      act: (cubit) => cubit.setHasTvsFilter(true),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.criteria.hasTvs, 'hasTvs', true)
            .having((s) => s.hasActiveFilters, 'hasActiveFilters', true),
      ],
    );

    // =========================================================================
    // 8. toggleHasTvsFilter - toggles between true and null
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'toggleHasTvsFilter toggles from null to true',
      build: () => cubit,
      act: (cubit) => cubit.toggleHasTvsFilter(),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.criteria.hasTvs, 'hasTvs', true),
      ],
    );

    blocTest<VenueFilterCubit, VenueFilterState>(
      'toggleHasTvsFilter toggles from true to null',
      build: () => cubit,
      seed: () => const VenueFilterState(
        criteria: VenueFilterCriteria(hasTvs: true),
      ),
      act: (cubit) => cubit.toggleHasTvsFilter(),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.criteria.hasTvs, 'hasTvs', isNull),
      ],
    );

    // =========================================================================
    // 9. setHasSpecialsFilter - sets specials filter
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'setHasSpecialsFilter sets specials filter',
      build: () => cubit,
      act: (cubit) => cubit.setHasSpecialsFilter(true),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.criteria.hasSpecials, 'hasSpecials', true)
            .having((s) => s.hasActiveFilters, 'hasActiveFilters', true),
      ],
    );

    // =========================================================================
    // 10. toggleHasSpecialsFilter - toggles between true and null
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'toggleHasSpecialsFilter toggles from null to true',
      build: () => cubit,
      act: (cubit) => cubit.toggleHasSpecialsFilter(),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.criteria.hasSpecials, 'hasSpecials', true),
      ],
    );

    blocTest<VenueFilterCubit, VenueFilterState>(
      'toggleHasSpecialsFilter toggles from true to null',
      build: () => cubit,
      seed: () => const VenueFilterState(
        criteria: VenueFilterCriteria(hasSpecials: true),
      ),
      act: (cubit) => cubit.toggleHasSpecialsFilter(),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.criteria.hasSpecials, 'hasSpecials', isNull),
      ],
    );

    // =========================================================================
    // 11. setAtmosphereTagsFilter - sets atmosphere tags
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'setAtmosphereTagsFilter sets atmosphere tags',
      build: () => cubit,
      act: (cubit) =>
          cubit.setAtmosphereTagsFilter(['family-friendly', 'casual']),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.criteria.atmosphereTags, 'atmosphereTags',
                ['family-friendly', 'casual'])
            .having((s) => s.hasActiveFilters, 'hasActiveFilters', true),
      ],
    );

    // =========================================================================
    // 12. addAtmosphereTag - adds new tag (no duplicates)
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'addAtmosphereTag adds a new tag',
      build: () => cubit,
      seed: () => const VenueFilterState(
        criteria: VenueFilterCriteria(atmosphereTags: ['casual']),
      ),
      act: (cubit) => cubit.addAtmosphereTag('rowdy'),
      expect: () => [
        isA<VenueFilterState>().having(
            (s) => s.criteria.atmosphereTags, 'atmosphereTags',
            ['casual', 'rowdy']),
      ],
    );

    blocTest<VenueFilterCubit, VenueFilterState>(
      'addAtmosphereTag does not add duplicate tag',
      build: () => cubit,
      seed: () => const VenueFilterState(
        criteria: VenueFilterCriteria(atmosphereTags: ['casual']),
      ),
      act: (cubit) => cubit.addAtmosphereTag('casual'),
      expect: () => [],
    );

    // =========================================================================
    // 13. removeAtmosphereTag - removes tag
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'removeAtmosphereTag removes an existing tag',
      build: () => cubit,
      seed: () => const VenueFilterState(
        criteria: VenueFilterCriteria(
            atmosphereTags: ['casual', 'rowdy', '21+']),
      ),
      act: (cubit) => cubit.removeAtmosphereTag('rowdy'),
      expect: () => [
        isA<VenueFilterState>().having(
            (s) => s.criteria.atmosphereTags, 'atmosphereTags',
            ['casual', '21+']),
      ],
    );

    blocTest<VenueFilterCubit, VenueFilterState>(
      'removeAtmosphereTag with non-existent tag does not emit new state',
      build: () => cubit,
      seed: () => const VenueFilterState(
        criteria: VenueFilterCriteria(atmosphereTags: ['casual']),
      ),
      act: (cubit) => cubit.removeAtmosphereTag('non-existent'),
      // Equatable detects the state is unchanged, so no new emission
      expect: () => [],
    );

    // =========================================================================
    // 14. setHasCapacityFilter - sets capacity filter
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'setHasCapacityFilter sets capacity filter',
      build: () => cubit,
      act: (cubit) => cubit.setHasCapacityFilter(true),
      expect: () => [
        isA<VenueFilterState>()
            .having(
                (s) => s.criteria.hasCapacityInfo, 'hasCapacityInfo', true)
            .having((s) => s.hasActiveFilters, 'hasActiveFilters', true),
      ],
    );

    // =========================================================================
    // 15. setTeamAffinityFilter - sets team affinity
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'setTeamAffinityFilter sets team affinity',
      build: () => cubit,
      act: (cubit) => cubit.setTeamAffinityFilter('USA'),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.criteria.teamAffinity, 'teamAffinity', 'USA')
            .having((s) => s.hasActiveFilters, 'hasActiveFilters', true),
      ],
    );

    // =========================================================================
    // 16. clearAllFilters - resets all filter criteria
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'clearAllFilters resets all filter criteria',
      build: () => cubit,
      seed: () => VenueFilterState(
        criteria: const VenueFilterCriteria(
          showsMatchId: 'match_1',
          hasTvs: true,
          hasSpecials: true,
          atmosphereTags: ['rowdy'],
          hasCapacityInfo: true,
          teamAffinity: 'MEX',
        ),
        enhancements: {
          'venue1': createEnhancement(venueId: 'venue1'),
        },
      ),
      act: (cubit) => cubit.clearAllFilters(),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.criteria, 'criteria',
                const VenueFilterCriteria())
            .having((s) => s.hasActiveFilters, 'hasActiveFilters', false)
            .having((s) => s.activeFilterCount, 'activeFilterCount', 0)
            // Enhancements should be preserved
            .having((s) => s.enhancements.length, 'enhancements count', 1),
      ],
    );

    // =========================================================================
    // 17. clearError - clears error message
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'clearError clears error message',
      build: () => cubit,
      seed: () => const VenueFilterState(
        errorMessage: 'Something went wrong',
      ),
      act: (cubit) => cubit.clearError(),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    // =========================================================================
    // 18. filterVenueIds - returns all IDs when no filters active
    // =========================================================================
    test('filterVenueIds returns all IDs when no filters are active', () {
      final venueIds = ['venue1', 'venue2', 'venue3'];
      final result = cubit.filterVenueIds(venueIds);
      expect(result, equals(venueIds));
    });

    // =========================================================================
    // 19. filterVenueIds - filters based on enhancements
    // =========================================================================
    group('filterVenueIds filters based on enhancements', () {
      test('filters by match broadcasting', () {
        final enhancements = {
          'venue1': createEnhancement(
            venueId: 'venue1',
            broadcastingSchedule: BroadcastingSchedule(
              matchIds: const ['match_1', 'match_2'],
              lastUpdated: now,
            ),
          ),
          'venue2': createEnhancement(
            venueId: 'venue2',
            broadcastingSchedule: BroadcastingSchedule(
              matchIds: const ['match_3'],
              lastUpdated: now,
            ),
          ),
          'venue3': createEnhancement(
            venueId: 'venue3',
            broadcastingSchedule: BroadcastingSchedule(
              matchIds: const ['match_1'],
              lastUpdated: now,
            ),
          ),
        };

        cubit.emit(VenueFilterState(
          criteria: const VenueFilterCriteria(showsMatchId: 'match_1'),
          enhancements: enhancements,
        ));

        final result = cubit.filterVenueIds(['venue1', 'venue2', 'venue3']);
        expect(result, equals(['venue1', 'venue3']));
      });

      test('filters by TV info', () {
        final enhancements = {
          'venue1': createEnhancement(
            venueId: 'venue1',
            tvSetup: const TvSetup(totalScreens: 5),
          ),
          'venue2': createEnhancement(
            venueId: 'venue2',
            // No TV setup
          ),
          'venue3': createEnhancement(
            venueId: 'venue3',
            tvSetup: const TvSetup(totalScreens: 0), // hasScreens = false
          ),
        };

        cubit.emit(VenueFilterState(
          criteria: const VenueFilterCriteria(hasTvs: true),
          enhancements: enhancements,
        ));

        final result = cubit.filterVenueIds(['venue1', 'venue2', 'venue3']);
        expect(result, equals(['venue1']));
      });

      test('filters by active specials', () {
        final activeSpecial = GameDaySpecial(
          id: 'special1',
          title: 'Happy Hour',
          description: '50% off',
          isActive: true,
          expiresAt: now.add(const Duration(days: 30)),
          createdAt: now,
        );
        final expiredSpecial = GameDaySpecial(
          id: 'special2',
          title: 'Old Special',
          description: 'Expired',
          isActive: true,
          expiresAt: DateTime(2020, 1, 1), // expired
          createdAt: now,
        );

        final enhancements = {
          'venue1': createEnhancement(
            venueId: 'venue1',
            gameSpecials: [activeSpecial],
          ),
          'venue2': createEnhancement(
            venueId: 'venue2',
            gameSpecials: [expiredSpecial],
          ),
          'venue3': createEnhancement(
            venueId: 'venue3',
            // No specials
          ),
        };

        cubit.emit(VenueFilterState(
          criteria: const VenueFilterCriteria(hasSpecials: true),
          enhancements: enhancements,
        ));

        final result = cubit.filterVenueIds(['venue1', 'venue2', 'venue3']);
        expect(result, equals(['venue1']));
      });

      test('filters by atmosphere tags', () {
        final enhancements = {
          'venue1': createEnhancement(
            venueId: 'venue1',
            atmosphere: const AtmosphereSettings(
              tags: ['family-friendly', 'casual'],
            ),
          ),
          'venue2': createEnhancement(
            venueId: 'venue2',
            atmosphere: const AtmosphereSettings(
              tags: ['21+', 'rowdy'],
            ),
          ),
          'venue3': createEnhancement(
            venueId: 'venue3',
            // No atmosphere
          ),
        };

        cubit.emit(VenueFilterState(
          criteria:
              const VenueFilterCriteria(atmosphereTags: ['family-friendly']),
          enhancements: enhancements,
        ));

        final result = cubit.filterVenueIds(['venue1', 'venue2', 'venue3']);
        expect(result, equals(['venue1']));
      });

      test('filters by capacity info', () {
        final enhancements = {
          'venue1': createEnhancement(
            venueId: 'venue1',
            liveCapacity: LiveCapacity.empty(),
          ),
          'venue2': createEnhancement(
            venueId: 'venue2',
            // No capacity
          ),
        };

        cubit.emit(VenueFilterState(
          criteria: const VenueFilterCriteria(hasCapacityInfo: true),
          enhancements: enhancements,
        ));

        final result = cubit.filterVenueIds(['venue1', 'venue2']);
        expect(result, equals(['venue1']));
      });

      test('filters by team affinity', () {
        final enhancements = {
          'venue1': createEnhancement(
            venueId: 'venue1',
            atmosphere: const AtmosphereSettings(
              fanBaseAffinity: ['USA', 'MEX'],
            ),
          ),
          'venue2': createEnhancement(
            venueId: 'venue2',
            atmosphere: const AtmosphereSettings(
              fanBaseAffinity: ['BRA'],
            ),
          ),
          'venue3': createEnhancement(
            venueId: 'venue3',
            atmosphere: const AtmosphereSettings(
              fanBaseAffinity: [], // empty = supports all teams
            ),
          ),
          'venue4': createEnhancement(
            venueId: 'venue4',
            // No atmosphere = fails filter
          ),
        };

        cubit.emit(VenueFilterState(
          criteria: const VenueFilterCriteria(teamAffinity: 'USA'),
          enhancements: enhancements,
        ));

        final result =
            cubit.filterVenueIds(['venue1', 'venue2', 'venue3', 'venue4']);
        expect(result, equals(['venue1', 'venue3']));
      });

      test('venue without enhancement data fails when filters are active', () {
        cubit.emit(const VenueFilterState(
          criteria: VenueFilterCriteria(hasTvs: true),
          enhancements: {}, // no enhancement data at all
        ));

        final result = cubit.filterVenueIds(['venue1', 'venue2']);
        expect(result, isEmpty);
      });

      test('filters combine - venue must pass all active filters', () {
        final enhancements = {
          'venue1': createEnhancement(
            venueId: 'venue1',
            tvSetup: const TvSetup(totalScreens: 5),
            broadcastingSchedule: BroadcastingSchedule(
              matchIds: const ['match_1'],
              lastUpdated: now,
            ),
          ),
          'venue2': createEnhancement(
            venueId: 'venue2',
            tvSetup: const TvSetup(totalScreens: 3),
            broadcastingSchedule: BroadcastingSchedule(
              matchIds: const ['match_2'],
              lastUpdated: now,
            ),
          ),
          'venue3': createEnhancement(
            venueId: 'venue3',
            // No TV, broadcasts match_1
            broadcastingSchedule: BroadcastingSchedule(
              matchIds: const ['match_1'],
              lastUpdated: now,
            ),
          ),
        };

        cubit.emit(VenueFilterState(
          criteria: const VenueFilterCriteria(
            showsMatchId: 'match_1',
            hasTvs: true,
          ),
          enhancements: enhancements,
        ));

        // Only venue1 has TVs AND broadcasts match_1
        final result = cubit.filterVenueIds(['venue1', 'venue2', 'venue3']);
        expect(result, equals(['venue1']));
      });
    });

    // =========================================================================
    // 20. hasActiveFilters / activeFilterCount computed properties
    // =========================================================================
    group('hasActiveFilters and activeFilterCount', () {
      test('hasActiveFilters is false when no filters set', () {
        expect(cubit.state.hasActiveFilters, isFalse);
        expect(cubit.state.activeFilterCount, 0);
      });

      test('hasActiveFilters is true with showsMatchId', () {
        cubit.emit(const VenueFilterState(
          criteria: VenueFilterCriteria(showsMatchId: 'match_1'),
        ));
        expect(cubit.state.hasActiveFilters, isTrue);
        expect(cubit.state.activeFilterCount, 1);
      });

      test('hasActiveFilters is true with hasTvs', () {
        cubit.emit(const VenueFilterState(
          criteria: VenueFilterCriteria(hasTvs: true),
        ));
        expect(cubit.state.hasActiveFilters, isTrue);
        expect(cubit.state.activeFilterCount, 1);
      });

      test('hasActiveFilters is true with hasSpecials', () {
        cubit.emit(const VenueFilterState(
          criteria: VenueFilterCriteria(hasSpecials: true),
        ));
        expect(cubit.state.hasActiveFilters, isTrue);
        expect(cubit.state.activeFilterCount, 1);
      });

      test('hasActiveFilters is true with atmosphereTags', () {
        cubit.emit(const VenueFilterState(
          criteria: VenueFilterCriteria(atmosphereTags: ['rowdy']),
        ));
        expect(cubit.state.hasActiveFilters, isTrue);
        expect(cubit.state.activeFilterCount, 1);
      });

      test('hasActiveFilters is true with hasCapacityInfo', () {
        cubit.emit(const VenueFilterState(
          criteria: VenueFilterCriteria(hasCapacityInfo: true),
        ));
        expect(cubit.state.hasActiveFilters, isTrue);
        expect(cubit.state.activeFilterCount, 1);
      });

      test('hasActiveFilters is true with teamAffinity', () {
        cubit.emit(const VenueFilterState(
          criteria: VenueFilterCriteria(teamAffinity: 'BRA'),
        ));
        expect(cubit.state.hasActiveFilters, isTrue);
        expect(cubit.state.activeFilterCount, 1);
      });

      test('activeFilterCount counts all active filters correctly', () {
        cubit.emit(const VenueFilterState(
          criteria: VenueFilterCriteria(
            showsMatchId: 'match_1',
            hasTvs: true,
            hasSpecials: true,
            atmosphereTags: ['rowdy', 'casual'],
            hasCapacityInfo: true,
            teamAffinity: 'USA',
          ),
        ));
        // 1 (match) + 1 (tvs) + 1 (specials) + 2 (atmosphere tags) + 1 (capacity) + 1 (team) = 7
        expect(cubit.state.activeFilterCount, 7);
      });

      test('activeFilterCount ignores false boolean filters', () {
        cubit.emit(const VenueFilterState(
          criteria: VenueFilterCriteria(
            hasTvs: false,
            hasSpecials: false,
            hasCapacityInfo: false,
          ),
        ));
        expect(cubit.state.hasActiveFilters, isFalse);
        expect(cubit.state.activeFilterCount, 0);
      });
    });

    // =========================================================================
    // Additional state tests
    // =========================================================================
    group('VenueFilterState', () {
      test('getEnhancement returns enhancement for known venue', () {
        final enhancement = createEnhancement(venueId: 'venue1');
        cubit.emit(VenueFilterState(
          enhancements: {'venue1': enhancement},
        ));
        expect(cubit.state.getEnhancement('venue1'), equals(enhancement));
      });

      test('getEnhancement returns null for unknown venue', () {
        expect(cubit.state.getEnhancement('unknown'), isNull);
      });

      test('venuePassesFilters returns true when no filters active', () {
        expect(cubit.state.venuePassesFilters('any_venue'), isTrue);
      });

      test('venuePassesFilters returns false for unknown venue with active filters',
          () {
        cubit.emit(const VenueFilterState(
          criteria: VenueFilterCriteria(hasTvs: true),
        ));
        expect(cubit.state.venuePassesFilters('unknown_venue'), isFalse);
      });

      test('copyWith preserves existing state when no args provided', () {
        final original = VenueFilterState(
          criteria: const VenueFilterCriteria(showsMatchId: 'match_1'),
          enhancements: {'v1': createEnhancement(venueId: 'v1')},
          isLoading: true,
          errorMessage: 'error',
        );
        final copy = original.copyWith();
        expect(copy.criteria, equals(original.criteria));
        expect(copy.enhancements, equals(original.enhancements));
        expect(copy.isLoading, equals(original.isLoading));
        expect(copy.errorMessage, equals(original.errorMessage));
      });

      test('copyWith with clearError removes error message', () {
        const original = VenueFilterState(
          errorMessage: 'some error',
        );
        final copy = original.copyWith(clearError: true);
        expect(copy.errorMessage, isNull);
      });
    });

    // =========================================================================
    // Merge behavior for loadEnhancementsForVenues
    // =========================================================================
    blocTest<VenueFilterCubit, VenueFilterState>(
      'loadEnhancementsForVenues merges with existing enhancements',
      build: () {
        when(() => mockService.getEnhancementsForVenues(['venue2']))
            .thenAnswer((_) async => {
                  'venue2': createEnhancement(venueId: 'venue2'),
                });
        return cubit;
      },
      seed: () => VenueFilterState(
        enhancements: {'venue1': createEnhancement(venueId: 'venue1')},
      ),
      act: (cubit) => cubit.loadEnhancementsForVenues(['venue2']),
      expect: () => [
        isA<VenueFilterState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.enhancements.length, 'enhancements during load', 1),
        isA<VenueFilterState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.enhancements.length, 'merged enhancements', 2)
            .having((s) => s.enhancements.containsKey('venue1'),
                'has venue1', true)
            .having((s) => s.enhancements.containsKey('venue2'),
                'has venue2', true),
      ],
    );

    // =========================================================================
    // Free-tier broadcasting check
    // =========================================================================
    test('filterVenueIds handles free-tier venues with showsMatches', () {
      final enhancements = {
        'venue1': createEnhancement(
          venueId: 'venue1',
          tier: SubscriptionTier.free,
          showsMatches: true, // free tier says "yes, I show matches"
        ),
        'venue2': createEnhancement(
          venueId: 'venue2',
          tier: SubscriptionTier.free,
          showsMatches: false,
        ),
      };

      cubit.emit(VenueFilterState(
        criteria: const VenueFilterCriteria(showsMatchId: 'any_match'),
        enhancements: enhancements,
      ));

      final result = cubit.filterVenueIds(['venue1', 'venue2']);
      // venue1 is free tier with showsMatches=true -> isBroadcastingMatch returns true
      // venue2 is free tier with showsMatches=false -> isBroadcastingMatch returns false
      expect(result, equals(['venue1']));
    });
  });
}
