import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/mixer/mixer_sheet.dart';
import '../../../common/widgets/tempo_wheel_overlay.dart';
import '../providers/metronome_providers.dart';
import 'widgets/beat_pattern_editor.dart';
import 'widgets/metronome_controls.dart';

class MetronomeScreen extends ConsumerWidget {
  const MetronomeScreen({super.key});

  static const _fixedContentHeight = 260.0;
  static const _minWheelHeight = 150.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bpm = ref.watch(metronomeProvider.select((s) => s.bpm));
    final isPlaying = ref.watch(metronomeProvider.select((s) => s.isPlaying));
    final notifier = ref.read(metronomeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metronome'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => showMixerSheet(context),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final showInlineWheel =
              constraints.maxHeight - _fixedContentHeight >= _minWheelHeight;

          return Column(
            children: [
              const BeatPatternEditor(),
              const Divider(height: 1),
              const MetronomeControls(),
              const Divider(height: 1),
              if (showInlineWheel)
                Expanded(
                  child: Center(
                    child: TempoWheel(bpm: bpm, onBpmChanged: notifier.setBpm),
                  ),
                ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    if (!showInlineWheel)
                      GestureDetector(
                        onTap: () => showTempoWheel(
                          context,
                          currentBpm: bpm,
                          onBpmChanged: notifier.setBpm,
                        ),
                        child: Text(
                          '\u2669 = $bpm',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => notifier.togglePlay(),
                      icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                      label: Text(isPlaying ? 'Stop' : 'Play'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
