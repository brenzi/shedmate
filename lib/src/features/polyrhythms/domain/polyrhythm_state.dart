class PolyrhythmState {
  const PolyrhythmState({
    this.a = 3,
    this.b = 4,
    this.bpm = 120,
    this.showSubdivision = false,
    this.isPlaying = false,
    this.currentTickA = -1,
    this.currentTickB = -1,
  });

  final int a;
  final int b;
  final int bpm;
  final bool showSubdivision;
  final bool isPlaying;
  final int currentTickA; // -1 = none active
  final int currentTickB;

  Map<String, dynamic> toJson() => {
    'a': a,
    'b': b,
    'bpm': bpm,
    'showSubdivision': showSubdivision,
  };

  factory PolyrhythmState.fromJson(Map<String, dynamic> j) {
    const d = PolyrhythmState();
    return PolyrhythmState(
      a: j['a'] as int? ?? d.a,
      b: j['b'] as int? ?? d.b,
      bpm: j['bpm'] as int? ?? d.bpm,
      showSubdivision: j['showSubdivision'] as bool? ?? d.showSubdivision,
    );
  }

  PolyrhythmState copyWith({
    int? a,
    int? b,
    int? bpm,
    bool? showSubdivision,
    bool? isPlaying,
    int? currentTickA,
    int? currentTickB,
  }) {
    return PolyrhythmState(
      a: a ?? this.a,
      b: b ?? this.b,
      bpm: bpm ?? this.bpm,
      showSubdivision: showSubdivision ?? this.showSubdivision,
      isPlaying: isPlaying ?? this.isPlaying,
      currentTickA: currentTickA ?? this.currentTickA,
      currentTickB: currentTickB ?? this.currentTickB,
    );
  }
}
