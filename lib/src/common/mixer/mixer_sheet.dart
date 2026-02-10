import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'mixer_providers.dart';
import 'mixer_state.dart';
import 'sound_catalog.dart';

void showMixerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _MixerSheetContent(),
  );
}

class _MixerSheetContent extends ConsumerWidget {
  const _MixerSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(activeTabProvider);
    final mixer = ref.watch(mixerProvider);
    final notifier = ref.read(mixerProvider.notifier);

    final strips = switch (tabIndex) {
      0 => _noteGenStrips(mixer, notifier),
      1 => _metronomeStrips(mixer, notifier),
      2 => _polyStrips(mixer, notifier),
      _ => <_StripConfig>[],
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Mixer', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: strips
                    .map((s) => Expanded(child: _ChannelStrip(config: s)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_StripConfig> _noteGenStrips(MixerState m, MixerNotifier n) => [
    _StripConfig(
      label: 'Piano',
      volume: m.noteGenPianoVolume,
      onVolumeChanged: (v) => n.setVolume(MixerTrack.noteGenPiano, v),
      soundIndex: null, // no sound choice for piano
      onSoundChanged: null,
    ),
    _StripConfig(
      label: 'Click',
      volume: m.noteGenClick.volume,
      onVolumeChanged: (v) => n.setVolume(MixerTrack.noteGenClick, v),
      soundIndex: m.noteGenClick.soundIndex,
      onSoundChanged: (i) => n.setSound(MixerTrack.noteGenClick, i),
    ),
  ];

  List<_StripConfig> _metronomeStrips(MixerState m, MixerNotifier n) => [
    _StripConfig(
      label: 'Beat',
      volume: m.metronomeBeat.volume,
      onVolumeChanged: (v) => n.setVolume(MixerTrack.metronomeBeat, v),
      soundIndex: m.metronomeBeat.soundIndex,
      onSoundChanged: (i) => n.setSound(MixerTrack.metronomeBeat, i),
    ),
    _StripConfig(
      label: 'Bar',
      volume: m.metronomeBar.volume,
      onVolumeChanged: (v) => n.setVolume(MixerTrack.metronomeBar, v),
      soundIndex: m.metronomeBar.soundIndex,
      onSoundChanged: (i) => n.setSound(MixerTrack.metronomeBar, i),
    ),
    _StripConfig(
      label: 'Section',
      volume: m.metronomeSection.volume,
      onVolumeChanged: (v) => n.setVolume(MixerTrack.metronomeSection, v),
      soundIndex: m.metronomeSection.soundIndex,
      onSoundChanged: (i) => n.setSound(MixerTrack.metronomeSection, i),
    ),
  ];

  List<_StripConfig> _polyStrips(MixerState m, MixerNotifier n) => [
    _StripConfig(
      label: 'A',
      volume: m.polyA.volume,
      onVolumeChanged: (v) => n.setVolume(MixerTrack.polyA, v),
      soundIndex: m.polyA.soundIndex,
      onSoundChanged: (i) => n.setSound(MixerTrack.polyA, i),
    ),
    _StripConfig(
      label: 'B',
      volume: m.polyB.volume,
      onVolumeChanged: (v) => n.setVolume(MixerTrack.polyB, v),
      soundIndex: m.polyB.soundIndex,
      onSoundChanged: (i) => n.setSound(MixerTrack.polyB, i),
    ),
    _StripConfig(
      label: 'Sub',
      volume: m.polySub.volume,
      onVolumeChanged: (v) => n.setVolume(MixerTrack.polySub, v),
      soundIndex: m.polySub.soundIndex,
      onSoundChanged: (i) => n.setSound(MixerTrack.polySub, i),
    ),
  ];
}

class _StripConfig {
  const _StripConfig({
    required this.label,
    required this.volume,
    required this.onVolumeChanged,
    required this.soundIndex,
    required this.onSoundChanged,
  });

  final String label;
  final double volume;
  final ValueChanged<double> onVolumeChanged;
  final int? soundIndex;
  final ValueChanged<int>? onSoundChanged;
}

class _ChannelStrip extends StatelessWidget {
  const _ChannelStrip({required this.config});

  final _StripConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (config.volume * 100).round();

    return Column(
      children: [
        Text(config.label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: config.volume,
                onChanged: config.onVolumeChanged,
              ),
            ),
          ),
        ),
        Text('$pct%', style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        if (config.onSoundChanged != null)
          SizedBox(
            width: 100,
            child: _SoundDropdown(
              soundIndex: config.soundIndex!,
              onChanged: config.onSoundChanged!,
            ),
          )
        else
          const SizedBox(height: 48), // placeholder to align strips
      ],
    );
  }
}

class _SoundDropdown extends StatelessWidget {
  const _SoundDropdown({required this.soundIndex, required this.onChanged});

  final int soundIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: soundIndex,
      isExpanded: true,
      isDense: true,
      style: Theme.of(context).textTheme.bodySmall,
      items: [
        for (var i = 0; i < soundCatalog.length; i++)
          DropdownMenuItem(
            value: i,
            child: Text(soundCatalog[i].name, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
