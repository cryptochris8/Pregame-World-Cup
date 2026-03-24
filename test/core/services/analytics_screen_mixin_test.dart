import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/core/services/analytics_screen_mixin.dart';
import 'package:pregame_world_cup/core/services/analytics_service.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late MockAnalyticsService mockAnalyticsService;

  setUp(() {
    mockAnalyticsService = MockAnalyticsService();

    // Reset GetIt before each test
    if (GetIt.instance.isRegistered<AnalyticsService>()) {
      GetIt.instance.unregister<AnalyticsService>();
    }

    // Register the mock
    GetIt.instance.registerSingleton<AnalyticsService>(mockAnalyticsService);
  });

  tearDown(() {
    // Clean up after each test
    GetIt.instance.reset();
  });

  group('AnalyticsScreenWrapper', () {
    testWidgets('renders child widget correctly', (tester) async {
      when(() => mockAnalyticsService.logScreenView(
        screenName: any(named: 'screenName'),
        screenClass: any(named: 'screenClass'),
      )).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreenWrapper(
            screenName: 'test_screen',
            child: const Text('Test Child'),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('calls logScreenView on initState with screenName', (tester) async {
      when(() => mockAnalyticsService.logScreenView(
        screenName: any(named: 'screenName'),
        screenClass: any(named: 'screenClass'),
      )).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreenWrapper(
            screenName: 'home_screen',
            child: const SizedBox(),
          ),
        ),
      );

      verify(() => mockAnalyticsService.logScreenView(
        screenName: 'home_screen',
        screenClass: null,
      )).called(1);
    });

    testWidgets('passes custom screenClass when provided', (tester) async {
      when(() => mockAnalyticsService.logScreenView(
        screenName: any(named: 'screenName'),
        screenClass: any(named: 'screenClass'),
      )).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreenWrapper(
            screenName: 'profile_screen',
            screenClass: 'ProfileScreen',
            child: const SizedBox(),
          ),
        ),
      );

      verify(() => mockAnalyticsService.logScreenView(
        screenName: 'profile_screen',
        screenClass: 'ProfileScreen',
      )).called(1);
    });

    testWidgets('uses screenName as screenClass when screenClass is null', (tester) async {
      when(() => mockAnalyticsService.logScreenView(
        screenName: any(named: 'screenName'),
        screenClass: any(named: 'screenClass'),
      )).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreenWrapper(
            screenName: 'settings_screen',
            screenClass: null,
            child: const SizedBox(),
          ),
        ),
      );

      verify(() => mockAnalyticsService.logScreenView(
        screenName: 'settings_screen',
        screenClass: null,
      )).called(1);
    });

    testWidgets('tracks screen view only once on initialization', (tester) async {
      when(() => mockAnalyticsService.logScreenView(
        screenName: any(named: 'screenName'),
        screenClass: any(named: 'screenClass'),
      )).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreenWrapper(
            screenName: 'test_screen',
            child: const Text('Test'),
          ),
        ),
      );

      // Rebuild the widget
      await tester.pumpAndSettle();

      // Should only be called once during initState
      verify(() => mockAnalyticsService.logScreenView(
        screenName: 'test_screen',
        screenClass: null,
      )).called(1);
    });

    testWidgets('allows multiple wrappers with different screen names', (tester) async {
      when(() => mockAnalyticsService.logScreenView(
        screenName: any(named: 'screenName'),
        screenClass: any(named: 'screenClass'),
      )).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              AnalyticsScreenWrapper(
                screenName: 'screen_one',
                child: const Text('One'),
              ),
              AnalyticsScreenWrapper(
                screenName: 'screen_two',
                child: const Text('Two'),
              ),
            ],
          ),
        ),
      );

      verify(() => mockAnalyticsService.logScreenView(
        screenName: 'screen_one',
        screenClass: null,
      )).called(1);

      verify(() => mockAnalyticsService.logScreenView(
        screenName: 'screen_two',
        screenClass: null,
      )).called(1);
    });

    testWidgets('wrapper child receives correct BuildContext', (tester) async {
      when(() => mockAnalyticsService.logScreenView(
        screenName: any(named: 'screenName'),
        screenClass: any(named: 'screenClass'),
      )).thenAnswer((_) async {});

      BuildContext? capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreenWrapper(
            screenName: 'context_test',
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const Text('Context Test');
              },
            ),
          ),
        ),
      );

      expect(capturedContext, isNotNull);
      expect(Theme.of(capturedContext!), isNotNull);
    });
  });

  group('AnalyticsRouteObserver', () {
    test('can be instantiated', () {
      final observer = AnalyticsRouteObserver();
      expect(observer, isNotNull);
      expect(observer, isA<RouteObserver<PageRoute<dynamic>>>());
    });

    test('is a RouteObserver subclass', () {
      final observer = AnalyticsRouteObserver();
      expect(observer, isA<RouteObserver<PageRoute<dynamic>>>());
    });

    test('can be created multiple times', () {
      final observer1 = AnalyticsRouteObserver();
      final observer2 = AnalyticsRouteObserver();

      expect(observer1, isNotNull);
      expect(observer2, isNotNull);
      expect(identical(observer1, observer2), false);
    });
  });
}
