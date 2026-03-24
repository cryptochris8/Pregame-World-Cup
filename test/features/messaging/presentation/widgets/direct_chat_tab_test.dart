import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/direct_chat_tab.dart';
import 'package:pregame_world_cup/features/social/domain/entities/user_profile.dart';

void main() {
  group('DirectChatTab', () {
    late TextEditingController searchController;
    late List<UserProfile> friends;
    late UserProfile testFriend;

    setUp(() {
      searchController = TextEditingController();
      testFriend = UserProfile.create(
        userId: 'user1',
        displayName: 'Test Friend',
        email: 'test@example.com',
      );
      friends = [testFriend];
    });

    tearDown(() {
      searchController.dispose();
    });

    test('is a StatelessWidget', () {
      final widget = DirectChatTab(
        searchController: searchController,
        isLoading: false,
        friends: friends,
        filteredFriends: friends,
        onFriendSelected: (_) {},
      );
      expect(widget, isA<StatelessWidget>());
    });

    test('can be constructed with required parameters', () {
      final widget = DirectChatTab(
        searchController: searchController,
        isLoading: false,
        friends: friends,
        filteredFriends: friends,
        onFriendSelected: (_) {},
      );
      expect(widget, isNotNull);
    });

    test('stores searchController', () {
      final widget = DirectChatTab(
        searchController: searchController,
        isLoading: false,
        friends: friends,
        filteredFriends: friends,
        onFriendSelected: (_) {},
      );
      expect(widget.searchController, equals(searchController));
    });

    test('stores isLoading', () {
      final widget = DirectChatTab(
        searchController: searchController,
        isLoading: true,
        friends: friends,
        filteredFriends: friends,
        onFriendSelected: (_) {},
      );
      expect(widget.isLoading, isTrue);
    });

    test('stores friends list', () {
      final widget = DirectChatTab(
        searchController: searchController,
        isLoading: false,
        friends: friends,
        filteredFriends: friends,
        onFriendSelected: (_) {},
      );
      expect(widget.friends, equals(friends));
      expect(widget.friends.length, equals(1));
      expect(widget.friends.first.userId, equals('user1'));
    });

    test('stores filteredFriends list', () {
      final filteredList = [testFriend];
      final widget = DirectChatTab(
        searchController: searchController,
        isLoading: false,
        friends: friends,
        filteredFriends: filteredList,
        onFriendSelected: (_) {},
      );
      expect(widget.filteredFriends, equals(filteredList));
      expect(widget.filteredFriends.length, equals(1));
    });

    test('stores onFriendSelected callback', () {
      UserProfile? selectedFriend;
      void testCallback(UserProfile friend) {
        selectedFriend = friend;
      }

      final widget = DirectChatTab(
        searchController: searchController,
        isLoading: false,
        friends: friends,
        filteredFriends: friends,
        onFriendSelected: testCallback,
      );

      expect(widget.onFriendSelected, equals(testCallback));
      widget.onFriendSelected(testFriend);
      expect(selectedFriend, equals(testFriend));
      expect(selectedFriend?.userId, equals('user1'));
    });

    test('handles empty friends list', () {
      final widget = DirectChatTab(
        searchController: searchController,
        isLoading: false,
        friends: [],
        filteredFriends: [],
        onFriendSelected: (_) {},
      );
      expect(widget.friends, isEmpty);
      expect(widget.filteredFriends, isEmpty);
    });

    test('handles multiple friends', () {
      final multipleFriends = [
        UserProfile.create(userId: 'user1', displayName: 'Friend 1'),
        UserProfile.create(userId: 'user2', displayName: 'Friend 2'),
        UserProfile.create(userId: 'user3', displayName: 'Friend 3'),
      ];
      final widget = DirectChatTab(
        searchController: searchController,
        isLoading: false,
        friends: multipleFriends,
        filteredFriends: multipleFriends,
        onFriendSelected: (_) {},
      );
      expect(widget.friends.length, equals(3));
      expect(widget.filteredFriends.length, equals(3));
    });
  });
}
