const _noteNames = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B',
];

String midiNoteToName(int midiNote, {bool includeOctave = true}) {
  final name = _noteNames[midiNote % 12];
  if (!includeOctave) return name;
  final octave = (midiNote ~/ 12) - 1;
  return '$name$octave';
}

int noteNameToMidi(String name) {
  final match = RegExp(r'^([A-G]#?)(-?\d+)$').firstMatch(name);
  if (match == null) throw ArgumentError('Invalid note name: $name');
  final noteName = match.group(1)!;
  final octave = int.parse(match.group(2)!);
  final noteIndex = _noteNames.indexOf(noteName);
  if (noteIndex == -1) throw ArgumentError('Invalid note name: $name');
  return (octave + 1) * 12 + noteIndex;
}
