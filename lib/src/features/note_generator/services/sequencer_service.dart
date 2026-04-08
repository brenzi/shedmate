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
  int? bassPitchClass;

  // Mixer: piano
  int pianoVelocity = 100;

  // Mixer: bass
  int bassVelocity = 100;

  // Mixer: click sound
  int clickChannel = 1;
  int clickKey = 76;
  int clickVelocity = 100;

  // Callbacks for UI
  void Function(int midiNote)? onNewNote;
  void Function(int? bassMidiNote)? onBassNote;
  void Function(int beatInMeasure)? onBeat;

  // Internal state
  Timer? _timer;
  int _nextBeatIndex = 0;
  int _nextBeatTickMs = 0;
  int? _previousNote;
  final List<int> _noteHistory = [];

  static const _historySize = 12;

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
    _noteHistory.clear();
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
        // Resolve bass pitch class first so _randomNote can avoid it.
        final bass = bassPitchClass;
        final bassPc = bass == null
            ? null
            : bass == -1
                ? _randomBassPitchClass()
                : bass;
        final note = _randomNote(excludePitchClass: bassPc);
        final duration = (_beatIntervalMs * beatsPerNote - _noteReleaseGapMs)
            .round();
        await audioService.scheduleNote(
          _nextBeatTickMs,
          note,
          duration,
          velocity: pianoVelocity,
        );
        if (bassPc != null) {
          // Bass in low register; SF2 range starts at E2 (MIDI 40).
          var bassMidi = 36 + bassPc;
          if (bassMidi < 40) bassMidi += 12;
          await audioService.scheduleBassNote(
            _nextBeatTickMs,
            bassMidi,
            duration,
            velocity: bassVelocity,
          );
          onBassNote?.call(bassMidi);
        } else {
          onBassNote?.call(null);
        }
        onNewNote?.call(note);
      }

      onBeat?.call(beatInMeasure);

      _nextBeatIndex++;
      _nextBeatTickMs += _beatIntervalMs.round();
    }
  }

  int _randomNote({int? excludePitchClass}) {
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

    if (excludePitchClass != null) {
      final filtered = candidates
          .where((n) => n % 12 != excludePitchClass)
          .toList();
      if (filtered.isNotEmpty) candidates = filtered;
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

    final note = _weightedPick(candidates);
    _previousNote = note;
    _noteHistory.add(note);
    if (_noteHistory.length > _historySize) _noteHistory.removeAt(0);
    return note;
  }

  int _randomBassPitchClass() {
    final root = rootPitchClass;
    final scale = scaleType;
    if (root != null && scale != null) {
      final pcs = scalePitchClasses(root, scale).toList();
      return pcs[_random.nextInt(pcs.length)];
    }
    return _random.nextInt(12);
  }

  /// Weighted random selection: recently played notes are less likely.
  /// Most recent in history gets weight 0, oldest gets 1.0,
  /// notes not in history get 1.0.
  int _weightedPick(List<int> candidates) {
    if (candidates.length == 1) return candidates.first;

    final weights = candidates.map((note) {
      final i = _noteHistory.lastIndexOf(note);
      if (i == -1) return 1.0;
      final recency = _noteHistory.length - i; // 1 = most recent
      return (recency - 1) / (_historySize - 1);
    }).toList();

    final total = weights.fold(0.0, (s, w) => s + w);
    if (total <= 0) return candidates[_random.nextInt(candidates.length)];

    var roll = _random.nextDouble() * total;
    for (var j = 0; j < candidates.length; j++) {
      roll -= weights[j];
      if (roll <= 0) return candidates[j];
    }
    return candidates.last;
  }
}
