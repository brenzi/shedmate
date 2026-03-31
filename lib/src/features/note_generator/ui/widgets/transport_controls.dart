import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/note_generator_providers.dart';

class TransportControls extends ConsumerWidget {
  const TransportControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pianoEnabled = ref.watch(
      noteGeneratorProvider.select((s) => s.pianoEnabled),
    );
    final metronomeEnabled = ref.watch(
      noteGeneratorProvider.select((s) => s.metronomeEnabled),
    );
    final isPlaying = ref.watch(
      noteGeneratorProvider.select((s) => s.isPlaying),
    );
    final notifier = ref.read(noteGeneratorProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _ToggleButton(
            label: 'Piano',
            active: pianoEnabled,
            onPressed: notifier.togglePiano,
          ),
          const SizedBox(width: 8),
          _ToggleButton(
            label: 'Metro',
            active: metronomeEnabled,
            onPressed: notifier.toggleMetronome,
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => notifier.togglePlay(),
            icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
            label: Text(isPlaying ? 'Stop' : 'Play'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(150, 60),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.active,
    required this.onPressed,
  });

  final String label;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return FilledButton.tonal(onPressed: onPressed, child: Text(label));
    }
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}
