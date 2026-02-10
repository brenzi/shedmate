import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/audio_service.dart';
import '../../../common/mixer/mixer_providers.dart';
import '../../../common/mixer/mixer_state.dart';
import '../../../common/providers.dart';
import '../../../common/wake_lock_service.dart';
import '../domain/metronome_state.dart';
import '../services/metronome_sequencer_service.dart';

final metronomeProvider = NotifierProvider<MetronomeNotifier, MetronomeState>(
  MetronomeNotifier.new,
);

class MetronomeNotifier extends Notifier<MetronomeState> {
  late final AudioService _audioService;
  late final MetronomeSequencerService _sequencer;
  late final SharedPreferences _prefs;
  Future<void>? _initFuture;

  static const _key = 'metronome';

  @override
  MetronomeState build() {
    _audioService = ref.read(audioServiceProvider);
    _prefs = ref.read(sharedPrefsProvider);
    _sequencer = MetronomeSequencerService(audioService: _audioService);
    _sequencer.onBeat = _onBeat;
    ref.listen(mixerProvider, (_, mixer) => _syncMixerParams(mixer));
    ref.onDispose(_dispose);
    return _load();
  }

  MetronomeState _load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const MetronomeState();
    try {
      return MetronomeState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return const MetronomeState();
    }
  }

  void _save() {
    _prefs.setString(_key, jsonEncode(state.toJson()));
  }

  Future<void> _ensureInit() => _initFuture ??= _audioService.init();

  void _onBeat(int beat, int bar) {
    state = state.copyWith(currentBeat: beat, currentBar: bar);
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await _sequencer.stop();
      await WakeLockService.instance.disable();
      state = state.copyWith(isPlaying: false, currentBeat: 0, currentBar: 0);
    } else {
      await _ensureInit();
      _syncParams();
      await _sequencer.start();
      await WakeLockService.instance.enable();
      state = state.copyWith(isPlaying: true);
    }
  }

  void setBpm(int value) {
    state = state.copyWith(bpm: value);
    _sequencer.bpm = value;
    _save();
  }

  void setBeatsPerBar(int value) {
    final beats = List.filled(value, true);
    final offbeats = List.filled(value, false);
    state = state.copyWith(
      beatsPerBar: value,
      beatToggles: beats,
      offbeatToggles: offbeats,
    );
    _sequencer
      ..beatsPerBar = value
      ..beatToggles = beats
      ..offbeatToggles = offbeats;
    _save();
  }

  void toggleBeat(int index) {
    final toggles = List<bool>.from(state.beatToggles);
    toggles[index] = !toggles[index];
    state = state.copyWith(beatToggles: toggles);
    _sequencer.beatToggles = toggles;
    _save();
  }

  void toggleOffbeat(int index) {
    final toggles = List<bool>.from(state.offbeatToggles);
    toggles[index] = !toggles[index];
    state = state.copyWith(offbeatToggles: toggles);
    _sequencer.offbeatToggles = toggles;
    _save();
  }

  void toggleAccent() {
    final value = !state.accentBeat1;
    state = state.copyWith(accentBeat1: value);
    _sequencer.accentBeat1 = value;
    _save();
  }

  void setBarsPerSection(int value) {
    state = state.copyWith(barsPerSection: value);
    _sequencer.barsPerSection = value;
    _save();
  }

  void _syncParams() {
    final mixer = ref.read(mixerProvider);
    _sequencer
      ..bpm = state.bpm
      ..beatsPerBar = state.beatsPerBar
      ..beatToggles = List<bool>.from(state.beatToggles)
      ..offbeatToggles = List<bool>.from(state.offbeatToggles)
      ..accentBeat1 = state.accentBeat1
      ..barsPerSection = state.barsPerSection;
    _syncMixerParams(mixer);
  }

  void _syncMixerParams(MixerState mixer) {
    _sequencer
      ..beatChannel = mixer.metronomeBeat.channel
      ..beatKey = mixer.metronomeBeat.key
      ..beatVelocity = mixer.metronomeBeat.velocity
      ..barChannel = mixer.metronomeBar.channel
      ..barKey = mixer.metronomeBar.key
      ..barVelocity = mixer.metronomeBar.velocity
      ..sectionChannel = mixer.metronomeSection.channel
      ..sectionKey = mixer.metronomeSection.key
      ..sectionVelocity = mixer.metronomeSection.velocity;
  }

  Future<void> _dispose() async {
    if (_sequencer.isPlaying) {
      await _sequencer.stop();
      await WakeLockService.instance.disable();
    }
  }
}
