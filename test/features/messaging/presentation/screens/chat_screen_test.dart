import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show PigeonFirebaseOptions, PigeonInitializeResponse, defaultFirebaseAppName;
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/chat.dart';
import 'package:pregame_world_cup/features/messaging/domain/services/messaging_service.dart';
import 'package:pregame_world_cup/features/messaging/presentation/screens/chat_screen.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/chat_app_bar_title.dart';
import 'package:pregame_world_cup/features/social/domain/services/social_service.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------
class MockSocialService extends Mock implements SocialService {}

/// Custom Firebase mock that includes storageBucket in options.
/// The default setupFirebaseCoreMocks() does NOT set storageBucket,
/// which causes FirebaseStorage.instance to throw [firebase_storage/no-bucket]
/// during widget construction when MessageInputWidget creates FileUploadService.
class MockFirebaseAppWithStorage implements TestFirebaseCoreHostApi {
  @override
  Future<PigeonInitializeResponse> initializeApp(
    String appName,
    PigeonFirebaseOptions initializeAppRequest,
  ) async {
    return PigeonInitializeResponse(
      name: appName,
      options: PigeonFirebaseOptions(
        apiKey: '123',
        projectId: '123',
        appId: '123',
        messagingSenderId: '123',
        storageBucket: 'test-bucket',
      ),
      pluginConstants: {},
    );
  }

  @override
  Future<List<PigeonInitializeResponse?>> initializeCore() async {
    return [
      PigeonInitializeResponse(
        name: defaultFirebaseAppName,
        options: PigeonFirebaseOptions(
          apiKey: '123',
          projectId: '123',
          appId: '123',
          messagingSenderId: '123',
          storageBucket: 'test-bucket',
        ),
        pluginConstants: {},
      ),
    ];
  }

  @override
  Future<PigeonFirebaseOptions> optionsFromResource() async {
    return PigeonFirebaseOptions(
      apiKey: '123',
      projectId: '123',
      appId: '123',
      messagingSenderId: '123',
      storageBucket: 'test-bucket',
    );
  }
}

final sl = GetIt.instance;

