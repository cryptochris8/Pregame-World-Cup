import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/domain/services/payment_models.dart';
import 'package:pregame_world_cup/features/worldcup/domain/services/world_cup_payment_service.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/match_stats_widget.dart';

class MockWorldCupPaymentService extends Mock implements WorldCupPaymentService {}

void main() {
  late MockWorldCupPaymentService mockPaymentService;

  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().contains('A RenderFlex overflowed by'),
          );
      if (isOverflowError) {
        // Ignore overflow errors
      } else {
        FlutterError.presentError(details);
      }
    };

    // Register mock service
    mockPaymentService = MockWorldCupPaymentService();
    GetIt.I.registerSingleton<WorldCupPaymentService>(mockPaymentService);

    // Default: user does not have access
    when(() => mockPaymentService.getCachedFanPassStatus()).thenAnswer(
      (_) async => FanPassStatus(
        hasPass: false,
        passType: FanPassType.free,
        features: const {},
      ),
    );
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('MatchStatsWidget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchStatsWidget(stageColor: Colors.blue),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MatchStatsWidget), findsOneWidget);
    });

    testWidgets('shows locked state when user does not have access', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchStatsWidget(stageColor: Colors.blue),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show upgrade prompt
      expect(find.textContaining('Upgrade'), findsWidgets);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('shows stats content when user has access', (tester) async {
      // Mock user has access
      when(() => mockPaymentService.getCachedFanPassStatus()).thenAnswer(
        (_) async => FanPassStatus(
          hasPass: true,
          passType: FanPassType.fanPass,
          features: const {'advancedStats': true},
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchStatsWidget(stageColor: Colors.green),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show stats content
      expect(find.text('Match Statistics'), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    });

    testWidgets('displays all stat labels when unlocked', (tester) async {
      // Mock user has access
      when(() => mockPaymentService.getCachedFanPassStatus()).thenAnswer(
        (_) async => FanPassStatus(
          hasPass: true,
          passType: FanPassType.fanPass,
          features: const {'advancedStats': true},
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchStatsWidget(stageColor: Colors.orange),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Possession'), findsOneWidget);
      expect(find.text('Shots'), findsOneWidget);
      expect(find.text('Shots on Target'), findsOneWidget);
      expect(find.text('Corners'), findsOneWidget);
      expect(find.text('Fouls'), findsOneWidget);
    });

    testWidgets('displays stat values when unlocked', (tester) async {
      // Mock user has access
      when(() => mockPaymentService.getCachedFanPassStatus()).thenAnswer(
        (_) async => FanPassStatus(
          hasPass: true,
          passType: FanPassType.fanPass,
          features: const {'advancedStats': true},
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchStatsWidget(stageColor: Colors.purple),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for hardcoded stat values
      expect(find.text('55'), findsOneWidget); // Possession home
      expect(find.text('45'), findsOneWidget); // Possession away
      expect(find.text('12'), findsOneWidget); // Shots home
      expect(find.text('8'), findsOneWidget); // Shots away
      expect(find.text('5'), findsOneWidget); // Shots on target home
      expect(find.text('3'), findsOneWidget); // Shots on target away
      expect(find.text('6'), findsOneWidget); // Corners home
      expect(find.text('4'), findsOneWidget); // Corners away
      expect(find.text('10'), findsOneWidget); // Fouls home
      expect(find.text('14'), findsOneWidget); // Fouls away
    });

    testWidgets('shows loading indicator initially', (tester) async {
      // Create a future that doesn't complete immediately
      when(() => mockPaymentService.getCachedFanPassStatus()).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 100),
          () => FanPassStatus(
            hasPass: false,
            passType: FanPassType.free,
            features: const {},
          ),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchStatsWidget(stageColor: Colors.red),
          ),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Loading should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays custom message for locked state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchStatsWidget(stageColor: Colors.teal),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Unlock detailed match statistics including possession, shots, corners, and more.'),
        findsOneWidget,
      );
    });

    testWidgets('uses provided stage color for stat bars', (tester) async {
      // Mock user has access
      when(() => mockPaymentService.getCachedFanPassStatus()).thenAnswer(
        (_) async => FanPassStatus(
          hasPass: true,
          passType: FanPassType.fanPass,
          features: const {'advancedStats': true},
        ),
      );

      const testColor = Colors.amber;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchStatsWidget(stageColor: testColor),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find all containers that should use the stage color
      final containers = tester.widgetList<Container>(find.byType(Container));

      // At least one container should have the stage color in its decoration
      final hasStageColor = containers.any((container) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          return decoration.color == testColor;
        }
        return false;
      });

      expect(hasStageColor, isTrue);
    });
  });
}
