// Oasis Infobyte Android Internship — Task 1: Unit Converter
// Flutter implementation (VS Code friendly).
//
// Feature checklist mapped to the task sheet:
//  - Input field for the numeric value                       ..............  ✓
//  - Dropdown (Spinner) for the SOURCE unit                  ..............  ✓
//  - Dropdown (Spinner) for the TARGET unit                  ..............  ✓
//  - Convert button that computes and displays the result    ..............  ✓
//  - Result display with unit label                          ..............  ✓
//  - At least 3 categories (ships with 8)                    ..............  ✓
//  - Toast on empty / non-numeric input                      ..............  ✓
//  - Category selector that resets the unit dropdowns        ..............  ✓
//
// Extras beyond the sheet:
//  - 8 categories: Length, Weight, Temperature, Volume, Speed, Area, Data, Time
//  - Swap button (⇄) to reverse source and target
//  - Live conversion as you type (Convert button still present per the sheet)
//  - Copy result to clipboard
//  - Formula / rate line showing what 1 source unit equals
//  - Haptic feedback, animated transitions, dark Material 3 theme

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'units.dart';

void main() => runApp(const UnitConverterApp());

class UnitConverterApp extends StatelessWidget {
  const UnitConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0EA5E9),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0B10),
        useMaterial3: true,
      ),
      home: const ConverterScreen(),
    );
  }
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  static const Color _accent = Color(0xFF0EA5E9);
  static const Color _card = Color(0xFF15151D);

  final TextEditingController _input = TextEditingController();

  int _categoryIndex = 0;
  late Unit _from;
  late Unit _to;

  String _result = '';
  bool _hasResult = false;

  UnitCategory get _category => kCategories[_categoryIndex];

  @override
  void initState() {
    super.initState();
    _resetUnitsForCategory();
    _input.addListener(_liveConvert);
  }

  @override
  void dispose() {
    _input.removeListener(_liveConvert);
    _input.dispose();
    super.dispose();
  }

  /// Per the task sheet: switching category resets the unit dropdowns.
  void _resetUnitsForCategory() {
    final List<Unit> units = _category.units;
    _from = units[0];
    _to = units.length > 1 ? units[1] : units[0];
    _result = '';
    _hasResult = false;
  }

  void _onCategoryChanged(int index) {
    if (index == _categoryIndex) return;
    HapticFeedback.selectionClick();
    setState(() {
      _categoryIndex = index;
      _resetUnitsForCategory();
    });
    _liveConvert();
  }

  /// Quietly recompute while typing. No toast here — the toast belongs to the
  /// explicit Convert button, which is what the task sheet asks for.
  void _liveConvert() {
    final String raw = _input.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _result = '';
        _hasResult = false;
      });
      return;
    }
    final double? v = double.tryParse(raw);
    if (v == null) {
      setState(() {
        _result = '';
        _hasResult = false;
      });
      return;
    }
    setState(() {
      _result = formatResult(convert(v, _from, _to));
      _hasResult = true;
    });
  }

  /// Explicit Convert button — this is the one that validates and toasts.
  void _onConvertPressed() {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    final String raw = _input.text.trim();

    if (raw.isEmpty) {
      _toast('Please enter a value to convert');
      setState(() {
        _result = '';
        _hasResult = false;
      });
      return;
    }

    final double? v = double.tryParse(raw);
    if (v == null) {
      _toast('"$raw" is not a valid number');
      setState(() {
        _result = '';
        _hasResult = false;
      });
      return;
    }

    setState(() {
      _result = formatResult(convert(v, _from, _to));
      _hasResult = true;
    });
  }

  void _onSwap() {
    HapticFeedback.selectionClick();
    setState(() {
      final Unit t = _from;
      _from = _to;
      _to = t;
    });
    _liveConvert();
  }

  void _onCopy() {
    if (!_hasResult) return;
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: '$_result ${_to.symbol}'));
    _toast('Copied $_result ${_to.symbol}');
  }

  /// Android Toast equivalent in Flutter — a short floating SnackBar.
  void _toast(String message) {
    final ScaffoldMessengerState m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2A2A33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// "1 cm = 0.3937007874 in" — useful context under the result.
  String get _rateLine {
    final double one = convert(1, _from, _to);
    return '1 ${_from.symbol} = ${formatResult(one)} ${_to.symbol}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Unit Converter',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildCategoryBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildFromCard(),
                    _buildSwapRow(),
                    _buildToCard(),
                    const SizedBox(height: 20),
                    _buildConvertButton(),
                    const SizedBox(height: 16),
                    _buildRateLine(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- category selector -----------------------------------------------------

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        key: const Key('category-bar'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        itemCount: kCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int i) {
          final bool selected = i == _categoryIndex;
          final UnitCategory c = kCategories[i];
          return GestureDetector(
            key: Key('category-${c.name}'),
            onTap: () => _onCategoryChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? _accent : _card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? _accent
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    c.icon,
                    size: 17,
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    c.name,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- from / to cards -------------------------------------------------------

  Widget _buildFromCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _label('From'),
          const SizedBox(height: 6),
          TextField(
            key: const Key('input-field'),
            controller: _input,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w300,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _unitDropdown(
            key: const Key('from-dropdown'),
            value: _from,
            onChanged: (Unit? u) {
              if (u == null) return;
              HapticFeedback.selectionClick();
              setState(() => _from = u);
              _liveConvert();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _label('To'),
              if (_hasResult)
                GestureDetector(
                  key: const Key('copy-button'),
                  onTap: _onCopy,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.copy_rounded,
                        size: 15,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 46,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _hasResult ? _result : '—',
                  key: const Key('result-text'),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    color: _hasResult
                        ? _accent
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _unitDropdown(
            key: const Key('to-dropdown'),
            value: _to,
            onChanged: (Unit? u) {
              if (u == null) return;
              HapticFeedback.selectionClick();
              setState(() => _to = u);
              _liveConvert();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwapRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Divider(color: Colors.white.withValues(alpha: 0.08)),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            key: const Key('swap-button'),
            onTap: _onSwap,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _card,
                shape: BoxShape.circle,
                border: Border.all(color: _accent.withValues(alpha: 0.4)),
              ),
              child: const Icon(
                Icons.swap_vert_rounded,
                color: _accent,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ],
      ),
    );
  }

  // --- convert button + rate line -------------------------------------------

  Widget _buildConvertButton() {
    return SizedBox(
      height: 56,
      child: FilledButton(
        key: const Key('convert-button'),
        onPressed: _onConvertPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Convert',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildRateLine() {
    return Center(
      child: Text(
        _rateLine,
        key: const Key('rate-line'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: Colors.white.withValues(alpha: 0.4),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // --- small helpers ---------------------------------------------------------

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Colors.white.withValues(alpha: 0.45),
        ),
      );

  Widget _unitDropdown({
    required Key key,
    required Unit value,
    required ValueChanged<Unit?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Unit>(
          key: key,
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1C1C24),
          borderRadius: BorderRadius.circular(14),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          style: const TextStyle(fontSize: 15, color: Colors.white),
          items: _category.units
              .map(
                (Unit u) => DropdownMenuItem<Unit>(
                  value: u,
                  child: Text(
                    '${u.name}  ·  ${u.symbol}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
