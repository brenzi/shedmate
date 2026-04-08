import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/audio_service.dart';
import '../../../common/midi_utils.dart';
import '../../../common/mixer/mixer_providers.dart';
import '../../../common/mixer/mixer_state.dart';
import '../../../common/providers.dart';
import '../../../common/wake_lock_service.dart';
import '../domain/note_range.dart';
import '../domain/scale.dart';
import '../domain/transposition.dart';
import '../services/sequencer_service.dart';

const _sentinel = Object();

class NoteGeneratorState {
  const NoteGeneratorState({
    this.bpm = 80,
    this.beatsPerNote = 4,
    this.rangeLow = NoteRange.pianoLow,
    this.rangeHigh = NoteRange.pianoHigh,
    this.pianoEnabled = true,
    this.metronomeEnabled = true,
    this.isPlaying = false,
    this.currentNoteName = '---',
    this.currentBassNoteName,
    this.currentMidiNote,
    this.currentBeat = 0,
    this.minInterval = 1,
    this.maxInterval = 12,
    this.rootPitchClass,
    this.scaleType,
    this.bassPitchClass,
    this.transposition = Transposition.concert,
  });

  final int bpm;
  final int beatsPerNote;
  final int rangeLow;
  final int rangeHigh;
  final bool pianoEnabled;
  final bool metronomeEnabled;
  final bool isPlaying;
  final String currentNoteName;
  final String? currentBassNoteName;
  final int? currentMidiNote;
  final int currentBeat;
  final int minInterval;
  final int maxInterval;
  final int? rootPitchClass;
  final ScaleType? scaleType;
  final int? bassPitchClass;
  final Transposition transposition;

  Map<String, dynamic> toJson() => {
    'bpm': bpm,
    'beatsPerNote': beatsPerNote,
    'rangeLow': rangeLow,
    'rangeHigh': rangeHigh,
    'pianoEnabled': pianoEnabled,
    'metronomeEnabled': metronomeEnabled,
    'minInterval': minInterval,
    'maxInterval': maxInterval,
    'rootPitchClass': rootPitchClass,
    'scaleType': scaleType?.name,
    'bassPitchClass': bassPitchClass,
    'transposition': transposition.name,
  };

  factory NoteGeneratorState.fromJson(Map<String, dynamic> j) {
    const d = NoteGeneratorState();
    return NoteGeneratorState(
      bpm: j['bpm'] as int? ?? d.bpm,
      beatsPerNote: j['beatsPerNote'] as int? ?? d.beatsPerNote,
      rangeLow: j['rangeLow'] as int? ?? d.rangeLow,
      rangeHigh: j['rangeHigh'] as int? ?? d.rangeHigh,
      pianoEnabled: j['pianoEnabled'] as bool? ?? d.pianoEnabled,
      metronomeEnabled: j['metronomeEnabled'] as bool? ?? d.metronomeEnabled,
      minInterval: j['minInterval'] as int? ?? d.minInterval,
      maxInterval: j['maxInterval'] as int? ?? d.maxInterval,
      rootPitchClass: j['rootPitchClass'] as int?,
      scaleType: j['scaleType'] != null
          ? ScaleType.values.byName(j['scaleType'] as String)
          : null,
      bassPitchClass: j['bassPitchClass'] as int?,
      transposition: j['transposition'] != null
          ? Transposition.values.byName(j['transposition'] as String)
          : d.transposition,
    );
  }

