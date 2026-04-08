import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/scale.dart';
import '../../providers/note_generator_providers.dart';

const _noteNames = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B',
];

const _intervalNames = [
  '', // 0 unused
  'b2nd',
  '2nd',
  'm3rd',
  '3rd',
  '4th',
  'b5th',
  '5th',
  'b6th',
  '6th',
  'b7th',
  '7th',
  'p8va',
  'b9th',
  '9th',
  'm10th',
  '10th',
  '11th',
  'b12th',
  '12th',
  'b13th',
  '13th',
  'b14th',
  '14th',
  '2xp8va',
];

class NoteRules extends ConsumerWidget {
  const NoteRules({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minInterval = ref.watch(
      noteGeneratorProvider.select((s) => s.minInterval),
    );
    final maxInterval = ref.watch(
      noteGeneratorProvider.select((s) => s.maxInterval),
    );
    final rootPitchClass = ref.watch(
      noteGeneratorProvider.select((s) => s.rootPitchClass),
    );
    final scaleType = ref.watch(
      noteGeneratorProvider.select((s) => s.scaleType),
    );
    final bassPitchClass = ref.watch(
      noteGeneratorProvider.select((s) => s.bassPitchClass),
    );
    final semitones = ref.watch(
      noteGeneratorProvider.select((s) => s.transposition.semitones),
    );
    final notifier = ref.read(noteGeneratorProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('Interval', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 12),
              Text(_intervalNames[minInterval]),
              const Spacer(),
              Text(_intervalNames[maxInterval]),
            ],
          ),
        ),
        RangeSlider(
          values: RangeValues(minInterval.toDouble(), maxInterval.toDouble()),
          min: 1,
          max: 24,
          divisions: 23,
          labels: RangeLabels(
            _intervalNames[minInterval],
            _intervalNames[maxInterval],
          ),
          onChanged: (values) {
            notifier.setIntervalRange(values.start.round(), values.end.round());
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('Scale', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 8),
              DropdownButton<int?>(
                value: rootPitchClass,
                isDense: true,
                items: [
                  const DropdownMenuItem(value: null, child: Text('chromatic')),
                  for (var i = 0; i < 12; i++)
                    DropdownMenuItem(
                      value: (i - semitones + 12) % 12,
                      child: Text(_noteNames[i]),
                    ),
                ],
                onChanged: (root) {
                  notifier.setScale(
                    root,
                    root != null ? (scaleType ?? ScaleType.major) : null,
                  );
                },
              ),
              if (rootPitchClass != null) ...[
                const SizedBox(width: 8),
                DropdownButton<ScaleType>(
                  value: scaleType ?? ScaleType.major,
                  isDense: true,
                  items: ScaleType.values
                      .map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                      )
                      .toList(),
                  onChanged: (s) => notifier.setScale(rootPitchClass, s),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('Bass', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 8),
              DropdownButton<int?>(
                value: bassPitchClass,
                isDense: true,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('no bass'),
                  ),
                  const DropdownMenuItem(
                    value: -1,
                    child: Text('random'),
                  ),
                  for (final pc in () {
                    if (rootPitchClass != null && scaleType != null) {
                      return scalePitchClasses(rootPitchClass, scaleType)
                          .toList()
                        ..sort();
                    }
                    return List.generate(12, (i) => i);
                  }())
                    DropdownMenuItem(
                      value: pc,
                      child: Text(
                        _noteNames[(pc + semitones + 12) % 12],
                      ),
                    ),
                ],
                onChanged: (v) => notifier.setBassPitchClass(v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
