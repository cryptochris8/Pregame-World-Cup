import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/widgets/watch_party_card.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/widgets/visibility_badge.dart';

import '../../mock_factories.dart';

void main() {
  // Ignore overflow errors in widget tests
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed')) {
        return; // Ignore overflow errors
      }
      FlutterError.presentError(details);
    };
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: child,
          ),
        ),
      ),
    );
  }

  group('WatchPartyCard', () {
    testWidgets('renders party name', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty(
        name: 'USA vs Mexico Watch Party',
      );

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(watchParty: watchParty)),
      );

      expect(find.text('USA vs Mexico Watch Party'), findsOneWidget);
    });

    testWidgets('renders game name', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty(
        gameName: 'Brazil vs Argentina',
      );

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(watchParty: watchParty)),
      );

      expect(find.text('Brazil vs Argentina'), findsOneWidget);
    });

    testWidgets('renders venue name when showVenue is true', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty(
        venueName: 'Sports Bar Downtown',
      );

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(
          watchParty: watchParty,
          showVenue: true,
        )),
      );

      expect(find.text('Sports Bar Downtown'), findsOneWidget);
    });

    testWidgets('hides venue name when showVenue is false', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty(
        venueName: 'Sports Bar Downtown',
      );

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(
          watchParty: watchParty,
          showVenue: false,
        )),
      );

      expect(find.text('Sports Bar Downtown'), findsNothing);
    });

    testWidgets('renders visibility badge', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty(
        visibility: WatchPartyVisibility.public,
      );

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(watchParty: watchParty)),
      );

      expect(find.byType(VisibilityBadge), findsOneWidget);
      expect(find.text('Public'), findsOneWidget);
    });

    testWidgets('renders private badge for private party', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty(
        visibility: WatchPartyVisibility.private,
      );

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(watchParty: watchParty)),
      );

      expect(find.text('Private'), findsOneWidget);
    });

    testWidgets('renders attendees count', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty(
        currentAttendeesCount: 8,
        maxAttendees: 20,
      );

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(watchParty: watchParty)),
      );

      expect(find.text('8/20 attending'), findsOneWidget);
    });

    testWidgets('renders full status when party is full', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty(
        currentAttendeesCount: 20,
        maxAttendees: 20,
      );

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(watchParty: watchParty)),
      );

      expect(find.text('Full (20/20)'), findsOneWidget);
    });

    testWidgets('renders upcoming status badge', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty(
        status: WatchPartyStatus.upcoming,
      );

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(watchParty: watchParty)),
      );

      expect(find.text('Upcoming'), findsOneWidget);
    });

    testWidgets('renders LIVE status badge', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty(
        status: WatchPartyStatus.live,
      );

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(watchParty: watchParty)),
      );

      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('renders Ended status badge', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty(
        status: WatchPartyStatus.ended,
      );

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(watchParty: watchParty)),
      );

      expect(find.text('Ended'), findsOneWidget);
    });

    testWidgets('renders Cancelled status badge', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty(
        status: WatchPartyStatus.cancelled,
      );

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(watchParty: watchParty)),
      );

      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty();
      bool tapped = false;

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(
          watchParty: watchParty,
          onTap: () => tapped = true,
        )),
      );

      await tester.tap(find.byType(WatchPartyCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders virtual attendance info when enabled', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty(
        allowVirtualAttendance: true,
        virtualAttendanceFee: 5.99,
        virtualAttendeesCount: 3,
      );

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(watchParty: watchParty)),
      );

      expect(find.textContaining('\$5.99'), findsOneWidget);
      expect(find.textContaining('3 virtual'), findsOneWidget);
    });

    testWidgets('shows free virtual attendance text', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty(
        allowVirtualAttendance: true,
        virtualAttendanceFee: 0.0,
      );

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(watchParty: watchParty)),
      );

      expect(find.textContaining('Free'), findsOneWidget);
    });

    testWidgets('renders card structure correctly', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty();

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(watchParty: watchParty)),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('renders compact card correctly', (tester) async {
      final watchParty = WatchPartyTestFactory.createWatchParty();

      await tester.pumpWidget(
        buildTestWidget(WatchPartyCard(
          watchParty: watchParty,
          compact: true,
        )),
      );

      expect(find.byType(WatchPartyCard), findsOneWidget);
    });
  });
}
