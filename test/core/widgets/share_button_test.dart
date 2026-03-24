import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/widgets/share_button.dart';
import 'package:pregame_world_cup/core/services/deep_link_service.dart';

void main() {
  group('ShareButton', () {
    test('is a StatelessWidget', () {
      const button = ShareButton(
        contentType: DeepLinkType.match,
        contentId: 'match123',
        title: 'Test Match',
        description: 'Test Description',
      );

      expect(button, isA<StatelessWidget>());
    });

    test('stores contentType', () {
      const button = ShareButton(
        contentType: DeepLinkType.team,
        contentId: 'team123',
        title: 'Test Team',
        description: 'Test Description',
      );

      expect(button.contentType, equals(DeepLinkType.team));
    });

    test('stores contentId', () {
      const contentId = 'match456';

      const button = ShareButton(
        contentType: DeepLinkType.match,
        contentId: contentId,
        title: 'Test',
        description: 'Test Description',
      );

      expect(button.contentId, equals(contentId));
    });

    test('stores title and description', () {
      const title = 'Test Title';
      const description = 'Test Description';

      const button = ShareButton(
        contentType: DeepLinkType.match,
        contentId: 'match123',
        title: title,
        description: description,
      );

      expect(button.title, equals(title));
      expect(button.description, equals(description));
    });

    test('showLabel defaults to false', () {
      const button = ShareButton(
        contentType: DeepLinkType.match,
        contentId: 'match123',
        title: 'Test',
        description: 'Test Description',
      );

      expect(button.showLabel, isFalse);
    });

    test('iconSize defaults to 24', () {
      const button = ShareButton(
        contentType: DeepLinkType.match,
        contentId: 'match123',
        title: 'Test',
        description: 'Test Description',
      );

      expect(button.iconSize, equals(24));
    });

    test('ShareButton.match factory creates with correct contentType', () {
      final button = ShareButton.match(
        matchId: 'match123',
        homeTeam: 'Team A',
        awayTeam: 'Team B',
      );

      expect(button.contentType, equals(DeepLinkType.match));
      expect(button.contentId, equals('match123'));
      expect(button.title, equals('Team A vs Team B'));
    });

    test('ShareButton.watchParty factory creates with correct contentType', () {
      final button = ShareButton.watchParty(
        partyId: 'party123',
        partyName: 'Test Party',
        matchName: 'Team A vs Team B',
        venueName: 'Test Venue',
      );

      expect(button.contentType, equals(DeepLinkType.watchParty));
      expect(button.contentId, equals('party123'));
      expect(button.title, equals('Test Party'));
    });

    test('ShareButton.team factory creates with correct contentType', () {
      final button = ShareButton.team(
        teamId: 'team123',
        teamName: 'Test Team',
      );

      expect(button.contentType, equals(DeepLinkType.team));
      expect(button.contentId, equals('team123'));
      expect(button.title, equals('Test Team'));
    });

    test('ShareButton.profile factory creates with correct contentType', () {
      final button = ShareButton.profile(
        usualId: 'user123',
        displayName: 'Test User',
      );

      expect(button.contentType, equals(DeepLinkType.userProfile));
      expect(button.contentId, equals('user123'));
      expect(button.title, equals('Test User'));
    });
  });

  group('ShareFloatingButton', () {
    test('is a StatelessWidget', () {
      const button = ShareFloatingButton(
        contentType: DeepLinkType.match,
        contentId: 'match123',
        title: 'Test',
        description: 'Test Description',
      );

      expect(button, isA<StatelessWidget>());
    });

    test('stores required parameters', () {
      const contentType = DeepLinkType.watchParty;
      const contentId = 'party123';
      const title = 'Test Party';
      const description = 'Test Description';

      const button = ShareFloatingButton(
        contentType: contentType,
        contentId: contentId,
        title: title,
        description: description,
      );

      expect(button.contentType, equals(contentType));
      expect(button.contentId, equals(contentId));
      expect(button.title, equals(title));
      expect(button.description, equals(description));
    });

    test('can be constructed with all optional parameters', () {
      const button = ShareFloatingButton(
        contentType: DeepLinkType.match,
        contentId: 'match123',
        title: 'Test',
        description: 'Test Description',
        imageUrl: 'https://example.com/image.jpg',
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        heroTag: 'share-fab',
      );

      expect(button.imageUrl, equals('https://example.com/image.jpg'));
      expect(button.backgroundColor, equals(Colors.blue));
      expect(button.foregroundColor, equals(Colors.white));
      expect(button.heroTag, equals('share-fab'));
    });
  });

  group('ShareBottomSheet', () {
    test('is a StatelessWidget', () {
      const sheet = ShareBottomSheet(
        title: 'Test',
        description: 'Test Description',
      );

      expect(sheet, isA<StatelessWidget>());
    });

    test('stores title and description', () {
      const title = 'Test Title';
      const description = 'Test Description';

      const sheet = ShareBottomSheet(
        title: title,
        description: description,
      );

      expect(sheet.title, equals(title));
      expect(sheet.description, equals(description));
    });

    test('can be constructed with all parameters', () {
      void onCopyLink() {}
      void onShareNative() {}

      final sheet = ShareBottomSheet(
        title: 'Test',
        description: 'Test Description',
        link: 'https://example.com',
        imageUrl: 'https://example.com/image.jpg',
        onCopyLink: onCopyLink,
        onShareNative: onShareNative,
      );

      expect(sheet.link, equals('https://example.com'));
      expect(sheet.imageUrl, equals('https://example.com/image.jpg'));
      expect(sheet.onCopyLink, equals(onCopyLink));
      expect(sheet.onShareNative, equals(onShareNative));
    });
  });
}
