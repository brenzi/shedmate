import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/audio_service.dart';
import '../../../common/providers.dart';
import '../domain/polyrhythm_state.dart';
import '../services/polyrhythm_sequencer_service.dart';

final polyrhythmProvider =
    NotifierProvider<PolyrhythmNotifier, PolyrhythmState>(
      PolyrhythmNotifier.new,
    );

class PolyrhythmNotifier extends Notifier<PolyrhythmState> {
  late final AudioService _audioService;
  late final PolyrhythmSequencerService _sequencer;
  Future<void>? _initFuture;

  @override
  PolyrhythmState build() {
    _audioService = ref.read(audioServiceProvider);
    _sequencer = PolyrhythmSequencerService(audioService: _audioService);
    _sequencer.onBeat = _onBeat;
    ref.onDispose(_dispose);
    return const PolyrhythmState();
  }

  Future<void> _ensureInit() => _initFuture ??= _audioService.init();

  void _onBeat(int indexA, int indexB) {
    state = state.copyWith(
      currentTickA: indexA >= 0 ? indexA : state.currentTickA,
      currentTickB: indexB >= 0 ? indexB : state.currentTickB,
    );
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await _sequencer.stop();
      state = state.copyWith(
        isPlaying: false,
        currentTickA: -1,
        currentTickB: -1,
      );
    } else {
      await _ensureInit();
      _syncParams();
      await _sequencer.start();
      state = state.copyWith(isPlaying: true);
    }
  }

  void setA(int value) {
    state = state.copyWith(a: value);
    _sequencer.a = value;
  }

  void setB(int value) {
    state = state.copyWith(b: value);
    _sequencer.b = value;
  }

  void setBpm(int value) {
    state = state.copyWith(bpm: value);
    _sequencer.bpm = value;
  }

  void toggleSubdivision() {
    final value = !state.showSubdivision;
    state = state.copyWith(showSubdivision: value);
    _sequencer.showSubdivision = value;
  }

  void _syncParams() {
    _sequencer
      ..a = state.a
      ..b = state.b
      ..bpm = state.bpm
      ..showSubdivision = state.showSubdivision;
  }

  Future<void> _dispose() async {
    if (_sequencer.isPlaying) await _sequencer.stop();
  }
}
