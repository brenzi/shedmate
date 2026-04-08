import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/transposition.dart';
import '../../providers/note_generator_providers.dart';

class NoteDisplay extends ConsumerWidget {
  const NoteDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteName = ref.watch(
      noteGeneratorProvider.select((s) => s.currentNoteName),
    );
    final currentBeat = ref.watch(
      noteGeneratorProvider.select((s) => s.currentBeat),
    );
    final beatsPerNote = ref.watch(
      noteGeneratorProvider.select((s) => s.beatsPerNote),
    );
    final isPlaying = ref.watch(
      noteGeneratorProvider.select((s) => s.isPlaying),
    );
    final bassNoteName = ref.watch(
      noteGeneratorProvider.select((s) => s.currentBassNoteName),
    );
    final transposition = ref.watch(
      noteGeneratorProvider.select((s) => s.transposition),
    );

    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            DropdownButton<Transposition>(
              value: transposition,
              underline: const SizedBox.shrink(),
              items: Transposition.values
                  .map(
                    (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                  )
                  .toList(),
              onChanged: (t) {
                if (t != null) {
                  ref.read(noteGeneratorProvider.notifier).setTransposition(t);
                }
              },
            ),
            const SizedBox(width: 8),
            Text(
              noteName,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            if (bassNoteName != null) ...[
              const SizedBox(width: 4),
              Text(
                '/$bassNoteName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(beatsPerNote, (i) {
            final isActive = isPlaying && i == currentBeat;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                width: 16,
                height: 16,
                child: Center(
                  child: CircleAvatar(
                    radius: isActive ? 8 : 6,
                    backgroundColor: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
