class PracticeTimerState {
  const PracticeTimerState({
    required this.date,
    this.practiceStart,
    this.noteSeconds = 0,
    this.metronomeSeconds = 0,
    this.polyrhythmSeconds = 0,
  });

  /// Current date as yyyy-MM-dd.
  final String date;

  /// Time of first play today (HH:mm), null if not yet played.
  final String? practiceStart;

  final int noteSeconds;
  final int metronomeSeconds;
  final int polyrhythmSeconds;

  int secondsForTab(int tab) => switch (tab) {
    0 => noteSeconds,
    1 => metronomeSeconds,
    2 => polyrhythmSeconds,
    _ => 0,
  };

  int get totalSeconds => noteSeconds + metronomeSeconds + polyrhythmSeconds;

  Map<String, dynamic> toJson() => {
    'date': date,
    'practiceStart': practiceStart,
    'noteSeconds': noteSeconds,
    'metronomeSeconds': metronomeSeconds,
    'polyrhythmSeconds': polyrhythmSeconds,
  };

  factory PracticeTimerState.fromJson(Map<String, dynamic> j) {
    return PracticeTimerState(
      date: j['date'] as String,
      practiceStart: j['practiceStart'] as String?,
      noteSeconds: j['noteSeconds'] as int? ?? 0,
      metronomeSeconds: j['metronomeSeconds'] as int? ?? 0,
      polyrhythmSeconds: j['polyrhythmSeconds'] as int? ?? 0,
    );
  }

  PracticeTimerState copyWith({
    String? date,
    Object? practiceStart = _sentinel,
    int? noteSeconds,
    int? metronomeSeconds,
    int? polyrhythmSeconds,
  }) {
    return PracticeTimerState(
      date: date ?? this.date,
      practiceStart: practiceStart == _sentinel
          ? this.practiceStart
          : practiceStart as String?,
      noteSeconds: noteSeconds ?? this.noteSeconds,
      metronomeSeconds: metronomeSeconds ?? this.metronomeSeconds,
      polyrhythmSeconds: polyrhythmSeconds ?? this.polyrhythmSeconds,
    );
  }
}

const _sentinel = Object();

String formatDuration(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final s = totalSeconds % 60;
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
