import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shedmate/src/common/widgets/tempo_wheel_overlay.dart';

Widget _buildApp({
  required int initialBpm,
  required ValueChanged<int> onBpmChanged,
  int min = 40,
  int max = 200,
}) {
  return MaterialApp(
    theme: ThemeData(
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.dark,
      useMaterial3: true,
    ),
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => showTempoWheel(
              context,
              currentBpm: initialBpm,
              onBpmChanged: onBpmChanged,
              min: min,
              max: max,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('displays initial BPM', (tester) async {
    await tester.pumpWidget(_buildApp(initialBpm: 120, onBpmChanged: (_) {}));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('120'), findsOneWidget);
  });

  testWidgets('pan gesture changes BPM', (tester) async {
    final values = <int>[];
    await tester.pumpWidget(
      _buildApp(initialBpm: 120, onBpmChanged: values.add),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Find the wheel area and drag clockwise
    final wheelFinder = find.byType(TempoWheelOverlay);
    final center = tester.getCenter(wheelFinder);

    // Drag from right of center upward (clockwise = increase BPM)
    await tester.timedDragFrom(
      Offset(center.dx + 100, center.dy),
      const Offset(0, -100),
      const Duration(milliseconds: 200),
    );
    await tester.pump();

    expect(values, isNotEmpty);
  });

  testWidgets('tap outside dismisses overlay', (tester) async {
    await tester.pumpWidget(_buildApp(initialBpm: 120, onBpmChanged: (_) {}));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('120'), findsOneWidget);

    // Tap at the edge of the screen (outside the wheel)
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('120'), findsNothing);
  });

  testWidgets('BPM clamped to min/max', (tester) async {
    final values = <int>[];
    await tester.pumpWidget(
      _buildApp(initialBpm: 295, onBpmChanged: values.add, max: 300),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('295'), findsOneWidget);

    // Large clockwise drag to try to exceed max
    final center = tester.getCenter(find.byType(TempoWheelOverlay));
    await tester.timedDragFrom(
      Offset(center.dx, center.dy - 100),
      const Offset(200, 0),
      const Duration(milliseconds: 300),
    );
    await tester.pump();

    // All reported values should be <= 300
    for (final v in values) {
      expect(v, lessThanOrEqualTo(300));
    }
  });
}
