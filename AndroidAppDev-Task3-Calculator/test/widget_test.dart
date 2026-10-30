// Widget + unit tests for the Calculator app.
//
// NOTE on finders: `find.text('0')` is ambiguous in this app — it matches
// both the big display AND the keypad button labelled "0". Same for any
// single-digit string. `displayText()` below scopes the match to the
// primary display only (fontSize 72), which is unique in the tree.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

/// Matches ONLY the big primary display, never a keypad button.
Finder displayText(String text) => find.byWidgetPredicate(
      (Widget w) => w is Text && w.data == text && w.style?.fontSize == 72,
      description: 'display showing "$text"',
    );

/// Matches ONLY a keypad button label, never the display.
Finder keyButton(String label) => find.byWidgetPredicate(
      (Widget w) =>
          w is Text && w.data == label && (w.style?.fontSize ?? 0) < 40,
      description: 'keypad button "$label"',
    );

Future<void> tapKey(WidgetTester tester, String label) async {
  await tester.tap(keyButton(label));
  await tester.pump();
}

void main() {
  group('Expression engine (pure Dart)', () {
    test('simple addition', () {
      expect(evaluateExpression('2+3'), 5);
    });

    test('operator precedence: × before +', () {
      expect(evaluateExpression('2+3×4'), 14);
    });

    test('operator precedence: ÷ before −', () {
      expect(evaluateExpression('10-8÷2'), 6);
    });

    test('division by zero throws', () {
      expect(() => evaluateExpression('5÷0'), throwsA(isA<Exception>()));
    });

    test('decimal arithmetic', () {
      expect(evaluateExpression('0.1+0.2'), closeTo(0.3, 1e-9));
    });

    test('unary minus', () {
      expect(evaluateExpression('-5+3'), -2);
      expect(evaluateExpression('3×-2'), -6);
    });

    test('formatNumber trims trailing zeros', () {
      expect(formatNumber(5.0), '5');
      expect(formatNumber(5.5), '5.5');
      expect(formatNumber(2 / 3), startsWith('0.6666666'));
    });
  });

  group('UI', () {
    testWidgets('Shows initial 0 display', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());
      expect(displayText('0'), findsOneWidget);
    });

    testWidgets('Typing digits and equals produces result',
        (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await tapKey(tester, '7');
      await tapKey(tester, '+');
      await tapKey(tester, '3');
      await tapKey(tester, '=');

      expect(displayText('10'), findsOneWidget);
    });

    testWidgets('Divide by zero shows Error', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await tapKey(tester, '5');
      await tapKey(tester, '÷');
      await tapKey(tester, '0');
      await tapKey(tester, '=');

      expect(displayText('Error'), findsOneWidget);
    });

    testWidgets('C clears everything', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await tapKey(tester, '9');
      await tapKey(tester, 'C');

      expect(displayText('0'), findsOneWidget);
    });

    testWidgets('Backspace deletes last char', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await tapKey(tester, '1');
      await tapKey(tester, '2');
      await tapKey(tester, '3');
      await tapKey(tester, '⌫');

      expect(displayText('12'), findsOneWidget);
    });

    testWidgets('Precedence respected end-to-end: 2 + 3 × 4 = 14',
        (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await tapKey(tester, '2');
      await tapKey(tester, '+');
      await tapKey(tester, '3');
      await tapKey(tester, '×');
      await tapKey(tester, '4');
      await tapKey(tester, '=');

      expect(displayText('14'), findsOneWidget);
    });

    testWidgets('Error state recovers on next digit',
        (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await tapKey(tester, '8');
      await tapKey(tester, '÷');
      await tapKey(tester, '0');
      await tapKey(tester, '=');
      expect(displayText('Error'), findsOneWidget);

      await tapKey(tester, '6');
      expect(displayText('6'), findsOneWidget);
    });
  });

  // Smoke test: rapid repeated taps should not throw.
  testWidgets('Rapid repeated digit taps do not crash',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());
    for (int i = 0; i < 50; i++) {
      await tester.tap(keyButton('5'));
    }
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
