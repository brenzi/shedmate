import 'package:flutter_test/flutter_test.dart';
import 'package:shedmate/src/features/note_generator/domain/scale.dart';
import 'package:shedmate/src/features/note_generator/services/sequencer_service.dart';

import '../../../common/mock_audio_service.dart';

void main() {
  late MockAudioService mockAudio;
  late SequencerService sequencer;

  setUp(() {
    mockAudio = MockAudioService();
    sequencer = SequencerService(audioService: mockAudio);
  });

  List<int> clickTicks() =>
      mockAudio.scheduledSounds.map((c) => c.tick).toList();

  group('scheduling logic', () {
    test('start triggers immediate scheduling', () async {
      sequencer.bpm = 120;
      sequencer.beatsPerNote = 2;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      expect(mockAudio.scheduledSounds, isNotEmpty);
      expect(mockAudio.scheduledNotes, isNotEmpty);
    });

    test('schedules beats within lookahead window', () async {
      sequencer.bpm = 120; // 500ms per beat
      sequencer.beatsPerNote = 4;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // At 120 BPM, beat interval is 500ms. Lookahead is 200ms.
      // So only beat at tick 0 should be scheduled (next at 500 > 200).
      expect(clickTicks(), equals([0]));
      expect(mockAudio.scheduledNotes.length, 1);
      expect(mockAudio.scheduledNotes.first.tick, 0);
    });

    test('schedules multiple beats when interval is short', () async {
      sequencer.bpm = 600; // 100ms per beat
      sequencer.beatsPerNote = 4;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // At 600 BPM, beat interval is 100ms. Lookahead is 200ms.
      // Beats at 0, 100, 200 should be scheduled.
      expect(clickTicks(), equals([0, 100, 200]));
      // Piano note only on beat 0 (beatInMeasure == 0)
      expect(mockAudio.scheduledNotes.length, 1);
    });

    test('random notes are within range', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerNote = 1;
      sequencer.rangeLow = 60;
      sequencer.rangeHigh = 72;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      for (final note in mockAudio.scheduledNotes) {
        expect(note.midiNote, greaterThanOrEqualTo(60));
        expect(note.midiNote, lessThanOrEqualTo(72));
      }
    });

    test('piano disabled means no notes scheduled', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerNote = 1;
      sequencer.pianoEnabled = false;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      expect(mockAudio.scheduledNotes, isEmpty);
    });

    test('metronome disabled means no clicks scheduled', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerNote = 1;
      sequencer.metronomeEnabled = false;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      expect(mockAudio.scheduledSounds, isEmpty);
    });

    test('stop calls stopAllNotes', () async {
      mockAudio.currentTick = 0;
      await sequencer.start();
      await sequencer.stop();
      expect(mockAudio.stopAllCalled, isTrue);
    });

    test('onNewNote callback fires on note beats', () async {
      sequencer.bpm = 600;
      sequencer.beatsPerNote = 1;
      mockAudio.currentTick = 0;
      final notes = <int>[];
      sequencer.onNewNote = notes.add;

      await sequencer.start();
      await sequencer.stop();

      expect(notes, isNotEmpty);
    });

    test('note duration accounts for release gap', () async {
      sequencer.bpm = 120; // 500ms per beat
      sequencer.beatsPerNote = 2; // note spans 1000ms
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      // Duration should be beatsPerNote * beatInterval - releaseGap
      // = 2 * 500 - 50 = 950ms
      expect(mockAudio.scheduledNotes.first.durationMs, 950);
    });

    test('no consecutive duplicate notes', () async {
      sequencer.bpm = 6000; // very fast to generate many notes
      sequencer.beatsPerNote = 1;
      sequencer.rangeLow = 60;
      sequencer.rangeHigh = 61;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      final notes = mockAudio.scheduledNotes.map((n) => n.midiNote).toList();
      expect(notes.length, greaterThan(1));
      for (var i = 1; i < notes.length; i++) {
        expect(notes[i], isNot(equals(notes[i - 1])));
      }
    });

    test('interval range constrains distance between notes', () async {
      sequencer.bpm = 6000;
      sequencer.beatsPerNote = 1;
      sequencer.rangeLow = 48;
      sequencer.rangeHigh = 72;
      sequencer.minInterval = 1;
      sequencer.maxInterval = 2;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      final notes = mockAudio.scheduledNotes.map((n) => n.midiNote).toList();
      expect(notes.length, greaterThan(1));
      for (var i = 1; i < notes.length; i++) {
        final diff = (notes[i] - notes[i - 1]).abs();
        expect(diff, greaterThanOrEqualTo(1));
        expect(diff, lessThanOrEqualTo(2));
      }
    });

    test('minInterval enforces minimum jump distance', () async {
      sequencer.bpm = 6000;
      sequencer.beatsPerNote = 1;
      sequencer.rangeLow = 48;
      sequencer.rangeHigh = 72;
      sequencer.minInterval = 3;
      sequencer.maxInterval = 24;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      final notes = mockAudio.scheduledNotes.map((n) => n.midiNote).toList();
      expect(notes.length, greaterThan(1));
      for (var i = 1; i < notes.length; i++) {
        expect((notes[i] - notes[i - 1]).abs(), greaterThanOrEqualTo(3));
      }
    });

    test('scale filter restricts to pitch classes', () async {
      sequencer.bpm = 6000;
      sequencer.beatsPerNote = 1;
      sequencer.rangeLow = 60;
      sequencer.rangeHigh = 72;
      sequencer.rootPitchClass = 0; // C
      sequencer.scaleType = ScaleType.major;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      final majorPCs = {0, 2, 4, 5, 7, 9, 11};
      for (final note in mockAudio.scheduledNotes) {
        expect(majorPCs.contains(note.midiNote % 12), isTrue);
      }
    });

    test('impossible constraints still return a note', () async {
      sequencer.bpm = 120;
      sequencer.beatsPerNote = 1;
      sequencer.rangeLow = 60;
      sequencer.rangeHigh = 60;
      sequencer.rootPitchClass = 1; // C# — 60 is C, not in C# major
      sequencer.scaleType = ScaleType.major;
      mockAudio.currentTick = 0;

      await sequencer.start();
      await sequencer.stop();

      expect(mockAudio.scheduledNotes, isNotEmpty);
    });
  });
}
