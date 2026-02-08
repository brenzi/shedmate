import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/metronome_providers.dart';

class MetronomeControls extends ConsumerWidget {
  const MetronomeControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beatsPerBar = ref.watch(
      metronomeProvider.select((s) => s.beatsPerBar),
    );
    final accentBeat1 = ref.watch(
      metronomeProvider.select((s) => s.accentBeat1),
    );
    final barsPerSection = ref.watch(
      metronomeProvider.select((s) => s.barsPerSection),
    );
    final notifier = ref.read(metronomeProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Beats per bar selector
          Row(
            children: [
              Text('Beats', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<int>(
                    segments: List.generate(
                      11,
                      (i) =>
                          ButtonSegment(value: i + 1, label: Text('${i + 1}')),
                    ),
                    selected: {beatsPerBar},
                    onSelectionChanged: (s) => notifier.setBeatsPerBar(s.first),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Accent + Section controls
          Row(
            children: [
              accentBeat1
                  ? FilledButton.tonal(
                      onPressed: notifier.toggleAccent,
                      child: const Text('Accent 1'),
                    )
                  : OutlinedButton(
                      onPressed: notifier.toggleAccent,
                      child: const Text('Accent 1'),
                    ),
              const SizedBox(width: 16),
              Text('Section', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 8),
              IconButton(
                onPressed: barsPerSection > 0
                    ? () => notifier.setBarsPerSection(barsPerSection - 1)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$barsPerSection'),
              IconButton(
                onPressed: barsPerSection < 32
                    ? () => notifier.setBarsPerSection(barsPerSection + 1)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
