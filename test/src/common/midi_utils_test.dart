import 'package:flutter_test/flutter_test.dart';
import 'package:shedmate/src/common/midi_utils.dart';

void main() {
  group('midiNoteToName', () {
    test('middle C', () => expect(midiNoteToName(60), 'C4'));
    test('C#4', () => expect(midiNoteToName(61), 'C#4'));
    test('A0 (piano low)', () => expect(midiNoteToName(21), 'A0'));
    test('C8 (piano high)', () => expect(midiNoteToName(108), 'C8'));
    test('C-1 (MIDI 0)', () => expect(midiNoteToName(0), 'C-1'));
    test('G9 (MIDI 127)', () => expect(midiNoteToName(127), 'G9'));
  });

  group('noteNameToMidi', () {
    test('middle C', () => expect(noteNameToMidi('C4'), 60));
    test('C#4', () => expect(noteNameToMidi('C#4'), 61));
    test('A0', () => expect(noteNameToMidi('A0'), 21));
    test('C8', () => expect(noteNameToMidi('C8'), 108));
    test('C-1', () => expect(noteNameToMidi('C-1'), 0));
    test(
      'invalid throws',
      () => expect(() => noteNameToMidi('X9'), throwsArgumentError),
    );
  });

  group('round-trip', () {
    test('all MIDI notes round-trip', () {
      for (var i = 0; i <= 127; i++) {
        expect(noteNameToMidi(midiNoteToName(i)), i);
      }
    });
  });
}
