import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/utils/lifecycle_helper.dart';

// Helper widget for testing State-dependent methods
class _TestWidget extends StatefulWidget {
  final void Function(State state) onBuild;
  final void Function(State state)? onTap;

  const _TestWidget({required this.onBuild, this.onTap});

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> {
  @override
  Widget build(BuildContext context) {
    widget.onBuild(this);
    return GestureDetector(
      onTap: () => widget.onTap?.call(this),
      child: const SizedBox(width: 100, height: 100),
    );
  }
}

void main() {
  group('LifecycleHelper', () {
    group('debounce', () {
      test('delays execution by specified duration', () async {
        int callCount = 0;
        final debounced = LifecycleHelper.debounce(
          () => callCount++,
          const Duration(milliseconds: 50),
        );

        debounced();
        expect(callCount, 0);

        await Future.delayed(const Duration(milliseconds: 100));
        expect(callCount, 1);
      });

      test('only executes once for rapid successive calls', () async {
        int callCount = 0;
        final debounced = LifecycleHelper.debounce(
          () => callCount++,
          const Duration(milliseconds: 50),
        );

        debounced();
        debounced();
        debounced();
        debounced();

        await Future.delayed(const Duration(milliseconds: 100));
        expect(callCount, 1);
      });

      test('executes again after delay expires', () async {
        int callCount = 0;
        final debounced = LifecycleHelper.debounce(
          () => callCount++,
          const Duration(milliseconds: 50),
        );

        debounced();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(callCount, 1);

        debounced();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(callCount, 2);
      });

      test('cancels previous timer on new call', () async {
        int callCount = 0;
        final debounced = LifecycleHelper.debounce(
          () => callCount++,
          const Duration(milliseconds: 100),
        );

        debounced();
        await Future.delayed(const Duration(milliseconds: 50));
        debounced(); // Should reset the timer

        await Future.delayed(const Duration(milliseconds: 60));
        // First timer would have fired at 100ms but was cancelled
        // Second timer fires at 50 + 100 = 150ms, we're at 110ms
        expect(callCount, 0);

        await Future.delayed(const Duration(milliseconds: 60));
        // Now at 170ms, second timer should have fired
        expect(callCount, 1);
      });

      test('accepts debugTag parameter', () async {
        int callCount = 0;
        final debounced = LifecycleHelper.debounce(
          () => callCount++,
          const Duration(milliseconds: 50),
          debugTag: 'TestDebounce',
        );

        debounced();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(callCount, 1);
      });

      test('handles exception in function without crashing', () async {
        final debounced = LifecycleHelper.debounce(
          () => throw Exception('test error'),
          const Duration(milliseconds: 50),
          debugTag: 'ErrorTest',
        );

        debounced();
        // Should not throw, error is caught internally
        await Future.delayed(const Duration(milliseconds: 100));
      });
    });

    group('throttle', () {
      test('executes immediately on first call', () {
        int callCount = 0;
        final throttled = LifecycleHelper.throttle(
          () => callCount++,
          const Duration(milliseconds: 100),
        );

        throttled();
        expect(callCount, 1);
      });

      test('blocks subsequent calls within interval', () {
        int callCount = 0;
        final throttled = LifecycleHelper.throttle(
          () => callCount++,
          const Duration(milliseconds: 100),
        );

        throttled();
        throttled();
        throttled();
        expect(callCount, 1);
      });

      test('allows execution after interval expires', () async {
        int callCount = 0;
        final throttled = LifecycleHelper.throttle(
          () => callCount++,
          const Duration(milliseconds: 50),
        );

        throttled();
        expect(callCount, 1);

        await Future.delayed(const Duration(milliseconds: 100));

        throttled();
        expect(callCount, 2);
      });

      test('accepts debugTag parameter', () {
        int callCount = 0;
        final throttled = LifecycleHelper.throttle(
          () => callCount++,
          const Duration(milliseconds: 100),
          debugTag: 'TestThrottle',
        );

        throttled();
        expect(callCount, 1);
      });

      test('handles exception in function without crashing', () {
        final throttled = LifecycleHelper.throttle(
          () => throw Exception('test error'),
          const Duration(milliseconds: 100),
          debugTag: 'ThrottleErrorTest',
        );

        // Should not throw, error is caught internally
        expect(() => throttled(), returnsNormally);
      });
    });

    group('safeDispose', () {
      test('cancels StreamSubscription', () async {
        final controller = StreamController<int>();
        final sub = controller.stream.listen((_) {});
        expect(
          () => LifecycleHelper.safeDispose([sub]),
          returnsNormally,
        );
        await controller.close();
      });

      test('cancels Timer', () {
        final timer = Timer(const Duration(seconds: 10), () {});
        expect(
          () => LifecycleHelper.safeDispose([timer]),
          returnsNormally,
        );
        expect(timer.isActive, isFalse);
      });

      test('handles empty list', () {
        expect(
          () => LifecycleHelper.safeDispose([]),
          returnsNormally,
        );
      });

      test('handles mixed resource types', () async {
        final controller = StreamController<int>();
        final sub = controller.stream.listen((_) {});
        final timer = Timer(const Duration(seconds: 10), () {});

        expect(
          () => LifecycleHelper.safeDispose([sub, timer]),
          returnsNormally,
        );

        expect(timer.isActive, isFalse);
        await controller.close();
      });

      test('handles null items gracefully', () {
        expect(
          () => LifecycleHelper.safeDispose([null]),
          returnsNormally,
        );
      });

      test('continues after one resource throws during dispose', () {
        final timer1 = Timer(const Duration(seconds: 10), () {});
        timer1.cancel();
        final timer2 = Timer(const Duration(seconds: 10), () {});

        expect(
          () => LifecycleHelper.safeDispose([timer1, timer2]),
          returnsNormally,
        );

        expect(timer2.isActive, isFalse);
      });

      test('accepts debugTag parameter', () {
        final timer = Timer(const Duration(seconds: 10), () {});
        expect(
          () => LifecycleHelper.safeDispose(
            [timer],
            debugTag: 'TestDispose',
          ),
          returnsNormally,
        );
      });
    });

    group('safeStreamSubscription', () {
      test('creates subscription that receives data', () async {
        final controller = StreamController<int>();
        final received = <int>[];

        final sub = LifecycleHelper.safeStreamSubscription<int>(
          controller.stream,
          (data) => received.add(data),
        );

        controller.add(1);
        controller.add(2);
        controller.add(3);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(received, [1, 2, 3]);

        await sub.cancel();
        await controller.close();
      });

      test('handles errors in stream without crashing', () async {
        final controller = StreamController<int>();
        final received = <int>[];

        final sub = LifecycleHelper.safeStreamSubscription<int>(
          controller.stream,
          (data) => received.add(data),
          debugTag: 'ErrorStream',
        );

        controller.add(1);
        controller.addError('test error');
        controller.add(2);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(received, [1, 2]);

        await sub.cancel();
        await controller.close();
      });

      test('calls onDone when stream closes', () async {
        final controller = StreamController<int>();
        bool doneCalled = false;

        final sub = LifecycleHelper.safeStreamSubscription<int>(
          controller.stream,
          (data) {},
          onDone: () => doneCalled = true,
        );

        await controller.close();
        await Future.delayed(const Duration(milliseconds: 50));

        expect(doneCalled, isTrue);

        await sub.cancel();
      });

      test('calls onError when error occurs', () async {
        final controller = StreamController<int>();
        Object? capturedError;

        final sub = LifecycleHelper.safeStreamSubscription<int>(
          controller.stream,
          (data) {},
          onError: (error) => capturedError = error,
        );

        controller.addError('custom error');
        await Future.delayed(const Duration(milliseconds: 50));

        expect(capturedError, 'custom error');

        await sub.cancel();
        await controller.close();
      });

      test('accepts debugTag parameter', () async {
        final controller = StreamController<int>();

        final sub = LifecycleHelper.safeStreamSubscription<int>(
          controller.stream,
          (data) {},
          debugTag: 'TaggedStream',
        );

        await sub.cancel();
        await controller.close();
      });
    });

    group('safeExecute', () {
      test('returns result on success', () {
        final result = LifecycleHelper.safeExecute<int>(
          () => 42,
        );
        expect(result, 42);
      });

      test('returns null on exception', () {
        final result = LifecycleHelper.safeExecute<int>(
          () => throw Exception('test'),
        );
        expect(result, isNull);
      });

      test('returns defaultValue on exception', () {
        final result = LifecycleHelper.safeExecute<int>(
          () => throw Exception('test'),
          defaultValue: -1,
        );
        expect(result, -1);
      });

      test('returns string result', () {
        final result = LifecycleHelper.safeExecute<String>(
          () => 'hello',
        );
        expect(result, 'hello');
      });

      test('returns list result', () {
        final result = LifecycleHelper.safeExecute<List<int>>(
          () => [1, 2, 3],
        );
        expect(result, [1, 2, 3]);
      });

      test('accepts debugTag', () {
        final result = LifecycleHelper.safeExecute<int>(
          () => 10,
          debugTag: 'TestExec',
        );
        expect(result, 10);
      });

      test('handles null return correctly', () {
        final result = LifecycleHelper.safeExecute<int?>(
          () => null,
        );
        expect(result, isNull);
      });
    });

    group('isSafeToUpdate', () {
      testWidgets('returns true for mounted widget', (tester) async {
        late bool safeToUpdate;

        await tester.pumpWidget(
          MaterialApp(
            home: _TestWidget(
              onBuild: (state) {
                safeToUpdate = LifecycleHelper.isSafeToUpdate(state);
              },
            ),
          ),
        );

        expect(safeToUpdate, isTrue);
      });
    });

    group('safeSetState', () {
      testWidgets('calls setState on mounted widget', (tester) async {
        int counter = 0;
        State? capturedState;

        await tester.pumpWidget(
          MaterialApp(
            home: _TestWidget(
              onBuild: (state) {
                capturedState = state;
              },
            ),
          ),
        );

        // Call safeSetState directly with the captured state
        LifecycleHelper.safeSetState(capturedState!, () {
          counter++;
        });
        await tester.pump();

        expect(counter, 1);
      });

      testWidgets('accepts debugTag parameter', (tester) async {
        int counter = 0;
        State? capturedState;

        await tester.pumpWidget(
          MaterialApp(
            home: _TestWidget(
              onBuild: (state) {
                capturedState = state;
              },
            ),
          ),
        );

        LifecycleHelper.safeSetState(
          capturedState!,
          () => counter++,
          debugTag: 'TestWidget',
        );
        await tester.pump();

        expect(counter, 1);
      });
    });
  });
}
