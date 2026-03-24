import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/presentation/widgets/profile_feature_cards.dart';
import 'package:pregame_world_cup/features/social/domain/entities/user_profile.dart';
import '../../../social/mock_factories.dart';

void main() {
  late UserProfile testProfile;

  setUp(() {
    testProfile = SocialTestFactory.createUserProfile();
  });

  test('can be constructed with required parameters', () {
    final widget = ProfileFeatureCards(
      isCurrentUser: true,
      profile: testProfile,
    );
    expect(widget, isNotNull);
    expect(widget.isCurrentUser, isTrue);
    expect(widget.profile, equals(testProfile));
  });

  test('is a StatelessWidget', () {
    final widget = ProfileFeatureCards(
      isCurrentUser: true,
      profile: testProfile,
    );
    expect(widget, isA<StatelessWidget>());
  });

  test('stores isCurrentUser property', () {
    final widget = ProfileFeatureCards(
      isCurrentUser: false,
      profile: testProfile,
    );
    expect(widget.isCurrentUser, isFalse);
  });

  test('stores profile property', () {
    final widget = ProfileFeatureCards(
      isCurrentUser: true,
      profile: testProfile,
    );
    expect(widget.profile, equals(testProfile));
  });

  test('can be constructed with null profile', () {
    final widget = ProfileFeatureCards(
      isCurrentUser: true,
      profile: null,
    );
    expect(widget, isNotNull);
    expect(widget.profile, isNull);
  });

  test('optional callbacks are null by default', () {
    final widget = ProfileFeatureCards(
      isCurrentUser: true,
      profile: testProfile,
    );
    expect(widget.onAccessibilityTap, isNull);
    expect(widget.onProfileCustomizeTap, isNull);
  });

  test('stores onAccessibilityTap callback when provided', () {
    bool callbackCalled = false;
    void testCallback() {
      callbackCalled = true;
    }

    final widget = ProfileFeatureCards(
      isCurrentUser: true,
      profile: testProfile,
      onAccessibilityTap: testCallback,
    );
    expect(widget.onAccessibilityTap, equals(testCallback));
    widget.onAccessibilityTap?.call();
    expect(callbackCalled, isTrue);
  });

  test('stores onProfileCustomizeTap callback when provided', () {
    bool callbackCalled = false;
    void testCallback() {
      callbackCalled = true;
    }

    final widget = ProfileFeatureCards(
      isCurrentUser: true,
      profile: testProfile,
      onProfileCustomizeTap: testCallback,
    );
    expect(widget.onProfileCustomizeTap, equals(testCallback));
    widget.onProfileCustomizeTap?.call();
    expect(callbackCalled, isTrue);
  });
}
