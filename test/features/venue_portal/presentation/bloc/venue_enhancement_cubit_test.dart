import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/entities.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/services/venue_enhancement_service.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/bloc/venue_enhancement_cubit.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/bloc/venue_enhancement_state.dart';

// Mocks
class MockVenueEnhancementService extends Mock
    implements VenueEnhancementService {}

// Fakes for registerFallbackValue
class FakeTvSetup extends Fake implements TvSetup {}

class FakeGameDaySpecial extends Fake implements GameDaySpecial {}

class FakeAtmosphereSettings extends Fake implements AtmosphereSettings {}

// Test Data Helpers
final _now = DateTime(2026, 6, 15, 12, 0, 0);

VenueEnhancement createTestEnhancement({
  String venueId = 'venue_1',
  String ownerId = 'owner_1',
  SubscriptionTier subscriptionTier = SubscriptionTier.premium,
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
    subscriptionTier: subscriptionTier,
    showsMatches: showsMatches,
    broadcastingSchedule: broadcastingSchedule,
    tvSetup: tvSetup,
    gameSpecials: gameSpecials,
    atmosphere: atmosphere,
    liveCapacity: liveCapacity,
    createdAt: _now,
    updatedAt: _now,
  );
}

GameDaySpecial createTestSpecial({
  String id = 'special_1',
  String title = 'Happy Hour',
  String description = '50% off wings during matches',
  double? price = 4.99,
}) {
  return GameDaySpecial(
    id: id,
    title: title,
    description: description,
    price: price,
    createdAt: _now,
  );
}

TvSetup createTestTvSetup({
  int totalScreens = 4,
  AudioSetup audioSetup = AudioSetup.dedicated,
}) {
  return TvSetup(
    totalScreens: totalScreens,
    audioSetup: audioSetup,
    screenDetails: [
      const ScreenDetail(
        id: 'screen_1',
        size: '75"',
        location: 'main bar',
        hasAudio: true,
        isPrimary: true,
      ),
    ],
  );
}

AtmosphereSettings createTestAtmosphere({
  List<String> tags = const ['family-friendly', 'casual'],
  NoiseLevel noiseLevel = NoiseLevel.loud,
  CrowdDensity crowdDensity = CrowdDensity.cozy,
}) {
  return AtmosphereSettings(
    tags: tags,
    noiseLevel: noiseLevel,
    crowdDensity: crowdDensity,
  );
}

