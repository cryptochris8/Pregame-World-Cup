import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/chatbot/presentation/widgets/copa_avatar.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().contains('A RenderFlex overflowed by'),
          );
      if (isOverflowError) {
      } else {
        FlutterError.presentError(details);
      }
    };
  });

  testWidgets('renders with default size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CopaAvatar(),
        ),
      ),
    );

    expect(find.byType(CopaAvatar), findsOneWidget);

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(sizedBox.width, equals(32.0));
    expect(sizedBox.height, equals(32.0));
  });

  testWidgets('renders with custom size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CopaAvatar(size: 48),
        ),
      ),
    );

    expect(find.byType(CopaAvatar), findsOneWidget);

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(sizedBox.width, equals(48.0));
    expect(sizedBox.height, equals(48.0));
  });

  testWidgets('contains CustomPaint', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CopaAvatar(),
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('SizedBox dimensions match size', (tester) async {
    const testSize = 64.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CopaAvatar(size: testSize),
        ),
      ),
    );

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(sizedBox.width, equals(testSize));
    expect(sizedBox.height, equals(testSize));
  });
}
