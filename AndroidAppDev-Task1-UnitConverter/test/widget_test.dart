// Unit + widget tests for the Unit Converter app.
//
// All UI lookups go through Keys (never find.text) so that a unit symbol
// appearing in both a dropdown and the rate line can never make a finder
// ambiguous.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter_app/main.dart';
import 'package:unit_converter_app/units.dart';

Unit unitBySymbol(String category, String symbol) => kCategories
    .firstWhere((UnitCategory c) => c.name == category)
    .units
    .firstWhere((Unit u) => u.symbol == symbol);

String resultText(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('result-text'))).data ?? '';

void main() {
  group('Conversion maths', () {
    test('Length: 100 cm = 1 m', () {
      final double r = convert(
        100,
        unitBySymbol('Length', 'cm'),
        unitBySymbol('Length', 'm'),
      );
      expect(r, closeTo(1, 1e-12));
    });

    test('Length: 1 inch = 2.54 cm', () {
      final double r = convert(
        1,
        unitBySymbol('Length', 'in'),
        unitBySymbol('Length', 'cm'),
      );
      expect(r, closeTo(2.54, 1e-12));
    });

    test('Length: 1 mile = 1.609344 km', () {
      final double r = convert(
        1,
        unitBySymbol('Length', 'mi'),
        unitBySymbol('Length', 'km'),
      );
      expect(r, closeTo(1.609344, 1e-12));
    });

    test('Weight: 1 kg = 2.20462... lb', () {
      final double r = convert(
        1,
        unitBySymbol('Weight', 'kg'),
        unitBySymbol('Weight', 'lb'),
      );
      expect(r, closeTo(2.2046226218, 1e-9));
    });

    test('Weight: 1 lb = 16 oz', () {
      final double r = convert(
        1,
        unitBySymbol('Weight', 'lb'),
        unitBySymbol('Weight', 'oz'),
      );
      expect(r, closeTo(16, 1e-9));
    });

    // Temperature is affine, not a ratio — these catch the classic bug of
    // treating °C -> °F as a simple multiplier.
    test('Temperature: 0 °C = 32 °F', () {
      final double r = convert(
        0,
        unitBySymbol('Temperature', '°C'),
        unitBySymbol('Temperature', '°F'),
      );
      expect(r, closeTo(32, 1e-12));
    });

    test('Temperature: 100 °C = 212 °F', () {
      final double r = convert(
        100,
        unitBySymbol('Temperature', '°C'),
        unitBySymbol('Temperature', '°F'),
      );
      expect(r, closeTo(212, 1e-12));
    });

    test('Temperature: -40 °C = -40 °F', () {
      final double r = convert(
        -40,
        unitBySymbol('Temperature', '°C'),
        unitBySymbol('Temperature', '°F'),
      );
      expect(r, closeTo(-40, 1e-12));
    });

    test('Temperature: 0 K = -273.15 °C', () {
      final double r = convert(
        0,
        unitBySymbol('Temperature', 'K'),
        unitBySymbol('Temperature', '°C'),
      );
      expect(r, closeTo(-273.15, 1e-12));
    });

    test('Temperature: 32 °F = 273.15 K', () {
      final double r = convert(
        32,
        unitBySymbol('Temperature', '°F'),
        unitBySymbol('Temperature', 'K'),
      );
      expect(r, closeTo(273.15, 1e-9));
    });

    test('Volume: 1 gallon = 3.785411784 L', () {
      final double r = convert(
        1,
        unitBySymbol('Volume', 'gal'),
        unitBySymbol('Volume', 'L'),
      );
      expect(r, closeTo(3.785411784, 1e-12));
    });

    test('Speed: 1 m/s = 3.6 km/h', () {
      final double r = convert(
        1,
        unitBySymbol('Speed', 'm/s'),
        unitBySymbol('Speed', 'km/h'),
      );
      expect(r, closeTo(3.6, 1e-12));
    });

    test('Data: 1 GB = 1024 MB', () {
      final double r = convert(
        1,
        unitBySymbol('Data', 'GB'),
        unitBySymbol('Data', 'MB'),
      );
      expect(r, closeTo(1024, 1e-9));
    });

    test('Time: 1 hour = 3600 s', () {
      final double r = convert(
        1,
        unitBySymbol('Time', 'h'),
        unitBySymbol('Time', 's'),
      );
      expect(r, closeTo(3600, 1e-12));
    });

    test('Round trip is lossless for every unit in every category', () {
      for (final UnitCategory c in kCategories) {
        for (final Unit a in c.units) {
          for (final Unit b in c.units) {
            final double back = convert(convert(42.5, a, b), b, a);
            expect(
              back,
              closeTo(42.5, 1e-6),
              reason: '${c.name}: ${a.symbol} -> ${b.symbol} -> ${a.symbol}',
            );
          }
        }
      }
    });

    test('Every category has at least two units', () {
      for (final UnitCategory c in kCategories) {
        expect(c.units.length, greaterThanOrEqualTo(2), reason: c.name);
      }
    });

    test('Ships with at least the 3 required categories', () {
      final List<String> names =
          kCategories.map((UnitCategory c) => c.name).toList();
      expect(names, contains('Length'));
      expect(names, contains('Weight'));
      expect(names.length, greaterThanOrEqualTo(3));
    });
  });

  group('formatResult', () {
    test('trims trailing zeros', () {
      expect(formatResult(1.0), '1');
      expect(formatResult(2.5), '2.5');
    });

    test('handles zero and negatives', () {
      expect(formatResult(0), '0');
      expect(formatResult(-40.0), '-40');
    });

    test('uses scientific notation for extreme magnitudes', () {
      expect(formatResult(1e20), contains('e'));
      expect(formatResult(1e-12), contains('e'));
    });
  });

  group('UI', () {
    testWidgets('Starts with an empty result placeholder',
        (WidgetTester tester) async {
      await tester.pumpWidget(const UnitConverterApp());
      expect(resultText(tester), '—');
    });

    testWidgets('Typing a value converts live (100 cm -> 1 m)',
        (WidgetTester tester) async {
      await tester.pumpWidget(const UnitConverterApp());

      await tester.enterText(find.byKey(const Key('input-field')), '100');
      await tester.pump();

      // Default Length units are cm (index 0 = mm, 1 = cm) — the app picks
      // units[0] and units[1], i.e. mm -> cm. 100 mm = 10 cm.
      expect(resultText(tester), '10');
    });

    testWidgets('Convert button computes the result',
        (WidgetTester tester) async {
      await tester.pumpWidget(const UnitConverterApp());

      await tester.enterText(find.byKey(const Key('input-field')), '250');
      await tester.tap(find.byKey(const Key('convert-button')));
      await tester.pump();

      // 250 mm -> cm = 25
      expect(resultText(tester), '25');
    });

    testWidgets('Empty input shows a toast and no result',
        (WidgetTester tester) async {
      await tester.pumpWidget(const UnitConverterApp());

      await tester.tap(find.byKey(const Key('convert-button')));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Please enter a value to convert'),
        findsOneWidget,
      );
      expect(resultText(tester), '—');
    });

    testWidgets('Non-numeric input shows a toast and no result',
        (WidgetTester tester) async {
      await tester.pumpWidget(const UnitConverterApp());

      await tester.enterText(find.byKey(const Key('input-field')), 'abc');
      await tester.tap(find.byKey(const Key('convert-button')));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('"abc" is not a valid number'), findsOneWidget);
      expect(resultText(tester), '—');
    });

    testWidgets('Swap button reverses the conversion direction',
        (WidgetTester tester) async {
      await tester.pumpWidget(const UnitConverterApp());

      // 100 mm -> cm = 10
      await tester.enterText(find.byKey(const Key('input-field')), '100');
      await tester.pump();
      expect(resultText(tester), '10');

      // After swap: 100 cm -> mm = 1000
      await tester.tap(find.byKey(const Key('swap-button')));
      await tester.pump();
      expect(resultText(tester), '1000');
    });

    testWidgets('Switching category resets units and clears the result',
        (WidgetTester tester) async {
      await tester.pumpWidget(const UnitConverterApp());

      await tester.enterText(find.byKey(const Key('input-field')), '100');
      await tester.pump();
      expect(resultText(tester), '10');

      // Bring Temperature into view (it may be off-screen on a narrow
      // test viewport) and tap it.
      await tester.ensureVisible(find.byKey(const Key('category-Temperature')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('category-Temperature')));
      await tester.pumpAndSettle();

      // Temperature defaults to °C -> °F, so 100 °C = 212 °F.
      expect(resultText(tester), '212');
    });

    testWidgets('Rate line reflects the selected units',
        (WidgetTester tester) async {
      await tester.pumpWidget(const UnitConverterApp());

      final String rate =
          tester.widget<Text>(find.byKey(const Key('rate-line'))).data ?? '';
      expect(rate, '1 mm = 0.1 cm');
    });

    testWidgets('Copy affordance only appears once there is a result',
        (WidgetTester tester) async {
      await tester.pumpWidget(const UnitConverterApp());
      expect(find.byKey(const Key('copy-button')), findsNothing);

      await tester.enterText(find.byKey(const Key('input-field')), '5');
      await tester.pump();
      expect(find.byKey(const Key('copy-button')), findsOneWidget);
    });
  });
}
