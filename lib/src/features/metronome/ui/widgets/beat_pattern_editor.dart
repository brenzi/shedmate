import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/metronome_providers.dart';

class BeatPatternEditor extends ConsumerStatefulWidget {
  const BeatPatternEditor({super.key});

  @override
  ConsumerState<BeatPatternEditor> createState() => _BeatPatternEditorState();
}

class _BeatPatternEditorState extends ConsumerState<BeatPatternEditor>
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
    final bpm = ref.read(metronomeProvider.select((s) => s.bpm));
    final beatsPerBar = ref.read(
      metronomeProvider.select((s) => s.beatsPerBar),
    );
    final barDurationMs = beatsPerBar * 60000.0 / bpm;
    const audioLatencyMs = 180;
    final elapsed = (_stopwatch.elapsedMilliseconds - audioLatencyMs)
        .clamp(0, double.maxFinite.toInt());
    final pos = (elapsed % barDurationMs) / barDurationMs;
    if ((pos - _barPosition).abs() > 0.001) {
      setState(() => _barPosition = pos);
    }
  }

  @override
  Widget build(BuildContext context) {
    final beats = ref.watch(metronomeProvider.select((s) => s.beatsPerBar));
    final barsPerSection = ref.watch(
      metronomeProvider.select((s) => s.barsPerSection),
    );
    final sectionEnabled = ref.watch(
      metronomeProvider.select((s) => s.sectionEnabled),
    );
    final currentBar = ref.watch(metronomeProvider.select((s) => s.currentBar));
    final isPlaying = ref.watch(metronomeProvider.select((s) => s.isPlaying));
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen<bool>(metronomeProvider.select((s) => s.isPlaying), (
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const beatRadius = 16.0;
          const margin = beatRadius;
          final ledWidth = width - 2 * margin;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 108,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Offbeat dots — centered between adjacent beats
                    ...List.generate(beats, (i) {
                      final x = margin + (i + 0.5) / beats * ledWidth;
                      return Positioned(
                        left: x - 22,
                        top: 0,
                        child: _OffbeatDot(index: i),
                      );
                    }),
                    // Beat dots
                    ...List.generate(beats, (i) {
                      final x = margin + i / beats * ledWidth;
                      return Positioned(
                        left: x - 22,
                        top: 52,
                        child: _BeatDot(index: i),
                      );
                    }),
                    // Ghost beat at position 1.0
                    Positioned(
                      left: margin + ledWidth - beatRadius,
                      top: 52 + 12,
                      child: Container(
                        width: beatRadius * 2,
                        height: beatRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surfaceContainerHighest,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Scrolling playback line
                    if (isPlaying)
                      Positioned(
                        left: margin + _barPosition * ledWidth - 1,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
               ),
               if (sectionEnabled && barsPerSection > 0) ...[
                 const SizedBox(height: 12),
                 Text(
                   'Bar ${currentBar + 1} / $barsPerSection',
                   style: Theme.of(context).textTheme.bodyMedium,
                 ),
               ] else ...[
                 const SizedBox(height: 30),
               ],
             ],
          );
        },
      ),
    );
  }
}

class _BeatDot extends ConsumerWidget {
  const _BeatDot({required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(
      metronomeProvider.select((s) => s.beatToggles[index]),
    );
    final notifier = ref.read(metronomeProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => notifier.toggleBeat(index),
      child: SizedBox(
        width: 44,
        height: 56,
        child: Center(
          child: CircleAvatar(
            radius: 16,
            backgroundColor: active
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}

class _OffbeatDot extends ConsumerWidget {
  const _OffbeatDot({required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(
      metronomeProvider.select((s) => s.offbeatToggles[index]),
    );
    final notifier = ref.read(metronomeProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => notifier.toggleOffbeat(index),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: CircleAvatar(
            radius: 10,
            backgroundColor: active
                ? colorScheme.tertiary
                : colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}
