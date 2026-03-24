import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/new_chat_bottom_sheet.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/chat.dart';

void main() {
  group('NewChatBottomSheet', () {
    test('is a StatefulWidget', () {
      final widget = NewChatBottomSheet(
        onDirectChatCreated: (_) {},
        onGroupChatCreated: (_) {},
        onTeamChatCreated: (_) {},
      );
      expect(widget, isA<StatefulWidget>());
    });

    test('can be constructed with required parameters', () {
      final widget = NewChatBottomSheet(
        onDirectChatCreated: (_) {},
        onGroupChatCreated: (_) {},
        onTeamChatCreated: (_) {},
      );
      expect(widget, isNotNull);
    });

    test('stores onDirectChatCreated callback', () {
      Chat? createdChat;
      void testCallback(Chat chat) {
        createdChat = chat;
      }

      final widget = NewChatBottomSheet(
        onDirectChatCreated: testCallback,
        onGroupChatCreated: (_) {},
        onTeamChatCreated: (_) {},
      );

      expect(widget.onDirectChatCreated, equals(testCallback));

      final testChat = Chat.direct(
        currentUserId: 'user1',
        participantUserId: 'user2',
      );
      widget.onDirectChatCreated(testChat);
      expect(createdChat, equals(testChat));
      expect(createdChat?.type, equals(ChatType.direct));
    });

    test('stores onGroupChatCreated callback', () {
      Chat? createdChat;
      void testCallback(Chat chat) {
        createdChat = chat;
      }

      final widget = NewChatBottomSheet(
        onDirectChatCreated: (_) {},
        onGroupChatCreated: testCallback,
        onTeamChatCreated: (_) {},
      );

      expect(widget.onGroupChatCreated, equals(testCallback));

      final testChat = Chat.group(
        name: 'Test Group',
        creatorId: 'user1',
        participantIds: ['user2', 'user3'],
      );
      widget.onGroupChatCreated(testChat);
      expect(createdChat, equals(testChat));
      expect(createdChat?.type, equals(ChatType.group));
    });

    test('stores onTeamChatCreated callback', () {
      Chat? createdChat;
      void testCallback(Chat chat) {
        createdChat = chat;
      }

      final widget = NewChatBottomSheet(
        onDirectChatCreated: (_) {},
        onGroupChatCreated: (_) {},
        onTeamChatCreated: testCallback,
      );

      expect(widget.onTeamChatCreated, equals(testCallback));

      final testChat = Chat.team(
        teamName: 'Test Team',
        creatorId: 'user1',
        memberIds: ['user2', 'user3'],
      );
      widget.onTeamChatCreated(testChat);
      expect(createdChat, equals(testChat));
      expect(createdChat?.type, equals(ChatType.team));
    });

    test('can be constructed with all three callbacks', () {
      Chat? directChat;
      Chat? groupChat;
      Chat? teamChat;

      final widget = NewChatBottomSheet(
        onDirectChatCreated: (chat) => directChat = chat,
        onGroupChatCreated: (chat) => groupChat = chat,
        onTeamChatCreated: (chat) => teamChat = chat,
      );

      expect(widget, isNotNull);

      final testDirect = Chat.direct(
        currentUserId: 'user1',
        participantUserId: 'user2',
      );
      widget.onDirectChatCreated(testDirect);
      expect(directChat, isNotNull);

      final testGroup = Chat.group(
        name: 'Group',
        creatorId: 'user1',
        participantIds: ['user2'],
      );
      widget.onGroupChatCreated(testGroup);
      expect(groupChat, isNotNull);

      final testTeam = Chat.team(
        teamName: 'Team',
        creatorId: 'user1',
        memberIds: ['user2'],
      );
      widget.onTeamChatCreated(testTeam);
      expect(teamChat, isNotNull);
    });
  });
}
