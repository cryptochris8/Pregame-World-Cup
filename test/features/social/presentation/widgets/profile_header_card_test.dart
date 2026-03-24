import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pregame_world_cup/features/social/presentation/widgets/profile_header_card.dart';
import 'package:pregame_world_cup/features/social/domain/entities/user_profile.dart';

void main() {
  group('ProfileHeaderCard', () {
    late UserProfile testProfile;

    setUp(() {
      testProfile = UserProfile.create(
        userId: 'user123',
        displayName: 'John Doe',
        email: 'john@example.com',
      );
    });

    test('is a StatelessWidget', () {
      final widget = ProfileHeaderCard(
        profile: testProfile,
        currentUser: null,
        isCurrentUser: false,
      );

      expect(widget, isA<StatelessWidget>());
    });

    test('constructor stores profile', () {
      final widget = ProfileHeaderCard(
        profile: testProfile,
        currentUser: null,
        isCurrentUser: false,
      );

      expect(widget.profile, testProfile);
      expect(widget.profile?.userId, 'user123');
      expect(widget.profile?.displayName, 'John Doe');
      expect(widget.profile?.email, 'john@example.com');
    });

    test('constructor stores isCurrentUser', () {
      final widget = ProfileHeaderCard(
        profile: testProfile,
        currentUser: null,
        isCurrentUser: true,
      );

      expect(widget.isCurrentUser, true);
    });

    test('constructor with isCurrentUser false', () {
      final widget = ProfileHeaderCard(
        profile: testProfile,
        currentUser: null,
        isCurrentUser: false,
      );

      expect(widget.isCurrentUser, false);
    });

    test('profile can be null', () {
      final widget = ProfileHeaderCard(
        profile: null,
        currentUser: null,
        isCurrentUser: false,
      );

      expect(widget.profile, isNull);
    });

    test('currentUser can be null', () {
      final widget = ProfileHeaderCard(
        profile: testProfile,
        currentUser: null,
        isCurrentUser: false,
      );

      expect(widget.currentUser, isNull);
    });

    test('constructor stores all parameters', () {
      final widget = ProfileHeaderCard(
        profile: testProfile,
        currentUser: null,
        isCurrentUser: true,
      );

      expect(widget.profile, testProfile);
      expect(widget.currentUser, isNull);
      expect(widget.isCurrentUser, true);
    });

    test('constructor with online profile', () {
      final onlineProfile = testProfile.copyWith(isOnline: true);
      final widget = ProfileHeaderCard(
        profile: onlineProfile,
        currentUser: null,
        isCurrentUser: false,
      );

      expect(widget.profile?.isOnline, true);
    });

    test('constructor with offline profile', () {
      final offlineProfile = testProfile.copyWith(isOnline: false);
      final widget = ProfileHeaderCard(
        profile: offlineProfile,
        currentUser: null,
        isCurrentUser: false,
      );

      expect(widget.profile?.isOnline, false);
    });

    test('constructor with profile with profileImageUrl', () {
      final profileWithImage = testProfile.copyWith(
        profileImageUrl: 'https://example.com/photo.jpg',
      );
      final widget = ProfileHeaderCard(
        profile: profileWithImage,
        currentUser: null,
        isCurrentUser: false,
      );

      expect(widget.profile?.profileImageUrl, 'https://example.com/photo.jpg');
    });

    test('constructor with profile without profileImageUrl', () {
      final widget = ProfileHeaderCard(
        profile: testProfile,
        currentUser: null,
        isCurrentUser: false,
      );

      expect(widget.profile?.profileImageUrl, isNull);
    });

    test('constructor with different user profiles', () {
      final profiles = [
        UserProfile.create(userId: 'user1', displayName: 'User One'),
        UserProfile.create(userId: 'user2', displayName: 'User Two'),
        UserProfile.create(userId: 'user3', displayName: 'User Three'),
      ];

      for (final profile in profiles) {
        final widget = ProfileHeaderCard(
          profile: profile,
          currentUser: null,
          isCurrentUser: false,
        );

        expect(widget.profile, profile);
      }
    });

    test('constructor with current user viewing own profile', () {
      final widget = ProfileHeaderCard(
        profile: testProfile,
        currentUser: null,
        isCurrentUser: true,
      );

      expect(widget.profile?.userId, 'user123');
      expect(widget.isCurrentUser, true);
    });

    test('constructor with current user viewing another profile', () {
      final otherProfile = UserProfile.create(
        userId: 'user456',
        displayName: 'Jane Smith',
      );
      final widget = ProfileHeaderCard(
        profile: otherProfile,
        currentUser: null,
        isCurrentUser: false,
      );

      expect(widget.profile?.userId, 'user456');
      expect(widget.isCurrentUser, false);
    });
  });
}
