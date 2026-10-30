// Unit + category model and the full conversion table.
//
// Every unit declares how to convert TO and FROM its category's base unit.
// Most units are a simple ratio (Unit.linear). Temperature is affine
// (offset + scale), which is why the model uses function pairs rather than
// a single multiplier — Celsius -> Fahrenheit is not a ratio.

import 'package:flutter/material.dart';

class Unit {
  final String name;
  final String symbol;
  final double Function(double) toBase;
  final double Function(double) fromBase;

  const Unit({
    required this.name,
    required this.symbol,
    required this.toBase,
    required this.fromBase,
  });

  /// A unit that is a fixed ratio of the base unit.
  /// e.g. 1 km = 1000 m  ->  Unit.linear('Kilometre', 'km', 1000)
  factory Unit.linear(String name, String symbol, double factor) => Unit(
        name: name,
        symbol: symbol,
        toBase: (double v) => v * factor,
        fromBase: (double v) => v / factor,
      );

  @override
  String toString() => '$name ($symbol)';
}

class UnitCategory {
  final String name;
  final IconData icon;
  final List<Unit> units;

  const UnitCategory({
    required this.name,
    required this.icon,
    required this.units,
  });
}

/// Convert [value] from [from] to [to] by routing through the base unit.
double convert(double value, Unit from, Unit to) =>
    to.fromBase(from.toBase(value));

// ---------------------------------------------------------------------------
//  Conversion table
// ---------------------------------------------------------------------------

