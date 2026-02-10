import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/audio_service.dart';
import '../../../common/mixer/mixer_providers.dart';
import '../../../common/mixer/mixer_state.dart';
import '../../../common/providers.dart';
import '../../../common/wake_lock_service.dart';
import '../domain/polyrhythm_state.dart';
import '../services/polyrhythm_sequencer_service.dart';

final polyrhythmProvider =
    NotifierProvider<PolyrhythmNotifier, PolyrhythmState>(
      PolyrhythmNotifier.new,
    );

class PolyrhythmNotifier extends Notifier<PolyrhythmState> {
  late final AudioService _audioService;
  late final PolyrhythmSequencerService _sequencer;
  late final SharedPreferences _prefs;
  Future<void>? _initFuture;

  static const _key = 'polyrhythm';

  @override
  PolyrhythmState build() {
    _audioService = ref.read(audioServiceProvider);
    _prefs = ref.read(sharedPrefsProvider);
    _sequencer = PolyrhythmSequencerService(audioService: _audioService);
    _sequencer.onBeat = _onBeat;
    ref.listen(mixerProvider, (_, mixer) => _syncMixerParams(mixer));
    ref.onDispose(_dispose);
    return _load();
  }

  PolyrhythmState _load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const PolyrhythmState();
    try {
      return PolyrhythmState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return const PolyrhythmState();
    }
  }

  void _save() {
    _prefs.setString(_key, jsonEncode(state.toJson()));
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
      await WakeLockService.instance.disable();
      state = state.copyWith(
        isPlaying: false,
        currentTickA: -1,
        currentTickB: -1,
      );
    } else {
      await _ensureInit();
      _syncParams();
      await _sequencer.start();
      await WakeLockService.instance.enable();
      state = state.copyWith(isPlaying: true);
    }
  }

  void setA(int value) {
    state = state.copyWith(a: value);
    _sequencer.a = value;
    _save();
  }

  void setB(int value) {
    state = state.copyWith(b: value);
    _sequencer.b = value;
    _save();
  }

  void setBpm(int value) {
    state = state.copyWith(bpm: value);
    _sequencer.bpm = value;
    _save();
  }

  void toggleSubdivision() {
    final value = !state.showSubdivision;
    state = state.copyWith(showSubdivision: value);
    _sequencer.showSubdivision = value;
    _save();
  }

  void _syncParams() {
    final mixer = ref.read(mixerProvider);
    _sequencer
      ..a = state.a
      ..b = state.b
      ..bpm = state.bpm
      ..showSubdivision = state.showSubdivision;
    _syncMixerParams(mixer);
  }

  void _syncMixerParams(MixerState mixer) {
    _sequencer
      ..aChannel = mixer.polyA.channel
      ..aKey = mixer.polyA.key
      ..aVelocity = mixer.polyA.velocity
      ..bChannel = mixer.polyB.channel
      ..bKey = mixer.polyB.key
      ..bVelocity = mixer.polyB.velocity
      ..subChannel = mixer.polySub.channel
      ..subKey = mixer.polySub.key
      ..subVelocity = mixer.polySub.velocity;
  }

  Future<void> _dispose() async {
    if (_sequencer.isPlaying) {
      await _sequencer.stop();
      await WakeLockService.instance.disable();
    }
  }
}
