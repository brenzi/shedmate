class MetronomeState {
  const MetronomeState({
    this.bpm = 120,
    this.beatsPerBar = 4,
    this.beatToggles = const [true, true, true, true],
    this.offbeatToggles = const [false, false, false, false],
    this.accentBeat1 = true,
    this.countIn = true,
    this.barsPerSection = 0,
    this.sectionEnabled = false,
    this.isPlaying = false,
    this.currentBeat = 0,
    this.currentBar = 0,
  });

  final int bpm;
  final int beatsPerBar;
  final List<bool> beatToggles;
  final List<bool> offbeatToggles;
  final bool accentBeat1;
  final bool countIn;
  final int barsPerSection;
  final bool sectionEnabled;
  final bool isPlaying;
  final int currentBeat;
  final int currentBar;

  Map<String, dynamic> toJson() => {
    'bpm': bpm,
    'beatsPerBar': beatsPerBar,
    'beatToggles': beatToggles,
    'offbeatToggles': offbeatToggles,
    'accentBeat1': accentBeat1,
    'countIn': countIn,
    'barsPerSection': barsPerSection,
    'sectionEnabled': sectionEnabled,
  };

  factory MetronomeState.fromJson(Map<String, dynamic> j) {
    const d = MetronomeState();
    final beatsPerBar = j['beatsPerBar'] as int? ?? d.beatsPerBar;
    return MetronomeState(
      bpm: j['bpm'] as int? ?? d.bpm,
      beatsPerBar: beatsPerBar,
      beatToggles:
          (j['beatToggles'] as List<dynamic>?)?.cast<bool>() ??
          List.filled(beatsPerBar, true),
      offbeatToggles:
          (j['offbeatToggles'] as List<dynamic>?)?.cast<bool>() ??
          List.filled(beatsPerBar, false),
      accentBeat1: j['accentBeat1'] as bool? ?? d.accentBeat1,
      countIn: j['countIn'] as bool? ?? d.countIn,
      barsPerSection: j['barsPerSection'] as int? ?? d.barsPerSection,
      sectionEnabled: j['sectionEnabled'] as bool? ?? d.sectionEnabled,
    );
  }

  MetronomeState copyWith({
    int? bpm,
    int? beatsPerBar,
    List<bool>? beatToggles,
    List<bool>? offbeatToggles,
    bool? accentBeat1,
    bool? countIn,
    int? barsPerSection,
    bool? sectionEnabled,
    bool? isPlaying,
    int? currentBeat,
    int? currentBar,
  }) {
    return MetronomeState(
      bpm: bpm ?? this.bpm,
      beatsPerBar: beatsPerBar ?? this.beatsPerBar,
      beatToggles: beatToggles ?? this.beatToggles,
      offbeatToggles: offbeatToggles ?? this.offbeatToggles,
      accentBeat1: accentBeat1 ?? this.accentBeat1,
      countIn: countIn ?? this.countIn,
      barsPerSection: barsPerSection ?? this.barsPerSection,
      sectionEnabled: sectionEnabled ?? this.sectionEnabled,
      isPlaying: isPlaying ?? this.isPlaying,
      currentBeat: currentBeat ?? this.currentBeat,
      currentBar: currentBar ?? this.currentBar,
    );
  }
}
