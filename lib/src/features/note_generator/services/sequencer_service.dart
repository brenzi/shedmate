import 'dart:async';
import 'dart:math';

import '../domain/scale.dart';
import '../../../common/audio_service.dart';

class SequencerService {
  SequencerService({required this.audioService});

  final AudioService audioService;
  final _random = Random();

  // Mutable parameters — changed at any time
  int bpm = 80;
  int beatsPerNote = 4;
  int rangeLow = 21;
  int rangeHigh = 108;
  bool pianoEnabled = true;
  bool metronomeEnabled = true;
  int minInterval = 1;
  int maxInterval = 12;
  int? rootPitchClass;
  ScaleType? scaleType;

  // Mixer: piano
  int pianoVelocity = 100;

  // Mixer: click sound
  int clickChannel = 1;
  int clickKey = 76;
  int clickVelocity = 100;

  // Callbacks for UI
  void Function(int midiNote)? onNewNote;
  void Function(int beatInMeasure)? onBeat;

  // Internal state
  Timer? _timer;
  int _nextBeatIndex = 0;
  int _nextBeatTickMs = 0;
  int? _previousNote;

  static const _timerIntervalMs = 50;
  static const _lookaheadMs = 200;
  static const _noteReleaseGapMs = 50;

  bool get isPlaying => _timer != null;

  double get _beatIntervalMs => 60000.0 / bpm;

  Future<void> start() async {
    final currentTick = await audioService.getCurrentTick();
    _nextBeatTickMs = currentTick;
    _nextBeatIndex = 0;
    _previousNote = null;
    _timer = Timer.periodic(
      const Duration(milliseconds: _timerIntervalMs),
      (_) => _tick(),
    );
    await _tick();
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    await audioService.stopAllNotes();
  }

  Future<void> _tick() async {
    final currentTick = await audioService.getCurrentTick();
    final horizon = currentTick + _lookaheadMs;

    while (_nextBeatTickMs <= horizon) {
      final beatInMeasure = _nextBeatIndex % beatsPerNote;

      if (metronomeEnabled) {
        await audioService.scheduleSound(
          _nextBeatTickMs,
          channel: clickChannel,
          key: clickKey,
          velocity: clickVelocity,
        );
      }

      if (beatInMeasure == 0 && pianoEnabled) {
        final note = _randomNote();
        final duration = (_beatIntervalMs * beatsPerNote - _noteReleaseGapMs)
            .round();
        await audioService.scheduleNote(
          _nextBeatTickMs,
          note,
          duration,
          velocity: pianoVelocity,
        );
        onNewNote?.call(note);
      }

      onBeat?.call(beatInMeasure);

      _nextBeatIndex++;
      _nextBeatTickMs += _beatIntervalMs.round();
    }
  }

  int _randomNote() {
    var candidates = List.generate(
      rangeHigh - rangeLow + 1,
      (i) => rangeLow + i,
    );

    final root = rootPitchClass;
    final scale = scaleType;
    if (root != null && scale != null) {
      final pitchClasses = scalePitchClasses(root, scale);
      candidates = candidates
          .where((n) => pitchClasses.contains(n % 12))
          .toList();
    }

    final prev = _previousNote;
    if (prev != null) {
      candidates = candidates.where((n) {
        final d = (n - prev).abs();
        return d >= minInterval && d <= maxInterval;
      }).toList();
    }

    if (candidates.isEmpty) {
      candidates = List.generate(rangeHigh - rangeLow + 1, (i) => rangeLow + i);
    }

    final note = candidates[_random.nextInt(candidates.length)];
    _previousNote = note;
    return note;
  }
}
