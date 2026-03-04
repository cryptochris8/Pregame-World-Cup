import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:pregame_world_cup/features/match_chat/presentation/screens/match_chat_screen.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

void main() {
  final matchDateTime = DateTime(2026, 6, 15, 20, 0);

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  // Suppress overflow and rendering errors in constrained test environments.
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.toString();
      if (message.contains('overflowed') ||
          message.contains('RenderFlex') ||
          message.contains('HTTP request failed') ||
          message.contains('FirebaseException') ||
          message.contains('No Firebase App') ||
          message.contains('PlatformException')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  // ---------------------------------------------------------------------------
  // Helper: wrap MatchChatScreen in MaterialApp with localization
  // ---------------------------------------------------------------------------
  Widget buildTestWidget({
    String matchId = 'match_001',
    String matchName = 'USA vs England',
    String homeTeam = 'USA',
    String awayTeam = 'England',
    DateTime? dateTime,
    String? chatId,
  }) {
    return MediaQuery(
      data: const MediaQueryData(size: Size(414, 896)),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MatchChatScreen(
          matchId: matchId,
          matchName: matchName,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          matchDateTime: dateTime ?? matchDateTime,
          chatId: chatId,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Test cases
  // ---------------------------------------------------------------------------

  group('MatchChatScreen', () {
    testWidgets('renders Scaffold without crashing', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(MatchChatScreen), findsOneWidget);
    });

    testWidgets('shows AppBar with Live Chat title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Live Chat'), findsOneWidget);
    });

    testWidgets('shows match teams in AppBar subtitle', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        homeTeam: 'Brazil',
        awayTeam: 'Germany',
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Brazil vs Germany'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      // Pump just once to show loading state before async completes
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders with different team names', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        homeTeam: 'Mexico',
        awayTeam: 'Argentina',
        matchName: 'MEX vs ARG',
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Mexico vs Argentina'), findsOneWidget);
    });

    testWidgets('renders with chatId parameter', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        chatId: 'existing_chat_123',
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Should render without crashing when chatId is provided
      expect(find.byType(MatchChatScreen), findsOneWidget);
    });

    testWidgets('renders with null chatId parameter', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        chatId: null,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Should render without crashing when chatId is null
      expect(find.byType(MatchChatScreen), findsOneWidget);
    });

    testWidgets('AppBar has Column layout for title and subtitle',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // The AppBar title is a Column with Live Chat title and teams subtitle
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isA<Column>());
    });
  });
}
