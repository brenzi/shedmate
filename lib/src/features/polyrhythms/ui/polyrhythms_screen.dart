import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/mixer/mixer_sheet.dart';
import '../../../common/widgets/tempo_wheel_overlay.dart';
import '../providers/polyrhythm_providers.dart';
import 'widgets/polyrhythm_leds.dart';
import 'widgets/polyrhythm_selector.dart';

class PolyrhythmsScreen extends ConsumerWidget {
  const PolyrhythmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bpm = ref.watch(polyrhythmProvider.select((s) => s.bpm));
    final isPlaying = ref.watch(polyrhythmProvider.select((s) => s.isPlaying));
    final notifier = ref.read(polyrhythmProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Polyrhythms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => showMixerSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const Expanded(child: Center(child: PolyrhythmLeds())),
          const Divider(height: 1),
          const PolyrhythmSelector(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => showTempoWheel(
                    context,
                    currentBpm: bpm,
                    onBpmChanged: notifier.setBpm,
                  ),
                  child: Text(
                    'A: \u2669 = $bpm',
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
      ),
    );
  }
}
