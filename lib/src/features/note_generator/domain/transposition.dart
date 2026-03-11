enum Transposition {
  concert('C', 0),
  bb('B\u266d', 2),
  eb('E\u266d', 9),
  g('G', 5);

  const Transposition(this.label, this.semitones);

  final String label;

  /// Semitones to add to concert pitch to get written pitch.
  final int semitones;
}