final List<UnitCategory> kCategories = <UnitCategory>[
  // --- Length (base: metre) ------------------------------------------------
  UnitCategory(
    name: 'Length',
    icon: Icons.straighten,
    units: <Unit>[
      Unit.linear('Millimetre', 'mm', 0.001),
      Unit.linear('Centimetre', 'cm', 0.01),
      Unit.linear('Metre', 'm', 1),
      Unit.linear('Kilometre', 'km', 1000),
      Unit.linear('Inch', 'in', 0.0254),
      Unit.linear('Foot', 'ft', 0.3048),
      Unit.linear('Yard', 'yd', 0.9144),
      Unit.linear('Mile', 'mi', 1609.344),
      Unit.linear('Nautical mile', 'nmi', 1852),
    ],
  ),

  // --- Weight / mass (base: kilogram) --------------------------------------
  UnitCategory(
    name: 'Weight',
    icon: Icons.scale,
    units: <Unit>[
      Unit.linear('Milligram', 'mg', 1e-6),
      Unit.linear('Gram', 'g', 0.001),
      Unit.linear('Kilogram', 'kg', 1),
      Unit.linear('Tonne', 't', 1000),
      Unit.linear('Ounce', 'oz', 0.028349523125),
      Unit.linear('Pound', 'lb', 0.45359237),
      Unit.linear('Stone', 'st', 6.35029318),
    ],
  ),

  // --- Temperature (base: Celsius) — affine, not a ratio --------------------
  UnitCategory(
    name: 'Temperature',
    icon: Icons.thermostat,
    units: <Unit>[
      Unit(
        name: 'Celsius',
        symbol: '°C',
        toBase: (double v) => v,
        fromBase: (double v) => v,
      ),
      Unit(
        name: 'Fahrenheit',
        symbol: '°F',
        toBase: (double v) => (v - 32) * 5 / 9,
        fromBase: (double v) => v * 9 / 5 + 32,
      ),
      Unit(
        name: 'Kelvin',
        symbol: 'K',
        toBase: (double v) => v - 273.15,
        fromBase: (double v) => v + 273.15,
      ),
    ],
  ),

  // --- Volume (base: litre) -------------------------------------------------
  UnitCategory(
    name: 'Volume',
    icon: Icons.local_drink,
    units: <Unit>[
      Unit.linear('Millilitre', 'mL', 0.001),
      Unit.linear('Litre', 'L', 1),
      Unit.linear('Cubic metre', 'm³', 1000),
      Unit.linear('Teaspoon (US)', 'tsp', 0.00492892159375),
      Unit.linear('Tablespoon (US)', 'tbsp', 0.01478676478125),
      Unit.linear('Fluid ounce (US)', 'fl oz', 0.0295735295625),
      Unit.linear('Cup (US)', 'cup', 0.2365882365),
      Unit.linear('Pint (US)', 'pt', 0.473176473),
      Unit.linear('Quart (US)', 'qt', 0.946352946),
      Unit.linear('Gallon (US)', 'gal', 3.785411784),
    ],
  ),

  // --- Speed (base: metre per second) --------------------------------------
  UnitCategory(
    name: 'Speed',
    icon: Icons.speed,
    units: <Unit>[
      Unit.linear('Metre / second', 'm/s', 1),
      Unit.linear('Kilometre / hour', 'km/h', 1 / 3.6),
      Unit.linear('Mile / hour', 'mph', 0.44704),
      Unit.linear('Foot / second', 'ft/s', 0.3048),
      Unit.linear('Knot', 'kn', 0.514444444444),
    ],
  ),

  // --- Area (base: square metre) -------------------------------------------
  UnitCategory(
    name: 'Area',
    icon: Icons.crop_square,
    units: <Unit>[
      Unit.linear('Square millimetre', 'mm²', 1e-6),
      Unit.linear('Square centimetre', 'cm²', 1e-4),
      Unit.linear('Square metre', 'm²', 1),
      Unit.linear('Hectare', 'ha', 10000),
      Unit.linear('Square kilometre', 'km²', 1e6),
      Unit.linear('Square inch', 'in²', 0.00064516),
      Unit.linear('Square foot', 'ft²', 0.09290304),
      Unit.linear('Acre', 'ac', 4046.8564224),
      Unit.linear('Square mile', 'mi²', 2589988.110336),
    ],
  ),

  // --- Digital storage (base: byte, binary prefixes) ------------------------
  UnitCategory(
    name: 'Data',
    icon: Icons.storage,
    units: <Unit>[
      Unit.linear('Bit', 'bit', 0.125),
      Unit.linear('Byte', 'B', 1),
      Unit.linear('Kilobyte', 'KB', 1024),
      Unit.linear('Megabyte', 'MB', 1048576),
      Unit.linear('Gigabyte', 'GB', 1073741824),
      Unit.linear('Terabyte', 'TB', 1099511627776),
    ],
  ),

  // --- Time (base: second) --------------------------------------------------
  UnitCategory(
    name: 'Time',
    icon: Icons.schedule,
    units: <Unit>[
      Unit.linear('Millisecond', 'ms', 0.001),
      Unit.linear('Second', 's', 1),
      Unit.linear('Minute', 'min', 60),
      Unit.linear('Hour', 'h', 3600),
      Unit.linear('Day', 'd', 86400),
      Unit.linear('Week', 'wk', 604800),
      Unit.linear('Year (365 d)', 'yr', 31536000),
    ],
  ),
];

// ---------------------------------------------------------------------------
//  Number formatting
// ---------------------------------------------------------------------------

/// Format a conversion result for display: trims trailing zeros, falls back
/// to scientific notation for very large / very small magnitudes.
String formatResult(double v) {
  if (v.isNaN || v.isInfinite) return '—';
  if (v == 0) return '0';

  final double abs = v.abs();

  if (abs < 1e-9 || abs >= 1e15) {
    String s = v.toStringAsExponential(6);
    // Trim trailing zeros in the mantissa: 1.230000e+5 -> 1.23e+5
    s = s.replaceFirstMapped(
      RegExp(r'^(-?\d)\.(\d*?)0+e'),
      (Match m) => '${m[1]}.${m[2]}e',
    );
    s = s.replaceFirst(RegExp(r'\.e'), 'e');
    return s;
  }

  if (v == v.roundToDouble()) {
    return v.toInt().toString();
  }

  String s = v.toStringAsPrecision(10);
  if (s.contains('e')) return s;
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
  }
  return s;
}
