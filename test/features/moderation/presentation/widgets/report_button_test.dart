import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/moderation/domain/entities/report.dart';
import 'package:pregame_world_cup/features/moderation/presentation/widgets/report_button.dart';

/// Widget tests for ReportButton, ReportMenuItem, and ReportMenuExtension.
///
/// Note: ReportButton opens a ReportBottomSheet on tap which internally
/// instantiates ModerationService() (a Firebase-dependent singleton).
/// Tests that trigger bottom sheet opening are skipped in pure unit tests.
/// Rendering and structural tests work without Firebase.
void main() {
  group('ReportButton', () {
    group('Constructor', () {
      test('creates button with required fields', () {
        const button = ReportButton(
          contentType: ReportableContentType.message,
          contentId: 'msg_1',
        );

        expect(button.contentType, equals(ReportableContentType.message));
        expect(button.contentId, equals('msg_1'));
        expect(button.showLabel, isFalse);
        expect(button.iconSize, equals(20));
        expect(button.child, isNull);
        expect(button.contentOwnerId, isNull);
        expect(button.contentOwnerDisplayName, isNull);
        expect(button.contentSnapshot, isNull);
        expect(button.iconColor, isNull);
      });

      test('creates button with all optional fields', () {
        const button = ReportButton(
          contentType: ReportableContentType.user,
          contentId: 'u1',
          contentOwnerId: 'u1',
          contentOwnerDisplayName: 'User One',
          contentSnapshot: 'Some snapshot',
          showLabel: true,
          iconColor: Colors.red,
          iconSize: 24,
        );

        expect(button.contentOwnerId, equals('u1'));
        expect(button.contentOwnerDisplayName, equals('User One'));
        expect(button.contentSnapshot, equals('Some snapshot'));
        expect(button.showLabel, isTrue);
        expect(button.iconColor, equals(Colors.red));
        expect(button.iconSize, equals(24));
      });
    });

    group('Factory: ReportButton.user', () {
      test('creates button with user content type', () {
        final button = ReportButton.user(
          userId: 'user_123',
          displayName: 'Test User',
        );

        expect(button.contentType, equals(ReportableContentType.user));
        expect(button.contentId, equals('user_123'));
        expect(button.contentOwnerId, equals('user_123'));
        expect(button.contentOwnerDisplayName, equals('Test User'));
        expect(button.showLabel, isFalse);
      });

      test('accepts optional parameters', () {
        final button = ReportButton.user(
          userId: 'user_123',
          displayName: 'Test User',
          showLabel: true,
          iconColor: Colors.blue,
          iconSize: 28,
        );

        expect(button.showLabel, isTrue);
        expect(button.iconColor, equals(Colors.blue));
        expect(button.iconSize, equals(28));
      });
    });

    group('Factory: ReportButton.message', () {
      test('creates button with message content type', () {
        final button = ReportButton.message(
          messageId: 'msg_123',
          senderId: 'sender_1',
          senderDisplayName: 'Sender Name',
          messageContent: 'Bad message content',
        );

        expect(button.contentType, equals(ReportableContentType.message));
        expect(button.contentId, equals('msg_123'));
        expect(button.contentOwnerId, equals('sender_1'));
        expect(button.contentOwnerDisplayName, equals('Sender Name'));
        expect(button.contentSnapshot, equals('Bad message content'));
      });
    });

    group('Factory: ReportButton.watchParty', () {
      test('creates button with watchParty content type', () {
        final button = ReportButton.watchParty(
          watchPartyId: 'wp_123',
          hostId: 'host_1',
          hostDisplayName: 'Host Name',
          watchPartyName: 'Party Name',
        );

        expect(button.contentType, equals(ReportableContentType.watchParty));
        expect(button.contentId, equals('wp_123'));
        expect(button.contentOwnerId, equals('host_1'));
        expect(button.contentOwnerDisplayName, equals('Host Name'));
        expect(button.contentSnapshot, equals('Party Name'));
      });
    });

    group('Widget rendering', () {
      testWidgets('renders as IconButton by default', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ReportButton(
                contentType: ReportableContentType.user,
                contentId: 'u1',
              ),
            ),
          ),
        );

        expect(find.byType(IconButton), findsOneWidget);
        expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
      });

      testWidgets('renders custom child when provided', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ReportButton(
                contentType: ReportableContentType.user,
                contentId: 'u1',
                child: Text('Custom Report'),
              ),
            ),
          ),
        );

        expect(find.text('Custom Report'), findsOneWidget);
        expect(find.byType(GestureDetector), findsOneWidget);
        // Should not render IconButton
        expect(find.byType(IconButton), findsNothing);
      });

      testWidgets('uses custom icon color', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ReportButton(
                contentType: ReportableContentType.user,
                contentId: 'u1',
                iconColor: Colors.red,
              ),
            ),
          ),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.flag_outlined));
        expect(icon.color, equals(Colors.red));
      });

      testWidgets('uses custom icon size', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ReportButton(
                contentType: ReportableContentType.user,
                contentId: 'u1',
                iconSize: 32,
              ),
            ),
          ),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.flag_outlined));
        expect(icon.size, equals(32));
      });

      testWidgets('IconButton has Report tooltip', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ReportButton(
                contentType: ReportableContentType.user,
                contentId: 'u1',
              ),
            ),
          ),
        );

        final iconButton =
            tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.tooltip, equals('Report'));
      });

      testWidgets('uses default grey color when no iconColor specified',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ReportButton(
                contentType: ReportableContentType.user,
                contentId: 'u1',
              ),
            ),
          ),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.flag_outlined));
        expect(icon.color, equals(Colors.grey[600]));
      });

      testWidgets('renders flag icon regardless of content type',
          (tester) async {
        for (final type in ReportableContentType.values) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ReportButton(
                  contentType: type,
                  contentId: 'test_${type.name}',
                ),
              ),
            ),
          );

          expect(find.byIcon(Icons.flag_outlined), findsOneWidget,
              reason: 'No flag icon for content type: ${type.name}');
        }
      });

      testWidgets('renders showLabel with Report text and icon',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ReportButton(
                contentType: ReportableContentType.user,
                contentId: 'u1',
                showLabel: true,
              ),
            ),
          ),
        );

        // showLabel renders TextButton.icon which contains text and icon
        expect(find.text('Report'), findsOneWidget);
        expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
        // Should not render a plain IconButton when showLabel is true
        expect(find.byType(IconButton), findsNothing);
      });
    });
  });

  group('ReportMenuItem', () {
    test('creates with required fields', () {
      const item = ReportMenuItem(
        contentType: ReportableContentType.message,
        contentId: 'msg_1',
      );

      expect(item.contentType, equals(ReportableContentType.message));
      expect(item.contentId, equals('msg_1'));
      expect(item.height, equals(48));
    });

    test('creates with all optional fields', () {
      const item = ReportMenuItem(
        contentType: ReportableContentType.message,
        contentId: 'msg_1',
        contentOwnerId: 'sender_1',
        contentOwnerDisplayName: 'Sender',
        contentSnapshot: 'Message text',
      );

      expect(item.contentOwnerId, equals('sender_1'));
      expect(item.contentOwnerDisplayName, equals('Sender'));
      expect(item.contentSnapshot, equals('Message text'));
    });

    test('represents returns true for report value', () {
      const item = ReportMenuItem(
        contentType: ReportableContentType.user,
        contentId: 'u1',
      );

      expect(item.represents('report'), isTrue);
    });

    test('represents returns false for other values', () {
      const item = ReportMenuItem(
        contentType: ReportableContentType.user,
        contentId: 'u1',
      );

      expect(item.represents('other'), isFalse);
      expect(item.represents(null), isFalse);
      expect(item.represents('edit'), isFalse);
      expect(item.represents('delete'), isFalse);
    });

    test('height is 48', () {
      const item = ReportMenuItem(
        contentType: ReportableContentType.user,
        contentId: 'u1',
      );

      expect(item.height, equals(48));
    });
  });

  group('ReportMenuExtension', () {
    test('addReportOption adds divider and menu item', () {
      final List<PopupMenuEntry<String>> items = [];

      items.addReportOption(
        contentType: ReportableContentType.user,
        contentId: 'u1',
        contentOwnerId: 'u1',
        contentOwnerDisplayName: 'User',
      );

      expect(items, hasLength(2));
      expect(items[0], isA<PopupMenuDivider>());
      expect(items[1], isA<ReportMenuItem>());
    });

    test('addReportOption preserves existing items', () {
      final List<PopupMenuEntry<String>> items = [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Edit'),
        ),
      ];

      items.addReportOption(
        contentType: ReportableContentType.message,
        contentId: 'msg_1',
      );

      expect(items, hasLength(3));
      expect(items[0], isA<PopupMenuItem<String>>());
      expect(items[1], isA<PopupMenuDivider>());
      expect(items[2], isA<ReportMenuItem>());
    });

    test('added ReportMenuItem has correct content type', () {
      final List<PopupMenuEntry<String>> items = [];

      items.addReportOption(
        contentType: ReportableContentType.watchParty,
        contentId: 'wp_1',
        contentOwnerId: 'host_1',
        contentOwnerDisplayName: 'Host',
        contentSnapshot: 'Party Name',
      );

      final reportItem = items[1] as ReportMenuItem;
      expect(reportItem.contentType, equals(ReportableContentType.watchParty));
      expect(reportItem.contentId, equals('wp_1'));
      expect(reportItem.contentOwnerId, equals('host_1'));
      expect(reportItem.contentOwnerDisplayName, equals('Host'));
      expect(reportItem.contentSnapshot, equals('Party Name'));
    });

    test('can add multiple report options', () {
      final List<PopupMenuEntry<String>> items = [];

      items.addReportOption(
        contentType: ReportableContentType.user,
        contentId: 'u1',
      );

      items.addReportOption(
        contentType: ReportableContentType.message,
        contentId: 'msg_1',
      );

      expect(items, hasLength(4));
      expect(items[0], isA<PopupMenuDivider>());
      expect(items[1], isA<ReportMenuItem>());
      expect(items[2], isA<PopupMenuDivider>());
      expect(items[3], isA<ReportMenuItem>());
    });
  });
}
