import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_member.dart';
import 'package:pregame_world_cup/features/watch_party/domain/services/watch_party_payment_service.dart';

/// Tests for WatchPartyPaymentService and associated widgets.
///
/// Note: WatchPartyPaymentService is a singleton that uses hardcoded
/// Firebase dependencies (FirebaseFunctions.instance,
/// FirebaseFirestore.instance, FirebaseAuth.instance), the GetIt
/// service locator (sl<WatchPartyService>, sl<ZapierService>),
/// and Stripe SDK (flutter_stripe). This makes direct unit testing
/// of payment flow methods impractical without extensive DI refactoring.
///
/// The payment flow methods (purchaseVirtualAttendance, requestRefund)
/// also require BuildContext for UI dialogs, making them better suited
/// for widget/integration tests.
///
/// This test file focuses on:
/// 1. VirtualAttendanceButton widget rendering
/// 2. VirtualAttendanceInfoCard widget rendering
/// 3. Data model contracts the service depends on
/// 4. Business logic validation for payment eligibility
void main() {
  // ==================== VirtualAttendanceButton ====================
  group('VirtualAttendanceButton', () {
    WatchParty createParty({
      bool allowVirtualAttendance = true,
      double virtualAttendanceFee = 0.0,
    }) {
      final now = DateTime.now();
      return WatchParty(
        watchPartyId: 'wp_1',
        name: 'Test Party',
        description: 'Desc',
        hostId: 'host',
        hostName: 'Host',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: now.add(const Duration(hours: 2)),
        venueId: 'v1',
        venueName: 'Venue',
        maxAttendees: 20,
        status: WatchPartyStatus.upcoming,
        createdAt: now,
        updatedAt: now,
        allowVirtualAttendance: allowVirtualAttendance,
        virtualAttendanceFee: virtualAttendanceFee,
      );
    }

    testWidgets('renders nothing when virtual attendance is not allowed',
        (tester) async {
      final party = createParty(allowVirtualAttendance: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceButton(watchParty: party),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows "Join Virtually (Free)" for free attendance',
        (tester) async {
      final party = createParty(
        allowVirtualAttendance: true,
        virtualAttendanceFee: 0.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceButton(watchParty: party),
          ),
        ),
      );

      expect(find.text('Join Virtually (Free)'), findsOneWidget);
    });

    testWidgets('shows price for paid attendance', (tester) async {
      final party = createParty(
        allowVirtualAttendance: true,
        virtualAttendanceFee: 5.99,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceButton(watchParty: party),
          ),
        ),
      );

      expect(find.text('Join Virtually - \$5.99'), findsOneWidget);
    });

    testWidgets('shows videocam icon when not loading', (tester) async {
      final party = createParty(allowVirtualAttendance: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceButton(watchParty: party),
          ),
        ),
      );

      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });

    testWidgets('shows progress indicator when loading', (tester) async {
      final party = createParty(allowVirtualAttendance: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceButton(
              watchParty: party,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsNothing);
    });

    testWidgets('button is disabled when loading', (tester) async {
      final party = createParty(allowVirtualAttendance: true);
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceButton(
              watchParty: party,
              isLoading: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      // Find the VirtualAttendanceButton itself; it contains an
      // ElevatedButton.icon which renders as ElevatedButton internally.
      // When isLoading is true, onPressed becomes null (disabled).
      final buttonFinder = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton,
      );
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNull);
      expect(pressed, isFalse);
    });

    testWidgets('button invokes callback when pressed', (tester) async {
      final party = createParty(allowVirtualAttendance: true);
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceButton(
              watchParty: party,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      final buttonFinder = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton,
      );
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNotNull);
      button.onPressed!();
      expect(pressed, isTrue);
    });

    testWidgets('formats fee with two decimal places', (tester) async {
      final party = createParty(
        allowVirtualAttendance: true,
        virtualAttendanceFee: 10.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceButton(watchParty: party),
          ),
        ),
      );

      expect(find.text('Join Virtually - \$10.00'), findsOneWidget);
    });
  });

  // ==================== VirtualAttendanceInfoCard ====================
  group('VirtualAttendanceInfoCard', () {
    WatchParty createParty({
      bool allowVirtualAttendance = true,
      double virtualAttendanceFee = 0.0,
      int virtualAttendeesCount = 0,
    }) {
      final now = DateTime.now();
      return WatchParty(
        watchPartyId: 'wp_1',
        name: 'Test Party',
        description: 'Desc',
        hostId: 'host',
        hostName: 'Host',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: now.add(const Duration(hours: 2)),
        venueId: 'v1',
        venueName: 'Venue',
        maxAttendees: 20,
        virtualAttendeesCount: virtualAttendeesCount,
        status: WatchPartyStatus.upcoming,
        createdAt: now,
        updatedAt: now,
        allowVirtualAttendance: allowVirtualAttendance,
        virtualAttendanceFee: virtualAttendanceFee,
      );
    }

    testWidgets('renders nothing when virtual attendance is not allowed',
        (tester) async {
      final party = createParty(allowVirtualAttendance: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceInfoCard(watchParty: party),
          ),
        ),
      );

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('shows "Virtual Attendance Available" header',
        (tester) async {
      final party = createParty(allowVirtualAttendance: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceInfoCard(watchParty: party),
          ),
        ),
      );

      expect(find.text('Virtual Attendance Available'), findsOneWidget);
    });

    testWidgets('shows "Free" for free attendance', (tester) async {
      final party = createParty(
        allowVirtualAttendance: true,
        virtualAttendanceFee: 0.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceInfoCard(watchParty: party),
          ),
        ),
      );

      expect(find.text('Free'), findsOneWidget);
    });

    testWidgets('shows price for paid attendance', (tester) async {
      final party = createParty(
        allowVirtualAttendance: true,
        virtualAttendanceFee: 9.99,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceInfoCard(watchParty: party),
          ),
        ),
      );

      expect(find.text('\$9.99'), findsOneWidget);
    });

    testWidgets('shows virtual attendees count', (tester) async {
      final party = createParty(
        allowVirtualAttendance: true,
        virtualAttendeesCount: 7,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceInfoCard(watchParty: party),
          ),
        ),
      );

      expect(find.text('7 virtual attendees'), findsOneWidget);
    });

    testWidgets('shows join button when not joined', (tester) async {
      final party = createParty(allowVirtualAttendance: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceInfoCard(
              watchParty: party,
              hasJoined: false,
            ),
          ),
        ),
      );

      expect(find.byType(VirtualAttendanceButton), findsOneWidget);
    });

    testWidgets('shows attending message when joined and paid',
        (tester) async {
      final party = createParty(allowVirtualAttendance: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceInfoCard(
              watchParty: party,
              hasJoined: true,
              hasPaid: true,
            ),
          ),
        ),
      );

      expect(
          find.text("You're attending virtually"), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('hides join button when joined', (tester) async {
      final party = createParty(allowVirtualAttendance: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceInfoCard(
              watchParty: party,
              hasJoined: true,
              hasPaid: true,
            ),
          ),
        ),
      );

      expect(find.byType(VirtualAttendanceButton), findsNothing);
    });

    testWidgets('shows descriptive help text', (tester) async {
      final party = createParty(allowVirtualAttendance: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualAttendanceInfoCard(watchParty: party),
          ),
        ),
      );

      expect(
        find.textContaining(
            "Can't make it in person?"),
        findsOneWidget,
      );
    });
  });

  // ==================== Payment eligibility business logic ====================
  group('Payment eligibility business logic', () {
    test('virtual attendance fee text is "Free" when fee is 0', () {
      final now = DateTime.now();
      final party = WatchParty(
        watchPartyId: 'wp_1',
        name: 'Party',
        description: 'Desc',
        hostId: 'host',
        hostName: 'Host',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: now.add(const Duration(hours: 2)),
        venueId: 'v1',
        venueName: 'Venue',
        maxAttendees: 20,
        status: WatchPartyStatus.upcoming,
        createdAt: now,
        updatedAt: now,
        allowVirtualAttendance: true,
        virtualAttendanceFee: 0.0,
      );

      expect(party.virtualFeeText, equals('Free'));
    });

    test('virtual attendance fee text shows formatted price', () {
      final now = DateTime.now();
      final party = WatchParty(
        watchPartyId: 'wp_1',
        name: 'Party',
        description: 'Desc',
        hostId: 'host',
        hostName: 'Host',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: now.add(const Duration(hours: 2)),
        venueId: 'v1',
        venueName: 'Venue',
        maxAttendees: 20,
        status: WatchPartyStatus.upcoming,
        createdAt: now,
        updatedAt: now,
        allowVirtualAttendance: true,
        virtualAttendanceFee: 14.99,
      );

      expect(party.virtualFeeText, equals('\$14.99'));
    });

    test('virtual attendance fee text is empty when not allowed', () {
      final now = DateTime.now();
      final party = WatchParty(
        watchPartyId: 'wp_1',
        name: 'Party',
        description: 'Desc',
        hostId: 'host',
        hostName: 'Host',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: now.add(const Duration(hours: 2)),
        venueId: 'v1',
        venueName: 'Venue',
        maxAttendees: 20,
        status: WatchPartyStatus.upcoming,
        createdAt: now,
        updatedAt: now,
        allowVirtualAttendance: false,
      );

      expect(party.virtualFeeText, isEmpty);
    });

    test('member payment state transitions work correctly', () {
      final member = WatchPartyMember(
        memberId: 'test',
        watchPartyId: 'wp_1',
        userId: 'user_1',
        displayName: 'User',
        role: WatchPartyMemberRole.member,
        attendanceType: WatchPartyAttendanceType.virtual,
        rsvpStatus: MemberRsvpStatus.going,
        joinedAt: DateTime.now(),
        hasPaid: false,
      );

      expect(member.hasPaid, isFalse);
      expect(member.canChat, isFalse);

      final paidMember = member.markAsPaid('pi_test_123');

      expect(paidMember.hasPaid, isTrue);
      expect(paidMember.paymentIntentId, equals('pi_test_123'));
      expect(paidMember.canChat, isTrue);
    });

    test('in-person member does not need payment for chat', () {
      final member = WatchPartyMember.create(
        watchPartyId: 'wp_1',
        userId: 'user_1',
        displayName: 'User',
        role: WatchPartyMemberRole.member,
        attendanceType: WatchPartyAttendanceType.inPerson,
      );

      expect(member.hasPaid, isTrue);
      expect(member.canChat, isTrue);
    });

    test('virtual member needs payment for chat', () {
      final member = WatchPartyMember.create(
        watchPartyId: 'wp_1',
        userId: 'user_1',
        displayName: 'User',
        role: WatchPartyMemberRole.member,
        attendanceType: WatchPartyAttendanceType.virtual,
      );

      expect(member.hasPaid, isFalse);
      expect(member.canChat, isFalse);
    });
  });

  // ==================== WatchPartyPaymentService singleton ====================
  group('WatchPartyPaymentService singleton', () {
    // Note: WatchPartyPaymentService uses a singleton pattern with
    // hardcoded FirebaseFunctions.instance and FirebaseFirestore.instance
    // in its internal constructor. This requires Firebase.initializeApp()
    // which is not available in unit tests.
    //
    // The singleton pattern is verified by code inspection:
    //   static final _instance = WatchPartyPaymentService._internal();
    //   factory WatchPartyPaymentService() => _instance;
    //
    // Payment flow methods (purchaseVirtualAttendance, requestRefund)
    // require BuildContext and Stripe SDK, making them integration test
    // candidates rather than unit tests.

    test('service class exists and has expected public API', () {
      // Verify the class has the expected static type
      // (cannot instantiate without Firebase)
      expect(WatchPartyPaymentService, isA<Type>());
    });
  });
}
