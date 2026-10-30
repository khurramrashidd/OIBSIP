// Widget tests for the Stopwatch app.
//
// Replace the auto-generated `test/widget_test.dart` with this file.
// The default scaffold tests `MyApp` (counter template) which doesn't
// exist in this project — our root widget is `StopwatchApp`.
//
// Note: Dart's Stopwatch uses the real OS monotonic clock, not Flutter's
// fake test clock. tester.pump(duration) advances the frame scheduler
// but does NOT make _watch.elapsed advance. So these tests verify
// state-driven UI (button labels, hint text, lap entries) rather than
// time-value changes.

import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_app/main.dart';

void main() {
  testWidgets('Stopwatch starts at 00:00.00 and shows Start button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StopwatchApp());

    expect(find.text('00:00.00'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Press START to begin'), findsOneWidget);
  });

  testWidgets('Tapping Start swaps the primary button Start → Lap',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StopwatchApp());

    await tester.tap(find.text('Start'));
    await tester.pump();

    // Start button becomes Lap once running.
    expect(find.text('Start'), findsNothing);
    expect(find.text('Lap'), findsOneWidget);
    // The "Press START to begin" hint goes away.
    expect(find.text('Press START to begin'), findsNothing);
  });

  testWidgets('Pause shows Resume label and paused hint',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StopwatchApp());

    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.tap(find.text('Pause'));
    await tester.pump();

    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Paused · press Resume or Reset'), findsOneWidget);
  });

  testWidgets('Reset clears state back to Start + initial display',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StopwatchApp());

    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.tap(find.text('Pause'));
    await tester.pump();
    await tester.tap(find.text('Reset'));
    await tester.pump();

    expect(find.text('00:00.00'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Press START to begin'), findsOneWidget);
  });

  testWidgets('Lap button records a split while running',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StopwatchApp());

    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.tap(find.text('Lap'));
    await tester.pump();

    expect(find.text('Lap 1'), findsOneWidget);
  });

  testWidgets('Multiple laps stack newest-first', (WidgetTester tester) async {
    await tester.pumpWidget(const StopwatchApp());

    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.tap(find.text('Lap'));
    await tester.pump();
    await tester.tap(find.text('Lap'));
    await tester.pump();
    await tester.tap(find.text('Lap'));
    await tester.pump();

    expect(find.text('Lap 1'), findsOneWidget);
    expect(find.text('Lap 2'), findsOneWidget);
    expect(find.text('Lap 3'), findsOneWidget);
  });
}