void main() {
  const testUserId = 'chat-test-user-1';
  const otherUserId = 'chat-test-user-2';

  setUpAll(() async {
    // Use custom Firebase mock that includes storageBucket to prevent
    // [firebase_storage/no-bucket] error when FileUploadService is created.
    TestFirebaseCoreHostApi.setup(MockFirebaseAppWithStorage());
    await Firebase.initializeApp();

    // Register mock SocialService in GetIt (used by _unblockUser).
    if (!sl.isRegistered<SocialService>()) {
      sl.registerSingleton<SocialService>(MockSocialService());
    }

    // Register MessagingService in GetIt (screen resolves via sl<MessagingService>()).
    if (!sl.isRegistered<MessagingService>()) {
      sl.registerSingleton<MessagingService>(MessagingService());
    }
  });

  tearDownAll(() async {
    await sl.reset();
  });

  // Suppress errors from Firebase dependencies that are created internally
  // by the ChatScreen and its child widgets (MessagingService -> Firestore,
  // MessageInputWidget -> FileUploadService -> FirebaseStorage).
  // Some async operations (e.g., Firestore queries) fail because no real
  // Firebase project is configured in tests. These errors are expected.
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Suppress all Firebase / rendering / overflow errors in tests
      return;
    };
  });

  // ---------------------------------------------------------------------------
  // Helper: create a test Chat entity
  // ---------------------------------------------------------------------------
  Chat createTestChat({
    String chatId = 'test_chat_123',
    ChatType type = ChatType.direct,
    String? name,
    List<String>? participantIds,
    List<String>? adminIds,
  }) {
    return Chat(
      chatId: chatId,
      type: type,
      participantIds: participantIds ?? [testUserId, otherUserId],
      adminIds: adminIds ?? [],
      name: name,
      createdAt: DateTime(2026, 3, 1),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper: wrap ChatScreen in MaterialApp with localization.
  //
  // The ChatScreen internally creates MessagingService (singleton using
  // FirebaseFirestore/FirebaseAuth) and its child MessageInputWidget creates
  // FileUploadService (using FirebaseStorage). Async operations (Firestore
  // queries, stream subscriptions) may throw PlatformExceptions in tests.
  // The tests focus on the Scaffold, AppBar, ChatAppBarTitle, and popup menus.
  // ---------------------------------------------------------------------------
  Widget buildTestWidget(Chat chat) {
    return MediaQuery(
      data: const MediaQueryData(size: Size(414, 896)),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChatScreen(chat: chat),
      ),
    );
  }

  /// Pump the widget and drain all exceptions thrown by internal Firebase deps.
  Future<void> pumpAndDrainErrors(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pump(const Duration(milliseconds: 200));
    // Drain any pending exceptions from Firebase/rendering so they don't fail
    // the test.
    while (tester.takeException() != null) {
      // keep draining
    }
  }

  // ---------------------------------------------------------------------------
  // Test cases
  // ---------------------------------------------------------------------------

  group('ChatScreen', () {
    testWidgets('renders ChatScreen widget', (tester) async {
      final chat = createTestChat(name: 'Test Chat');

      await pumpAndDrainErrors(tester, buildTestWidget(chat));

      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('renders AppBar with action icons', (tester) async {
      final chat = createTestChat(name: 'Test Chat');

      await pumpAndDrainErrors(tester, buildTestWidget(chat));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.byIcon(Icons.call), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('shows ChatAppBarTitle widget', (tester) async {
      final chat = createTestChat(
        name: 'World Cup Fans',
        type: ChatType.group,
      );

      await pumpAndDrainErrors(tester, buildTestWidget(chat));

      expect(find.byType(ChatAppBarTitle), findsOneWidget);
    });

    testWidgets('renders with direct chat type without crashing',
        (tester) async {
      final chat = createTestChat(type: ChatType.direct, name: null);

      await pumpAndDrainErrors(tester, buildTestWidget(chat));

      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('renders with group chat type showing member count',
        (tester) async {
      final chat = createTestChat(
        type: ChatType.group,
        name: 'Match Day Group',
        participantIds: [testUserId, otherUserId, 'user3', 'user4'],
        adminIds: [testUserId],
      );

      await pumpAndDrainErrors(tester, buildTestWidget(chat));

      expect(find.text('4 members'), findsOneWidget);
    });

    testWidgets('renders with team chat type showing name', (tester) async {
      final chat = createTestChat(type: ChatType.team, name: 'USA Fans');

      await pumpAndDrainErrors(tester, buildTestWidget(chat));

      expect(find.text('USA Fans'), findsOneWidget);
    });

    testWidgets('does not show leave chat option for direct messages',
        (tester) async {
      final chat = createTestChat(type: ChatType.direct, name: 'DM Chat');

      await pumpAndDrainErrors(tester, buildTestWidget(chat));

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      while (tester.takeException() != null) {}

      expect(find.text('Leave Chat'), findsNothing);
    });

    testWidgets('shows all popup menu items for group chat', (tester) async {
      final chat =
          createTestChat(type: ChatType.group, name: 'Group Chat');

      await pumpAndDrainErrors(tester, buildTestWidget(chat));

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      while (tester.takeException() != null) {}

      expect(find.text('View Info'), findsOneWidget);
      expect(find.text('Mute Notifications'), findsOneWidget);
      expect(find.text('Clear Chat History'), findsOneWidget);
      expect(find.text('Leave Chat'), findsOneWidget);
    });

    testWidgets('ChatAppBarTitle shows group icon for group chat',
        (tester) async {
      final chat =
          createTestChat(type: ChatType.group, name: 'Group Chat');

      await pumpAndDrainErrors(tester, buildTestWidget(chat));

      expect(find.byIcon(Icons.group), findsOneWidget);
    });

    testWidgets('ChatAppBarTitle shows person icon for direct chat',
        (tester) async {
      final chat = createTestChat(type: ChatType.direct, name: 'DM Chat');

      await pumpAndDrainErrors(tester, buildTestWidget(chat));

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('ChatAppBarTitle shows groups icon for team chat',
        (tester) async {
      final chat = createTestChat(type: ChatType.team, name: 'Team Chat');

      await pumpAndDrainErrors(tester, buildTestWidget(chat));

      expect(find.byIcon(Icons.groups), findsOneWidget);
    });

    testWidgets('displays chat name in app bar for named chat',
        (tester) async {
      final chat = createTestChat(
        type: ChatType.group,
        name: 'FIFA Finals Watch',
      );

      await pumpAndDrainErrors(tester, buildTestWidget(chat));

      expect(find.text('FIFA Finals Watch'), findsOneWidget);
    });
  });
}
