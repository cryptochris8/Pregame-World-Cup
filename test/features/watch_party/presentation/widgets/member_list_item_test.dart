import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_member.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/widgets/member_list_item.dart';

import '../../mock_factories.dart';

void main() {
  group('MemberListItem construction and type tests', () {
    test('can be constructed with required member parameter', () {
      final member = WatchPartyTestFactory.createMember();
      final widget = MemberListItem(member: member);

      expect(widget, isNotNull);
      expect(widget, isA<MemberListItem>());
      expect(widget.member, equals(member));
    });

    test('can be constructed with all parameters', () {
      final member = WatchPartyTestFactory.createMember();
      bool tapped = false;
      bool muted = false;
      bool removed = false;
      bool promoted = false;
      bool demoted = false;

      final widget = MemberListItem(
        member: member,
        isCurrentUser: true,
        canManage: true,
        onTap: () => tapped = true,
        onMute: () => muted = true,
        onRemove: () => removed = true,
        onPromote: () => promoted = true,
        onDemote: () => demoted = true,
      );

      expect(widget, isNotNull);
      expect(widget.isCurrentUser, isTrue);
      expect(widget.canManage, isTrue);
      expect(widget.onTap, isNotNull);
      expect(widget.onMute, isNotNull);
      expect(widget.onRemove, isNotNull);
      expect(widget.onPromote, isNotNull);
      expect(widget.onDemote, isNotNull);
    });

    test('default values are set correctly', () {
      final member = WatchPartyTestFactory.createMember();
      final widget = MemberListItem(member: member);

      expect(widget.isCurrentUser, isFalse);
      expect(widget.canManage, isFalse);
      expect(widget.onTap, isNull);
      expect(widget.onMute, isNull);
      expect(widget.onRemove, isNull);
      expect(widget.onPromote, isNull);
      expect(widget.onDemote, isNull);
    });

    test('callbacks are executed correctly', () {
      final member = WatchPartyTestFactory.createMember();
      bool tapped = false;
      bool muted = false;
      bool removed = false;

      final widget = MemberListItem(
        member: member,
        onTap: () => tapped = true,
        onMute: () => muted = true,
        onRemove: () => removed = true,
      );

      widget.onTap?.call();
      expect(tapped, isTrue);

      widget.onMute?.call();
      expect(muted, isTrue);

      widget.onRemove?.call();
      expect(removed, isTrue);
    });

    test('is a StatelessWidget', () {
      final member = WatchPartyTestFactory.createMember();
      final widget = MemberListItem(member: member);

      expect(widget, isA<StatelessWidget>());
    });

    test('stores member with different roles', () {
      final hostMember = WatchPartyTestFactory.createMember(
        role: WatchPartyMemberRole.host,
      );
      final coHostMember = WatchPartyTestFactory.createMember(
        role: WatchPartyMemberRole.coHost,
      );
      final regularMember = WatchPartyTestFactory.createMember(
        role: WatchPartyMemberRole.member,
      );

      final widget1 = MemberListItem(member: hostMember);
      final widget2 = MemberListItem(member: coHostMember);
      final widget3 = MemberListItem(member: regularMember);

      expect(widget1.member.role, equals(WatchPartyMemberRole.host));
      expect(widget2.member.role, equals(WatchPartyMemberRole.coHost));
      expect(widget3.member.role, equals(WatchPartyMemberRole.member));
    });

    test('stores member with different attendance types', () {
      final inPersonMember = WatchPartyTestFactory.createMember(
        attendanceType: WatchPartyAttendanceType.inPerson,
      );
      final virtualMember = WatchPartyTestFactory.createMember(
        attendanceType: WatchPartyAttendanceType.virtual,
      );

      final widget1 = MemberListItem(member: inPersonMember);
      final widget2 = MemberListItem(member: virtualMember);

      expect(widget1.member.attendanceType, equals(WatchPartyAttendanceType.inPerson));
      expect(widget2.member.attendanceType, equals(WatchPartyAttendanceType.virtual));
    });

    test('stores member mute state correctly', () {
      final mutedMember = WatchPartyTestFactory.createMember(isMuted: true);
      final unmutedMember = WatchPartyTestFactory.createMember(isMuted: false);

      final widget1 = MemberListItem(member: mutedMember);
      final widget2 = MemberListItem(member: unmutedMember);

      expect(widget1.member.isMuted, isTrue);
      expect(widget2.member.isMuted, isFalse);
    });
  });

  group('MemberListSection construction and type tests', () {
    test('can be constructed with required parameters', () {
      const widget = MemberListSection(
        title: 'Hosts',
        count: 2,
      );

      expect(widget, isNotNull);
      expect(widget, isA<MemberListSection>());
      expect(widget.title, equals('Hosts'));
      expect(widget.count, equals(2));
    });

    test('can be constructed with optional icon', () {
      const widget = MemberListSection(
        title: 'Members',
        count: 5,
        icon: Icons.people,
      );

      expect(widget.title, equals('Members'));
      expect(widget.count, equals(5));
      expect(widget.icon, equals(Icons.people));
    });

    test('icon is optional and defaults to null', () {
      const widget = MemberListSection(
        title: 'Virtual',
        count: 3,
      );

      expect(widget.icon, isNull);
    });

    test('is a StatelessWidget', () {
      const widget = MemberListSection(
        title: 'Test',
        count: 1,
      );

      expect(widget, isA<StatelessWidget>());
    });

    test('can be constructed with all parameters', () {
      const widget = MemberListSection(
        title: 'Section Title',
        count: 10,
        icon: Icons.star,
      );

      expect(widget.title, equals('Section Title'));
      expect(widget.count, equals(10));
      expect(widget.icon, equals(Icons.star));
    });

    test('multiple instances are independent', () {
      const widget1 = MemberListSection(
        title: 'Section 1',
        count: 5,
      );

      const widget2 = MemberListSection(
        title: 'Section 2',
        count: 10,
        icon: Icons.person,
      );

      expect(widget1.title, equals('Section 1'));
      expect(widget1.count, equals(5));
      expect(widget1.icon, isNull);
      expect(widget2.title, equals('Section 2'));
      expect(widget2.count, equals(10));
      expect(widget2.icon, equals(Icons.person));
    });

    test('count can be zero', () {
      const widget = MemberListSection(
        title: 'Empty',
        count: 0,
      );

      expect(widget.count, equals(0));
    });

    test('count can be large values', () {
      const widget = MemberListSection(
        title: 'Large',
        count: 1000,
      );

      expect(widget.count, equals(1000));
    });
  });
}