void main() {
  late MockVenueEnhancementService mockService;
  late VenueEnhancementCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeTvSetup());
    registerFallbackValue(FakeGameDaySpecial());
    registerFallbackValue(FakeAtmosphereSettings());
  });

  setUp(() {
    mockService = MockVenueEnhancementService();
    cubit = VenueEnhancementCubit(service: mockService);
  });

  tearDown(() {
    cubit.close();
  });

  group('VenueEnhancementCubit', () {
    // =========================================================================
    // 1. Initial state
    // =========================================================================
    test('initial state is correct', () {
      expect(cubit.state, equals(const VenueEnhancementState()));
      expect(cubit.state.status, VenueEnhancementStatus.initial);
      expect(cubit.state.enhancement, isNull);
      expect(cubit.state.venueId, isNull);
      expect(cubit.state.venueName, isNull);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.isSaving, isFalse);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isPremium, isFalse);
      expect(cubit.state.isFree, isTrue);
    });

    // =========================================================================
    // 2. loadEnhancement - existing enhancement
    // =========================================================================
    group('loadEnhancement', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'loads existing enhancement and emits loaded state',
        build: () {
          final enhancement = createTestEnhancement();
          when(() => mockService.getVenueEnhancement('venue_1'))
              .thenAnswer((_) async => enhancement);
          return cubit;
        },
        act: (cubit) => cubit.loadEnhancement('venue_1', venueName: 'My Bar'),
        expect: () => [
          // First: loading
          isA<VenueEnhancementState>()
              .having((s) => s.status, 'status',
                  VenueEnhancementStatus.loading)
              .having((s) => s.venueId, 'venueId', 'venue_1')
              .having((s) => s.venueName, 'venueName', 'My Bar')
              .having((s) => s.errorMessage, 'errorMessage', isNull),
          // Second: loaded with enhancement
          isA<VenueEnhancementState>()
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.loaded)
              .having((s) => s.enhancement, 'enhancement', isNotNull)
              .having(
                  (s) => s.enhancement!.venueId, 'venueId', 'venue_1')
              .having((s) => s.isPremium, 'isPremium', true),
        ],
        verify: (_) {
          verify(() => mockService.getVenueEnhancement('venue_1')).called(1);
        },
      );

      // =========================================================================
      // 3. loadEnhancement - creates new when none exists
      // =========================================================================
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'creates new enhancement when none exists',
        build: () {
          final newEnhancement = createTestEnhancement(
            subscriptionTier: SubscriptionTier.free,
          );
          when(() => mockService.getVenueEnhancement('venue_1'))
              .thenAnswer((_) async => null);
          when(() => mockService.createVenueEnhancement(venueId: 'venue_1'))
              .thenAnswer((_) async => newEnhancement);
          return cubit;
        },
        act: (cubit) => cubit.loadEnhancement('venue_1'),
        expect: () => [
          // Loading
          isA<VenueEnhancementState>().having(
              (s) => s.status, 'status', VenueEnhancementStatus.loading),
          // Loaded with newly created enhancement
          isA<VenueEnhancementState>()
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.loaded)
              .having((s) => s.enhancement, 'enhancement', isNotNull),
        ],
        verify: (_) {
          verify(() => mockService.getVenueEnhancement('venue_1')).called(1);
          verify(() => mockService.createVenueEnhancement(venueId: 'venue_1'))
              .called(1);
        },
      );

      // =========================================================================
      // 4. loadEnhancement - error handling
      // =========================================================================
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error state on exception',
        build: () {
          when(() => mockService.getVenueEnhancement('venue_1'))
              .thenThrow(Exception('Network error'));
          return cubit;
        },
        act: (cubit) => cubit.loadEnhancement('venue_1'),
        expect: () => [
          // Loading
          isA<VenueEnhancementState>().having(
              (s) => s.status, 'status', VenueEnhancementStatus.loading),
          // Error
          isA<VenueEnhancementState>()
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.error)
              .having((s) => s.errorMessage, 'errorMessage',
                  contains('Failed to load venue data')),
        ],
      );
    });

    // =========================================================================
    // 5. updateShowsMatches - success
    // =========================================================================
    group('updateShowsMatches', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'updates showsMatches flag and emits saved state',
        build: () {
          when(() => mockService.updateShowsMatches('venue_1', true))
              .thenAnswer((_) async => true);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(showsMatches: false),
        ),
        act: (cubit) => cubit.updateShowsMatches(true),
        expect: () => [
          // Saving
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          // Saved with updated value
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved)
              .having((s) => s.showsMatches, 'showsMatches', true),
        ],
      );

      // =========================================================================
      // 6. updateShowsMatches - service returns false
      // =========================================================================
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error when service returns false',
        build: () {
          when(() => mockService.updateShowsMatches('venue_1', true))
              .thenAnswer((_) async => false);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(showsMatches: false),
        ),
        act: (cubit) => cubit.updateShowsMatches(true),
        expect: () => [
          // Saving
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          // Failed
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.errorMessage, 'errorMessage',
                  'Failed to update setting'),
        ],
      );

      // =========================================================================
      // 7. updateShowsMatches - exception
      // =========================================================================
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error on exception',
        build: () {
          when(() => mockService.updateShowsMatches('venue_1', true))
              .thenThrow(Exception('Server error'));
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(showsMatches: false),
        ),
        act: (cubit) => cubit.updateShowsMatches(true),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.errorMessage, 'errorMessage',
                  contains('Error')),
        ],
      );

      // =========================================================================
      // 8. updateShowsMatches - no-op when venueId is null
      // =========================================================================
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'does nothing when venueId is null',
        build: () => cubit,
        act: (cubit) => cubit.updateShowsMatches(true),
        expect: () => [],
      );

      // =========================================================================
      // 9. updateShowsMatches - no-op when enhancement is null
      // =========================================================================
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'does nothing when enhancement is null',
        build: () => cubit,
        seed: () => const VenueEnhancementState(venueId: 'venue_1'),
        act: (cubit) => cubit.updateShowsMatches(true),
        expect: () => [],
      );
    });

    // =========================================================================
    // 10. updateBroadcastingSchedule
    // =========================================================================
    group('updateBroadcastingSchedule', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'updates broadcasting schedule for premium venue',
        build: () {
          when(() => mockService.updateBroadcastingSchedule(
                'venue_1',
                ['match_1', 'match_2'],
              )).thenAnswer((_) async => true);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.updateBroadcastingSchedule(
          ['match_1', 'match_2'],
        ),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved)
              .having(
                (s) => s.broadcastingSchedule?.matchIds,
                'matchIds',
                ['match_1', 'match_2'],
              ),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'does nothing for free-tier venue',
        build: () => cubit,
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(
            subscriptionTier: SubscriptionTier.free,
          ),
        ),
        act: (cubit) => cubit.updateBroadcastingSchedule(['match_1']),
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error when service returns false',
        build: () {
          when(() => mockService.updateBroadcastingSchedule(
                'venue_1',
                ['match_1'],
              )).thenAnswer((_) async => false);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.updateBroadcastingSchedule(['match_1']),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.errorMessage, 'errorMessage',
                  'Failed to update broadcasting schedule'),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error on exception',
        build: () {
          when(() => mockService.updateBroadcastingSchedule(
                'venue_1',
                ['match_1'],
              )).thenThrow(Exception('Network error'));
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.updateBroadcastingSchedule(['match_1']),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.errorMessage, 'errorMessage', contains('Error')),
        ],
      );
    });

    // =========================================================================
    // 11. addMatchToBroadcast
    // =========================================================================
    group('addMatchToBroadcast', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'adds match to existing broadcasting schedule',
        build: () {
          when(() => mockService.updateBroadcastingSchedule(
                'venue_1',
                ['match_1', 'match_2'],
              )).thenAnswer((_) async => true);
          return cubit;
        },
        seed: () {
          final schedule = BroadcastingSchedule(
            matchIds: ['match_1'],
            lastUpdated: _now,
          );
          return VenueEnhancementState(
            status: VenueEnhancementStatus.loaded,
            venueId: 'venue_1',
            enhancement: createTestEnhancement(
              broadcastingSchedule: schedule,
            ),
          );
        },
        act: (cubit) => cubit.addMatchToBroadcast('match_2'),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'does not add duplicate match to schedule',
        build: () => cubit,
        seed: () {
          final schedule = BroadcastingSchedule(
            matchIds: ['match_1'],
            lastUpdated: _now,
          );
          return VenueEnhancementState(
            status: VenueEnhancementStatus.loaded,
            venueId: 'venue_1',
            enhancement: createTestEnhancement(
              broadcastingSchedule: schedule,
            ),
          );
        },
        act: (cubit) => cubit.addMatchToBroadcast('match_1'),
        // No state changes - match already in schedule
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'creates schedule from empty when no schedule exists',
        build: () {
          when(() => mockService.updateBroadcastingSchedule(
                'venue_1',
                ['match_1'],
              )).thenAnswer((_) async => true);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.addMatchToBroadcast('match_1'),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved),
        ],
      );
    });

    // =========================================================================
    // 12. removeMatchFromBroadcast
    // =========================================================================
    group('removeMatchFromBroadcast', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'removes match from broadcasting schedule',
        build: () {
          when(() => mockService.updateBroadcastingSchedule(
                'venue_1',
                ['match_1'],
              )).thenAnswer((_) async => true);
          return cubit;
        },
        seed: () {
          final schedule = BroadcastingSchedule(
            matchIds: ['match_1', 'match_2'],
            lastUpdated: _now,
          );
          return VenueEnhancementState(
            status: VenueEnhancementStatus.loaded,
            venueId: 'venue_1',
            enhancement: createTestEnhancement(
              broadcastingSchedule: schedule,
            ),
          );
        },
        act: (cubit) => cubit.removeMatchFromBroadcast('match_2'),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved),
        ],
      );
    });

    // =========================================================================
    // 13. updateTvSetup
    // =========================================================================
    group('updateTvSetup', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'updates TV setup for premium venue',
        build: () {
          final tvSetup = createTestTvSetup();
          when(() => mockService.updateTvSetup('venue_1', tvSetup))
              .thenAnswer((_) async => true);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.updateTvSetup(createTestTvSetup()),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved)
              .having((s) => s.tvSetup?.totalScreens, 'totalScreens', 4),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'does nothing for free-tier venue',
        build: () => cubit,
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(
            subscriptionTier: SubscriptionTier.free,
          ),
        ),
        act: (cubit) => cubit.updateTvSetup(createTestTvSetup()),
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error when service returns false',
        build: () {
          when(() => mockService.updateTvSetup('venue_1', any()))
              .thenAnswer((_) async => false);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.updateTvSetup(createTestTvSetup()),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.errorMessage, 'errorMessage',
                  'Failed to update TV setup'),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error on exception',
        build: () {
          when(() => mockService.updateTvSetup('venue_1', any()))
              .thenThrow(Exception('Network failure'));
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.updateTvSetup(createTestTvSetup()),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.errorMessage, 'errorMessage', contains('Error')),
        ],
      );
    });

    // =========================================================================
    // 14. addGameSpecial
    // =========================================================================
    group('addGameSpecial', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'adds special and emits saved state',
        build: () {
          final special = createTestSpecial();
          when(() => mockService.addGameSpecial('venue_1', special))
              .thenAnswer((_) async => true);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.addGameSpecial(createTestSpecial()),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved)
              .having((s) => s.gameSpecials.length, 'specials count', 1)
              .having((s) => s.gameSpecials.first.title, 'special title',
                  'Happy Hour'),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'does nothing for free-tier venue',
        build: () => cubit,
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(
            subscriptionTier: SubscriptionTier.free,
          ),
        ),
        act: (cubit) => cubit.addGameSpecial(createTestSpecial()),
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error when service returns false',
        build: () {
          when(() => mockService.addGameSpecial('venue_1', any()))
              .thenAnswer((_) async => false);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.addGameSpecial(createTestSpecial()),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.errorMessage, 'errorMessage',
                  'Failed to add special'),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error on exception',
        build: () {
          when(() => mockService.addGameSpecial('venue_1', any()))
              .thenThrow(Exception('Firestore error'));
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.addGameSpecial(createTestSpecial()),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.errorMessage, 'errorMessage', contains('Error')),
        ],
      );
    });

    // =========================================================================
    // 15. updateGameSpecial
    // =========================================================================
    group('updateGameSpecial', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'updates existing special and emits saved state',
        build: () {
          final updatedSpecial = createTestSpecial(
            id: 'special_1',
            title: 'Updated Happy Hour',
            price: 3.99,
          );
          when(() => mockService.updateGameSpecial('venue_1', updatedSpecial))
              .thenAnswer((_) async => true);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(
            gameSpecials: [createTestSpecial()],
          ),
        ),
        act: (cubit) => cubit.updateGameSpecial(
          createTestSpecial(
            id: 'special_1',
            title: 'Updated Happy Hour',
            price: 3.99,
          ),
        ),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved)
              .having((s) => s.gameSpecials.length, 'specials count', 1)
              .having((s) => s.gameSpecials.first.title, 'updated title',
                  'Updated Happy Hour'),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error when service returns false',
        build: () {
          when(() => mockService.updateGameSpecial('venue_1', any()))
              .thenAnswer((_) async => false);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(
            gameSpecials: [createTestSpecial()],
          ),
        ),
        act: (cubit) => cubit.updateGameSpecial(createTestSpecial()),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.errorMessage, 'errorMessage',
                  'Failed to update special'),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'does nothing for free-tier venue',
        build: () => cubit,
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(
            subscriptionTier: SubscriptionTier.free,
          ),
        ),
        act: (cubit) => cubit.updateGameSpecial(createTestSpecial()),
        expect: () => [],
      );
    });

    // =========================================================================
    // 16. deleteGameSpecial
    // =========================================================================
    group('deleteGameSpecial', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'deletes special and removes from list',
        build: () {
          when(() => mockService.deleteGameSpecial('venue_1', 'special_1'))
              .thenAnswer((_) async => true);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(
            gameSpecials: [
              createTestSpecial(id: 'special_1'),
              createTestSpecial(id: 'special_2', title: 'Lunch Deal'),
            ],
          ),
        ),
        act: (cubit) => cubit.deleteGameSpecial('special_1'),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved)
              .having((s) => s.gameSpecials.length, 'specials count', 1)
              .having((s) => s.gameSpecials.first.id, 'remaining id',
                  'special_2'),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error when service returns false',
        build: () {
          when(() => mockService.deleteGameSpecial('venue_1', 'special_1'))
              .thenAnswer((_) async => false);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(
            gameSpecials: [createTestSpecial()],
          ),
        ),
        act: (cubit) => cubit.deleteGameSpecial('special_1'),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.errorMessage, 'errorMessage',
                  'Failed to delete special'),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'does nothing for free-tier venue',
        build: () => cubit,
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(
            subscriptionTier: SubscriptionTier.free,
          ),
        ),
        act: (cubit) => cubit.deleteGameSpecial('special_1'),
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error on exception',
        build: () {
          when(() => mockService.deleteGameSpecial('venue_1', 'special_1'))
              .thenThrow(Exception('DB error'));
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(
            gameSpecials: [createTestSpecial()],
          ),
        ),
        act: (cubit) => cubit.deleteGameSpecial('special_1'),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.errorMessage, 'errorMessage', contains('Error')),
        ],
      );
    });

    // =========================================================================
    // 17. updateAtmosphere
    // =========================================================================
    group('updateAtmosphere', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'updates atmosphere settings and emits saved state',
        build: () {
          final atmosphere = createTestAtmosphere();
          when(() => mockService.updateAtmosphere('venue_1', atmosphere))
              .thenAnswer((_) async => true);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.updateAtmosphere(createTestAtmosphere()),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved)
              .having((s) => s.atmosphere?.noiseLevel, 'noiseLevel',
                  NoiseLevel.loud)
              .having((s) => s.atmosphere?.crowdDensity, 'crowdDensity',
                  CrowdDensity.cozy),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'does nothing for free-tier venue',
        build: () => cubit,
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(
            subscriptionTier: SubscriptionTier.free,
          ),
        ),
        act: (cubit) => cubit.updateAtmosphere(createTestAtmosphere()),
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error when service returns false',
        build: () {
          when(() => mockService.updateAtmosphere('venue_1', any()))
              .thenAnswer((_) async => false);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.updateAtmosphere(createTestAtmosphere()),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.errorMessage, 'errorMessage',
                  'Failed to update atmosphere'),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error on exception',
        build: () {
          when(() => mockService.updateAtmosphere('venue_1', any()))
              .thenThrow(Exception('Network error'));
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.updateAtmosphere(createTestAtmosphere()),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.errorMessage, 'errorMessage', contains('Error')),
        ],
      );
    });

    // =========================================================================
    // 18. updateLiveCapacity
    // =========================================================================
    group('updateLiveCapacity', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'updates live capacity and emits saved state',
        build: () {
          when(() => mockService.updateLiveCapacity(
                'venue_1',
                currentOccupancy: 75,
                waitTimeMinutes: 10,
                reservationsAvailable: true,
              )).thenAnswer((_) async => true);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.updateLiveCapacity(
          currentOccupancy: 75,
          waitTimeMinutes: 10,
          reservationsAvailable: true,
        ),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved)
              .having((s) => s.liveCapacity?.currentOccupancy,
                  'currentOccupancy', 75)
              .having((s) => s.liveCapacity?.waitTimeMinutes,
                  'waitTimeMinutes', 10)
              .having((s) => s.liveCapacity?.reservationsAvailable,
                  'reservationsAvailable', true),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'does nothing for free-tier venue',
        build: () => cubit,
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(
            subscriptionTier: SubscriptionTier.free,
          ),
        ),
        act: (cubit) => cubit.updateLiveCapacity(currentOccupancy: 50),
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'does nothing when venueId is null',
        build: () => cubit,
        act: (cubit) => cubit.updateLiveCapacity(currentOccupancy: 50),
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error when service returns false',
        build: () {
          when(() => mockService.updateLiveCapacity(
                'venue_1',
                currentOccupancy: any(named: 'currentOccupancy'),
                waitTimeMinutes: any(named: 'waitTimeMinutes'),
                reservationsAvailable: any(named: 'reservationsAvailable'),
              )).thenAnswer((_) async => false);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.updateLiveCapacity(currentOccupancy: 50),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.errorMessage, 'errorMessage',
                  'Failed to update capacity'),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error on exception',
        build: () {
          when(() => mockService.updateLiveCapacity(
                'venue_1',
                currentOccupancy: any(named: 'currentOccupancy'),
                waitTimeMinutes: any(named: 'waitTimeMinutes'),
                reservationsAvailable: any(named: 'reservationsAvailable'),
              )).thenThrow(Exception('Error'));
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.updateLiveCapacity(currentOccupancy: 50),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.errorMessage, 'errorMessage', contains('Error')),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'uses existing liveCapacity when updating',
        build: () {
          when(() => mockService.updateLiveCapacity(
                'venue_1',
                currentOccupancy: 90,
                waitTimeMinutes: null,
                reservationsAvailable: null,
              )).thenAnswer((_) async => true);
          return cubit;
        },
        seed: () {
          final existingCapacity = LiveCapacity(
            currentOccupancy: 50,
            maxCapacity: 200,
            lastUpdated: _now,
            waitTimeMinutes: 5,
            reservationsAvailable: true,
          );
          return VenueEnhancementState(
            status: VenueEnhancementStatus.loaded,
            venueId: 'venue_1',
            enhancement: createTestEnhancement(
              liveCapacity: existingCapacity,
            ),
          );
        },
        act: (cubit) => cubit.updateLiveCapacity(currentOccupancy: 90),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved)
              .having((s) => s.liveCapacity?.currentOccupancy,
                  'currentOccupancy', 90),
        ],
      );
    });

    // =========================================================================
    // 19. setMaxCapacity
    // =========================================================================
    group('setMaxCapacity', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'sets max capacity and emits saved state',
        build: () {
          when(() => mockService.setMaxCapacity('venue_1', 250))
              .thenAnswer((_) async => true);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.setMaxCapacity(250),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved)
              .having((s) => s.liveCapacity?.maxCapacity, 'maxCapacity', 250),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'does nothing for free-tier venue',
        build: () => cubit,
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(
            subscriptionTier: SubscriptionTier.free,
          ),
        ),
        act: (cubit) => cubit.setMaxCapacity(250),
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error when service returns false',
        build: () {
          when(() => mockService.setMaxCapacity('venue_1', 250))
              .thenAnswer((_) async => false);
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.setMaxCapacity(250),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having((s) => s.errorMessage, 'errorMessage',
                  'Failed to set max capacity'),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'emits error on exception',
        build: () {
          when(() => mockService.setMaxCapacity('venue_1', 250))
              .thenThrow(Exception('Failed'));
          return cubit;
        },
        seed: () => VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          enhancement: createTestEnhancement(),
        ),
        act: (cubit) => cubit.setMaxCapacity(250),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.errorMessage, 'errorMessage', contains('Error')),
        ],
      );
    });

    // =========================================================================
    // 20. clearError
    // =========================================================================
    group('clearError', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'clears error message',
        build: () => cubit,
        seed: () => const VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          errorMessage: 'Something went wrong',
        ),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          isA<VenueEnhancementState>()
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
      );
    });

    // =========================================================================
    // 21. refresh
    // =========================================================================
    group('refresh', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'reloads enhancement data when venueId exists',
        build: () {
          final enhancement = createTestEnhancement();
          when(() => mockService.getVenueEnhancement('venue_1'))
              .thenAnswer((_) async => enhancement);
          return cubit;
        },
        seed: () => const VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          venueId: 'venue_1',
          venueName: 'My Bar',
        ),
        act: (cubit) => cubit.refresh(),
        expect: () => [
          // Loading
          isA<VenueEnhancementState>()
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.loading)
              .having((s) => s.venueId, 'venueId', 'venue_1')
              .having((s) => s.venueName, 'venueName', 'My Bar'),
          // Loaded
          isA<VenueEnhancementState>()
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.loaded)
              .having((s) => s.enhancement, 'enhancement', isNotNull),
        ],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'does nothing when venueId is null',
        build: () => cubit,
        act: (cubit) => cubit.refresh(),
        expect: () => [],
      );
    });

    // =========================================================================
    // 22. VenueEnhancementState computed properties
    // =========================================================================
    group('VenueEnhancementState', () {
      test('computed properties reflect enhancement data', () {
        final enhancement = createTestEnhancement(
          subscriptionTier: SubscriptionTier.premium,
          showsMatches: true,
          tvSetup: createTestTvSetup(),
          atmosphere: createTestAtmosphere(),
          liveCapacity: LiveCapacity(
            currentOccupancy: 50,
            maxCapacity: 200,
            lastUpdated: _now,
          ),
          gameSpecials: [createTestSpecial()],
        );
        final state = VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          enhancement: enhancement,
        );

        expect(state.isPremium, isTrue);
        expect(state.isFree, isFalse);
        expect(state.showsMatches, isTrue);
        expect(state.hasTvInfo, isTrue);
        expect(state.hasAtmosphereInfo, isTrue);
        expect(state.hasCapacityInfo, isTrue);
        expect(state.gameSpecials.length, 1);
        expect(state.tvSetup?.totalScreens, 4);
        expect(state.atmosphere?.noiseLevel, NoiseLevel.loud);
        expect(state.liveCapacity?.currentOccupancy, 50);
        expect(state.tier, SubscriptionTier.premium);
        expect(state.hasEnhancement, isTrue);
        expect(state.isLoaded, isTrue);
      });

      test('computed properties default correctly when enhancement is null', () {
        const state = VenueEnhancementState();

        expect(state.isPremium, isFalse);
        expect(state.isFree, isTrue);
        expect(state.showsMatches, isFalse);
        expect(state.hasTvInfo, isFalse);
        expect(state.hasAtmosphereInfo, isFalse);
        expect(state.hasCapacityInfo, isFalse);
        expect(state.gameSpecials, isEmpty);
        expect(state.activeSpecials, isEmpty);
        expect(state.tvSetup, isNull);
        expect(state.atmosphere, isNull);
        expect(state.liveCapacity, isNull);
        expect(state.broadcastingSchedule, isNull);
        expect(state.tier, SubscriptionTier.free);
        expect(state.hasEnhancement, isFalse);
        expect(state.hasActiveSpecials, isFalse);
        expect(state.hasError, isFalse);
      });

      test('isLoading returns true for loading status', () {
        const state = VenueEnhancementState(
          status: VenueEnhancementStatus.loading,
        );
        expect(state.isLoading, isTrue);
        expect(state.isLoaded, isFalse);
        expect(state.hasError, isFalse);
      });

      test('hasError returns true for error status', () {
        const state = VenueEnhancementState(
          status: VenueEnhancementStatus.error,
          errorMessage: 'Something failed',
        );
        expect(state.hasError, isTrue);
        expect(state.isLoading, isFalse);
        expect(state.isLoaded, isFalse);
      });

      test('copyWith preserves fields when no overrides given', () {
        final enhancement = createTestEnhancement();
        final state = VenueEnhancementState(
          status: VenueEnhancementStatus.loaded,
          enhancement: enhancement,
          venueId: 'venue_1',
          venueName: 'My Bar',
          errorMessage: 'error',
          isSaving: true,
        );

        final copied = state.copyWith();
        expect(copied.status, state.status);
        expect(copied.enhancement, state.enhancement);
        expect(copied.venueId, state.venueId);
        expect(copied.venueName, state.venueName);
        expect(copied.errorMessage, state.errorMessage);
        expect(copied.isSaving, state.isSaving);
      });

      test('copyWith clearError removes error message', () {
        const state = VenueEnhancementState(
          errorMessage: 'Previous error',
        );

        final cleared = state.copyWith(clearError: true);
        expect(cleared.errorMessage, isNull);
      });
    });

    // =========================================================================
    // 23. Premium guard tests across all premium methods
    // =========================================================================
    group('premium guard', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'updateBroadcastingSchedule is no-op when venueId is null',
        build: () => cubit,
        act: (cubit) => cubit.updateBroadcastingSchedule(['match_1']),
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'updateTvSetup is no-op when venueId is null',
        build: () => cubit,
        act: (cubit) => cubit.updateTvSetup(createTestTvSetup()),
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'addGameSpecial is no-op when venueId is null',
        build: () => cubit,
        act: (cubit) => cubit.addGameSpecial(createTestSpecial()),
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'updateGameSpecial is no-op when venueId is null',
        build: () => cubit,
        act: (cubit) => cubit.updateGameSpecial(createTestSpecial()),
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'deleteGameSpecial is no-op when venueId is null',
        build: () => cubit,
        act: (cubit) => cubit.deleteGameSpecial('special_1'),
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'updateAtmosphere is no-op when venueId is null',
        build: () => cubit,
        act: (cubit) => cubit.updateAtmosphere(createTestAtmosphere()),
        expect: () => [],
      );

      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'setMaxCapacity is no-op when venueId is null',
        build: () => cubit,
        act: (cubit) => cubit.setMaxCapacity(100),
        expect: () => [],
      );
    });

    // =========================================================================
    // 24. Full flow: load -> update -> save
    // =========================================================================
    group('full flow', () {
      blocTest<VenueEnhancementCubit, VenueEnhancementState>(
        'load enhancement, update showsMatches, add special',
        build: () {
          final enhancement = createTestEnhancement();
          when(() => mockService.getVenueEnhancement('venue_1'))
              .thenAnswer((_) async => enhancement);
          when(() => mockService.updateShowsMatches('venue_1', true))
              .thenAnswer((_) async => true);
          final special = createTestSpecial();
          when(() => mockService.addGameSpecial('venue_1', special))
              .thenAnswer((_) async => true);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadEnhancement('venue_1');
          await cubit.updateShowsMatches(true);
          await cubit.addGameSpecial(createTestSpecial());
        },
        expect: () => [
          // loadEnhancement: loading
          isA<VenueEnhancementState>().having(
              (s) => s.status, 'status', VenueEnhancementStatus.loading),
          // loadEnhancement: loaded
          isA<VenueEnhancementState>().having(
              (s) => s.status, 'status', VenueEnhancementStatus.loaded),
          // updateShowsMatches: saving
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          // updateShowsMatches: saved
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved)
              .having((s) => s.showsMatches, 'showsMatches', true),
          // addGameSpecial: saving
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', true),
          // addGameSpecial: saved
          isA<VenueEnhancementState>()
              .having((s) => s.isSaving, 'isSaving', false)
              .having(
                  (s) => s.status, 'status', VenueEnhancementStatus.saved)
              .having((s) => s.gameSpecials.length, 'specials count', 1),
        ],
      );
    });
  });
}
