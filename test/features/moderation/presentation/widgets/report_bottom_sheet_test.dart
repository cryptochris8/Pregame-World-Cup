import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/moderation/domain/entities/report.dart';
import 'package:pregame_world_cup/features/moderation/presentation/widgets/report_bottom_sheet.dart';

/// Widget tests for ReportBottomSheet.
///
/// The ReportBottomSheet internally instantiates ModerationService() which is a
/// singleton that requires Firebase. Full rendering tests that trigger state
/// changes (submit, etc.) are not feasible in pure unit tests without Firebase.
///
/// These tests verify the constructor, static method signature, and basic
/// structural properties of the widget.
void main() {
  group('ReportBottomSheet', () {
    group('Constructor', () {
      test('creates with required fields', () {
        const sheet = ReportBottomSheet(
          contentType: ReportableContentType.message,
          contentId: 'msg_1',
        );

        expect(sheet.contentType, equals(ReportableContentType.message));
        expect(sheet.contentId, equals('msg_1'));
        expect(sheet.title, equals('Report'));
        expect(sheet.contentOwnerId, isNull);
        expect(sheet.contentOwnerDisplayName, isNull);
        expect(sheet.contentSnapshot, isNull);
      });

      test('creates with all optional fields', () {
        const sheet = ReportBottomSheet(
          contentType: ReportableContentType.user,
          contentId: 'u1',
          contentOwnerId: 'u1',
          contentOwnerDisplayName: 'User One',
          contentSnapshot: 'Offensive content here',
          title: 'Report User',
        );

        expect(sheet.contentOwnerId, equals('u1'));
        expect(sheet.contentOwnerDisplayName, equals('User One'));
        expect(sheet.contentSnapshot, equals('Offensive content here'));
        expect(sheet.title, equals('Report User'));
      });

      test('default title is Report', () {
        const sheet = ReportBottomSheet(
          contentType: ReportableContentType.message,
          contentId: 'msg_1',
        );

        expect(sheet.title, equals('Report'));
      });

      test('creates for each content type', () {
        for (final type in ReportableContentType.values) {
          final sheet = ReportBottomSheet(
            contentType: type,
            contentId: 'test_${type.name}',
          );

          expect(sheet.contentType, equals(type));
          expect(sheet.contentId, equals('test_${type.name}'));
        }
      });
    });

    group('Static show method', () {
      test('show method exists and is a function', () {
        expect(ReportBottomSheet.show, isA<Function>());
      });
    });

    test('is a StatefulWidget', () {
      const sheet = ReportBottomSheet(
        contentType: ReportableContentType.message,
        contentId: 'msg_1',
      );
      expect(sheet, isA<StatefulWidget>());
    });

    test('accepts null contentSnapshot for no preview', () {
      const sheet = ReportBottomSheet(
        contentType: ReportableContentType.user,
        contentId: 'u1',
        contentSnapshot: null,
      );
      expect(sheet.contentSnapshot, isNull);
    });

    test('accepts contentSnapshot for content preview', () {
      const sheet = ReportBottomSheet(
        contentType: ReportableContentType.message,
        contentId: 'msg_1',
        contentSnapshot: 'Bad message content here',
      );
      expect(sheet.contentSnapshot, equals('Bad message content here'));
    });
  });
}
