import 'package:flutter_test/flutter_test.dart';
import 'package:shedmate/src/features/note_generator/domain/note_range.dart';

void main() {
  group('NoteRange', () {
    const range = NoteRange(low: 40, high: 80);

    test('contains', () {
      expect(range.contains(40), isTrue);
      expect(range.contains(60), isTrue);
      expect(range.contains(80), isTrue);
      expect(range.contains(39), isFalse);
      expect(range.contains(81), isFalse);
    });

    test('span', () => expect(range.span, 40));

    test('piano range constants', () {
      expect(NoteRange.pianoLow, 21);
      expect(NoteRange.pianoHigh, 108);
      expect(NoteRange.piano.low, 21);
      expect(NoteRange.piano.high, 108);
      expect(NoteRange.piano.span, 87);
    });
  });
}
