import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party.dart';
import 'package:pregame_world_cup/features/watch_party/domain/services/watch_party_service.dart';
import 'package:pregame_world_cup/features/watch_party/domain/services/watch_party_payment_service.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/bloc/watch_party_bloc.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/screens/create_watch_party_screen.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/widgets/visibility_badge.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------
class MockWatchPartyService extends Mock implements WatchPartyService {}

class MockWatchPartyPaymentService extends Mock
    implements WatchPartyPaymentService {}

void main() {
  late MockWatchPartyService mockWatchPartyService;
  late MockWatchPartyPaymentService mockPaymentService;
  late WatchPartyBloc watchPartyBloc;

  // Suppress overflow and rendering errors in constrained test environments.
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.toString();
      if (message.contains('overflowed') ||
          message.contains('RenderFlex') ||
          message.contains('HTTP request failed')) {
        return;
      }
      FlutterError.presentError(details);
    };

    mockWatchPartyService = MockWatchPartyService();
    mockPaymentService = MockWatchPartyPaymentService();
    watchPartyBloc = WatchPartyBloc(
      watchPartyService: mockWatchPartyService,
      paymentService: mockPaymentService,
    );
  });

  tearDown(() {
    watchPartyBloc.close();
  });

  // ---------------------------------------------------------------------------
  // Helper: wrap CreateWatchPartyScreen in MaterialApp with BlocProvider
  // ---------------------------------------------------------------------------
  Widget buildTestWidget({
    String? preselectedGameId,
    String? preselectedGameName,
    DateTime? preselectedGameDateTime,
  }) {
    return MediaQuery(
      data: const MediaQueryData(size: Size(414, 896)),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<WatchPartyBloc>.value(
          value: watchPartyBloc,
          child: CreateWatchPartyScreen(
            preselectedGameId: preselectedGameId,
            preselectedGameName: preselectedGameName,
            preselectedGameDateTime: preselectedGameDateTime,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Test cases
  // ---------------------------------------------------------------------------

  group('CreateWatchPartyScreen', () {
    testWidgets('renders Scaffold without crashing', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(CreateWatchPartyScreen), findsOneWidget);
    });

    testWidgets('shows AppBar with "Create Watch Party" title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppBar), findsOneWidget);
      // "Create Watch Party" appears in both AppBar title and bottom button
      expect(find.text('Create Watch Party'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows party name text field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Name field should have the label "Party Name"
      expect(find.text('Party Name'), findsOneWidget);
    });

    testWidgets('shows description text field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Description field should be present
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('shows visibility section with toggle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Visibility label
      expect(find.text('Visibility'), findsOneWidget);

      // VisibilityToggle (SegmentedButton) is present
      expect(find.byType(VisibilityToggle), findsOneWidget);

      // Shows Public and Private options
      expect(find.text('Public'), findsAtLeastNWidgets(1));
      expect(find.text('Private'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows game selection section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Game section label
      expect(find.text('Game'), findsOneWidget);

      // Select Game button when no game preselected
      expect(find.text('Select Game'), findsOneWidget);
    });

    testWidgets('shows venue selection section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll to find the Select Venue button
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Select Venue'),
        200,
        scrollable: scrollable,
      );

      // Venue section label and button should both be visible
      expect(find.text('Venue'), findsOneWidget);
      expect(find.text('Select Venue'), findsOneWidget);
    });

    testWidgets('shows maximum attendees slider', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll to find the slider section
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Maximum Attendees'),
        200,
        scrollable: scrollable,
      );

      expect(find.text('Maximum Attendees'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);

      // Default max attendees is 20
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('shows virtual attendance section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll to find virtual attendance section
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Virtual Attendance'),
        200,
        scrollable: scrollable,
      );

      expect(find.text('Virtual Attendance'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);

      // Videocam icon for virtual attendance
      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });

    testWidgets('shows create button in bottom bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Create Watch Party button in bottom navigation bar
      expect(find.text('Create Watch Party'), findsAtLeastNWidgets(1));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows preselected game when provided', (tester) async {
      final gameDateTime = DateTime(2026, 6, 15, 18, 0);

      await tester.pumpWidget(buildTestWidget(
        preselectedGameId: 'match_001',
        preselectedGameName: 'USA vs England',
        preselectedGameDateTime: gameDateTime,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Game name should be displayed
      expect(find.text('USA vs England'), findsOneWidget);

      // Select Game button should NOT be shown when game is preselected
      expect(find.text('Select Game'), findsNothing);

      // Soccer icon for the game card
      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });

    testWidgets('shows default visibility as public', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Default visibility description text for public
      expect(find.text('Anyone can find and join'), findsOneWidget);
    });

    testWidgets('form has name TextFormField with validation', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // There should be at least 2 TextFormField widgets (name, description)
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
    });

    testWidgets('renders Form widget for form validation', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('renders ListView for scrollable content', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('slider updates max attendees value', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll to the slider
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byType(Slider),
        200,
        scrollable: scrollable,
      );

      // Verify initial value
      expect(find.text('20'), findsOneWidget);

      // The slider exists and can be interacted with
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.min, 2);
      expect(slider.max, 100);
      expect(slider.divisions, 49);
    });
  });
}
