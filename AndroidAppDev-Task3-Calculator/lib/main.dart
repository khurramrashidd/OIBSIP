// Oasis Infobyte Android Internship — Task 3: Calculator
// Flutter implementation (VS Code friendly).
//
// Feature checklist mapped to the task sheet:
//  - Display TextView showing current input and result       ..............  ✓
//  - Number buttons (0–9) and decimal point                  ..............  ✓
//  - Operator buttons: + − × ÷                                ..............  ✓
//  - Equals (=) button to evaluate                           ..............  ✓
//  - Clear (C) button to reset                               ..............  ✓
//  - Backspace button to delete last character               ..............  ✓
//  - Division-by-zero error handling: shows "Error"          ..............  ✓
//  - Button grid using a responsive GridLayout equivalent     ..............  ✓
//  - No crashes on rapid/repeated button taps                ..............  ✓
//
// Extras beyond the sheet:
//  - Operator precedence (× / ÷ before + / −) via shunting-yard
//  - Percent (%) and sign toggle (+/−)
//  - Secondary expression display (shows the full expression)
//  - Haptic tick on every button press
//  - Animated button press feedback

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0B10),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
//  Pure Dart expression engine (shunting-yard + RPN eval)
// ---------------------------------------------------------------------------

class _CalcException implements Exception {
  final String message;
  _CalcException(this.message);
  @override
  String toString() => message;
}

enum _TokType { number, op, lparen, rparen }

class _Tok {
  final _TokType type;
  final String text;
  _Tok(this.type, this.text);
}

const Map<String, int> _precedence = <String, int>{
  '+': 1,
  '-': 1,
  '×': 2,
  '÷': 2,
};

List<_Tok> _tokenize(String expr) {
  final List<_Tok> out = <_Tok>[];
  int i = 0;
  while (i < expr.length) {
    final String c = expr[i];
    if (c == ' ') {
      i++;
      continue;
    }
    if ('0123456789.'.contains(c)) {
      final StringBuffer buf = StringBuffer();
      while (i < expr.length && '0123456789.'.contains(expr[i])) {
        buf.write(expr[i]);
        i++;
      }
      out.add(_Tok(_TokType.number, buf.toString()));
    } else if ('+-×÷'.contains(c)) {
      // Unary minus/plus: at the start, or after another operator or '('.
      if ((c == '-' || c == '+') &&
          (out.isEmpty ||
              out.last.type == _TokType.op ||
              out.last.type == _TokType.lparen)) {
        // Fold the sign into the next number.
        final StringBuffer buf = StringBuffer(c == '-' ? '-' : '');
        i++;
        while (i < expr.length && '0123456789.'.contains(expr[i])) {
          buf.write(expr[i]);
          i++;
        }
        if (buf.toString().isEmpty || buf.toString() == '-') {
          throw _CalcException('Error');
        }
        out.add(_Tok(_TokType.number, buf.toString()));
      } else {
        out.add(_Tok(_TokType.op, c));
        i++;
      }
    } else if (c == '(') {
      out.add(_Tok(_TokType.lparen, c));
      i++;
    } else if (c == ')') {
      out.add(_Tok(_TokType.rparen, c));
      i++;
    } else {
      throw _CalcException('Error');
    }
  }
  return out;
}

List<_Tok> _toRpn(List<_Tok> tokens) {
  final List<_Tok> output = <_Tok>[];
  final List<_Tok> stack = <_Tok>[];
  for (final _Tok t in tokens) {
    switch (t.type) {
      case _TokType.number:
        output.add(t);
        break;
      case _TokType.op:
        while (stack.isNotEmpty &&
            stack.last.type == _TokType.op &&
            (_precedence[stack.last.text] ?? 0) >=
                (_precedence[t.text] ?? 0)) {
          output.add(stack.removeLast());
        }
        stack.add(t);
        break;
      case _TokType.lparen:
        stack.add(t);
        break;
      case _TokType.rparen:
        while (stack.isNotEmpty && stack.last.type != _TokType.lparen) {
          output.add(stack.removeLast());
        }
        if (stack.isEmpty) throw _CalcException('Error');
        stack.removeLast();
        break;
    }
  }
  while (stack.isNotEmpty) {
    if (stack.last.type == _TokType.lparen) throw _CalcException('Error');
    output.add(stack.removeLast());
  }
  return output;
}

double _evalRpn(List<_Tok> rpn) {
  final List<double> st = <double>[];
  for (final _Tok t in rpn) {
    if (t.type == _TokType.number) {
      final double? v = double.tryParse(t.text);
      if (v == null) throw _CalcException('Error');
      st.add(v);
    } else if (t.type == _TokType.op) {
      if (st.length < 2) throw _CalcException('Error');
      final double b = st.removeLast();
      final double a = st.removeLast();
      switch (t.text) {
        case '+':
          st.add(a + b);
          break;
        case '-':
          st.add(a - b);
          break;
        case '×':
          st.add(a * b);
          break;
        case '÷':
          if (b == 0) throw _CalcException('Error');
          st.add(a / b);
          break;
      }
    }
  }
  if (st.length != 1) throw _CalcException('Error');
  return st.single;
}

