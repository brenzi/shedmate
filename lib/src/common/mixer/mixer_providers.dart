import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers.dart';
import 'mixer_state.dart';

final mixerProvider = NotifierProvider<MixerNotifier, MixerState>(
  MixerNotifier.new,
);

enum MixerTrack {
  noteGenPiano,
  noteGenClick,
  metronomeBeat,
  metronomeBar,
  metronomeSection,
  polyA,
  polyB,
  polySub,
}

class MixerNotifier extends Notifier<MixerState> {
  late final SharedPreferences _prefs;

  static const _key = 'mixer';

  @override
  MixerState build() {
    _prefs = ref.read(sharedPrefsProvider);
    return _load();
  }

  MixerState _load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const MixerState();
    try {
      return MixerState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return const MixerState();
    }
  }

  void _save() {
    _prefs.setString(_key, jsonEncode(state.toJson()));
  }

  void setVolume(MixerTrack track, double value) {
    final v = value.clamp(0.0, 1.0);
    state = switch (track) {
      MixerTrack.noteGenPiano => state.copyWith(noteGenPianoVolume: v),
      MixerTrack.noteGenClick => state.copyWith(
        noteGenClick: state.noteGenClick.copyWith(volume: v),
      ),
      MixerTrack.metronomeBeat => state.copyWith(
        metronomeBeat: state.metronomeBeat.copyWith(volume: v),
      ),
      MixerTrack.metronomeBar => state.copyWith(
        metronomeBar: state.metronomeBar.copyWith(volume: v),
      ),
      MixerTrack.metronomeSection => state.copyWith(
        metronomeSection: state.metronomeSection.copyWith(volume: v),
      ),
      MixerTrack.polyA => state.copyWith(
        polyA: state.polyA.copyWith(volume: v),
      ),
      MixerTrack.polyB => state.copyWith(
        polyB: state.polyB.copyWith(volume: v),
      ),
      MixerTrack.polySub => state.copyWith(
        polySub: state.polySub.copyWith(volume: v),
      ),
    };
    _save();
  }

  void setSound(MixerTrack track, int soundIndex) {
    state = switch (track) {
      MixerTrack.noteGenPiano => state, // piano has no sound choice
      MixerTrack.noteGenClick => state.copyWith(
        noteGenClick: state.noteGenClick.copyWith(soundIndex: soundIndex),
      ),
      MixerTrack.metronomeBeat => state.copyWith(
        metronomeBeat: state.metronomeBeat.copyWith(soundIndex: soundIndex),
      ),
      MixerTrack.metronomeBar => state.copyWith(
        metronomeBar: state.metronomeBar.copyWith(soundIndex: soundIndex),
      ),
      MixerTrack.metronomeSection => state.copyWith(
        metronomeSection: state.metronomeSection.copyWith(
          soundIndex: soundIndex,
        ),
      ),
      MixerTrack.polyA => state.copyWith(
        polyA: state.polyA.copyWith(soundIndex: soundIndex),
      ),
      MixerTrack.polyB => state.copyWith(
        polyB: state.polyB.copyWith(soundIndex: soundIndex),
      ),
      MixerTrack.polySub => state.copyWith(
        polySub: state.polySub.copyWith(soundIndex: soundIndex),
      ),
    };
    _save();
  }
}
