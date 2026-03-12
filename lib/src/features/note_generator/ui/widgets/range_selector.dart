import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/midi_utils.dart';
import '../../domain/instrument_preset.dart';
import '../../domain/note_range.dart';
import '../../providers/note_generator_providers.dart';

class RangeSelector extends ConsumerWidget {
  const RangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rangeLow = ref.watch(noteGeneratorProvider.select((s) => s.rangeLow));
    final rangeHigh = ref.watch(
      noteGeneratorProvider.select((s) => s.rangeHigh),
    );
    final semitones = ref.watch(
      noteGeneratorProvider.select((s) => s.transposition.semitones),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('Range', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 12),
              Text(midiNoteToName(rangeLow + semitones)),
              const Spacer(),
              Text(midiNoteToName(rangeHigh + semitones)),
            ],
          ),
        ),
        RangeSlider(
          values: RangeValues(rangeLow.toDouble(), rangeHigh.toDouble()),
          min: NoteRange.pianoLow.toDouble(),
          max: NoteRange.pianoHigh.toDouble(),
          divisions: NoteRange.pianoHigh - NoteRange.pianoLow,
          labels: RangeLabels(
            midiNoteToName(rangeLow + semitones),
            midiNoteToName(rangeHigh + semitones),
          ),
          onChanged: (values) {
            ref
                .read(noteGeneratorProvider.notifier)
                .setRange(values.start.round(), values.end.round());
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: InstrumentPreset.values.map((preset) {
              final isSelected =
                  rangeLow == preset.range.low &&
                  rangeHigh == preset.range.high;
              return ChoiceChip(
                label: Text(preset.label),
                selected: isSelected,
                visualDensity: VisualDensity.compact,
                onSelected: (_) {
                  ref
                      .read(noteGeneratorProvider.notifier)
                      .applyPreset(preset.range);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
