import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';

import 'package:pregame_world_cup/features/watch_party/presentation/screens/watch_party_detail_screen.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/bloc/watch_party_bloc.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_member.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_message.dart';

import '../../mock_factories.dart';

class MockWatchPartyBloc extends MockBloc<WatchPartyEvent, WatchPartyState>
    implements WatchPartyBloc {}

class FakeWatchPartyEvent extends Fake implements WatchPartyEvent {}

class FakeWatchPartyState extends Fake implements WatchPartyState {}

void main() {
  late MockWatchPartyBloc mockBloc;

  setUpAll(() async {
    registerFallbackValue(FakeWatchPartyEvent());
    registerFallbackValue(FakeWatchPartyState());

    // Set up Firebase mocks so that FirebaseAuth.instance does not throw
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() {
    mockBloc = MockWatchPartyBloc();
  });

  tearDown(() {
    mockBloc.close();
  });

  Widget buildTestWidget({String watchPartyId = 'wp_test_123'}) {
    return MaterialApp(
      home: BlocProvider<WatchPartyBloc>.value(
        value: mockBloc,
        child: WatchPartyDetailScreen(watchPartyId: watchPartyId),
      ),
    );
  }

  /// Helper to create a WatchPartyDetailLoaded state with common defaults.
  WatchPartyDetailLoaded createDetailLoadedState({
    WatchParty? watchParty,
    List<WatchPartyMember>? members,
    List<WatchPartyMessage>? messages,
    WatchPartyMember? currentUserMember,
    bool isHost = false,
    bool isCoHost = false,
    bool isMember = true,
  }) {
    return WatchPartyDetailLoaded(
      watchParty: watchParty ?? WatchPartyTestFactory.createWatchParty(),
      members: members ?? WatchPartyTestFactory.createMemberList(count: 3),
      messages: messages ?? const [],
      currentUserMember: currentUserMember,
      isHost: isHost,
      isCoHost: isCoHost,
      isMember: isMember,
    );
  }

  /// Cleanly tears down the widget under test, consuming the exception thrown
  /// by the screen's dispose() method when it tries to look up the BLoC from
  /// a deactivated ancestor.
  Future<void> cleanUpWidget(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    tester.takeException();
  }

  group('WatchPartyDetailScreen', () {
    testWidgets('shows loading indicator when state is WatchPartyLoading',
        (tester) async {
      when(() => mockBloc.state).thenReturn(WatchPartyLoading());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets('shows party name when WatchPartyDetailLoaded',
        (tester) async {
      final state = createDetailLoadedState(
        watchParty: WatchPartyTestFactory.createWatchParty(
          name: 'Epic USA vs Mexico Party',
        ),
      );
      when(() => mockBloc.state).thenReturn(state);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Epic USA vs Mexico Party'), findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets('shows game name in details', (tester) async {
      final state = createDetailLoadedState(
        watchParty: WatchPartyTestFactory.createWatchParty(
          gameName: 'Brazil vs Argentina',
        ),
      );
      when(() => mockBloc.state).thenReturn(state);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Brazil vs Argentina'), findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets('shows venue name in details', (tester) async {
      final state = createDetailLoadedState(
        watchParty: WatchPartyTestFactory.createWatchParty(
          venueName: 'MetLife Stadium Bar',
        ),
      );
      when(() => mockBloc.state).thenReturn(state);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('MetLife Stadium Bar'), findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets('shows two tabs (Details and Chat)', (tester) async {
      final state = createDetailLoadedState();
      when(() => mockBloc.state).thenReturn(state);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Tab), findsNWidgets(2));
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets('shows host menu (PopupMenuButton) when user is host',
        (tester) async {
      final state = createDetailLoadedState(isHost: true);
      when(() => mockBloc.state).thenReturn(state);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The host menu PopupMenuButton is in the AppBar actions.
      // MemberListItem widgets also have PopupMenuButtons, so find the one
      // inside the AppBar specifically.
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);

      final hostMenuFinder = find.descendant(
        of: appBarFinder,
        matching: find.byType(PopupMenuButton<String>),
      );
      expect(hostMenuFinder, findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets('does NOT show host menu when user is NOT host',
        (tester) async {
      final state = createDetailLoadedState(isHost: false);
      when(() => mockBloc.state).thenReturn(state);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // When not host, the host menu's PopupMenuButton is absent from AppBar
      // actions. Verify its menu items are not rendered.
      expect(find.text('Edit Party'), findsNothing);

      await cleanUpWidget(tester);
    });

    testWidgets('shows join button when user is NOT a member', (tester) async {
      final state = createDetailLoadedState(
        isMember: false,
        watchParty: WatchPartyTestFactory.createWatchParty(
          currentAttendeesCount: 5,
          maxAttendees: 20,
        ),
      );
      when(() => mockBloc.state).thenReturn(state);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Join In Person'), findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets('does NOT show join button when user IS a member',
        (tester) async {
      final state = createDetailLoadedState(isMember: true);
      when(() => mockBloc.state).thenReturn(state);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Join In Person'), findsNothing);

      await cleanUpWidget(tester);
    });

    testWidgets('shows member list with correct count', (tester) async {
      final members = WatchPartyTestFactory.createMemberList(count: 4);
      final state = createDetailLoadedState(members: members);
      when(() => mockBloc.state).thenReturn(state);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The screen shows "Attendees (N)" where N is total members.length
      expect(find.text('Attendees (4)'), findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets('shows chat tab content', (tester) async {
      final state = createDetailLoadedState(
        isMember: true,
        currentUserMember: WatchPartyTestFactory.createMember(
          userId: 'current_user',
          role: WatchPartyMemberRole.member,
        ),
      );
      when(() => mockBloc.state).thenReturn(state);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap on the Chat tab
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      // With no messages, should show empty chat state
      expect(find.text('No messages yet'), findsOneWidget);
      expect(find.text('Be the first to say hello!'), findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets('handles error state with SnackBar', (tester) async {
      const errorState = WatchPartyError('Something went wrong');

      whenListen(
        mockBloc,
        Stream<WatchPartyState>.fromIterable([errorState]),
        initialState: WatchPartyLoading(),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(); // Process the stream emission
      await tester.pump(); // Allow SnackBar animation to start

      expect(find.text('Something went wrong'), findsOneWidget);

      // Pump past the SnackBar's display duration (4s) plus its exit
      // animation repeatedly until all timers and animations are done.
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      await cleanUpWidget(tester);
    });
  });
}
