import 'dart:async';

import '../../../common/audio_service.dart';
import '../../../common/click_sounds.dart';
import '../domain/polyrhythm_math.dart';

class PolyrhythmSequencerService {
  PolyrhythmSequencerService({required this.audioService});

  final AudioService audioService;

  int a = 3;
  int b = 4;
  int bpm = 120;
  bool showSubdivision = false;

  void Function(int indexA, int indexB)? onBeat;

  Timer? _timer;
  int _cycleStartTickMs = 0;
  int _nextIndexA = 0;
  int _nextIndexB = 0;
  int _nextIndexSub = 0;
  final _pendingBeats = <({int tick, int indexA, int indexB})>[];

  static const _timerIntervalMs = 50;
  static const _lookaheadMs = 200;

  bool get isPlaying => _timer != null;

  double get _cycleMs => a * 60000.0 / bpm;
  double get _intervalA => 60000.0 / bpm;
  double get _intervalB => _cycleMs / b;
  double get _intervalSub => _cycleMs / lcm(a, b);

  Future<void> start() async {
    final currentTick = await audioService.getCurrentTick();
    _cycleStartTickMs = currentTick;
    _nextIndexA = 0;
    _nextIndexB = 0;
    _nextIndexSub = 0;
    _pendingBeats.clear();
    _timer = Timer.periodic(
      const Duration(milliseconds: _timerIntervalMs),
      (_) => _tick(),
    );
    await _tick();
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;

    // Flush any pending beat callbacks
    final currentTick = await audioService.getCurrentTick();
    while (_pendingBeats.isNotEmpty &&
        _pendingBeats.first.tick <= currentTick) {
      final e = _pendingBeats.removeAt(0);
      onBeat?.call(e.indexA, e.indexB);
    }
    _pendingBeats.clear();

    await audioService.stopAllNotes();
  }

  Future<void> _tick() async {
    final currentTick = await audioService.getCurrentTick();
    final horizon = currentTick + _lookaheadMs;

    // Fire pending beat callbacks whose tick has arrived
    while (_pendingBeats.isNotEmpty &&
        _pendingBeats.first.tick <= currentTick) {
      final e = _pendingBeats.removeAt(0);
      onBeat?.call(e.indexA, e.indexB);
    }

    while (true) {
      // Calculate next tick for each stream
      final nextTickA = _nextIndexA < a
          ? _cycleStartTickMs + (_nextIndexA * _intervalA).round()
          : double.infinity;
      final nextTickB = _nextIndexB < b
          ? _cycleStartTickMs + (_nextIndexB * _intervalB).round()
          : double.infinity;
      final subCount = lcm(a, b);
      final nextTickSub = showSubdivision && _nextIndexSub < subCount
          ? _cycleStartTickMs + (_nextIndexSub * _intervalSub).round()
          : double.infinity;

      // Find earliest
      var earliest = nextTickA;
      if (nextTickB < earliest) earliest = nextTickB;
      if (nextTickSub < earliest) earliest = nextTickSub;

      if (earliest == double.infinity || earliest > horizon) {
        // Check if we need to start a new cycle
        if (_nextIndexA >= a &&
            _nextIndexB >= b &&
            (!showSubdivision || _nextIndexSub >= subCount)) {
          _cycleStartTickMs += _cycleMs.round();
          _nextIndexA = 0;
          _nextIndexB = 0;
          _nextIndexSub = 0;
          continue;
        }
        break;
      }

      final tickMs = earliest.toInt();

      // Schedule whichever streams are at this tick
      int beatA = -1;
      int beatB = -1;

      if (tickMs == (_cycleStartTickMs + (_nextIndexA * _intervalA).round()) &&
          _nextIndexA < a) {
        await audioService.scheduleClick(tickMs, key: ClickSound.polyA);
        beatA = _nextIndexA;
        _nextIndexA++;
      }

      if (tickMs == (_cycleStartTickMs + (_nextIndexB * _intervalB).round()) &&
          _nextIndexB < b) {
        await audioService.scheduleClick(
          tickMs,
          key: ClickSound.polyB,
          velocity: 80,
        );
        beatB = _nextIndexB;
        _nextIndexB++;
      }

      if (showSubdivision &&
          _nextIndexSub < subCount &&
          tickMs ==
              (_cycleStartTickMs + (_nextIndexSub * _intervalSub).round())) {
        // Only schedule subdivision if no A or B was scheduled at this tick
        if (beatA < 0 && beatB < 0) {
          await audioService.scheduleClick(
            tickMs,
            key: ClickSound.polySub,
            velocity: 40,
          );
        }
        _nextIndexSub++;
      }

      if (beatA >= 0 || beatB >= 0) {
        _pendingBeats.add((tick: tickMs, indexA: beatA, indexB: beatB));
      }
    }

    // Fire callbacks for beats just scheduled at or before current tick
    while (_pendingBeats.isNotEmpty &&
        _pendingBeats.first.tick <= currentTick) {
      final e = _pendingBeats.removeAt(0);
      onBeat?.call(e.indexA, e.indexB);
    }
  }
}
