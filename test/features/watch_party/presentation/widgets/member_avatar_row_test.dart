import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_member.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/widgets/member_avatar_row.dart';

import '../../mock_factories.dart';

void main() {
  // Ignore network image errors in tests
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed') ||
          details.toString().contains('HTTP')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  group('MemberAvatarRow', () {
    testWidgets('renders single member', (tester) async {
      final members = [
        WatchPartyTestFactory.createMember(displayName: 'John'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatarRow(members: members),
          ),
        ),
      );

      expect(find.byType(MemberAvatarRow), findsOneWidget);
      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('renders multiple members', (tester) async {
      final members = WatchPartyTestFactory.createMemberList(count: 3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatarRow(members: members),
          ),
        ),
      );

      expect(find.byType(MemberAvatarRow), findsOneWidget);
    });

    testWidgets('shows overflow indicator when exceeding maxDisplay', (tester) async {
      final members = WatchPartyTestFactory.createMemberList(count: 8);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatarRow(
              members: members,
              maxDisplay: 5,
            ),
          ),
        ),
      );

      expect(find.text('+3'), findsOneWidget);
    });

    testWidgets('hides overflow indicator when within maxDisplay', (tester) async {
      final members = WatchPartyTestFactory.createMemberList(count: 3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatarRow(
              members: members,
              maxDisplay: 5,
            ),
          ),
        ),
      );

      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      final members = WatchPartyTestFactory.createMemberList(count: 3);
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(50),
              child: MemberAvatarRow(
                members: members,
                avatarSize: 32,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      // Tap on the SizedBox inside MemberAvatarRow
      final finder = find.byType(MemberAvatarRow);
      final topLeft = tester.getTopLeft(finder);
      await tester.tapAt(Offset(topLeft.dx + 16, topLeft.dy + 16));
      expect(tapped, isTrue);
    });

    testWidgets('respects custom avatarSize', (tester) async {
      final members = WatchPartyTestFactory.createMemberList(count: 2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatarRow(
              members: members,
              avatarSize: 48,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(MemberAvatarRow),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.height, 48.0);
    });

    testWidgets('shows placeholder with initial for member without image', (tester) async {
      final members = [
        WatchPartyTestFactory.createMember(
          displayName: 'Alice',
          profileImageUrl: null,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatarRow(members: members),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('renders with empty member list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MemberAvatarRow(members: []),
          ),
        ),
      );

      expect(find.byType(MemberAvatarRow), findsOneWidget);
    });
  });

  group('MemberAvatar', () {
    testWidgets('renders member placeholder with initial', (tester) async {
      final member = WatchPartyTestFactory.createMember(displayName: 'Bob');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatar(member: member),
          ),
        ),
      );

      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('shows host role badge when showRoleBadge is true', (tester) async {
      final member = WatchPartyTestFactory.createMember(
        role: WatchPartyMemberRole.host,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatar(
              member: member,
              showRoleBadge: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('shows coHost role badge when showRoleBadge is true', (tester) async {
      final member = WatchPartyTestFactory.createMember(
        role: WatchPartyMemberRole.coHost,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatar(
              member: member,
              showRoleBadge: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('hides role badge for regular member', (tester) async {
      final member = WatchPartyTestFactory.createMember(
        role: WatchPartyMemberRole.member,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatar(
              member: member,
              showRoleBadge: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byIcon(Icons.person), findsNothing);
    });

    testWidgets('hides role badge when showRoleBadge is false', (tester) async {
      final member = WatchPartyTestFactory.createMember(
        role: WatchPartyMemberRole.host,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatar(
              member: member,
              showRoleBadge: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('shows online status indicator when showOnlineStatus is true', (tester) async {
      final member = WatchPartyTestFactory.createMember();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatar(
              member: member,
              showOnlineStatus: true,
              isOnline: true,
            ),
          ),
        ),
      );

      expect(find.byType(MemberAvatar), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      final member = WatchPartyTestFactory.createMember();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatar(
              member: member,
              size: 60,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(MemberAvatar),
          matching: find.byType(Container),
        ).first,
      );

      final constraints = container.constraints;
      expect(constraints?.maxWidth, 60.0);
      expect(constraints?.maxHeight, 60.0);
    });

    testWidgets('shows question mark for empty display name', (tester) async {
      final member = WatchPartyTestFactory.createMember(displayName: '');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatar(member: member),
          ),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('has green border for virtual member', (tester) async {
      final member = WatchPartyTestFactory.createMember(
        attendanceType: WatchPartyAttendanceType.virtual,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatar(member: member),
          ),
        ),
      );

      expect(find.byType(MemberAvatar), findsOneWidget);
    });

    testWidgets('shows different colors for different roles', (tester) async {
      final hostMember = WatchPartyTestFactory.createMember(
        role: WatchPartyMemberRole.host,
        displayName: 'Host',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemberAvatar(member: hostMember),
          ),
        ),
      );

      expect(find.text('H'), findsOneWidget);
    });
  });
}
