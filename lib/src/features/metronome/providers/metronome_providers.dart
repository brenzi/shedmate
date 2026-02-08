import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/audio_service.dart';
import '../../../common/providers.dart';
import '../domain/metronome_state.dart';
import '../services/metronome_sequencer_service.dart';

final metronomeProvider = NotifierProvider<MetronomeNotifier, MetronomeState>(
  MetronomeNotifier.new,
);

class MetronomeNotifier extends Notifier<MetronomeState> {
  late final AudioService _audioService;
  late final MetronomeSequencerService _sequencer;
  Future<void>? _initFuture;

  @override
  MetronomeState build() {
    _audioService = ref.read(audioServiceProvider);
    _sequencer = MetronomeSequencerService(audioService: _audioService);
    _sequencer.onBeat = _onBeat;
    ref.onDispose(_dispose);
    return const MetronomeState();
  }

  Future<void> _ensureInit() => _initFuture ??= _audioService.init();

  void _onBeat(int beat, int bar) {
    state = state.copyWith(currentBeat: beat, currentBar: bar);
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await _sequencer.stop();
      state = state.copyWith(isPlaying: false, currentBeat: 0, currentBar: 0);
    } else {
      await _ensureInit();
      _syncParams();
      await _sequencer.start();
      state = state.copyWith(isPlaying: true);
    }
  }

  void setBpm(int value) {
    state = state.copyWith(bpm: value);
    _sequencer.bpm = value;
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
  }

  void toggleBeat(int index) {
    final toggles = List<bool>.from(state.beatToggles);
    toggles[index] = !toggles[index];
    state = state.copyWith(beatToggles: toggles);
    _sequencer.beatToggles = toggles;
  }

  void toggleOffbeat(int index) {
    final toggles = List<bool>.from(state.offbeatToggles);
    toggles[index] = !toggles[index];
    state = state.copyWith(offbeatToggles: toggles);
    _sequencer.offbeatToggles = toggles;
  }

  void toggleAccent() {
    final value = !state.accentBeat1;
    state = state.copyWith(accentBeat1: value);
    _sequencer.accentBeat1 = value;
  }

  void setBarsPerSection(int value) {
    state = state.copyWith(barsPerSection: value);
    _sequencer.barsPerSection = value;
  }

  void _syncParams() {
    _sequencer
      ..bpm = state.bpm
      ..beatsPerBar = state.beatsPerBar
      ..beatToggles = List<bool>.from(state.beatToggles)
      ..offbeatToggles = List<bool>.from(state.offbeatToggles)
      ..accentBeat1 = state.accentBeat1
      ..barsPerSection = state.barsPerSection;
  }

  Future<void> _dispose() async {
    if (_sequencer.isPlaying) await _sequencer.stop();
  }
}
