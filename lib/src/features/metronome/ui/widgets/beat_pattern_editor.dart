import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/metronome_providers.dart';

class BeatPatternEditor extends ConsumerWidget {
  const BeatPatternEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beats = ref.watch(metronomeProvider.select((s) => s.beatsPerBar));
    final beatToggles = ref.watch(
      metronomeProvider.select((s) => s.beatToggles),
    );
    final offbeatToggles = ref.watch(
      metronomeProvider.select((s) => s.offbeatToggles),
    );
    final currentBeat = ref.watch(
      metronomeProvider.select((s) => s.currentBeat),
    );
    final currentBar = ref.watch(metronomeProvider.select((s) => s.currentBar));
    final isPlaying = ref.watch(metronomeProvider.select((s) => s.isPlaying));
    final barsPerSection = ref.watch(
      metronomeProvider.select((s) => s.barsPerSection),
    );
    final notifier = ref.read(metronomeProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Offbeat row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(beats, (i) {
            final active = offbeatToggles[i];
            return GestureDetector(
              onTap: () => notifier.toggleOffbeat(i),
              child: SizedBox(
                width: 32,
                height: 32,
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
          }),
        ),
        const SizedBox(height: 12),
        // Beat row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(beats, (i) {
            final active = beatToggles[i];
            final isCurrent = isPlaying && i == currentBeat;
            return GestureDetector(
              onTap: () => notifier.toggleBeat(i),
              child: SizedBox(
                width: 48,
                height: 48,
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
              ),
            );
          }),
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
  }
}
