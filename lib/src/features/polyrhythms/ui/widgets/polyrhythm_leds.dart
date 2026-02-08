import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/polyrhythm_math.dart';
import '../../providers/polyrhythm_providers.dart';

class PolyrhythmLeds extends ConsumerStatefulWidget {
  const PolyrhythmLeds({super.key});

  @override
  ConsumerState<PolyrhythmLeds> createState() => _PolyrhythmLedsState();
}

class _PolyrhythmLedsState extends ConsumerState<PolyrhythmLeds>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _stopwatch = Stopwatch();
  double _barPosition = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  void _onTick(Duration _) {
    final a = ref.read(polyrhythmProvider.select((s) => s.a));
    final bpm = ref.read(polyrhythmProvider.select((s) => s.bpm));
    final cycleDurationMs = a * 60000.0 / bpm;
    final pos =
        (_stopwatch.elapsedMilliseconds % cycleDurationMs) / cycleDurationMs;
    if ((pos - _barPosition).abs() > 0.001) {
      setState(() => _barPosition = pos);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = ref.watch(polyrhythmProvider.select((s) => s.a));
    final b = ref.watch(polyrhythmProvider.select((s) => s.b));
    final showSub = ref.watch(
      polyrhythmProvider.select((s) => s.showSubdivision),
    );
    final isPlaying = ref.watch(polyrhythmProvider.select((s) => s.isPlaying));
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen<bool>(polyrhythmProvider.select((s) => s.isPlaying), (
      _,
      playing,
    ) {
      if (playing) {
        _stopwatch
          ..reset()
          ..start();
        _ticker.start();
      } else {
        _ticker.stop();
        _stopwatch.stop();
        setState(() => _barPosition = 0);
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - 48; // padding
        const ledRadius = 8.0;

        Widget buildRow({
          required String label,
          required int count,
          required Color inactiveColor,
        }) {
          final positions = beatPositions(count);
          return SizedBox(
            height: 40,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: 12,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                ...List.generate(count, (i) {
                  final x = 24 + positions[i] * width;
                  return Positioned(
                    left: x - ledRadius,
                    top: 12,
                    child: Container(
                      width: ledRadius * 2,
                      height: ledRadius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: inactiveColor,
                      ),
                    ),
                  );
                }),
                // Ghost beat at position 1.0
                Positioned(
                  left: 24 + width - ledRadius,
                  top: 12,
                  child: Container(
                    width: ledRadius * 2,
                    height: ledRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: inactiveColor, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final subCount = lcm(a, b);

        final rows = <Widget>[
          buildRow(
            label: 'A',
            count: a,
            inactiveColor: colorScheme.primaryContainer,
          ),
          const SizedBox(height: 8),
          buildRow(
            label: 'B',
            count: b,
            inactiveColor: colorScheme.tertiaryContainer,
          ),
          if (showSub) ...[
            const SizedBox(height: 8),
            buildRow(
              label: 's',
              count: subCount,
              inactiveColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ],
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: rows,
              ),
              if (isPlaying)
                Positioned(
                  left: 24 + _barPosition * width - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
