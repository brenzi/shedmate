import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/metronome_providers.dart';

class BeatPatternEditor extends ConsumerWidget {
  const BeatPatternEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beats = ref.watch(metronomeProvider.select((s) => s.beatsPerBar));
    final barsPerSection = ref.watch(
      metronomeProvider.select((s) => s.barsPerSection),
    );
    final currentBar = ref.watch(metronomeProvider.select((s) => s.currentBar));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Offbeat row — each centered between adjacent beats
              SizedBox(
                height: 44,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: List.generate(beats, (i) {
                    final center = (i + 1) / beats * width;
                    return Positioned(
                      left: center - 22,
                      top: 0,
                      child: _OffbeatDot(index: i),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              // Beat row — Row+Expanded ensures full-width hit areas
              SizedBox(
                height: 56,
                child: Row(
                  children: List.generate(
                    beats,
                    (i) => Expanded(child: _BeatDot(index: i)),
                  ),
                ),
              ),
              if (barsPerSection > 0) ...[
                const SizedBox(height: 12),
                Text(
                  'Bar ${currentBar + 1} / $barsPerSection',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
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
    final isCurrent = ref.watch(
      metronomeProvider.select((s) => s.isPlaying && s.currentBeat == index),
    );
    final notifier = ref.read(metronomeProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => notifier.toggleBeat(index),
      child: Center(
        child: CircleAvatar(
          radius: 16,
          backgroundColor: isCurrent
              ? colorScheme.primary
              : active
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
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
