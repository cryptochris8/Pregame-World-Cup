import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/presentation/widgets/profile_account_actions.dart';

void main() {
  test('can be constructed with required callbacks', () {
    final widget = ProfileAccountActions(
      onExportData: () {},
      onDeleteAccount: () {},
    );
    expect(widget, isNotNull);
  });

  test('is a StatelessWidget', () {
    final widget = ProfileAccountActions(
      onExportData: () {},
      onDeleteAccount: () {},
    );
    expect(widget, isA<StatelessWidget>());
  });

  test('stores onExportData callback', () {
    bool exportCalled = false;
    void exportCallback() {
      exportCalled = true;
    }

    final widget = ProfileAccountActions(
      onExportData: exportCallback,
      onDeleteAccount: () {},
    );
    expect(widget.onExportData, equals(exportCallback));
    widget.onExportData();
    expect(exportCalled, isTrue);
  });

  test('stores onDeleteAccount callback', () {
    bool deleteCalled = false;
    void deleteCallback() {
      deleteCalled = true;
    }

    final widget = ProfileAccountActions(
      onExportData: () {},
      onDeleteAccount: deleteCallback,
    );
    expect(widget.onDeleteAccount, equals(deleteCallback));
    widget.onDeleteAccount();
    expect(deleteCalled, isTrue);
  });

  test('stores both callbacks independently', () {
    bool exportCalled = false;
    bool deleteCalled = false;

    final widget = ProfileAccountActions(
      onExportData: () {
        exportCalled = true;
      },
      onDeleteAccount: () {
        deleteCalled = true;
      },
    );

    widget.onExportData();
    expect(exportCalled, isTrue);
    expect(deleteCalled, isFalse);

    widget.onDeleteAccount();
    expect(exportCalled, isTrue);
    expect(deleteCalled, isTrue);
  });
}
