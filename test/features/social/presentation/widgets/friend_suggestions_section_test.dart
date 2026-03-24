import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/presentation/widgets/friend_suggestions_section.dart';
import 'package:pregame_world_cup/features/social/domain/entities/social_connection.dart';
import '../../../social/mock_factories.dart';

void main() {
  late List<FriendSuggestion> testSuggestions;

  setUp(() {
    testSuggestions = [
      SocialTestFactory.createFriendSuggestion(
        userId: 'user_1',
        displayName: 'User One',
        mutualFriends: ['friend_1'],
        sharedTeams: ['USA'],
      ),
      SocialTestFactory.createFriendSuggestion(
        userId: 'user_2',
        displayName: 'User Two',
        mutualFriends: ['friend_1', 'friend_2'],
        sharedTeams: ['Brazil'],
      ),
    ];
  });

  test('can be constructed with required parameters', () {
    final widget = FriendSuggestionsSection(
      suggestions: testSuggestions,
      onSuggestionPressed: (suggestion) {},
      onConnectPressed: (userId) {},
    );
    expect(widget, isNotNull);
  });

  test('is a StatelessWidget', () {
    final widget = FriendSuggestionsSection(
      suggestions: testSuggestions,
      onSuggestionPressed: (suggestion) {},
      onConnectPressed: (userId) {},
    );
    expect(widget, isA<StatelessWidget>());
  });

  test('stores suggestions list', () {
    final widget = FriendSuggestionsSection(
      suggestions: testSuggestions,
      onSuggestionPressed: (suggestion) {},
      onConnectPressed: (userId) {},
    );
    expect(widget.suggestions, equals(testSuggestions));
    expect(widget.suggestions.length, equals(2));
  });

  test('stores onSuggestionPressed callback', () {
    FriendSuggestion? pressedSuggestion;

    final widget = FriendSuggestionsSection(
      suggestions: testSuggestions,
      onSuggestionPressed: (suggestion) {
        pressedSuggestion = suggestion;
      },
      onConnectPressed: (userId) {},
    );

    widget.onSuggestionPressed(testSuggestions[0]);
    expect(pressedSuggestion, equals(testSuggestions[0]));
  });

  test('stores onConnectPressed callback', () {
    String? connectedUserId;

    final widget = FriendSuggestionsSection(
      suggestions: testSuggestions,
      onSuggestionPressed: (suggestion) {},
      onConnectPressed: (userId) {
        connectedUserId = userId;
      },
    );

    widget.onConnectPressed('user_123');
    expect(connectedUserId, equals('user_123'));
  });

  test('can be constructed with empty suggestions list', () {
    final widget = FriendSuggestionsSection(
      suggestions: [],
      onSuggestionPressed: (suggestion) {},
      onConnectPressed: (userId) {},
    );
    expect(widget, isNotNull);
    expect(widget.suggestions, isEmpty);
  });

  test('onSuggestionPressed receives correct suggestion', () {
    final receivedSuggestions = <FriendSuggestion>[];

    final widget = FriendSuggestionsSection(
      suggestions: testSuggestions,
      onSuggestionPressed: (suggestion) {
        receivedSuggestions.add(suggestion);
      },
      onConnectPressed: (userId) {},
    );

    widget.onSuggestionPressed(testSuggestions[0]);
    widget.onSuggestionPressed(testSuggestions[1]);

    expect(receivedSuggestions.length, equals(2));
    expect(receivedSuggestions[0], equals(testSuggestions[0]));
    expect(receivedSuggestions[1], equals(testSuggestions[1]));
  });

  test('onConnectPressed receives correct userId', () {
    final connectedUserIds = <String>[];

    final widget = FriendSuggestionsSection(
      suggestions: testSuggestions,
      onSuggestionPressed: (suggestion) {},
      onConnectPressed: (userId) {
        connectedUserIds.add(userId);
      },
    );

    widget.onConnectPressed('user_1');
    widget.onConnectPressed('user_2');

    expect(connectedUserIds.length, equals(2));
    expect(connectedUserIds[0], equals('user_1'));
    expect(connectedUserIds[1], equals('user_2'));
  });
}