  NoteGeneratorState copyWith({
    int? bpm,
    int? beatsPerNote,
    int? rangeLow,
    int? rangeHigh,
    bool? pianoEnabled,
    bool? metronomeEnabled,
    bool? isPlaying,
    String? currentNoteName,
    Object? currentBassNoteName = _sentinel,
    Object? currentMidiNote = _sentinel,
    int? currentBeat,
    int? minInterval,
    int? maxInterval,
    Object? rootPitchClass = _sentinel,
    Object? scaleType = _sentinel,
    Object? bassPitchClass = _sentinel,
    Transposition? transposition,
  }) {
    return NoteGeneratorState(
      bpm: bpm ?? this.bpm,
      beatsPerNote: beatsPerNote ?? this.beatsPerNote,
      rangeLow: rangeLow ?? this.rangeLow,
      rangeHigh: rangeHigh ?? this.rangeHigh,
      pianoEnabled: pianoEnabled ?? this.pianoEnabled,
      metronomeEnabled: metronomeEnabled ?? this.metronomeEnabled,
      isPlaying: isPlaying ?? this.isPlaying,
      currentNoteName: currentNoteName ?? this.currentNoteName,
      currentBassNoteName: currentBassNoteName == _sentinel
          ? this.currentBassNoteName
          : currentBassNoteName as String?,
      currentMidiNote: currentMidiNote == _sentinel
          ? this.currentMidiNote
          : currentMidiNote as int?,
      currentBeat: currentBeat ?? this.currentBeat,
      minInterval: minInterval ?? this.minInterval,
      maxInterval: maxInterval ?? this.maxInterval,
      rootPitchClass: rootPitchClass == _sentinel
          ? this.rootPitchClass
          : rootPitchClass as int?,
      scaleType: scaleType == _sentinel
          ? this.scaleType
          : scaleType as ScaleType?,
      bassPitchClass: bassPitchClass == _sentinel
          ? this.bassPitchClass
          : bassPitchClass as int?,
      transposition: transposition ?? this.transposition,
    );
  }
}

final noteGeneratorProvider =
    NotifierProvider<NoteGeneratorNotifier, NoteGeneratorState>(
      NoteGeneratorNotifier.new,
    );

class NoteGeneratorNotifier extends Notifier<NoteGeneratorState> {
  late final AudioService _audioService;
  late final SequencerService _sequencer;
  late final SharedPreferences _prefs;
  Future<void>? _initFuture;

  static const _key = 'noteGenerator';

  @override
  NoteGeneratorState build() {
    _audioService = ref.read(audioServiceProvider);
    _prefs = ref.read(sharedPrefsProvider);
    _sequencer = SequencerService(audioService: _audioService);
    _sequencer.onNewNote = _onNewNote;
    _sequencer.onBassNote = _onBassNote;
    _sequencer.onBeat = _onBeat;
    ref.listen(mixerProvider, (_, mixer) => _syncMixerParams(mixer));
    ref.onDispose(_dispose);
    _ensureInit(); // eager: audio driver warms up while user sees UI
    return _load();
  }

