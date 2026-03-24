import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/chat_blocked_banner.dart';
import 'package:pregame_world_cup/features/messaging/domain/services/messaging_chat_settings_service.dart';

void main() {
  group('ChatBlockedBanner', () {
    test('is a StatelessWidget', () {
      const blockStatus = BlockStatus(isBlocked: true);
      final widget = ChatBlockedBanner(
        blockStatus: blockStatus,
        onUnblock: () {},
      );
      expect(widget, isA<StatelessWidget>());
    });

    test('can be constructed with required parameters', () {
      const blockStatus = BlockStatus(isBlocked: true);
      final widget = ChatBlockedBanner(
        blockStatus: blockStatus,
        onUnblock: () {},
      );
      expect(widget, isNotNull);
    });

    test('stores blockStatus', () {
      const blockStatus = BlockStatus(isBlocked: true, blockedByCurrentUser: true);
      final widget = ChatBlockedBanner(
        blockStatus: blockStatus,
        onUnblock: () {},
      );
      expect(widget.blockStatus, equals(blockStatus));
      expect(widget.blockStatus.isBlocked, isTrue);
      expect(widget.blockStatus.blockedByCurrentUser, isTrue);
    });

    test('stores onUnblock callback', () {
      bool callbackCalled = false;
      void testCallback() {
        callbackCalled = true;
      }

      const blockStatus = BlockStatus(isBlocked: true);
      final widget = ChatBlockedBanner(
        blockStatus: blockStatus,
        onUnblock: testCallback,
      );

      expect(widget.onUnblock, equals(testCallback));
      widget.onUnblock();
      expect(callbackCalled, isTrue);
    });

    test('stores BlockStatus with message', () {
      const blockStatus = BlockStatus(
        isBlocked: true,
        blockedByCurrentUser: false,
        message: 'You cannot message this user',
      );
      final widget = ChatBlockedBanner(
        blockStatus: blockStatus,
        onUnblock: () {},
      );
      expect(widget.blockStatus.message, equals('You cannot message this user'));
    });

    test('stores BlockStatus when blocked by current user', () {
      const blockStatus = BlockStatus(
        isBlocked: true,
        blockedByCurrentUser: true,
        message: 'You blocked this user',
      );
      final widget = ChatBlockedBanner(
        blockStatus: blockStatus,
        onUnblock: () {},
      );
      expect(widget.blockStatus.blockedByCurrentUser, isTrue);
      expect(widget.blockStatus.message, equals('You blocked this user'));
    });
  });
}
