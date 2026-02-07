import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/midi_utils.dart';
import '../domain/note_range.dart';
import '../services/audio_service.dart';
import '../services/sequencer_service.dart';

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
    this.currentBeat = 0,
  });

  final int bpm;
  final int beatsPerNote;
  final int rangeLow;
  final int rangeHigh;
  final bool pianoEnabled;
  final bool metronomeEnabled;
  final bool isPlaying;
  final String currentNoteName;
  final int currentBeat;

  NoteGeneratorState copyWith({
    int? bpm,
    int? beatsPerNote,
    int? rangeLow,
    int? rangeHigh,
    bool? pianoEnabled,
    bool? metronomeEnabled,
    bool? isPlaying,
    String? currentNoteName,
    int? currentBeat,
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
      currentBeat: currentBeat ?? this.currentBeat,
    );
  }
}

final audioServiceProvider = Provider<AudioService>((ref) => AudioService());

final noteGeneratorProvider =
    NotifierProvider<NoteGeneratorNotifier, NoteGeneratorState>(
      NoteGeneratorNotifier.new,
    );

class NoteGeneratorNotifier extends Notifier<NoteGeneratorState> {
  late final AudioService _audioService;
  late final SequencerService _sequencer;
  Future<void>? _initFuture;

  @override
  NoteGeneratorState build() {
    _audioService = ref.read(audioServiceProvider);
    _sequencer = SequencerService(audioService: _audioService);
    _sequencer.onNewNote = _onNewNote;
    _sequencer.onBeat = _onBeat;
    ref.onDispose(_dispose);
    _ensureInit(); // eager: audio driver warms up while user sees UI
    return const NoteGeneratorState();
  }

  Future<void> _ensureInit() => _initFuture ??= _audioService.init();

  void _onNewNote(int midiNote) {
    state = state.copyWith(currentNoteName: midiNoteToName(midiNote));
  }

  void _onBeat(int beat) {
    state = state.copyWith(currentBeat: beat);
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await _sequencer.stop();
      state = state.copyWith(
        isPlaying: false,
        currentNoteName: '---',
        currentBeat: 0,
      );
    } else {
      await _ensureInit();
      _syncSequencerParams();
      await _sequencer.start();
      state = state.copyWith(isPlaying: true);
    }
  }

  void setBpm(int value) {
    state = state.copyWith(bpm: value);
    _sequencer.bpm = value;
  }

  void setBeatsPerNote(int value) {
    state = state.copyWith(beatsPerNote: value);
    _sequencer.beatsPerNote = value;
  }

  void setRange(int low, int high) {
    state = state.copyWith(rangeLow: low, rangeHigh: high);
    _sequencer.rangeLow = low;
    _sequencer.rangeHigh = high;
  }

  void applyPreset(NoteRange range) {
    setRange(range.low, range.high);
  }

  void togglePiano() {
    final enabled = !state.pianoEnabled;
    state = state.copyWith(pianoEnabled: enabled);
    _sequencer.pianoEnabled = enabled;
  }

  void toggleMetronome() {
    final enabled = !state.metronomeEnabled;
    state = state.copyWith(metronomeEnabled: enabled);
    _sequencer.metronomeEnabled = enabled;
  }

  void _syncSequencerParams() {
    _sequencer
      ..bpm = state.bpm
      ..beatsPerNote = state.beatsPerNote
      ..rangeLow = state.rangeLow
      ..rangeHigh = state.rangeHigh
      ..pianoEnabled = state.pianoEnabled
      ..metronomeEnabled = state.metronomeEnabled;
  }

  Future<void> _dispose() async {
    if (_sequencer.isPlaying) await _sequencer.stop();
    if (_initFuture != null) await _audioService.dispose();
  }
}