  NoteGeneratorState _load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const NoteGeneratorState();
    try {
      return NoteGeneratorState.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      return const NoteGeneratorState();
    }
  }

  void _save() {
    _prefs.setString(_key, jsonEncode(state.toJson()));
  }

  Future<void> _ensureInit() => _initFuture ??= _audioService.init();

  void _onNewNote(int midiNote) {
    final display = midiNote + state.transposition.semitones;
    state = state.copyWith(
      currentMidiNote: midiNote,
      currentNoteName: midiNoteToName(display),
    );
  }

  void _onBassNote(int? bassMidiNote) {
    final name = bassMidiNote != null
        ? midiNoteToName(bassMidiNote + state.transposition.semitones,
            includeOctave: false)
        : null;
    state = state.copyWith(currentBassNoteName: name);
  }

  void _onBeat(int beat) {
    state = state.copyWith(currentBeat: beat);
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await _stop();
      ref.read(playbackCoordinatorProvider).release(_stop);
    } else {
      await ref.read(playbackCoordinatorProvider).requestPlayback(_stop);
      await _ensureInit();
      _syncSequencerParams();
      await _sequencer.start();
      await WakeLockService.instance.enable();
      state = state.copyWith(isPlaying: true);
    }
  }

  Future<void> _stop() async {
    if (!state.isPlaying) return;
    await _sequencer.stop();
    await WakeLockService.instance.disable();
    state = state.copyWith(
      isPlaying: false,
      currentNoteName: '---',
      currentBassNoteName: null,
      currentMidiNote: null,
      currentBeat: 0,
    );
  }

  void setTransposition(Transposition value) {
    final midi = state.currentMidiNote;
    final name = midi != null ? midiNoteToName(midi + value.semitones) : state.currentNoteName;
    state = state.copyWith(transposition: value, currentNoteName: name);
    _save();
  }

  void setBpm(int value) {
    state = state.copyWith(bpm: value);
    _sequencer.bpm = value;
    _save();
  }

  void setBeatsPerNote(int value) {
    state = state.copyWith(beatsPerNote: value);
    _sequencer.beatsPerNote = value;
    _save();
  }

  void setRange(int low, int high) {
    state = state.copyWith(rangeLow: low, rangeHigh: high);
    _sequencer.rangeLow = low;
    _sequencer.rangeHigh = high;
    _save();
  }

  void applyPreset(NoteRange range) {
    setRange(range.low, range.high);
  }

  void togglePiano() {
    final enabled = !state.pianoEnabled;
    state = state.copyWith(pianoEnabled: enabled);
    _sequencer.pianoEnabled = enabled;
    _save();
  }

  void toggleMetronome() {
    final enabled = !state.metronomeEnabled;
    state = state.copyWith(metronomeEnabled: enabled);
    _sequencer.metronomeEnabled = enabled;
    _save();
  }

  void setIntervalRange(int min, int max) {
    state = state.copyWith(minInterval: min, maxInterval: max);
    _sequencer.minInterval = min;
    _sequencer.maxInterval = max;
    _save();
  }

  void setScale(int? rootPitchClass, ScaleType? scaleType) {
    // Clear bass if scale is removed or bass note is no longer in the new scale.
    var bass = state.bassPitchClass;
    if (rootPitchClass == null || scaleType == null) {
      bass = null;
    } else if (bass != null && bass != -1) {
      final pitchClasses = scalePitchClasses(rootPitchClass, scaleType);
      if (!pitchClasses.contains(bass)) bass = null;
    }
    state = state.copyWith(
      rootPitchClass: rootPitchClass,
      scaleType: scaleType,
      bassPitchClass: bass,
    );
    _sequencer.rootPitchClass = rootPitchClass;
    _sequencer.scaleType = scaleType;
    _sequencer.bassPitchClass = bass;
    _save();
  }

  void setBassPitchClass(int? pitchClass) {
    state = state.copyWith(bassPitchClass: pitchClass);
    _sequencer.bassPitchClass = pitchClass;
    _save();
  }

  void _syncSequencerParams() {
    final mixer = ref.read(mixerProvider);
    _sequencer
      ..bpm = state.bpm
      ..beatsPerNote = state.beatsPerNote
      ..rangeLow = state.rangeLow
      ..rangeHigh = state.rangeHigh
      ..pianoEnabled = state.pianoEnabled
      ..metronomeEnabled = state.metronomeEnabled
      ..minInterval = state.minInterval
      ..maxInterval = state.maxInterval
      ..rootPitchClass = state.rootPitchClass
      ..scaleType = state.scaleType
      ..bassPitchClass = state.bassPitchClass;
    _syncMixerParams(mixer);
  }

  void _syncMixerParams(MixerState mixer) {
    _sequencer
      ..pianoVelocity = (mixer.noteGenPianoVolume * 127).round().clamp(0, 127)
      ..bassVelocity = (mixer.noteGenBassVolume * 127).round().clamp(0, 127)
      ..clickChannel = mixer.noteGenClick.channel
      ..clickKey = mixer.noteGenClick.key
      ..clickVelocity = mixer.noteGenClick.velocity;
  }

  Future<void> _dispose() async {
    if (_sequencer.isPlaying) {
      await _sequencer.stop();
      await WakeLockService.instance.disable();
    }
    if (_initFuture != null) await _audioService.dispose();
  }
}