double evaluateExpression(String expr) =>
    _evalRpn(_toRpn(_tokenize(expr)));

String formatNumber(double v) {
  if (v.isNaN || v.isInfinite) throw _CalcException('Error');
  if (v == v.truncateToDouble() && v.abs() < 1e15) {
    return v.toInt().toString();
  }
  // Up to 10 significant digits, trim trailing zeros.
  String s = v.toStringAsPrecision(10);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return s;
}

// ---------------------------------------------------------------------------
//  UI
// ---------------------------------------------------------------------------

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _secondary = '';
  bool _errored = false;
  bool _justEvaluated = false;

  bool get _isOperator {
    if (_expression.isEmpty) return false;
    return '+-×÷'.contains(_expression[_expression.length - 1]);
  }

  bool _endsWithDigit(String s) {
    if (s.isEmpty) return false;
    return '0123456789'.contains(s[s.length - 1]);
  }

  String _currentNumberTail() {
    final RegExpMatch? m = RegExp(r'[-+]?\d*\.?\d*$').firstMatch(_expression);
    return m?.group(0) ?? '';
  }

  void _onDigit(String d) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_errored) _reset();
      if (_justEvaluated) {
        _expression = '';
        _secondary = '';
        _justEvaluated = false;
      }
      // Prevent leading zeros like 00007
      final String tail = _currentNumberTail();
      if (d == '0' && tail == '0') return;
      if (tail == '0' && d != '.') {
        _expression = _expression.substring(0, _expression.length - 1);
      }
      _expression += d;
    });
  }

  void _onDot() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_errored) _reset();
      if (_justEvaluated) {
        _expression = '';
        _secondary = '';
        _justEvaluated = false;
      }
      final String tail = _currentNumberTail();
      if (tail.contains('.')) return; // one dot per number
      if (tail.isEmpty || !_endsWithDigit(tail)) {
        _expression += '0';
      }
      _expression += '.';
    });
  }

  void _onOperator(String op) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_errored) _reset();
      _justEvaluated = false;
      if (_expression.isEmpty) {
        if (op == '-') {
          _expression = '-';
        }
        return;
      }
      if (_isOperator) {
        // Replace trailing operator rather than stacking two.
        _expression =
            _expression.substring(0, _expression.length - 1) + op;
      } else {
        _expression += op;
      }
    });
  }

  void _onEquals() {
    HapticFeedback.mediumImpact();
    if (_expression.isEmpty) return;
    setState(() {
      try {
        String expr = _expression;
        // If user hit = with a trailing operator, drop it.
        if ('+-×÷'.contains(expr[expr.length - 1])) {
          expr = expr.substring(0, expr.length - 1);
        }
        if (expr.isEmpty) return;
        final double result = evaluateExpression(expr);
        final String formatted = formatNumber(result);
        _secondary = '$expr =';
        _expression = formatted;
        _justEvaluated = true;
        _errored = false;
      } on _CalcException {
        _errored = true;
        _secondary = _expression;
        _expression = 'Error';
      } catch (_) {
        _errored = true;
        _secondary = _expression;
        _expression = 'Error';
      }
    });
  }

  void _onClear() {
    HapticFeedback.mediumImpact();
    setState(_reset);
  }

  void _reset() {
    _expression = '';
    _secondary = '';
    _errored = false;
    _justEvaluated = false;
  }

  void _onBackspace() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_errored || _justEvaluated) {
        _reset();
        return;
      }
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    });
  }

  void _onToggleSign() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_errored) return;
      // Toggle the sign of the current number tail.
      final RegExpMatch? m =
          RegExp(r'(-?\d*\.?\d+)$').firstMatch(_expression);
      if (m == null) {
        if (_expression.isEmpty) _expression = '-';
        return;
      }
      final String tail = m.group(0)!;
      final int start = m.start;
      final String head = _expression.substring(0, start);
      final String toggled =
          tail.startsWith('-') ? tail.substring(1) : '-$tail';
      // If there's a preceding operator and we added a leading '-', keep it tidy.
      _expression = head + toggled;
      _justEvaluated = false;
    });
  }

  void _onPercent() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_errored) return;
      final RegExpMatch? m =
          RegExp(r'(-?\d*\.?\d+)$').firstMatch(_expression);
      if (m == null) return;
      final String tail = m.group(0)!;
      final double? v = double.tryParse(tail);
      if (v == null) return;
      final String replaced = formatNumber(v / 100);
      _expression =
          _expression.substring(0, m.start) + replaced;
      _justEvaluated = false;
    });
  }

  String get _display =>
      _expression.isEmpty ? '0' : _expression;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculator',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Display area
            Expanded(
              flex: 3,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    // Secondary (expression history)
                    SizedBox(
                      height: 28,
                      child: FittedBox(
                        alignment: Alignment.centerRight,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _secondary,
                          style: TextStyle(
                            color:
                                Colors.white.withValues(alpha: 0.45),
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Primary display
                    FittedBox(
                      alignment: Alignment.centerRight,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _display,
                        style: TextStyle(
                          color: _errored
                              ? const Color(0xFFEF4444)
                              : Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Button grid
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: _buildGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5 rows × 4 cols — equivalent to a GridLayout with 4 columns.
  Widget _buildGrid() {
    // Visual tokens
    const Color funcBg = Color(0xFF2A2A33); // C, +/-, %
    const Color numBg = Color(0xFF1C1C24);  // digits + dot + ⌫
    const Color opBg = Color(0xFF4F46E5);   // + − × ÷
    const Color eqBg = Color(0xFF16A34A);   // =

    final List<List<_Btn>> rows = <List<_Btn>>[
      <_Btn>[
        _Btn('C', funcBg, onTap: _onClear, kind: _BtnKind.func),
        _Btn('+/−', funcBg, onTap: _onToggleSign, kind: _BtnKind.func),
        _Btn('%', funcBg, onTap: _onPercent, kind: _BtnKind.func),
        _Btn('÷', opBg, onTap: () => _onOperator('÷'), kind: _BtnKind.op),
      ],
      <_Btn>[
        _Btn('7', numBg, onTap: () => _onDigit('7')),
        _Btn('8', numBg, onTap: () => _onDigit('8')),
        _Btn('9', numBg, onTap: () => _onDigit('9')),
        _Btn('×', opBg, onTap: () => _onOperator('×'), kind: _BtnKind.op),
      ],
      <_Btn>[
        _Btn('4', numBg, onTap: () => _onDigit('4')),
        _Btn('5', numBg, onTap: () => _onDigit('5')),
        _Btn('6', numBg, onTap: () => _onDigit('6')),
        _Btn('−', opBg, onTap: () => _onOperator('-'), kind: _BtnKind.op),
      ],
      <_Btn>[
        _Btn('1', numBg, onTap: () => _onDigit('1')),
        _Btn('2', numBg, onTap: () => _onDigit('2')),
        _Btn('3', numBg, onTap: () => _onDigit('3')),
        _Btn('+', opBg, onTap: () => _onOperator('+'), kind: _BtnKind.op),
      ],
      <_Btn>[
        _Btn('0', numBg, onTap: () => _onDigit('0')),
        _Btn('.', numBg, onTap: _onDot),
        _Btn('⌫', numBg, onTap: _onBackspace),
        _Btn('=', eqBg, onTap: _onEquals, kind: _BtnKind.equals),
      ],
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        const double gap = 10;
        const int cols = 4;
        final int rowsCount = rows.length;
        final double w =
            (c.maxWidth - gap * (cols - 1)) / cols;
        final double h =
            (c.maxHeight - gap * (rowsCount - 1)) / rowsCount;
        final double side = w < h ? w : h;

        return Center(
          child: SizedBox(
            width: side * cols + gap * (cols - 1),
            height: side * rowsCount + gap * (rowsCount - 1),
            child: Column(
              children: <Widget>[
                for (int r = 0; r < rows.length; r++) ...<Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        for (int ci = 0; ci < rows[r].length; ci++) ...<Widget>[
                          Expanded(child: _CalcButton(btn: rows[r][ci])),
                          if (ci != rows[r].length - 1)
                            const SizedBox(width: gap),
                        ],
                      ],
                    ),
                  ),
                  if (r != rows.length - 1) const SizedBox(height: gap),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _BtnKind { digit, func, op, equals }

class _Btn {
  final String label;
  final Color bg;
  final VoidCallback onTap;
  final _BtnKind kind;
  _Btn(this.label, this.bg,
      {required this.onTap, this.kind = _BtnKind.digit});
}

class _CalcButton extends StatefulWidget {
  final _Btn btn;
  const _CalcButton({required this.btn});

  @override
  State<_CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<_CalcButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final _Btn b = widget.btn;
    final bool strong = b.kind == _BtnKind.op || b.kind == _BtnKind.equals;
    const Color textColor = Colors.white;
    final double textSize = switch (b.label) {
      '+/−' || '⌫' => 24,
      '=' || '÷' || '×' || '+' || '−' => 30,
      _ => 26,
    };

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        b.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          decoration: BoxDecoration(
            color: _pressed
                ? Color.lerp(b.bg, Colors.white, 0.15)
                : b.bg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: strong
                ? <BoxShadow>[
                    BoxShadow(
                      color: b.bg.withValues(alpha: 0.35),
                      blurRadius: 14,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              b.label,
              style: TextStyle(
                color: textColor,
                fontSize: textSize,
                fontWeight: strong ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
