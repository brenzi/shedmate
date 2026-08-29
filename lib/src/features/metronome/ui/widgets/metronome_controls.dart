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
    final countIn = ref.watch(
      metronomeProvider.select((s) => s.countIn),
    );
    final barsPerSection = ref.watch(
      metronomeProvider.select((s) => s.barsPerSection),
    );
    final sectionEnabled = ref.watch(
      metronomeProvider.select((s) => s.sectionEnabled),
    );
    final notifier = ref.read(metronomeProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 400;
          final accentLabel = narrow ? 'Accnt' : 'Accent 1';
          final countInLabel = narrow ? 'CntIn' : 'Count In';
          final sectionLabel = narrow ? 'Sect' : 'Section';

          return Column(
            children: [
              // Beats per bar selector
              Row(
                children: [
                  Text(
                    'Beats',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<int>(
                        segments: List.generate(
                          11,
                          (i) => ButtonSegment(
                            value: i + 1,
                            label: Text('${i + 1}'),
                          ),
                        ),
                        selected: {beatsPerBar},
                        onSelectionChanged: (s) =>
                            notifier.setBeatsPerBar(s.first),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Accent + Count In + Section controls
              Row(
                children: [
                  SizedBox(
                    height: 40,
                    child: accentBeat1
                        ? FilledButton.tonal(
                            onPressed: notifier.toggleAccent,
                            child: Text(accentLabel),
                          )
                        : OutlinedButton(
                            onPressed: notifier.toggleAccent,
                            child: Text(accentLabel),
                          ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 40,
                    child: countIn
                        ? FilledButton.tonal(
                            onPressed: notifier.toggleCountIn,
                            child: Text(countInLabel),
                          )
                        : OutlinedButton(
                            onPressed: notifier.toggleCountIn,
                            child: Text(countInLabel),
                          ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 40,
                    child: sectionEnabled
                        ? FilledButton.tonal(
                            onPressed: notifier.toggleSection,
                            child: Text(sectionLabel),
                          )
                        : OutlinedButton(
                            onPressed: notifier.toggleSection,
                            child: Text(sectionLabel),
                          ),
                  ),
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
          );
        },
      ),
    );
  }
}
