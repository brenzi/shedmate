import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:shedmate/src/features/metronome/domain/metronome_state.dart';
import 'package:shedmate/src/features/note_generator/providers/note_generator_providers.dart';
import 'package:shedmate/src/features/note_generator/domain/scale.dart';
import 'package:shedmate/src/features/polyrhythms/domain/polyrhythm_state.dart';

void main() {
  group('NoteGeneratorState', () {
    test('round-trip with all defaults', () {
      const s = NoteGeneratorState();
      final json = jsonEncode(s.toJson());
      final restored = NoteGeneratorState.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
      expect(restored.bpm, s.bpm);
      expect(restored.beatsPerNote, s.beatsPerNote);
      expect(restored.rangeLow, s.rangeLow);
      expect(restored.rangeHigh, s.rangeHigh);
      expect(restored.pianoEnabled, s.pianoEnabled);
      expect(restored.metronomeEnabled, s.metronomeEnabled);
      expect(restored.minInterval, s.minInterval);
      expect(restored.maxInterval, s.maxInterval);
      expect(restored.rootPitchClass, isNull);
      expect(restored.scaleType, isNull);
    });

    test('round-trip with custom values and scale', () {
      const s = NoteGeneratorState(
        bpm: 140,
        beatsPerNote: 2,
        rangeLow: 40,
        rangeHigh: 80,
        pianoEnabled: false,
        metronomeEnabled: false,
        minInterval: 3,
        maxInterval: 7,
        rootPitchClass: 5,
        scaleType: ScaleType.melodicMinor,
      );
      final json = jsonEncode(s.toJson());
      final restored = NoteGeneratorState.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
      expect(restored.bpm, 140);
      expect(restored.beatsPerNote, 2);
      expect(restored.rangeLow, 40);
      expect(restored.rangeHigh, 80);
      expect(restored.pianoEnabled, false);
      expect(restored.metronomeEnabled, false);
      expect(restored.minInterval, 3);
      expect(restored.maxInterval, 7);
      expect(restored.rootPitchClass, 5);
      expect(restored.scaleType, ScaleType.melodicMinor);
    });

    test('fromJson falls back to defaults on empty map', () {
      final s = NoteGeneratorState.fromJson({});
      const d = NoteGeneratorState();
      expect(s.bpm, d.bpm);
      expect(s.beatsPerNote, d.beatsPerNote);
    });

    test('non-persistent fields are not serialized', () {
      const s = NoteGeneratorState(
        isPlaying: true,
        currentNoteName: 'C4',
        currentBeat: 3,
      );
      final j = s.toJson();
      expect(j.containsKey('isPlaying'), false);
      expect(j.containsKey('currentNoteName'), false);
      expect(j.containsKey('currentBeat'), false);
    });
  });

  group('MetronomeState', () {
    test('round-trip with all defaults', () {
      const s = MetronomeState();
      final json = jsonEncode(s.toJson());
      final restored = MetronomeState.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
      expect(restored.bpm, s.bpm);
      expect(restored.beatsPerBar, s.beatsPerBar);
      expect(restored.beatToggles, s.beatToggles);
      expect(restored.offbeatToggles, s.offbeatToggles);
      expect(restored.accentBeat1, s.accentBeat1);
      expect(restored.barsPerSection, s.barsPerSection);
    });

    test('round-trip with custom values', () {
      final s = MetronomeState(
        bpm: 90,
        beatsPerBar: 7,
        beatToggles: [true, false, true, false, true, true, false],
        offbeatToggles: [false, true, false, true, false, false, true],
        accentBeat1: false,
        barsPerSection: 4,
      );
      final json = jsonEncode(s.toJson());
      final restored = MetronomeState.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
      expect(restored.bpm, 90);
      expect(restored.beatsPerBar, 7);
      expect(restored.beatToggles, s.beatToggles);
      expect(restored.offbeatToggles, s.offbeatToggles);
      expect(restored.accentBeat1, false);
      expect(restored.barsPerSection, 4);
    });

    test('fromJson falls back to defaults on empty map', () {
      final s = MetronomeState.fromJson({});
      const d = MetronomeState();
      expect(s.bpm, d.bpm);
      expect(s.beatsPerBar, d.beatsPerBar);
    });

    test('non-persistent fields are not serialized', () {
      const s = MetronomeState(isPlaying: true, currentBeat: 2, currentBar: 1);
      final j = s.toJson();
      expect(j.containsKey('isPlaying'), false);
      expect(j.containsKey('currentBeat'), false);
      expect(j.containsKey('currentBar'), false);
    });
  });

  group('PolyrhythmState', () {
    test('round-trip with all defaults', () {
      const s = PolyrhythmState();
      final json = jsonEncode(s.toJson());
      final restored = PolyrhythmState.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
      expect(restored.a, s.a);
      expect(restored.b, s.b);
      expect(restored.bpm, s.bpm);
      expect(restored.showSubdivision, s.showSubdivision);
    });

    test('round-trip with custom values', () {
      const s = PolyrhythmState(a: 5, b: 7, bpm: 200, showSubdivision: true);
      final json = jsonEncode(s.toJson());
      final restored = PolyrhythmState.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
      expect(restored.a, 5);
      expect(restored.b, 7);
      expect(restored.bpm, 200);
      expect(restored.showSubdivision, true);
    });

    test('fromJson falls back to defaults on empty map', () {
      final s = PolyrhythmState.fromJson({});
      const d = PolyrhythmState();
      expect(s.a, d.a);
      expect(s.b, d.b);
    });

    test('non-persistent fields are not serialized', () {
      const s = PolyrhythmState(
        isPlaying: true,
        currentTickA: 2,
        currentTickB: 3,
      );
      final j = s.toJson();
      expect(j.containsKey('isPlaying'), false);
      expect(j.containsKey('currentTickA'), false);
      expect(j.containsKey('currentTickB'), false);
    });
  });
}
