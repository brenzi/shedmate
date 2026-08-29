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
                        showSelectedIcon: false,
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
                  _toggle(accentBeat1, notifier.toggleAccent, accentLabel),
                  const SizedBox(width: 8),
                  _toggle(countIn, notifier.toggleCountIn, countInLabel),
                  const SizedBox(width: 8),
                  _toggle(sectionEnabled, notifier.toggleSection, sectionLabel),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: barsPerSection > 0
                        ? () => notifier.setBarsPerSection(barsPerSection - 1)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$barsPerSection'),
                  IconButton(
                    visualDensity: VisualDensity.compact,
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

  /// Compact toggle button; the three of them plus the section stepper have to
  /// fit one row on a 360dp phone.
  Widget _toggle(bool on, VoidCallback onPressed, String label) {
    const style = ButtonStyle(
      visualDensity: VisualDensity.compact,
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
    );
    return SizedBox(
      height: 40,
      child: on
          ? FilledButton.tonal(
              style: style,
              onPressed: onPressed,
              child: Text(label),
            )
          : OutlinedButton(
              style: style,
              onPressed: onPressed,
              child: Text(label),
            ),
    );
  }
}
