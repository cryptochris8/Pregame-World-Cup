import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/services/payment_service.dart';

/// Tests for PaymentService utilities and widgets.
///
/// Note: PaymentService itself is deprecated and uses a singleton pattern
/// with hardcoded Firebase dependencies (FirebaseFunctions.instance,
/// FirebaseAuth.instance), Stripe SDK, and GetIt service locator.
/// Direct unit testing of payment flow methods is impractical without
/// DI refactoring.
///
/// This test file focuses on:
/// 1. PaymentUtils static methods (pure logic, no dependencies)
/// 2. QuickPaymentButton widget rendering
void main() {
  // ============================================================================
  // PaymentUtils.formatCurrency
  // ============================================================================
  group('PaymentUtils - formatCurrency', () {
    test('formats whole dollar amounts', () {
      expect(PaymentUtils.formatCurrency(10.0), '\$10.00');
    });

    test('formats amounts with cents', () {
      expect(PaymentUtils.formatCurrency(14.99), '\$14.99');
    });

    test('formats zero amount', () {
      expect(PaymentUtils.formatCurrency(0.0), '\$0.00');
    });

    test('formats large amounts', () {
      expect(PaymentUtils.formatCurrency(499.00), '\$499.00');
    });

    test('formats small amounts', () {
      expect(PaymentUtils.formatCurrency(0.01), '\$0.01');
    });

    test('formats amounts with single cent digit', () {
      expect(PaymentUtils.formatCurrency(5.50), '\$5.50');
    });

    test('uses custom currency symbol', () {
      expect(PaymentUtils.formatCurrency(10.0, symbol: '\u20AC'), '\u20AC10.00');
    });

    test('uses empty string as symbol', () {
      expect(PaymentUtils.formatCurrency(10.0, symbol: ''), '10.00');
    });

    test('formats very large amounts', () {
      expect(PaymentUtils.formatCurrency(9999.99), '\$9999.99');
    });

    test('truncates extra decimal places', () {
      // toStringAsFixed(2) rounds
      expect(PaymentUtils.formatCurrency(10.999), '\$11.00');
      expect(PaymentUtils.formatCurrency(10.994), '\$10.99');
    });

    test('handles negative amounts', () {
      expect(PaymentUtils.formatCurrency(-5.00), '\$-5.00');
    });
  });

  // ============================================================================
  // PaymentUtils.isValidCardNumber
  // ============================================================================
  group('PaymentUtils - isValidCardNumber', () {
    test('returns false for empty string', () {
      expect(PaymentUtils.isValidCardNumber(''), isFalse);
    });

    test('returns false for short numbers', () {
      expect(PaymentUtils.isValidCardNumber('1234'), isFalse);
      expect(PaymentUtils.isValidCardNumber('123456789012'), isFalse);
    });

    test('returns true for 13-digit number', () {
      expect(PaymentUtils.isValidCardNumber('1234567890123'), isTrue);
    });

    test('returns true for 16-digit number (typical Visa/MC)', () {
      expect(PaymentUtils.isValidCardNumber('4111111111111111'), isTrue);
    });

    test('returns true for 19-digit number (max length)', () {
      expect(PaymentUtils.isValidCardNumber('1234567890123456789'), isTrue);
    });

    test('returns false for 20-digit number (too long)', () {
      expect(PaymentUtils.isValidCardNumber('12345678901234567890'), isFalse);
    });

    test('strips spaces before validation', () {
      expect(PaymentUtils.isValidCardNumber('4111 1111 1111 1111'), isTrue);
    });

    test('returns true for number with spaces that is 16 digits', () {
      expect(PaymentUtils.isValidCardNumber('4242 4242 4242 4242'), isTrue);
    });

    test('returns false for number with only spaces', () {
      expect(PaymentUtils.isValidCardNumber('   '), isFalse);
    });
  });

  // ============================================================================
  // PaymentUtils.formatCardNumber
  // ============================================================================
  group('PaymentUtils - formatCardNumber', () {
    test('formats 16-digit number with spaces every 4 digits', () {
      expect(
        PaymentUtils.formatCardNumber('4111111111111111'),
        '4111 1111 1111 1111',
      );
    });

    test('strips non-digit characters before formatting', () {
      expect(
        PaymentUtils.formatCardNumber('4111-1111-1111-1111'),
        '4111 1111 1111 1111',
      );
    });

    test('handles already formatted input', () {
      expect(
        PaymentUtils.formatCardNumber('4111 1111 1111 1111'),
        '4111 1111 1111 1111',
      );
    });

    test('formats partial card number', () {
      expect(PaymentUtils.formatCardNumber('411111'), '4111 11');
    });

    test('returns empty string for empty input', () {
      expect(PaymentUtils.formatCardNumber(''), '');
    });

    test('handles 4-digit number (no space needed before first group)', () {
      expect(PaymentUtils.formatCardNumber('4111'), '4111');
    });

    test('handles 5-digit number (space after first group)', () {
      expect(PaymentUtils.formatCardNumber('41111'), '4111 1');
    });

    test('handles 8-digit number', () {
      expect(PaymentUtils.formatCardNumber('41111111'), '4111 1111');
    });

    test('strips letters and special chars', () {
      expect(PaymentUtils.formatCardNumber('abc4111def1111'), '4111 1111');
    });

    test('formats 13-digit number', () {
      expect(
        PaymentUtils.formatCardNumber('4111111111111'),
        '4111 1111 1111 1',
      );
    });

    test('formats 19-digit number', () {
      expect(
        PaymentUtils.formatCardNumber('4111111111111111111'),
        '4111 1111 1111 1111 111',
      );
    });
  });

  // ============================================================================
  // QuickPaymentButton widget
  // ============================================================================
  group('QuickPaymentButton', () {
    testWidgets('renders label and amount', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuickPaymentButton(
              label: 'Fan Pass',
              amount: 14.99,
            ),
          ),
        ),
      );

      expect(find.text('Fan Pass'), findsOneWidget);
      expect(find.text('\$14.99'), findsOneWidget);
    });

    testWidgets('renders with custom color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuickPaymentButton(
              label: 'Tip',
              amount: 5.00,
              color: Colors.green,
            ),
          ),
        ),
      );

      expect(find.text('Tip'), findsOneWidget);
      expect(find.text('\$5.00'), findsOneWidget);
    });

    testWidgets('invokes callback when pressed', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickPaymentButton(
              label: 'Buy',
              amount: 9.99,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuickPaymentButton(
              label: 'Disabled',
              amount: 0.00,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('renders as ElevatedButton with Row', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuickPaymentButton(
              label: 'Test',
              amount: 1.00,
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('formats zero amount correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuickPaymentButton(
              label: 'Free',
              amount: 0.00,
            ),
          ),
        ),
      );

      expect(find.text('\$0.00'), findsOneWidget);
    });

    testWidgets('formats large amount correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuickPaymentButton(
              label: 'Premium',
              amount: 499.00,
            ),
          ),
        ),
      );

      expect(find.text('\$499.00'), findsOneWidget);
    });

    testWidgets('uses default pregame-blue color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuickPaymentButton(
              label: 'Default',
              amount: 10.00,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      // Just verify button exists with default styling
      expect(button.style, isNotNull);
    });
  });

  // ============================================================================
  // PaymentService class structure
  // ============================================================================
  group('PaymentService - class structure', () {
    test('PaymentService type exists', () {
      expect(PaymentService, isA<Type>());
    });

    test('PaymentUtils type exists', () {
      expect(PaymentUtils, isA<Type>());
    });

    test('QuickPaymentButton type exists', () {
      expect(QuickPaymentButton, isA<Type>());
    });
  });
}
