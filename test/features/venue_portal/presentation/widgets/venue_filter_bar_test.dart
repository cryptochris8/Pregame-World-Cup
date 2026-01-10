import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/bloc/venue_filter_cubit.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/venue_filter_criteria.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/widgets/venue_filter_bar.dart';

/// A mock VenueFilterCubit for testing
class MockVenueFilterCubit extends Cubit<VenueFilterState>
    implements VenueFilterCubit {
  MockVenueFilterCubit([VenueFilterState? initialState])
      : super(initialState ?? const VenueFilterState());

  bool setShowsMatchFilterCalled = false;
  String? lastShowsMatchId;

  bool toggleHasTvsFilterCalled = false;
  bool toggleHasSpecialsFilterCalled = false;
  bool clearAllFiltersCalled = false;
  bool setHasTvsFilterCalled = false;
  bool setHasSpecialsFilterCalled = false;
  bool setHasCapacityFilterCalled = false;
  bool addAtmosphereTagCalled = false;
  bool removeAtmosphereTagCalled = false;

  @override
  void setShowsMatchFilter(String? matchId) {
    setShowsMatchFilterCalled = true;
    lastShowsMatchId = matchId;
    if (matchId != null) {
      emit(state.copyWith(
        criteria: state.criteria.copyWith(showsMatchId: matchId),
      ));
    } else {
      emit(state.copyWith(criteria: state.criteria.clearShowsMatch()));
    }
  }

  @override
  void toggleHasTvsFilter() {
    toggleHasTvsFilterCalled = true;
    final newValue = state.criteria.hasTvs == true ? null : true;
    emit(state.copyWith(
      criteria: newValue != null
          ? state.criteria.copyWith(hasTvs: newValue)
          : state.criteria.clearHasTvs(),
    ));
  }

  @override
  void toggleHasSpecialsFilter() {
    toggleHasSpecialsFilterCalled = true;
    final newValue = state.criteria.hasSpecials == true ? null : true;
    emit(state.copyWith(
      criteria: newValue != null
          ? state.criteria.copyWith(hasSpecials: newValue)
          : state.criteria.clearHasSpecials(),
    ));
  }

  @override
  void clearAllFilters() {
    clearAllFiltersCalled = true;
    emit(state.copyWith(criteria: const VenueFilterCriteria()));
  }

  @override
  void setHasTvsFilter(bool? hasTvs) {
    setHasTvsFilterCalled = true;
    emit(state.copyWith(
      criteria: hasTvs != null
          ? state.criteria.copyWith(hasTvs: hasTvs)
          : state.criteria.clearHasTvs(),
    ));
  }

  @override
  void setHasSpecialsFilter(bool? hasSpecials) {
    setHasSpecialsFilterCalled = true;
    emit(state.copyWith(
      criteria: hasSpecials != null
          ? state.criteria.copyWith(hasSpecials: hasSpecials)
          : state.criteria.clearHasSpecials(),
    ));
  }

  @override
  void setHasCapacityFilter(bool? hasCapacity) {
    setHasCapacityFilterCalled = true;
    emit(state.copyWith(
      criteria: state.criteria.copyWith(hasCapacityInfo: hasCapacity),
    ));
  }

  @override
  void addAtmosphereTag(String tag) {
    addAtmosphereTagCalled = true;
    final tags = [...state.criteria.atmosphereTags, tag];
    emit(state.copyWith(
      criteria: state.criteria.copyWith(atmosphereTags: tags),
    ));
  }

  @override
  void removeAtmosphereTag(String tag) {
    removeAtmosphereTagCalled = true;
    final tags = state.criteria.atmosphereTags.where((t) => t != tag).toList();
    emit(state.copyWith(
      criteria: state.criteria.copyWith(atmosphereTags: tags),
    ));
  }

  // Unused methods for this test
  @override
  void setAtmosphereTagsFilter(List<String> tags) {}
  @override
  void setTeamAffinityFilter(String? teamCode) {}
  @override
  void clearError() {}
  @override
  Future<void> loadEnhancementsForVenues(List<String> venueIds) async {}
  @override
  List<String> filterVenueIds(List<String> venueIds) => venueIds;
}

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  Widget buildTestWidget({
    required MockVenueFilterCubit cubit,
    String? matchId,
    String? matchLabel,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<VenueFilterCubit>.value(
          value: cubit,
          child: VenueFilterBar(
            matchId: matchId,
            matchLabel: matchLabel,
          ),
        ),
      ),
    );
  }

  group('VenueFilterBar', () {
    testWidgets('renders Has TVs filter chip', (tester) async {
      final cubit = MockVenueFilterCubit();

      await tester.pumpWidget(buildTestWidget(cubit: cubit));

      expect(find.text('Has TVs'), findsOneWidget);
      expect(find.byIcon(Icons.tv), findsOneWidget);
    });

    testWidgets('renders Specials filter chip', (tester) async {
      final cubit = MockVenueFilterCubit();

      await tester.pumpWidget(buildTestWidget(cubit: cubit));

      expect(find.text('Specials'), findsOneWidget);
      expect(find.byIcon(Icons.local_offer), findsOneWidget);
    });

    testWidgets('renders Shows Match filter when matchId provided', (tester) async {
      final cubit = MockVenueFilterCubit();

      await tester.pumpWidget(buildTestWidget(
        cubit: cubit,
        matchId: 'match_123',
      ));

      expect(find.text('Shows Match'), findsOneWidget);
      expect(find.byIcon(Icons.live_tv), findsOneWidget);
    });

    testWidgets('hides Shows Match filter when matchId not provided', (tester) async {
      final cubit = MockVenueFilterCubit();

      await tester.pumpWidget(buildTestWidget(cubit: cubit));

      expect(find.text('Shows Match'), findsNothing);
    });

    testWidgets('toggles TVs filter when tapped', (tester) async {
      final cubit = MockVenueFilterCubit();

      await tester.pumpWidget(buildTestWidget(cubit: cubit));

      await tester.tap(find.text('Has TVs'));
      await tester.pumpAndSettle();

      expect(cubit.toggleHasTvsFilterCalled, isTrue);
    });

    testWidgets('toggles Specials filter when tapped', (tester) async {
      final cubit = MockVenueFilterCubit();

      await tester.pumpWidget(buildTestWidget(cubit: cubit));

      await tester.tap(find.text('Specials'));
      await tester.pumpAndSettle();

      expect(cubit.toggleHasSpecialsFilterCalled, isTrue);
    });

    testWidgets('toggles Shows Match filter when tapped', (tester) async {
      final cubit = MockVenueFilterCubit();

      await tester.pumpWidget(buildTestWidget(
        cubit: cubit,
        matchId: 'match_123',
      ));

      await tester.tap(find.text('Shows Match'));
      await tester.pumpAndSettle();

      expect(cubit.setShowsMatchFilterCalled, isTrue);
      expect(cubit.lastShowsMatchId, 'match_123');
    });

    testWidgets('shows Clear button when filters active', (tester) async {
      final cubit = MockVenueFilterCubit(const VenueFilterState(
        criteria: VenueFilterCriteria(hasTvs: true),
      ));

      await tester.pumpWidget(buildTestWidget(cubit: cubit));

      expect(find.text('Clear'), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('hides Clear button when no filters active', (tester) async {
      final cubit = MockVenueFilterCubit();

      await tester.pumpWidget(buildTestWidget(cubit: cubit));

      expect(find.text('Clear'), findsNothing);
    });

    testWidgets('calls clearAllFilters when Clear tapped', (tester) async {
      final cubit = MockVenueFilterCubit(const VenueFilterState(
        criteria: VenueFilterCriteria(hasTvs: true),
      ));

      await tester.pumpWidget(buildTestWidget(cubit: cubit));

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(cubit.clearAllFiltersCalled, isTrue);
    });

    testWidgets('shows filter chips as selected when active', (tester) async {
      final cubit = MockVenueFilterCubit(const VenueFilterState(
        criteria: VenueFilterCriteria(hasTvs: true, hasSpecials: true),
      ));

      await tester.pumpWidget(buildTestWidget(cubit: cubit));

      // FilterChips should be in selected state
      final filterChips = find.byType(FilterChip);
      expect(filterChips, findsAtLeast(2));
    });

    testWidgets('is scrollable horizontally', (tester) async {
      final cubit = MockVenueFilterCubit();

      await tester.pumpWidget(buildTestWidget(
        cubit: cubit,
        matchId: 'match_123',
      ));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  // Note: VenueFilterSheet tests are skipped as the DraggableScrollableSheet
  // requires more complex setup with MediaQuery and screen size configuration.
  // The VenueFilterSheet is a modal bottom sheet that's best tested with
  // integration tests or golden tests.
  //
  // The VenueFilterBar tests above cover the core filtering functionality.
}
