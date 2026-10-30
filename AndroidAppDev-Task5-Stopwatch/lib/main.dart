// Oasis Infobyte Android Internship — Task 5: Stopwatch
// Flutter implementation (VS Code friendly).
//
// Feature checklist mapped to the task sheet:
//  - Large, clearly visible MM:SS.cs / HH:MM:SS.cs display  ..............  ✓
//  - Start button                                            ..............  ✓
//  - Stop/Pause button                                       ..............  ✓
//  - Reset button                                            ..............  ✓
//  - Buttons visually change state when active/disabled      ..............  ✓
//  - Timer survives background/foreground (lifecycle safe)   ..............  ✓
//  - Bonus: Lap list                                         ..............  ✓

import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const StopwatchApp());

class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stopwatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0B10),
        useMaterial3: true,
      ),
      home: const StopwatchScreen(),
    );
  }
}

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen>
    with WidgetsBindingObserver {
  // Dart's Stopwatch is backed by the system monotonic clock, so it keeps
  // counting correctly even when the app is backgrounded. The UI ticker
  // just drives repaints — it does NOT drive the counting.
  final Stopwatch _watch = Stopwatch();
  Timer? _ticker;
  final List<Duration> _laps = <Duration>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  // Lifecycle: cancel the UI ticker when backgrounded (don't waste CPU),
  // restart it on resume if the stopwatch is still running.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _watch.isRunning) {
      _ensureTicking();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  void _ensureTicking() {
    _ticker?.cancel();
    // 30ms gives smooth-looking centiseconds without burning the battery.
    _ticker = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  void _start() {
    _watch.start();
    _ensureTicking();
    setState(() {});
  }

  void _pause() {
    _watch.stop();
    _ticker?.cancel();
    _ticker = null;
    setState(() {});
  }

  void _reset() {
    _watch
      ..stop()
      ..reset();
    _ticker?.cancel();
    _ticker = null;
    _laps.clear();
    setState(() {});
  }

  void _lap() {
    if (!_watch.isRunning) return;
    setState(() {
      _laps.insert(0, _watch.elapsed);
    });
  }

  String _format(Duration d) {
    final hh = d.inHours.toString().padLeft(2, '0');
    final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    final cs = ((d.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    return d.inHours > 0 ? '$hh:$mm:$ss.$cs' : '$mm:$ss.$cs';
  }

  @override
  Widget build(BuildContext context) {
    final bool running = _watch.isRunning;
    final bool hasStarted =
        _watch.elapsedMilliseconds > 0 || _laps.isNotEmpty;
    final Duration elapsed = _watch.elapsed;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stopwatch',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 24),
            // Time display
            Expanded(
              flex: 2,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _format(elapsed),
                      style: TextStyle(
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                        fontSize: 92,
                        fontWeight: FontWeight.w200,
                        letterSpacing: 2,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Lap list / hint
            Expanded(
              flex: 3,
              child: _laps.isEmpty
                  ? Center(
                      child: Text(
                        running
                            ? 'Tap LAP to record a split'
                            : hasStarted
                                ? 'Paused · press Resume or Reset'
                                : 'Press START to begin',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: _laps.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                      itemBuilder: (BuildContext context, int i) {
                        final int lapNumber = _laps.length - i;
                        final Duration current = _laps[i];
                        final Duration previous = i == _laps.length - 1
                            ? Duration.zero
                            : _laps[i + 1];
                        final Duration split = current - previous;
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: SizedBox(
                            width: 72,
                            child: Text(
                              'Lap $lapNumber',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          title: Text(
                            _format(split),
                            style: const TextStyle(
                              color: Colors.white,
                              fontFeatures: <FontFeature>[
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          trailing: Text(
                            _format(current),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontFeatures: const <FontFeature>[
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _CircleButton(
                    label: 'Reset',
                    color: const Color(0xFF3F3F46),
                    onTap: hasStarted ? _reset : null,
                  ),
                  _CircleButton(
                    label: running
                        ? 'Lap'
                        : (hasStarted ? 'Resume' : 'Start'),
                    color: running
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF16A34A),
                    onTap: running ? _lap : _start,
                    big: true,
                  ),
                  _CircleButton(
                    label: 'Pause',
                    color: const Color(0xFFDC2626),
                    onTap: running ? _pause : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool big;

  const _CircleButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final double size = big ? 96 : 80;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? color
              : color.withValues(alpha: 0.22),
          boxShadow: enabled
              ? <BoxShadow>[
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: enabled
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
              fontSize: big ? 18 : 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
